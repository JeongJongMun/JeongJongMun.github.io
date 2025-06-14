---
title: "가상 메모리 Virtual Memory"
writer: Langerak
date: 2024-02-15 12:01:00 +0800
categories: [Operating System]
tags: [Operating System]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/c6e4aaa6-21e3-4a38-8835-39c444deb56d

  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Operating System
---

> 본 글은 제 개인적인 공부를 위해 작성한 글입니다. 틀린 내용이 있다면 언제든지 피드백을 주시면 감사하겠습니다. 참고로만 활용해주시길 바랍니다.

## 가상 메모리 시스템

---

**`가상 메모리(Virtual Memory)`**는 컴퓨터의 운영체제에서 사용되는 메모리 관리 기술 중 하나로, **주 기억장치(RAM)의 한계를 극복**하기 위해 **디스크 공간을 일시적으로 메모리처럼 사용하는 것**을 의미한다.

이렇게 디스크 공간을 일시적으로 메모리처럼 사용하는 공간을 **`스왑 공간`** 또는 페이징 파일이라고 부른다.

### 왜 가상 메모리를 사용하는가?

주 기억장치(RAM)은 한정된 용량을 가지고 있어서 모든 프로그램이 동시에 실행될 수 없거나, 큰 프로그램을 실행하기 어려울 수 있다.

가상 메모리를 사용함으로써 우리는 물리적 메모리의 한계(4GB, 8GB, 16GB..)에도 불구하고 더 많은 용량을 가진 프로그램들을 실행시킬 수 있다.

### 가상 메모리 구현 방식

가상 메모리는 시스템이 **프로그램을 실행시키는데 필요한 일부분만 메모리에 로드**하고 나머지는 디스크에 두고서 필요할 때마다 교체하면서 쓰는 방식으로 구현된다.

이를 통해 프로세스 전체가 물리적 메모리에 있는 것 ‘처럼’ 수행되는, 즉 물리적 메모리가 훨씬 더 많이 있는 것처럼 보이게 된다.

프로세스는 운영체제가 어디에 있는 지, 물리 메모리의 크기가 어느정도인지 신경 쓰지 않고 메모리를 마음대로 사용할 수 있다.

### 장점

1. 더 많고, 큰 프로세스를 실행 가능하다.
2. 필요한 프로세스만 메모리에 로드하고, 사용하지 않는 메모리 영역을 가상 메모리로 이동시킴으로써 물리적 메모리 관리에 용이하다.
3. 프로세스가 필요로 하는 데이터가 메모리에 있을 때 더 빠른 응답 시간을 제공한다.
4. 프로세스 간의 메모리 공간을 독립적으로 관리할 수 있어, 보안성이 향상된다.

### 단점

1. 페이징 테이블이나 세그먼트 테이블과 같은 데이터 구조를 유지하기 위한 오버헤드가 있다.
2. 실제 메모리와 디스크 간의 데이터 전송이 필요하므로 성능이 저하될 수 있다.
3. 가상 메모리 시스템은 복잡한 구조를 가지고 있으며, 구현과 관리가 어려울 수 있다.
4. 프로세스의 페이지나 세그먼트를 스왑 인/아웃 하는데 필요한 오버헤드가 있다.

## 가상 메모리 주소

---

가상 메모리 시스템의 모든 프로세스는 물리적 메모리와 별개로 자신이 메모리의 어느 위치에 있는지 상관없이 **0번지부터 시작하는 연속된 메모리 공간**을 가진다.

## 스왑 공간(메모리) Swap Space(Memory)

---

![image](https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/4998b89b-a04e-4a5f-8d74-657c5253ed8c)
_가상 메모리의 구성_

가상 메모리는 크게 두 가지로 나뉜다.

1. **프로세스가 바라보는 메모리 영역**
2. **메모리 관리자가 바라보는 메모리 영역 (물리적 메모리 + 스왑 공간)**

`메모리 관리자`는 물리 메모리의 부족한 부분을 **`스왑 공간`**으로 보충한다.

`스왑 공간`은 물리적 메모리와 가상 메모리 사이의 중간 영역으로, 물리적 메모리에 저장할 수 없는 프로세스의 데이터를 임시로 저장하는 버퍼 역할을 하는 공간으로 보통 하드 디스크에 생성된다.

> 💡**메모리 관리자** <br/>
> 운영체제의 일부로, 프로세스의 메모리 할당, 해제, 스왑 등을 담당

<br/> <br/>

물리 메모리가 꽉 찼을 때 일부 프로세스를 스왑 공간으로 보내고(**`Swap Out`**),

몇 개의 프로세스가 작업을 마치면 스왑 공간에 있는 프로세스를 메모리로 가져온다(**`Swap In`**)

따라서 가상 메모리에서 메모리 관리자가 사용할 수 있는 메모리의 전체 크기는 **물리적 메모리와 스왑 공간을 합한 크기**이다.

가상 메모리 시스템에서 메모리 관리자는 `메모리 관리 유닛(MMU)`으로 물리적 메모리와 스왑 영역을 합쳐서 프로세스가 사용하는 가상 주소를 물리적 메모리 주소로 변환하는데, 이러한 작업을 `동적 주소 변환(Dynamic Address Translation, DAT)`라고 한다.

> 💡 **메모리 관리 유닛 (Memory Management Unit)** <br/>
> 하드웨어 장치로, 가상 주소를 물리적 주소로 변환하는 역할을 담당
> CPU가 생성하는 가상 주소를 실제 메모리의 물리적 위치로 매핑

<br/> <br/>

### **Swap Out**

프로세스를 물리적 메모리에서 스왑 공간으로

### **Swap In**

프로세스를 스왑 공간에서 물리적 메모리로

## 동적 주소 변환 Dynamic Address Translation (DAT)

---

**프로세스가 가상 주소를 사용하여 메모리에 접근할 때 실제 메모리 주소로의 변환하는 기법**이다.

이 과정은 **`메모리 관리 유닛(Memory Management Unit, MMU)`**에 의해 수행된다.

**MMU**는 가상 주소를 물리적 주소로 **`매핑 테이블`**을 가지고 있으며, 이 테이블을 통해 가상 주소를 실제 메모리 주소로 변환한다.

이렇게 동적으로 주소를 변환함으로써, 프로세스는 실제 메모리 위치를 몰라도 된다.

## 매핑 테이블 Mapping Table

---

메모리를 관리할 때, 가상 메모리 시스템에서 가상 주소는 물리적 주소나 스왑 영역 중 한 곳에 위치하며 메모리 관리자는 **가상 주소와 물리적 주소**를 **1대1 매핑 테이블**로 관리한다.

![image](https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/4c600baf-2ec0-40ca-9b33-878a72a86937)
_메모리 매핑 테이블_

**매핑 테이블로 가상 주소가 물리적 메모리의 어느 위치에 알 수 있다.**

가상 주소의 프로세스 A는 물리적 메모리의 세그먼트 0에 위치하고, 프로세스 B는 세그먼트 1에 위치한다.

프로세스 A의 어떤 값이 필요할 때는 물리적 메모리의 세그먼트 0에서 원하는 데이터를 가져오면 된다.

프로세스 D의 경우 물리적 메모리가 아니라 스왑 영역에 있다.

매핑 테이블은 **Segmentation**으로 분할된 경우 뿐만 아니라 **Paging**으로 분할된 경우에도 똑같이 작동한다.

## 가상 메모리 고정 분할 방식: 페이징 Paging

---

![image](https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/2ed12375-88e8-41ce-a38e-2d414f24c696)
_페이징_

페이징 기법은 주소 공간을 같은 크기로 나누어 사용하는 기법이다.

**가상 주소 공간**은 프로세스 입장에서 바라본 메모리 공간으로, 항상 0번지부터 시작한다.

- 각 영역은 `페이지`라고 부르며 페이지 0, 페이지 1과 같이 번호를 매겨 관리한다.
- 필요한 페이지만 메모리에 올리고, 나머지는 디스크 등의 보조 기억 장치에 저장한다.

**물리적 주소 공간**은 `프레임`이라고 부른다.

- 마찬가지로 번호를 매겨 관리하고 이 둘의 크기는 같다

위 그림은 가상 주소의 각 페이지가 물리 메모리의 어디에 위치하는 지를 나타낸다. 페이지와 프레임은 크기가 같기에 어떤 프레임에도 배치될 수 있다. 이에 대한 매핑 정보는 페이지 테이블에 담겨있다.

`페이지 테이블`은 하나의 열로 구성된다. 모든 페이지의 정보를 순서대로 가지고 있기에 위에서부터 차례대로 페이지 0, 페이지 1, 페이지 2…에 해당하는 프레임 번호를 가지고 있다.

`invaild`는 해당 페이지가 **스왑 영역**에 있다는 의미이다.

## 가상 메모리 가변 분할 방식: 세그멘테이션 Segmentation

---

![image](https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/a3ab7324-b8a0-42df-8783-84844a174e11)
_세그멘테이션_

프로그램을 `세그먼트`라는 논리적 단위로 나누어 관리한다. 각 세그먼트는 서로 다른 크기를 가질 수 있으며, 필요한 세그먼트만 메모리에 올려서 사용한다.

분할 방식을 제외하면 페이징과 세그멘테이션이 동일하기 때문에 매핑 테이블의 동작 방식도 동일하다. (**세그먼트 크기**에 대한 정보가 매핑 테이블에 추가된다.)

<br/> <br/>

_참고_

- [https://velog.io/@chappi/OS는-할껀데-핵심만-합니다.-14편-가상-메모리-개요-페이징](https://velog.io/@chappi/OS는-할껀데-핵심만-합니다.-14편-가상-메모리-개요-페이징)
