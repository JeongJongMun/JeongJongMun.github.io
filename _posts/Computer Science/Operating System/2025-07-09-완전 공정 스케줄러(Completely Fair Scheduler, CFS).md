---
title: "완전 공정 스케줄러(Completely Fair Scheduler, CFS)"
writer: Langerak
date: 2025-07-09 12:00:00 +0800
categories: [Operating System]
tags: [Operating System]
pin: false
math: true
mermaid: true
image:
  path: https://1drv.ms/i/c/0feb846c92fbe54a/IQSt7bCqbNPUTIA7G836zI0iARqaNqNShiONAD4gWNyMMpo?width=660
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Operating System
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

### 개요

---

완전 공정 스케줄러(Completely Fair Scheduler, CFS)는 리눅스 2.6.23(2007년 10월) 릴리스에 병합된 스케줄러이다.
리눅스 6.6(2023년)에선 EEVDF(Earliest Eligible Virtual Deadline First) 스케줄러로 대체되었다.

CFS의 아이디어는 **모든 프로세스가 CPU 시간을 공정하게 분배받아야 한다**는 것이다.
전통적인 스케줄러들이 타임 슬라이스와 우선순위를 기반으로 작동했다면, CFS는 각 프로세스가 **이상적으로 받아야 할 CPU 시간**과 **실제로 받은 CPU 시간**의 차이를 추적하여 스케줄링 결정을 내린다.

이 글에서는 기본적인 개념과 간단하게 동작 과정을 살펴본다.

<br/>

### 기본 개념 : nice

---

nice 값은 프로세스의 우선순위를 조정하여 CPU 사용 비율에 영향을 준다.
기본 값은 0이며, 가장 높은 우선순위인 -20에서 가장 낮은 우선순위인 19까지의 범위를 가진다.

nice한 프로세스일 수록 다른 프로세스에게 CPU 시간을 더 많이 양보한다고 이해하면 된다.

- 낮은 nice 값 = 높은 우선순위 = CPU 시간을 더 많이 할당받음 = 불친절
- 높은 nice 값 = 낮은 우선순위 = CPU 시간을 덜 할당받음 = 친절

```c
static const int prio_to_weight[40] = {
    /* -20 */ 88761, 71755, 56483, 46273, 36291,
    /* -15 */ 29154, 23254, 18705, 14949, 11916,
    /* -10 */ 9548,  7620,  6100,  4904,  3906,
    /*  -5 */ 3121,  2501,  1991,  1586,  1277,
    /*   0 */ 1024,   820,   655,   526,   423,
    /*   5 */ 335,    272,   215,   172,   137,
    /*  10 */ 110,    87,    70,    56,    45,
    /*  15 */ 36,     29,    23,    18,    15,
};
```


<br/>

### 기본 개념 : 가상 실행 시간(Virtual Runtime, vruntime)

---

vruntime은 해당 프로세스가 실제로 실행된 시간에서 nice 값에 따라 가중치가 적용된 **가상적으로 실행된 시간**이다.

```c
vruntime = 실제_실행시간 * (NICE_0_WEIGHT / NICE_WEIGHT)
```

nice 값이 낮은 프로세스는 같은 시간을 실행해도 vruntime이 더 적게 증가하고,
nice 값이 높은 프로세스는 같은 시간을 실행해도 vruntime이 더 많이 증가한다.

<br/>

### 기본 개념 : 레드 블랙 트리(Red-Black Tree)

---

CFS는 모든 실행 가능한 프로세스들을 RB 트리로 관리한다.

RB 트리에서 각 프로세스는 vruntime을 기준으로 정렬되어 있고 트리의 가장 왼쪽 노드는 vruntime이 가장 작은 프로세스, 즉 가장 적게 실행된 프로세스가 된다.

RB 트리는 삽입/삭제/검색이 모두 O(log n)의 시간복잡도를 가지며, 최소값(가장 왼쪽 노드) 찾기는 O(1)로 효율적이다.

<br/>

### 기본 개념 : 목표 지연 시간(target latency)

---

CFS는 고정된 타임 슬라이스를 사용하지 않고, 목표 지연 시간이라는 개념을 사용한다.
이는 모든 실행 가능한 프로세스가 적어도 한 번씩은 스케줄링되는 시간을 의미한다.

기본 값은 20ms로 설정되어 있다.

만약 현재 실행 가능한 프로세스가 4개라면, 각 프로세스는 이론적으로 5ms씩 실행될 수 있다.
하지만, 프로세스가 무한개로 많아지면 각 프로세스가 실행되는 시간은 0에 수렴하기에 문맥 교환 비용이 상당히 커진다.
그렇기에 Minimum Granularity를 사용하여 최소 실행 시간을 보장한다.

<br/>

### 기본 개념 : 최소 세분성(minimum granularity)

---

minimum granularity는 현재 실행 중인 프로세스가 선점되기 전에 CPU에서 실행될 수 있는 최소 시간이다.
즉, 작업이 CPU에서 실행되다가 강제 종료되기 전에 허용되는 최소 시간이다.

기본 값은 4ms로 설정되어 있다.

taerget latency와 minimum granularity를 조합하여 스케줄러 주기를 결정한다.
```c
if (number_of_runnable_tasks <= target_latency / minimum_granularity)
{
  scheduler_period = target_latency;
}
else
{
  scheduler_period = minimum_granularity * number_of_runnable_tasks;
}
```

<br/>

### 스케줄링 결정 과정

---

CFS는 항상 RB 트리의 가장 왼쪽 노드, 즉 vruntime이 가장 작은 프로세스를 선택하여 실행한다.
이는 가장 적게 실행된 프로세스를 우선적으로 실행하는 것이다.

프로세스가 실행되면 그 시간과 nice 수치로 vruntime이 계산되어 더해지고, 실행 후 RB 트리에 다시 삽입된다.

<br/>

### 그룹 스케줄링

---

CFS는 프로세스 뿐만 아니라 프로세스 그룹 간의 공정성도 보장한다.
사용자 별, 컨트롤 그룹 별로 CPu 시간을 공정하게 분배하며 이는 계층적 구조로 구현된다.

예를 들어, 사용자 A가 100개의 프로세스를 사용자 B가 1개의 프로세스를 실행 중이라면, 각 사용자가 50%씩 CPU 시간을 할당받는다.
각 그룹도 개별 프로세스처럼 자체 vruntime을 가진다.

1. 그룹 간 스케줄링 : 각 그룹을 하나의 가상 프로세스처럼 취급하여 그룹 간의 CPU 시간을 분배
2. 그룹 내 스케줄링 : 각 그룹 내에서 프로세스들 간에 할당받은 CPU 시간을 분배

<br/>

_참고_

- [https://stackoverflow.com/questions/21391176/linux-kernel-targeted-latency-vs-minimum-granularity](https://stackoverflow.com/questions/21391176/linux-kernel-targeted-latency-vs-minimum-granularity)
- [https://oakbytes.wordpress.com/2012/06/06/linux-scheduler-cfs-and-latency/](https://oakbytes.wordpress.com/2012/06/06/linux-scheduler-cfs-and-latency/)
- [https://velog.io/@yyj0110/kernel-Process-Scheduling](https://velog.io/@yyj0110/kernel-Process-Scheduling)
- [https://en.wikipedia.org/wiki/Completely_Fair_Scheduler](https://en.wikipedia.org/wiki/Completely_Fair_Scheduler)
- [https://jamcorp6733.tistory.com/201](https://jamcorp6733.tistory.com/201)
- [https://sundaland.tistory.com/517](https://sundaland.tistory.com/517)
- claude
