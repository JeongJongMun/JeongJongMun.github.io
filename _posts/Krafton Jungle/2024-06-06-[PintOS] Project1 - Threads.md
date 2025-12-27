---
title: "[PintOS] Project1 - Threads"
writer: Langerak
date: 2024-06-6 12:00:00 +0800
categories: [Krafton Jungle]
tags: [Krafton Jungle]
pin: false
math: true
mermaid: true
---

> 본 글은 제 개인적인 공부를 위해 작성한 글입니다. 틀린 내용이 있다면 언제든지 피드백을 주시면 감사하겠습니다. 참고로만 활용해주시길 바랍니다.

<br/><br/>

**_들어가며_**

---

이 글은 KAIST Pintos 과제를 수행하며 주어진 깃북을 해석/이해한 내용을 정리한 것입니다.

솔루션 이전까지의 내용은 깃북의 내용을 번역한 것과 크게 다름이 없으나, 제 주관적인 해석이 들어가 있으므로 잘못된 내용이 있을 수 있습니다.

## Introduction

---

프로젝트 1에서는 **최소한의 기능만 있는 스레드 시스템을 제공**한다.

우리는 이 시스템의 기능을 확장하여 **동기화 문제를 이해하는 것이 목표**이다.

프로젝트 1에서는 주로 `threads` 폴더에서 작업하고, 일부 작업은 `devices` 폴더에서 한다.

이 프로젝트를 진행하기 전에 **동기화**에 대한 학습이 선행되어야 한다.

### Understanding Threads

첫 번째 단계는 기본으로 제공되는 스레드 시스템의 코드를 읽고 이해하는 것이다.

pintos는 이미 스레드 생성, 스레드 완료, 스레드 간 전환을 위한 간단한 스케줄러, 동기화 기본 요소(세마포어, 잠금, 조건 변수 및 최적화 배리어)가 구현되어 있다.

스레드가 생성되면 스케줄링할 새로운 Context가 만들어진다.

우리는 이 Context에서 실행할 함수를 `thread_create()`의 매개변수로 제공한다.

스레드가 처음 예약되어 실행되면 해당 함수의 시작 부분부터 시작하여 해당 Context에서 실행된다.

함수가 반환되면 스레드는 종료된다.

따라서 각 스레드는 핀토스 내부에서 실행되는 미니 프로그램처럼 작동하며, `thread_create()`에 전달된 함수는 `main()`처럼 작동한다.

특정 시간에 정확히 **하나의 스레드만 실행**되고 나머지 스레드는 비활성 상태가 된다. 스케줄러는 다음에 실행할 스레드를 결정할 수 있다.

(다음에 실행할 준비된 스레드가 없는 경우 `idle()`을 호출하여 특별한 Idle 스레드가 실행된다.)

**동기화 프리미티브**는 한 스레드가 다른 스레드가 어떤 작업을 수행할 때까지 기다려야 할 때 Context Switching을 강제할 수 있다.

Context Switching의 메커니즘은 `threads/thread.c`의 `thread_launch()`에 있다. (이해할 필요는 없다.) 현재 실행 중인 스레드의 상태를 저장하고 전환하려는 스레드의 상태를 가져온다.

### Source Files

아래는 `threads`와 `include/threads` 디렉토리에 있는 파일에 대한 간략한 개요이다. 이 코드들의 대부분은 수정할 필요가 없지만, 어떤 코드를 살펴봐야 할지에 대한 도움이 될 수 있다.

**`threads` 코드들**

- `loader.S`, `loader.h`
    
    커널 로더.
    
    512 바이트의 코드와 데이터로 구성되며, PC BIOS가 메모리에 로드한 후 디스크에서 커널을 찾아 메모리에 로드하고 `start.S`의 `bootstrap()`으로 점프한다.
    
    `start.S`는 메모리 보호에 필요한 기본 설정을 수행하고 64비트 long 모드로 점프한다.
    
    로더와 달리 이 코드는 실제로 커널의 일부이다.
    
- `kernel.lds.S`
    
    커널을 연결하는 데 사용되는 링커 스크립트이다.
    
    커널의 로드 주소를 설정하고 `start.S`가 커널 이미지의 시작 부분 근처에 위치하도록 정렬한다.
    
    다시 말하지만, 이 코드를 보거나 수정할 필요는 없지만 궁금한 경우를 대비하여 여기에 있다.
    
- `init.c`, `init.h`
    
    커널의 `main program`인 `main()`을 포함한 커널 초기화.
    
    최소한 `main()`을 살펴보고 무엇이 초기화되는지 확인해야 한다. 여기에 자신만의 초기화 코드를 추가할 수 있다. 
    
- `thread.c`, `thread.h`
    
    기본적인 스레드 지원. 대부분의 작업은 이 파일에서 이루어진다.
    
    `thread.h`는 네 개의 프로젝트 모두에서 수정할 가능성이 높은 **스레드 구조체**를 정의한다.
    
- `palloc.c`, `palloc.h`
    
    페이지 할당기는 시스템 메모리를 4KB 페이지의 배수로 나눠준다. 
    
- `malloc.c`, `malloc.h`
    
    커널용 `malloc()` 및 `free()`의 간단한 구현이다.
    
- `interrupt.c`, `interrupt.h`
    
    기본적인 인터럽트 처리 및 인터럽트를 켜고 끄는 기능이다.
    
- `intr-stubs.S`, `intr-stubs.h`
    
    low-level 인터럽트 처리를 위한 어셈블리 코드이다.
    
- `synch.c`, `synch.h`
    
    기본 동기화 프리미티브. 세마포어/잠금/조건 변수/최적화 베리어.
    
    네 가지 프로젝트 모두에서 동기화를 위해 이걸 사용해야 한다.
    
- `mmu.c`, `mmu.h`
    
    x86-64 페이지 테이블 작업용 함수이다.
    
    프로젝트 1 이후에 이 파일을 자세히 보게 될 것이다.
    
- `io.h`
    
    I/O 포트 접근을 위한 함수이다.
    
    이 함수는 대부분 `devices` 디렉토리에 있는 소스 코드에서 사용하므로 건드릴 필요가 없다.
    
- `vaddr.h`, `pte.h`
    
    가상 주소 및 페이지 테이블 엔트리 작업을 위한 함수 및 매크로이다.
    
    프로젝트 3에서 중요하게 사용하므로 지금은 무시해도 된다. 
    
- `flags.h`
    
    x86-64 플래그 레지스터에서 비트를 정의하는 매크로이다.
    
    아마 관심 없어 할 것이다.
    

**`devices` 코드들**

기본 스레드 커널에는 이러한 파일도 `devices` 디렉토리에 포함되어 있다.

- `timer.c`, `timer.h`
    
    기본적으로 초당 100회 틱하는 시스템 타이머이다.
    
    이 프로젝트에서 이 코드를 수정한다.
    
- `vga.c`, `vga.`
    
    화면에 텍스트를 쓰는 일을 담당하는 VGA 디스플레이 드라이버이다.
    
    이 코드를 볼 필요는 없다.
    
    `printf()` 함수가 VGA 디스플레이 드라이버를 대신 호출하므로 이 코드를 직접 호출할 이유는 없다.
    
- `serial.c`, `serial.h`
    
    직렬 포트 드라이버이다.
    
    다시 말하지만, `printf()`가 이 코드를 대신 호출하므로 직접 호출할 필요는 없다.
    
    직렬 입력을 입력 레이어에 전달하여 처리한다.
    
- `block.c`, `block.h`
    
    블록 디바이스, 즉 고정 크기 블록의 배열로 구성된 랜덤 접근 디스크와 같은 디바이스를 위한 추상화 계층이다.
    
    핀토스는 기본적으로 두 가지 유형의 블록 장치를 지원한다: IDE 디스크와 파티션.
    
    블록 디바이스는 타입에 관계없이 프로젝트 2까지는 실제로 사용되지 않는다.
    
- `ide.c`, `ide.h`
    
    최대 4개의 IDE 디스크에서 섹터 읽기 및 쓰기를 지원한다.
    
- `partition.c`, `partition.h`
    
    디스크의 파티션 구조를 이해하여 하나의 디스크를 여러 영역(파티션)으로 분할하여 독립적으로 사용할 수 있다.
    
- `kbd.c`, `kbd.h`
    
    키보드 드라이버이다.
    
    키 입력을 처리하여 입력 레이어로 전달한다.
    
- `input.c`, `input.h`
    
    입력 레이어이다.
    
    키보드 또는 직렬 드라이버가 전달한 입력 문자를 대기열에 넣는다.
    
- `intq.c`, `intq.h`
    
    커널 스레드와 인터럽트 핸들러가 모두 접근하려는 순환 큐를 관리하기 위한 인터럽트 큐이다.
    
    키보드 및 직렬 드라이버에서 사용된다.
    
- `rtc.c`, `rtc.h`
    
    Real-Time Clock 드라이버를 사용하여 커널이 현재 날짜와 시간을 확인할 수 있도록 한다.
    
    기본적으로 이 드라이버는 난수 생성기의 초기 시드를 선택하기 위해 `thread/init.c`에서만 사용된다.
    
- `speaker.c`, `speaker.h`
    
    PC 스피커에서 톤을 생성할 수 있는 드라이버이다.
    
- `pit.c`, `pit.h`
    
    8254 프로그래밍 가능 인터럽트 타이머를 구성하는 코드이다.
    
    이 코드는 각 장치가 PIT의 출력 채널 중 하나를 사용하기 때문에 `devices/timer.c`와 `devices/speaker.c`에서 모두 사용된다.
    

**`lib` 코드들**

`lib`와 `lib/kernel`에는 유용한 라이브러리 루틴이 포함되어 있다. (`lib/user`는 프로젝트 2부터 사용자 프로그램에서 사용되지만 커널의 일부가 아니다.)

- `ctype.h`, `inttypes.h`, `limits.h`, `stdarg.h`, `stdbool.h`, `stddef.h`, `stdint.h`, `stdio.c`, `stdio.h`, `stdlib.c`, `stdlib.h`, `string.c`, `string.h`
    
    표준 C 라이브러리의 하위 집합이다.
    
- `debug.c`, `debug.h`
    
    디버깅을 지원하는 함수 및 매크로이다.
    
- `random.c`, `random.h`
    
    의사 난수 생성기이다.
    
    실제 난수 값의 순서는 핀토스 실행마다 달라지지 않는다.
    
- `round.h`
    
    반올림을 위한 매크로이다.
    
- `syscall-nr.h`
    
    시스템 콜 번호이다. 
    
    프로젝트 2까지는 사용되지 않는다.
    
- `kernel/list.c`, `kernel/list.h`
    
    이중 연결 리스트 구현.
    
    pintos 코드 전체에서 사용되며 프로젝트 1에서 몇 군데 직접 사용한다.
    
    **시작하기 전에 이 코드를 훑어보는 것을 권장한다. (특히 헤더 파일의 주석)**
    
- `kernel/bitmap.c`, `kernel/bitmap.h`
    
    비트맵 구현이다.
    
    원하는 경우 코드에서 사용할 수 있지만 프로젝트 1에서는 필요하지 않을 것이다.
    
- `kernel/hash.c`, `kernel/hash.h`
    
    해시 테이블 구현이다.
    
    프로젝트 3에서 유용하게 사용된다.
    
- `kernel/console.c`, `kernel/console.h`, `kernel/stdio.h`
    
    `printf()` 및 기타 몇 가지 함수를 구현한다.
    

### Synchronization

적절한 동기화는 **경쟁 조건(Race Condition), 독점자 문제(Readers-Writers Problem), 생산자-소비자 문제(Producer-Consumer Problem)** 과 같은 문제를 해결하는 데 있어 중요한 부분이다.

당연한 소리지만, 인터럽트를 끄면 모든 동기화 문제를 쉽게 해결할 수 있다. 인터럽트가 꺼져 있는 동안에는 동시성이 없으므로 경쟁 조건이 발생할 가능성이 없다.

하지만 모든 동기화 문제를 이러한 방법으로 해결하고 싶은 유혹이 있을 수 있지만, 그러지 말자.

대신 세마포어, 잠금, 조건 변수를 사용하여 동기화 문제의 대부분을 해결해보자.

이떤 상황에서 어떤 동기화 프리미티브가 사용될 수 있는지 잘 모르겠다면 github.io의 동기화 섹션이나 `threads/synch.c`의 주석을 읽어보라.

핀토스 프로젝트에서 인터럽트를 비활성화하면 가장 잘 해결되는 유일한 문제는 커널 스레드와 인터럽트 핸들러 간에 공유되는 데이터를 조정하는 것이다.

인터럽트 핸들러는 수면 상태가 될 수 없으므로 잠금을 얻을 수 없다.

즉, 커널 스레드와 인터럽트 핸들러 간에 공유되는 데이터는 인터럽트를 해결하여 커널 스레드 내에서 보호해야 한다.

이 프로젝트는 인터럽트 핸들러에서 일부 스레드 상태만 접근하면 된다.

Alarm Clock의 경우 타이머 인터럽트는 잠자는 스레드를 깨워야 한다.

고급 스케줄러에서 타이머 인터럽트는 몇 가지 전역 및 스레드별 변수에 접근해야 한다.

커널 스레드에서 이러한 변수에 접근할 때는 타이머 인터럽트가 간섭하지 못하도록 인터럽트를 비활성화해야 한다.

인터럽트를 끌 때는 가능한 한 최소한의 코드만 사용하도록 주의해야 한다.

그렇지 않으면 타이머 틱이나 입력 이벤트와 같은 중요한 정보가 손실될 수 있다.

또한 인터럽트를 끄면 인터럽트 처리 지연 시간이 증가하므로 너무 오래 걸리면 컴퓨터가 느려질 수 있다.

`synch.c`의 동기화 프리미티브 자체는 인터럽트를 비활성화하여 구현된다.

여기서 인터럽트를 비활성화한 상태에서 실행되는 코드의 양을 늘려야 할 수도 있지만, 그래도 최소한으로 유지해야 한다.

코드 섹션이 중단되지 않도록 하려는 경우 인터럽트를 비활성화하면 디버깅에 유용할 수 있다.

프로젝트를 제출하기 전에 디버깅 코드를 제거해야 한다.

(코드를 주석 처리하면 코드를 읽기 어려울 수 있으므로 그냥 제거하지 마라.)

제출에 Busy Waiting이 없어야 한다.

`thread_yield()`를 호출하는 타이트한 루프는 Busy Waiting의 한 형태이다.

## Alarm Clock

---

> `devices/timer.c`에 정의된 `timer_sleep()` 재구현
> 

이미 작동하게 끔 구현은 되어있지만, **바쁜 대기** 즉, 현재 시간을 확인하고 충분한 시간이 경과할 때까지 `thread_yield()`를 호출하는 루프에서 회전한다. **바쁜 대기**를 피하려면 다시 구현해야 한다.

```c
void timer_sleep (int64_t ticks);
```

시간이 **x** **timer ticks**만큼 진행될 때까지 호출 스레드의 실행을 일시 중단한다. (sleeping)

시스템이 Idle 상태가 아닌 한, 스레드는 정확히 **x** **timer ticks**후에 깨어날 필요가 없다.

적절한 시간 동안 기다린 후 준비 큐에 넣으면 된다.

`timer_sleep()`은 초당 한 번 커서를 깜박이는 등 실시간으로 작동하는 스레드에 유용하다.

`timer_sleep()`의 인수는 밀리초나 다른 단위가 아닌 **timer ticks**로 표현된다.

초당 **timer ticks**은 `devices/timer.h`에 정의된 매크로인 `TIMER_FREQ`이다. (Default = 100)

이 값을 변경하면 많은 테스트가 실패할 수 있으므로 변경하지 말자.

각각 특정 밀리초, 마이크로초 또는 나노초동안 실행을 일시 중단하기 위한 별도의 함수인 `timer_msleep()`, `timer_usleep()`, `timer_nsleep()`이 존재하지만 필요한 경우 `timer_sleep()`을 자동으로 호출한다. 

### Solution

![img](assets/img/inpost/126.png)
_Busy Waiting 상태_

![img](assets/img/inpost/127.png)
_수정된 Non Busy Waiting 상태_

`timer_alarm(int ticks)` 는 `ticks` 시간 뒤에 프로세스를 깨우는 시스템 콜이다.

현재 pintos는 알람을 위해 **Busy Waiting**을 사용하는데, **sleep/wakeup**을 사용하게 하여 **Non Busy Waiting**으로  수정하는 게 목표이다.

**수정/추가해야 하는 파일/함수**

- `threads/thread.c`
    1. `static struct list sleep_list`
    2. `sleep_list`를 정렬하기 위한 비교 함수
    3. `thread_sleep()`
        
        스레드를 BLOCKED 상태로 전환하고 `sleep_list`에 삽입
        
    4. `thread_wakeup()`
        
        스레드가 깨어날 시간이 되었다면, READY 상태로 전환하고 `ready_list`로 삽입
        
    5. `thread_init()`
        
        `sleep_list` 초기화
        
- `include/threads/thread.h`
    1. `struct thread`
- `devices/timer.c`
    1. `timer_interrupt()`
    2. `timer_sleep()`

**기존 상태** - 스레드들의 상태는 **READY <-> RUNNING**를 반복

`timer_sleep(int64_t ticks)`을 호출하면 현재 실행 중인 스레드가 `ready_list`로 삽입되어 `ticks` 시간이 지날 때까지 **RUNNING** **상태를 양보**하게 된다. `thread_yield()`를 반복하므로 Busy Waiting이다.

하지만 여전히 READY 상태이므로 CPU를 점유하고 있다. 

**수정된 상태** - 스레드들의 상태는 **READY -> RUNNING -> BLOCKED -> READY** 를 반복

1. `timer_sleep()` 를 호출하면 내부에서 `thread_sleep()`을 호출하여 현재 실행 중인 스레드를 BLOCKED 상태로 만들고, `sleep_list`에 추가하고, 스케줄링한다.
2. 매 `timer_interrupt()`가 호출될 때 마다 `thread_wakeup()`을 호출하여, `sleep_list`에 깨어나야 할 스레드가 있는지 확인하고, 있다면 해당 스레드를 READY 상태로 만들고 `ready_list`로 우선순위 오름차순으로 삽입한다.

이를 구현하기 위해서는 `struct thread`에 `wakeup_ticks`라는 깨어나야 하는 시간을 명시해주는 필드가 필요하고, `sleep_list`에서 스레드들을 `wakeup_ticks`를 기준으로 오름차순 정렬하여 삽입해주어야 한다.

그렇다면, 매 `timer_interrupt()` 호출 시마다 `sleep_list`의 모든 스레드를 확인할 필요 없게 된다. 

**결과**

![img](assets/img/inpost/128.png)

기존 Busy Waiting 시에는 Idle ticks가 0이었는데, Non Busy Waiting 방식으로 개선하니 Idle ticks가 많이 오른 것을 볼 수 있다.

**코드**

`thread.h/struct thread`

```c
struct thread {
	...
	int64_t wakeup_ticks; /* Time to wake up. */
	...
}
```

`timer.c/timer_sleep()`

```c
/* timer_sleep() - 현재 스레드를 ticks만큼 BLOCKED 상태로 만들고, wakeup_tick 내림차순으로 sleep_list에 삽입한다.
 */
void timer_sleep(int64_t ticks)
{
	ASSERT(intr_get_level() == INTR_ON);
	thread_sleep(timer_ticks() + ticks);
}
```

`timer.c/imer_interrupt()` - 본인은 전역으로 선언된 `ticks`를 인자로 들어오는 `ticks`와 구분하기 위해 `os_ticks`로 이름을 변경하였다.

```c
/* timer_interrupt() - 타이머 인터럽트 핸들러. 10ms당 한 번씩 호출. 1초에 100번 호출
 */
static void timer_interrupt(struct intr_frame *args UNUSED)
{
	os_ticks++;
	thread_tick();
	thread_wakeup(os_ticks);
}
```

`thread.c/thread_init()` & `sleep_list` init

```c
...
/* THREAD_BLOCKED 상태의 스레드 리스트, 즉 실행할 준비가 되지 않은 스레드의 리스트
 * wakeup_tick을 기준으로 오름차순 정렬되어 있다.
 */
static struct list sleep_list;
...

void thread_init(void)
{
	...
	list_init(&sleep_list);
	...
}
```

`thread.c/thread_sleep()`

```c
/* thread_sleep - 현재 실행 중인 스레드들 재운다.
 * sleep_list에 wakeup_ticks 기준으로 오름차순으로 삽입하고 스레드의 상태를 BLOCKED로 전환한다
 * thread_block() 내부적으로 schedule()을 호출하여 스케줄링을 수행한다.
 * Idle 스레드는 thread_sleep()을 호출할 수 없다.
 * 스레드 리스트를 조작할때, 인터럽트를 비활성화하고 조작이 끝나면 다시 활성화해야 한다.
 */
void thread_sleep(int64_t ticks)
{
	enum intr_level old_level = intr_disable();
	struct thread *t = thread_current();

	ASSERT(t != idle_thread);

	t->wakeup_ticks = ticks;
	list_insert_ordered(&sleep_list, &t->elem, (list_less_func *)less_wakeup_ticks, NULL);
	thread_block();
	intr_set_level(old_level);
}
```

`thread.c/thread_wakeup()`

```c
/* thread_wakeup - 잠들어 있는 스레드를 깨운다.
 * sleep_list를 순회하면서 wakeup_ticks이 현재 os_ticks보다 작아진 스레드를 깨운다.
 * sleep_list는 wakeup_ticks 기준으로 오름차순으로 정렬되어 있다.
 * 깨어난 스레드는 READY 상태로 전환되고 ready_list에 priority 기준으로 내림차순 삽입된다.
 * 
 * 이 함수는 타이머 인터럽트 핸들러에서 호출된다. 따라서 이 함수는 외부 인터럽트 컨텍스트에서 실행된다.
 * 스레드 리스트를 조작할때, 인터럽트를 비활성화하고 조작이 끝나면 다시 활성화해야 한다.
 */
void thread_wakeup(int64_t os_ticks)
{
	if (list_empty(&sleep_list))
		return;
	enum intr_level old_level = intr_disable();
	struct thread *t;

	while (!list_empty(&sleep_list))
	{
		t = list_entry(list_front(&sleep_list), struct thread, elem);
		if (t->wakeup_ticks > os_ticks)
			break;
		list_pop_front(&sleep_list);
		list_insert_ordered(&ready_list, &t->elem, (list_less_func *)higher_priority, NULL);
		t->status = THREAD_READY;
	}
	intr_set_level(old_level);
}
```

`thread.c/비교함수들`

```c
/* higher_priority - ready_list를 우선순위 내림차순으로 정렬하기 위한 비교 함수.
 */
bool higher_priority(const struct list_elem *a, const struct list_elem *b, void *aux UNUSED)
{
	struct thread *ta = list_entry(a, struct thread, elem);
	struct thread *tb = list_entry(b, struct thread, elem);
	return ta->priority > tb->priority;
}

/* less_wakeup_ticks - sleep_list를 정렬하기 위한 비교 함수.
 */
bool less_wakeup_ticks(const struct list_elem *a, const struct list_elem *b, void *aux UNUSED)
{
	struct thread *ta = list_entry(a, struct thread, elem);
	struct thread *tb = list_entry(b, struct thread, elem);
	return ta->wakeup_ticks < tb->wakeup_ticks;
}
```

## Priority Scheduling

> pintos에서 **우선순위 스케줄링(Priority Scheduling)** 을 구현하고 **우선순위 역전(Priority Inversion)** 을 해결하기 위한 **우선순위 기부(Priority Donation)**을 구현하라
> 

초기 스레드 우선순위는 `thread_create()`에 인자로 전달되지만, 스케줄러는 우선순위를 무시하고 있다.

현재 실행 중인 스레드보다 우선순위가 높은 스레드가 `ready_list`에 추가되면 현재 스레드는 즉시 프로세서를 새 스레드에게 양보해야 한다.

마찬가지로 스레드가 **잠금(Lock)**, **세마포어(Semaphore)** 또는 **조건 변수(Condition Variable)** 를 기다리는 경우 우선순위가 가장 높은 대기 스레드가 먼저 깨어나야 한다. 

그리고 스레드는 언제든지 자신의 우선순위를 변경할 수 있지만, **우선순위를 낮추어 더 이상 가장 높은 우선순위를 갖지 않게 되면 즉시 CPU를 양보**해야 한다.

우선순위 스케줄링의 한 가지 문제는 **우선순위 역전**이다. 

우선순위 역전이 일어나는 예시를 하나 들어보자.

1. 우선순위가 각각 높은, 중간, 낮은 스레드 H, M, L이 있다.
2. L이 먼저 잠금을 획득하고, H가 잠금을 대기하고 있다.
3. 이때, 잠금을 요구하지 않는 M이 `ready_list`에 들어오면 L이 프로세서를 양보하고 M이 실행된다.
4. 결과적으로 M→L→H 순으로 실행이 완료되어 **우선순위가 역전된 현상**이 일어난다.

이러한 우선순위 역전 문제를 부분적으로 해결하는 방법은 **L이 잠금을 보유하는 동안 H가 자신의 우선순위를 L에게 기부한 다음 L이 잠금을 해제하고 H가 잠금을 획득하면 기부한 우선순위를 회수하는 방법**이다.

우선순위 기부을 구현하기 위해서는 우선순위 기부가 필요한 다양한 상황을 모두 고려해야 한다. 

1. 하나의 스레드에 여러 개의 우선순위가 기부되는 **다중 기부(Multiple Donation)** 를 처리해야 한다.

    ![img](assets/img/inpost/129.png)
    _다중 기부 예시 1_

    ![img](assets/img/inpost/130.png)
    _다중 기부 예시 2_
    
    t1의 우선순위는 1, t2의 우선순위는 2, t3와 t4도 마찬가지라고 하자.
    
    t1이 잠금 A, B, C를 보유하고 있는 상황에서 t2, t3, t4가 순서대로 잠금 A, B, C를 얻으려고 하면, **t1의 우선순위는 2→3→4 순으로 높여지게 된다.**
    
    만약 이 상황에서 **t1이 잠금 C를 놓아주게 되면, t4는 잠금 C를 얻고, t1의 우선순위는 자신 본래의 우선순위가 아닌 t3에게 기부 받은 우선순위인 3으로 변해야 한다.**
    
2. **중첩 기부(Nested Donation)** 를 처리해야 한다. 
    
    ![img](assets/img/inpost/131.png)
    _중첩 기부 예시 1_
    
    ![img](assets/img/inpost/132.png)
    _중첩 기부 예시 2_
    
    t1이 잠금 A를 보유하고 있고, t2가 잠금 B를 보유한 상태에서 잠금 A를 기다리고 있다.
    
    이 때, **t3가 잠금 B를 얻으려고 하면 t1과 t2 모두 t3의 우선순위로 높여져야 한다.**
    
    필요한 경우 중첩된 우선순위 기부 깊이에 8 단계와 같이 합리적인 제한을 둘 수 있다.
    

마지막으로 스레드가 자신의 우선순위를 검사하고 수정할 수 있는 아래 함수를 구현해야 한다.

이 함수를 위한 뼈대는 `threads/thread.c`에 제공된다.

---

```c
void thread_set_priority(int new_priority);
```

현재 스레드의 우선순위를 새 우선순위로 설정한다. **현재 스레드의 우선순위가 더 이상 높지 않으면 프로세서를 양보**한다.

---

```c
 int thread_get_priority(void);
```

현재 스레드의 우선순위를 반환한다. 우선순위 기부가 있는 경우, **더 높은(기부된) 우선순위를 반환**한다.

---

스레드가 다른 스레드의 우선순위를 직접 수정할 수 있도록 인터페이스를 제공할 필요는 없고, 우선순위 스케줄러는 이후 프로젝트에서 사용되지 않는다.

### Solution

pintos는 현재 선입선출(FIFO) 스케줄링을 사용하므로, **우선순위 스케줄링으로 변경**해야 한다.

그리고 **우선순위 기부를 구현**해야 한다.

**수정/추가해야 하는 파일/함수**

- `include/threads/thread.h`
    - `struct thread`
- `threads/thread.c`
    - `thread_create()`
    - `thread_unblock()`
    - `thread_yield()`
    - `thread_set_priority()`
    - `init_thread()`
- `threads/synch.c`
    - `sema_down()`
    - `sema_up()`
    - `lock_acquire()`
    - `lock_release()`
    - `cond_wait()`
    - `cond_signal()`
    - `semaphore_elem`을 위한 비교 함수

**기존 상태**

스케줄러가 스레드의 우선순위를 무시하고 FIFO 방식으로 스케줄링된다.

`ready_list`와 잠금의 `waiters`에 들어간 스레드들은 먼저 들어간 순으로 나오게 된다.

**수정된 상태**

스케줄러가 FIFO 방식이 아닌, **우선순위 스케줄링**을 한다. 이를 위해 **선점(Preemption)** 이 구현되어야 한다.

선점이란, **새로운 스레드가 현재 실행 중인 스레드보다 우선순위가 높다면, 새로운 스레드가 CPU를 선점**하는 것이다.

`ready_list`의 스레드들과 **동기화 프리미티브(잠금, 세마포어, 조건변수)에서** `waiters`의 스레드들은 FIFO 방식이 아닌 여러 스레드들 중 **우선순위가 높은 순으로 실행**되고, 잠금을 얻게 된다.

1. 스레드는 자신에게 기부를 해준 스레드들을 저장하기 위해 `donations`라는 스레드 리스트 필드를 보유해야 한다. 또한 이 리스트를 위한 `list_elem` 구조체도 필요하다.
2. 스레드가 잠금을 얻으려고 시도 했지만, 얻지 못하였을 때, 내가 기다리고 있는 잠금을 저장하기 위해 `wait_on_lock`이라는 필드가 필요하다.
3. 스레드가 기부를 받았다면, 나중에 잠금을 해제하였을 때 다시 되돌아갈 내 원본 우선순위를 저장하여야 한다.
4. 새로운 스레드가 생성되었을 때, 현재 실행 중인 스레드보다 우선순위가 높다면, 현재 실행 중인 스레드는 프로세서를 양보하여야 한다.
    
    이 때, `thread_yield()`는 인터럽트가 해제된 상태에서 호출되어야 한다.
    
5. 스레드가 `ready_list`에 삽입될 때, 우선순위 내림차순으로 삽입되어야 한다.
6. 스레드가 잠금의 `waiters` 리스트에 삽입될 때, 우선순위 내림차순으로 삽입되어야 한다.
7. 현재 스레드의 우선순위가 새로 조정된다면 여러 상황을 고려하여야 한다.
    1. 현재 스레드가 다른 스레드에게 기부 받아 우선순위가 변경되었다면, 변경된 우선순위를 조작하지 않고, 내 원본 우선순위를 변경하여야 한다.
    2. 만약 현재 스레드가 기부받지 않았다면, 상관없다.
    3. 현재 실행 중인 스레드의 우선순위가 낮아진다면, READY 상태인 임의의 스레드보다 우선순위가 낮아질 수 있다.
8. 스레드 초기화 시에 스레드 구조체에 새로 추가된 필드들을 초기화 해주어야 한다. 특히 리스트를 잊지 말자.
9. 스레드가 세마포어를 포기하고, `waiters` 리스트에서 BLOCKED 된 스레드를 UNBLOCK 해줄 때, `waiters` 리스트를 정렬해주어야 한다.
    
    ![img](assets/img/inpost/133.png)
    
    ![img](assets/img/inpost/134.png)
    
    위 그림과 같이 예시를 들어보자.
    
    - 두 개의 잠금 A, B가 있고, t1이 A를 t4가 B를 보유하고 있다.
    - t2와 t1이 순서대로 t4가 보유한 잠금 B에서 기다리고 있다.
    - 이 때, t3이 t1이 보유한 잠금 A를 얻으려고 한다면, t3의 우선순위가 t1보다 높기에 t3가 t1에게 우선순위 기부를 하게 된다.
    - 하지만 t1이 기다리고 있는 잠금 B의 `waiters` 리스트에서는, 이미 t2보다 후순위에 놓였기에, t4가 잠금 B를 포기하더라도 t2가 먼저 잠금을 얻게 되어 우선순위에 어긋나게 된다.
    - 삽입 할 때마다 정렬해주어도 되지만, 비효율적이기에 실제로 UNBLOCK 해주기 전에 정렬을 해주어 이러한 상황을 해결한다.
10. 또한 스레드가 세마포어를 포기하고, `waiters` 리스트에서 BLOCKED 된 스레드를 UNBLOCK 해준다면 해당 스레드는 `ready_list`에 들어가게 되는데, 이 때 UNBLOCK된 스레드가 실행 중인 스레드를 밀어내고 선점해야 할 수 있다.
11. 스레드가 잠금을 얻으려고 할 때, 잠금을 획득하지 못한다면 해당 잠금을 저장하여야 하고, 현재 스레드의 우선순위가 잠금을 보유하고 있는 스레드의 우선순위보다 높다면 중첩 기부를 수행하여야 한다.
    
    해당 스레드가 기부를 하였다면, 첫 번째로 기부를 받은 스레드의 `donations` 리스트에 해당 스레드를 넣어주는 걸 잊지 말자. 다중 기부에서 `donations` 리스트를 사용하여야 한다.
    
    그리고 해당 스레드의 `wait_on_lock`을 NULL로 만들어주자.
    
12. 현재 스레드가 잠금을 해제한다면, 현재 스레드의 `donations` 리스트에서 해당 잠금을 기다리고 있던 스레드를 삭제하고, 다중 잠금에서의 우선순위 기부를 고려하여 현재 스레드의 우선순위를 재조정한다.
    
    `donations` 리스트에서 가장 높은 우선순위로 재조정하고, `donations` 리스트가 비어있다면 현재 스레드의 원본 우선순위로 설정한다.
    
13. 조건 변수 사용 시에도 조건 변수의 `waiters` 리스트에 우선순위 순서대로 삽입한다. 조건 변수를 위한 `semaphore_elem`은 세마포어를 한번 더 감싸두었기에, 비교 함수가 조금 더 복잡해진다.
14. 조건 변수 사용 시에 대기 중인 스레드에게 신호를 보내 대기를 해제한다면, 세마포어 변수를 높히기 전에 조건 변수의 `watiers` 리스트를 정렬하여야 한다.

**코드**

`include/threads/thread.h/struct thread`

```c
struct thread {
	...
  /* For Priority Donation */
  struct list donations;     // 해당 스레드에게 기부를 해준 스레드
  struct list_elem d_elem;   // donations 리스트를 위한 list_elem
  struct lock *wait_on_lock; // 기다리고 있는 잠금
  int original_priority;     // 기부를 받기 전의 기존 우선순위
	...
};
```

`thread.c/thread_create()` 

```c
/* 새로운 커널 스레드를 생성한다. NAME은 스레드의 이름이며, PRIORITY는 스레드의 우선순위이다.
 * FUNCTION은 스레드가 실행할 함수이며, AUX는 FUNCTION에 전달할 인자이다.
 * 스레드를 생성하고, ready_list에 스레드를 추가한다.
 * 새 스레드의 tid를 반환하거나 생성에 실패하면 TID_ERROR를 반환한다.
 * FUNCTION이 실행되는 시점은 thread_create()가 반환된 이후이다.
 * 새로 생성된 스레드와 현재 실행 중인 스레드의 우선 순위를 비교하여 현재 스레드의 우선 순위가 더 낮다면 CPU를 양보한다.

 * thread_start()가 호출되었다면 thread_create()가 반환되기 전에 새 스레드가 예약될 수 있습니다.
 * 심지어 thread_create()가 반환되기 전에 종료될 수도 있습니다.
 * 반대로, 원래 스레드는 새 스레드가 예약되기 전에 얼마든지 실행될 수 있습니다.
 * 순서를 보장해야 하는 경우 세마포어 또는 다른 형태의 동기화를 사용하십시오.
 */
tid_t thread_create(const char *name, int priority, thread_func *function, void *aux)
{
	enum intr_level old_level;
	...
	old_level = intr_disable();
	if (thread_get_priority() < priority)
		thread_yield();
	
	intr_set_level(old_level);
}
```

`thread.c/thread_unblock()`

```c
/* thread_unblock - BLOCKED 스레드 t를 READY 상태로 전환하고 ready_list에 우선순위 내림차순으로 삽입한다.
 * t가 BLOCKED 상태가 아니라면 에러이다. (running thread를 READY 상태로 전환하려면 thread_yield()를 사용하라)
 * 이 함수는 현재 실행중인 스레드를 선점하지 않는다. 이것은 중요할 수 있다.
 * 만약 호출자가 직접 인터럽트를 비활성화했다면, 스레드를 unblock하고 다른 데이터를 업데이트할 수 있다고 기대할 수 있다.
 */
void thread_unblock(struct thread *t)
{
	...
	list_insert_ordered(&ready_list, &t->elem, (list_less_func *)higher_priority, NULL);
	...
}
```

`thread.c/thread_yield()`

```c
/* thread_yield - 현재 실행 중인 스레드가 CPU를 양보하고, ready_list에 우선순위 내림차순으로 삽입한다.
 * 현재 스레드는 BLOCKED 상태로 전환되지 않으며 스케줄러의 재량에 따라 즉시 다시 스케줄될 수 있다.
 * 만약 현재 스레드가 Idle 스레드라면 ready_list에 삽입하지 않는다.
 */
void thread_yield(void)
{
	...
	list_insert_ordered(&ready_list, &curr->elem, (list_less_func *)higher_priority, NULL);
	...
}
```

`thread.c/thread_set_priority()`

```c
/* thread_set_priority - 현재 스레드의 우선순위를 새로운 우선순위로 설정하고,
 * 우선순위가 낮아진다면 ready_list에서 자신보다 더 높은 우선순위를 가진 스레드가 있는지 확인하여야 한다.
 */
void thread_set_priority(int new_priority)
{
	thread_current()->original_priority = new_priority;
	if (list_empty(&thread_current()->donations))
	{
		thread_current()->priority = new_priority;
	}
	if (!list_empty(&ready_list) && list_entry(list_front(&ready_list), struct thread, elem)->priority > new_priority)
		thread_yield();
}
```

`thread.c/init_thread()`

```c
/* init_thread - 스레드 t를 name이라는 priority를 가진 BLOCKED 스레드로 초기화한다.
 * donations 리스트를 초기화한다.
 */
static void init_thread(struct thread *t, const char *name, int priority)
{
	...
	t->original_priority = priority;
	list_init(&t->donations);
	...
}
```

`synch.c/sema_down()`

```c
/* sema_down - 세마포어에 대한 Down 또는 P 연산이다.
 * 세마포어를 얻을 수 없다면, 현재 스레드를 세마포어의 waiters 리스트에 priority 내림차순으로 삽입하고, BLOCKED 상태로 전환한다.
 * 그리고 세마포어 값이 양수가 될 때까지 기다렸다가 원자적으로 감소시킨다.
 * 이 함수는 BLOCKED 될 수 있으므로 인터럽트 핸들러 내에서 호출해서는 안된다.
 * 인터럽트가 비활성화된 상태에서 호출될 수 있지만, BLOCKED가 발생하면 다음 스케줄링된 스레드가 인터럽트를 다시 활성화 할 수 있다.
 */
void sema_down(struct semaphore *sema)
{
	...
	while (sema->value == 0) 
	{
		list_insert_ordered(&sema->waiters, &thread_current()->elem, (list_less_func *)&higher_priority, NULL);
		...
	}
	...
}
```

`synch.c/sema_up()`

```c
/* sema_up - Up 또는 세마포어에서 V 연산을 수행한다.
 * 세마포어의 값을 증가시키고, 세마포어를 기다리는 스레드가 있다면 하나를 깨운다.
 * 우선순위 기부에 의해 waiters 리스트에서의 우선순위가 내림차순에 어긋날 수 있기에, waiters 리스트를 정렬한다.
 * 현재 실행 중인 스레드가 양보하고, 스케줄링된다. 스케줄러 재량에 따라 다시 같은 스레드가 실행될 수 있다.
 * 이 함수는 인터럽트 핸들러에서 호출될 수 있다.
 */
void sema_up(struct semaphore *sema)
{
	...
	if (!list_empty(&sema->waiters)) 
	{
		list_sort(&sema->waiters, (list_less_func *)&higher_priority, NULL);
		...
	}
	...
	thread_yield();
}
```

`synch.c/lock_acquire()`

```c
/* lock_acquire - 잠금을 획득하고 필요한 경우 잠금을 사용할 수 있을 때까지 대기한다.
 * 잠금은 현재 스레드가 이미 보유하고 있지 않아야 한다.
 *
 * 잠금을 획득하지 못할 경우, 해당 잠금을 wait_on_lock에 저장한다.
 * 이후, 현재 스레드의 우선순위가 잠금을 보유하고 있는 스레드의 우선순위보다 높을 경우,
 * 잠금을 보유하고 있는 스레드의 donations 리스트에 현재 스레드를 추가하고 중첩 기부를 수행한다.
 * 
 * 이 함수는 BLOCKED 될 수 있으므로 인터럽트 핸들러 내에서 호출해서는 안된다.
 * 이 함수는 인터럽트가 비활성화된 상태에서 호출될 수 있지만, Sleep이 필요하면 인터럽트가 다시 활성화된다.
 */
void lock_acquire (struct lock *lock) {
	...
	struct thread *t = thread_current();
	struct thread *holder;
	
	if (lock->holder != NULL) {
		t->wait_on_lock = lock;
		if (thread_get_priority() > lock->holder->priority) {
			list_insert_ordered(&lock->holder->donations, &t->d_elem, (list_less_func *)&higher_priority, NULL);
			while (t->wait_on_lock != NULL) {
				holder = t->wait_on_lock->holder;
				if (t->priority > holder->priority) {
					holder->priority = t->priority;
					t = holder;
				}
				else break;
			}
		}
	}
	sema_down(&lock->semaphore);
	thread_current()->wait_on_lock = NULL;
	lock->holder = thread_current();
}
```

`synch.c/lock_release()`

```c
/* lock_release - 현재 스레드가 소유하고 있는 잠금을 해제한다.
 *
 * 잠금이 해제되면, 해당 잠금을 가지고 있던 스레드의 donations 리스트에서 해당 잠금을 기다리고 있던 스레드를 삭제한다.
 * 그리고 다중 기부를 수행하기 위해 donations 리스트를 검사하여 현재 스레드의 우선순위를 재설정한다.
 * 만약 donations 리스트가 비어있지 않다면, 현재 스레드의 우선순위를 donations 리스트의 가장 높은 우선순위로 설정하고,
 * donations 리스트가 비어있다면, 현재 스레드의 우선순위를 원래의 우선순위로 설정한다.
 * 
 * 인터럽트 핸들러는 잠금을 획득할 수 없으므로 인터럽트 핸들러 내에서 잠금을 해제하려고 시도하는 것은 의미가 없다.
 */
void lock_release (struct lock *lock) {
	...
	struct thread *lock_holder = lock->holder;
	struct thread *t;
	struct list_elem *e;
	
	for (e = list_begin(&lock->holder->donations); e != list_end(&lock->holder->donations); e = list_next(e)) {
		t = list_entry(e, struct thread, d_elem);
		if (t->wait_on_lock == lock)
			list_remove(e);
	}

	if (!list_empty(&lock_holder->donations)) {
		lock_holder->priority = list_entry(list_front(&lock_holder->donations), struct thread, d_elem)->priority;
	}
	else
		lock_holder->priority = lock_holder->original_priority;
	...
}
```

`synch.c/cond_wait()`

```c
/* cond_wait - 잠금을 원자적으로 해제하고 다른 코드가 COND 신호를 보낼 때까지 기다린다.
 * COND가 신호를 받은 후 잠금을 다시 획득한 후 반환합니다.
 * 이 함수를 호출하기 전에 잠금을 유지해야 한다.
 * 
 * 이 함수가 구현하는 Monitor는 "Hoare" 스타일이 아닌 "Mesa" 스타일이다.
 * ( Mesa: 시그널을 보내거나 받는 것이 원자적인 작업이 아니다, Hoare: 시그널을 보내거나 받는 것이 원자적인 작업이다. )
 * 즉, Signal 송수신은 원자적인 작업이 아니다. 따라서 일반적으로 호출자는 대기가 완료된 후 조건을 다시 확인하고 필요한 경우 다시 대기해야 한다.
 * 
 * 주어진 조건 변수는 하나의 잠금에만 연결되지만, 하나의 잠금은 여러 개의 조건 변수와 연결될 수 있다.
 * 즉, 잠금에서 조건 변수로의 1대N 매핑이 존재한다.
 * 
 * 이 함수는 Sleep을 할 수 있으므로 인터럽트 핸들러 내에서 호출해서는 안된다.
 * 이 함수는 인터럽트가 비활성화된 상태에서 호출될 수 있지만, Sleep이 필요하면 인터럽트가 다시 활성화된다.
 */
void cond_wait (struct condition *cond, struct lock *lock) {
	...
	sema_init (&waiter.semaphore, 0);
	list_insert_ordered(&cond->waiters, &waiter.elem, (list_less_func *)&cond_priority, NULL);
	...
}
```

`synch.c/cond_signal()`

```c
/* cond_signal - COND에 대기 중인 스레드 중 하나에게 신호를 보낸다.
 * 신호를 받은 스레드는 대기를 해제하고, 신호를 보낸 스레드가 잠금을 유지하고 있는 경우 잠금을 다시 획득한다.
 * 
 * 이 함수는 LOCK이 유지되어야 한다.
 * 
 * 인터럽트 핸들러는 잠금을 획득할 수 없으므로 인터럽트 핸들러 내에서 조건 변수를 신호로 보내는 것은 의미가 없다.
 */
void cond_signal (struct condition *cond, struct lock *lock UNUSED) {
	...
	if (!list_empty (&cond->waiters)) {
		list_sort(&cond->waiters, (list_less_func *)&cond_priority, NULL);
		...
	}
}
```

`synch.c/semaphore_elem 비교 함수`

```c
/* cond_priority - 조건 변수의 대기자 리스트에서 우선순위가 높은 스레드를 찾는다.
 */
bool cond_priority(const struct list_elem *a, const struct list_elem  *b, void *aux UNUSED) {
    struct semaphore_elem *sema_a = list_entry(a, struct semaphore_elem, elem);
    struct semaphore_elem *sema_b = list_entry(b, struct semaphore_elem, elem);
    struct thread *t_a = list_entry(list_begin(&sema_a->semaphore.waiters), struct thread, elem);
    struct thread *t_b = list_entry(list_begin(&sema_b->semaphore.waiters), struct thread, elem);
    return t_a->priority > t_b->priority;
}
```

## Advanced Scheduler

> **4.4BSD 스케줄러**와 비슷한 **Multi-Level Feedback Queue 스케줄러**를 구현하여 시스템에서 실행 중인 작업의 평균 응답 시간을 줄이라.
> 

우선순위 스케줄러와 마찬가지로 고급 스케줄러도 우선순위에 따라 실행할 스레드를 선택한다.

그러나 **고급 스케줄러는 우선순위 기부를 하지 않는다.** 따라서 고급 스케줄러에서 작업을 시작하기 전에 우선순위 기부를 제외하고 우선순위 스케줄러를 작동시키는 것이 좋다.

핀토스 시작 시 **스케줄링 알고리즘 정책을 선택할 수 있도록 코드를 작성**해야 한다.

기본적으로 우선순위 스케줄러가 활성화되어 있어야 하지만, `-mlfqs` 커널 옵션으로 4.4BSD 스케줄러를 선택할 수 있어야 한다. 이 옵션을 전달하면 `main()` 초기에 발생하는 `parse_options()`에 의해 `threads/thread.h`에 선언된 `thread_mlfqs`가 `true`로 설정된다.

4.4BSD 스케줄러가 활성화되면, 스레드는 더 이상 자신의 우선순위를 직접 제어하지 않는다.

`thread_create()`의 **우선순위 인수는 무시**되어야 하며, `thread_set_priority()` 및 `thread_get_priority()` 호출은 **스케줄러가 설정한 스레드의 현재 우선순위를 반환**해야 한다.

고급 스케줄러는 이후 프로젝트에서 사용되지 않는다.

### 4.4BSD Scheduler

**범용 스케줄러**의 목표는 스레드의 다양한 스케줄링 요구 사항의 균형을 맞추는 것이다.

**많은 입출력을 수행하는 스레드**는 입출력 장치를 바쁘게 유지하기 위해 빠른 응답 시간이 필요하지만 CPU 시간은 거의 필요하지 않다.

반면에 **컴퓨팅에 바인딩된 스레드**는 작업을 완료하기 위해 많은 CPU 시간을 필요로 하지만 빠른 응답 시간은 필요하지 않다.

다른 스레드는 이 둘의 사이 어딘가에 위치하며, 연산 주기로 구분되는 I/O 주기로 인해 시간에 따라 요구 사항이 달라진다. 잘 설계된 스케줄러는 이러한 모든 요구 사항을 가진 스레드를 동시에 수용할 수 있는 경우가 많다.

Project 1의 경우 Appendix에 설명된 스케줄러를 구현해야 한다.

이 스케줄러는 Multi-Level Feedback Queue 스케줄러의 예시 중 하나인 [McKusick]에 설명된 것과 비슷하다.

이 유형의 **스케줄러는 실행 준비가 완료된 스레드의 여러 대기열을 유지**하며, **각 대기열에는 우선순위가 다른 스레드들이 보관**된다.

**스케줄러는 언제든지 우선순위가 가장 높은 비어 있지 않은 대기열에서 실행할 스레드를 선택**한다.

우선순위가 가장 높은 대기열에서 여러 개의 스레드가 포함되어 있으면 스레드가 **Round Robin** 순서로 실행된다.

스케줄러의 여러 측면에서는 특정 수의 타이머 틱 후에 데이터를 업데이트해야 한다.

모든 경우에 이러한 업데이트는 일반 커널 스레드가 실행되기 전에 이루어져야 커널 스레드가 새로 증가한 `timer_ticks()` 값 대신 이전 스케줄러 데이터 값을 볼 수 있는 가능성이 없다.

4.4BSD 스케줄러에는 우선순위 기부가 없다.

pintos에서는 여러 개의 큐를 사용해도 되지만, 하나의 큐에서 구현해도 가능하다.

Kaist 학생들은 여러 개의 큐를 사용하여 구현하면 10% 가산점이 있다.

MLFQS에서 중요한 개념으로는 **nice, priority, recent_cpu, decay, load_average**가 있다.

### Niceness

스레드 우선순위는 스케줄러가 아래 공식을 사용하여 동적으로 결정한다. 그러나 각 스레드에는 다른 스레드에 대한 스레드의 “nice” 정도를 결정하는 정수 nice 값도 있다.

- nice 값이 0이면 스레드 우선순위에 영향을 미치지 않는다.
- nice 값이 양수(최대 20)이면 스레드의 우선순위가 낮아지고, 그렇지 않으면 받을 수 있는 CPU 시간을 일부 포기하게 된다.
- nice 값이 음수(최소 -20)이면 다른 스레드에서 CPU 시간을 빼앗는 경향이 있다.

초기 스레드는 0의 nice 값으로 시작한다. 다른 스레드는 부모 스레드에서 상속된 nice 값으로 시작한다.

테스트 프로그램에서 사용하기 위해 아래에 설명된 함수를 구현해야 한다. 이에 대한 정의의 뼈대는 `threads/thread.c`에 제공되어 있다.

```c
int thread_get_nice(void);
```

현재 스레드의 nice 값 반환

---

```c
int thread_set_nice(int nice);
```

현재 스레드의 nice 값을 새로운 nice 값으로 설정하고, 

새 nice 값에 따라 스레드의 우선순위를 다시 **계산**한다. 실행 중인 스레드의 우선순위가 더 이상 높지 않으면 양보한다.

### Calculating Priority

스케줄러에는 64개의 우선순위가 있으며, 따라서 0(`PRI_MIN`)부터 63(`PRI_MAX`)까지 64개의 ready queue가 번호가 매겨져 있다. 스레드 우선순위는 **스레드 초기화 시 처음에 계산된다. 또한 모든 스레드에 대해 4 tick마다 한 번씩 다시 계산 된다. 두 경우 모두 공식에 의해 결정된다.**

> $priority = PRI\\_MAX - (recent\\_cpu / 4) -(nice*2)$
> 

여기서 `recent_cpu`는 **스레드가 최근에 사용한 CPU 시간의 추정치**이고, `nice`는 스레드의 nice 값이다.

결과는 가장 가까운 정수로 반내림해야 한다.

`recent_cpu`와 `nice`에 대한 계수 1/4과 2는 각각 실제로는 잘 작동하지만 더 깊은 의미는 없는 것으로 밝혀졌다.

계산된 우선순위는 항상 유효한 범위인 `PRI_MIN` ~ `PRI_MAX`에 속하도록 조정된다.

이 공식은 최근에 CPU 시간을 받은 스레드가 다음에 스케줄러가 실행될 때 CPU를 다시 할당받을 수 있는 우선순위를 낮게 부여한다. 최근에 CPU를 받지 않은 스레드는 `recent_cpu`가 0이 되므로 nice 값이 높지 않은 한, 곧 CPU를 할당 받을 수 있다.

### Calculating `recent_cpu`

각 프로세스가 “최근” 받은 CPU 시간을 측정하려면 `recent_cpu`가 필요하다. 또한, 더 자세하게, **최근에 계산된 recent_cpu는 예전에 계산된 recent_cpu에 비해 더 큰 가중치를 부여**해야 한다.

한 가지 접근 방식은 n개의 요소 배열을 사용해 지난 n초 동안 수신된 CPU 시간을 추적하는 것이다. 그러나 이 접근 방식은 스레드당 $O(n)$의 공간과 새로운 가중 평균을 계산할 때마다 $O(n)$의 시간이 필요하다.

대신, **지수 가중 이동 평균**을 사용하는데, 이는 일반적인 형태를 취한다.

> $x(0)=f(0),$   
> $x(t)=ax(t-1)+(1-a)f(t),$   
> $a=k/(k+1),$   
> 

여기서 $x(t)$는 정수 시간 $t>=0$에서의 이동 평균이고,

$f(t)$는 평균화되는 함수이며,

$k>0$은 감쇠 속도(rate of decay)를 제어한다.

이 공식은 다음과 같이 몇 단계에 걸쳐 반복할 수 있다.

> $x(1)=f(1),$   
> $x(2)=af(1)+f(2)$   
> $...$   
> $x(5)=a^4 * f(1) + a^3 * f(2) + a^2 * f(3) + a^1 * f(4) + a^0 * f(5)$

$f(t)$의 값은 시간 $t$에서 가중치 $1$, 시간 $t+1$에서 가중치 $a$, 시간 $t+2$에서 가중치 $a^2$ 등을 갖는다.

또한 $x(t)$를 $k$와 연관시킬 수도 있다.

즉, $f(t)$는 시간 $t+k$에서 약 $1\over e$, 시간 $t+2k$에서 약 $1\over e^2$의 가중치를 갖는다.

반대 방향에서 $f(t)$는 시간 $t+log_aw$에서 가중치 $w$로 감쇠한다.

`recent_cpu`의 초기 값은 처음 생성된 스레드에서는 0이고, 다른 새 스레드에서는 부모 스레드의 값이다.

타이머 인터럽트가 발생할 때마다 Idle 스레드가 아니라면, 실행 중인 스레드의 `recent_cpu`가 1씩 증가한다.

또한 초당 한 번씩 이 공식을 사용하여 모든 스레드(RUNNING, READY, BLOCKED)에 대해 `recent_cpu` 값이 다시 계산된다.


> $recent\\_cpu=(2 * load\\_avg)/(2 * load\\_avg+1) * recent\\_cpu+nice$   
> $decay=(2 * load\\_avg)/(2 * load\\_avg+1)$   
> $recent\\_cpu=decay*recent\\_cpu$   
> $recent\\_cpu=recent\\_cpu+nice$   
> → $recent\\_cpu=decay * recent\\_cpu+nice$    

여기서 `load_avg`는 실행할 준비가 된 스레드 수의 이동 평균이다.

만약 `load_avg`가 1이라면 평균적으로 단일 스레드가 CPU를 사용함을 나타내며, `recent_cpu`의 현재 값이 0.1의 가중치로 감소하는 데는 log_(2/3) .1 $\approx$ 6가 걸리고, `load_avg`가 2이면 0.1의 가중치로 감소하는 데 log_(3/4) .1 $\approx$ 8초가 걸린다. 


그 결과 최근 CPU는 스레드가 “최근” 받은 CPU 시간을 추정하며, 감쇠 속도는 CPU를 두고 경쟁하는 스레드 수에 반비례한다.

`decay`는 SVR3에서 $1\over 2$이고, **BSD4.4에서 부하가 많다면 1에 가까워지고, 부하가 적다면 0**이다.

일부 테스트에서의 가정 때문에 **`recent_cpu`의 재계산은 시스템 틱 카운터가 1초의 배수**에 도달할 때, 즉, `timer_tick() % TIMER_FREQ == 0`이 될 때 정확히 이루어져야 하며, 다른 때는 재계산하면 안된다.

`recent_cpu`의 값은 음수의 nice 값은 가진 스레드의 경우 음수일 수 있다. `recent_cpu`가 음수더라도 0으로 고정하지 마라.

이 공식에서 계산 순서를 고려해야 할 수도 있다. `recent_cpu` 계수를 먼저 계산한 다음 곱하는 것이 좋다. 일부 학생들은 `load_avg`에 `recent_cpu`를 직접 곱하면 오버플로가 발생할 수 있다고 한다.

`threads/thread.c`에 뼈대가 있는 `thread_get_recent_cpu()`를 구현해야 한다.

```c
int thread_get_recent_cpu(void);
```

현재 스레드의 `recent_cpu` 값 * 100을 가까운 정수로 반올림하여 반환한다.

### Calculating `load_avg`

시스템 로드 평균이라고도 하는 `load_avg`는 **지난 1분 동안 실행할 준비가 된 스레드의 평균 수를 추정**한다.

`recent_cpu`와 마찬가지로 기하급수적으로 가중치가 부여된 이동 평균이다.

우선순위 및 `recent_cpu`와 달리 `load_avg`는 스레드 별이 아닌 **시스템 전체에 적용**된다.

**시스템 부팅 시 0으로 초기화되며, 그 후 초당 한 번씩 다음 공식에 따라 업데이트**된다.

> $load\\_avg=(59/60) * load\\_avg+(1/60) * ready\\_threads$

여기서 `ready_threads`는 **업데이트 시점에 실행 중이거나 실행할 준비가 된 스레드의 수**이다. (Idle 스레드 제외)

일부 테스트에서의 가정 때문에 `load_avg`**는 시스템 틱 카운터가 1초의 배수에 도달**할 때, 즉 `timer_ticks() % TIMER_FREQ == 0`일 때 정확히 업데이트되어야 하며 다른 시간에는 업데이트되지 않아야 한다.

`threads/thread.c`에 뼈대가 있는 `thread_get_load_avg()`를 구현해야 한다.

```c
int thread_get_load_avg(void)
```

현재 `load_avg` 값 * 100을 가까운 정수로 반올림하여 반환한다.

### Summary

다음 공식들은 **스케줄러를 구현하는 데 필요한 계산을 요약**한 것이다. 하지만 이 공식들이 스케줄러 요구 사항에 대한 모든 설명은 아니다.

1. 매 4번째 틱마다 우선순위 계산
    
    **priority = PRI_MAX - (recent_cpu / 4) - (nice * 2)**
    
2. 매 틱마다 실행 중인 스레드의 `recent_cpu` **++**
3. 매 1초마다 모든 스레드의 `recent_cpu` 계산
    
    **recent_cpu = (2 * load_avg) / (2 * load_avg + 1) * recent_cpu + nice**
    
4. 매 1초마다 `load_avg` 계산
    
    **load_avg = (59/60) * load_avg + (1/60) * ready_threads**
    

### Solution

여러 개의 큐를 사용하지 않고 **하나의 큐로 MLFQ(Multi-Level Feedback Queue)** 인 4.4BSD 스케줄러를 구현해야 한다.

- 대화형 특성을 가진 프로세스에게 우선순위를 부여한다
- 우선순위 기반 스케줄러이다.

**방정식을 사용하여 우선순위를 계산**하고, **기아(Starvation)** 을 예방한다.

**수정/추가해야 하는 파일/함수**

- `threads/thread.h`
    - `struct thread`
- `threads/thread.c`
    - `all_list`
    - `#define MAX(a, b)`
    - `#define MIN(a, b)`
    - `load_avg`
    - `thread_init()`
    - `thread_set_nice()`
    - `thread_get_nice()`
    - `thread_get_load_avg()`
    - `thread_get_recent_cpu()`
    - `calculate_load_avg()`
    - `calculate_all_recent_cpu()`
    - `calculate_one_recent_cpu()`
    - `recent_cpu_plus()`
    - `calculate_all_priority()`
    - `calculate_one_priority()`
    - `init_thread()`
    - `schedule()`
- `devices/timer.c`
    - `timer_interrupt()`
- `threads/fixed-point.h`
- `threads/synch.c`

**기존 상태**

우선순위 스케줄링과 우선순위 기부까지 구현하였으면, 현재 스케줄러는 우선순위 스케줄링을 할 것이다.

각 스레드들은 우선순위를 수정하는 함수를 호출하지 않는 이상 **우선순위가 고정**되어 있다.

우선순위가 낮은 스레드들은 자신의 차례가 오지 않는 **기아(Starvation)**에 시달릴 수 있다.

현재 pintos는 Time-Slice가 4인 **Round-Robin 방식**을 사용하고 있지만, `thread_yield()` 호출 시에 `ready_list`에 우선순위 순으로 삽입되므로 여전히 문제가 있다.

**수정된 상태**

스케줄러에 의해 **스레드들의 우선순위가 동적으로 변한다.**

각 스레드는 자신이 최근에 CPU를 얼마나 사용했나를 저장하는 `recent_cpu` 값과 CPU를 얼마나 양보하려는 성향을 가지고 있는지에 대한 `nice` 값에 대한 구조체 필드를 가지고 있다.

이 두 값을 통해 매 초 Idle 스레드를 제외한 모든 스레드의 우선순위를 재계산하여 기아 상태를 방지한다.

매 초마다 `load_avg`와 모든 스레드의 `recent_cpu`를 계산하고, 매 4번째 틱마다 모든 스레드의 `priority`를 계산하고, 매 틱마다 현재 실행 중인 스레드의 `recent_cpu`의 값을 1 더한다.

참고로 코드 내에서 `load_avg`와 `recent_cpu`의 값은 실제 `load_avg`와 `recent_cpu`의 값에서 $F(2^{14})$를 곱한 값을 유지하고 있다.

**코드**

`devices/timer.c/timer_interrupt()`

```c
/* timer_interrupt() - 타이머 인터럽트 핸들러. 10ms당 한 번씩 호출. 1초에 100번 호출
 */
static void timer_interrupt(struct intr_frame *args UNUSED)
{
	...
	if (!thread_mlfqs)
		return;

	if (timer_ticks() % TIMER_FREQ == 0) {
		calculate_load_avg();
		calculate_all_recent_cpu();
	}
	if (timer_ticks() % 4 == 0)
		calculate_all_priority();
	recent_cpu_plus();
}
```

`threads/fixed-point.h`

```c
/* fixed-point.h */

#define F (1 << 14) // 2^14 = 16384
#define convert_to_fixed_point(n) (n * F)
#define convert_to_integer_towards_zero(x) (x / F)
#define convert_to_integer_towards_nearest(x) (x >= 0 ? ((x + F / 2) / F) : ((x - F / 2) / F))
#define add_fixed_point(x, y) (x + y)
#define add_fixed_point_integer(x, n) (x + n * F)
#define subtract_fixed_point(x, y) (x - y)
#define subtract_fixed_point_integer(x, n) (x - n * F)
#define multiply_fixed_point(x, y) (((int64_t) x) * y / F)
#define multiply_fixed_point_integer(x, n) (x * n)
#define divide_fixed_point(x, y) (((int64_t) x) * F / y)
#define divide_fixed_point_integer(x, n) (x / n)
```

`threads/thread.h/struct thread`

```c
struct thread {
	...
	/* For MLFQS */
	struct list_elem a_elem; // all_list를 위한 list_elem
	int nice;
	int recent_cpu;
	...
}
```

`threads/thread.c`

```c
#include "threads/fixed-point.h"
...
/* RUNNING, READY, BLOCKED 상태의 모든 스레드 리스트
 * IDLE 스레드는 포함하지 않는다.
 */
static struct list all_list;
...
/* load_avg - 시스템의 load_avg * 2^14(F)을 저장한다.
 */
int load_avg;
...
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MIN(a, b) ((a) < (b) ? (a) : (b))
...
```

`threads/thread.c/thread_init()`

```c
void thread_init(void)
{
	...
	list_init(&all_list);
	load_avg = 0;
	...
}
```

`threads/thread.c/thread_set_nice()`

```c
/* thread_set_nice - 현재 스레드의 nice 값을 새로운 nice로 설정한다.
 * 새로 설정된 nice 값에 따라 스레드의 우선순위가 변경되고, 우선순위가 변경된 경우 스케줄링을 수행한다.
 */
void thread_set_nice(int nice)
{
	struct thread *t = thread_current();
	t->nice = nice;
	thread_set_priority(calculate_one_priority(t));
}
```

`threads/thread.c/thread_get_nice()` 

```c
/* thread_get_nice - 현재 스레드의 nice 값을 반환한다.
 */
int thread_get_nice(void)
{
	return thread_current()->nice;
}
```

`threads/thread.c/thread_get_load_avg()`

```c
/* thread_get_load_avg - 시스템의 load_avg * 100을 반환한다.
 */
int thread_get_load_avg(void)
{
	return convert_to_integer_towards_nearest(multiply_fixed_point_integer(load_avg, 100));
}
```

`threads/thread.c/thread_get_recent_cpu()`

```c
/* thread_get_recent_cpu - 현재 스레드의 recent_cpu * 100을 반환한다.
 */
int thread_get_recent_cpu(void)
{
	return convert_to_integer_towards_zero(multiply_fixed_point_integer(thread_current()->recent_cpu, 100));
}
```

`threads/thread.c/calculate_load_avg()`

```c
/* calculate_load_avg - load_avg를 1초마다 계산한다.
 * load_avg = (59/60)*load_avg + (1/60)*ready_threads
 */
void calculate_load_avg(void)
{
	int ready_threads = list_size(&ready_list);
	if (thread_current() != idle_thread)
		ready_threads++;
	load_avg = multiply_fixed_point((59 * F) / 60, load_avg) + (((1 * F) / 60) * ready_threads);
}
```

`threads/thread.c/calculate_all_recent_cpu()`

```c
/* calculate_all_recent_cpu - 모든 스레드의 recent_cpu를 1초마다 계산한다.
 */
void calculate_all_recent_cpu(void)
{
	if (list_empty(&all_list))
		return;

	struct list_elem *e;
	struct thread *t;
	for (e = list_begin(&all_list); e != list_end(&all_list); e = list_next(e))
	{
		t = list_entry(e, struct thread, a_elem);
		t->recent_cpu = calculate_one_recent_cpu(t);
		t->priority = calculate_one_priority(t);
	}
}
```

`threads/thread.c/calculate_one_recent_cpu()`

```c
/* calculate_one_recent_cpu - 스레드 t의 recent_cpu를 계산한다.
 * decay = (2 * load_avg) / (2 * load_avg + 1)
 * recent_cpu = decay * recent_cpu + nice
 */
int calculate_one_recent_cpu(struct thread *t)
{
	int decay = divide_fixed_point(multiply_fixed_point_integer(load_avg, 2), add_fixed_point_integer(multiply_fixed_point_integer(load_avg, 2), 1));
	int _recent_cpu = add_fixed_point_integer(multiply_fixed_point(decay, t->recent_cpu), t->nice);
	return _recent_cpu;
}
```

`threads/thread.c/recent_cpu_plus()`

```c
/* recent_cpu_plus - 현재 스레드의 recent_cpu를 1초마다 1 증가시킨다.
 */
void recent_cpu_plus(void)
{
	struct thread *t = thread_current();
	ASSERT(t->status == THREAD_RUNNING);
	if (t != idle_thread) 
	{
		t->recent_cpu = add_fixed_point_integer(t->recent_cpu, 1);
	}
}
```

`threads/thread.c/calculate_all_priority()`

```c
/* calculate_all_priority - 모든 스레드의 priority를 4 ticks마다 계산한다.
 */
void calculate_all_priority(void) 
{
	if (list_empty(&all_list))
		return;

	struct list_elem *e;
	struct thread *t;

	for (e = list_begin(&all_list); e != list_end(&all_list); e = list_next(e))
	{
		t = list_entry(e, struct thread, a_elem);
		t->priority = calculate_one_priority(t);
	}
}
```

`threads/thread.c/calculate_one_priority()`

```c
/* calculate_one_priority - 스레드 t의 priority를 계산한다.
 */
int calculate_one_priority(struct thread *t)
{
	int priority = PRI_MAX - convert_to_integer_towards_zero(t->recent_cpu / 4) - (t->nice * 2);
	priority = MAX(priority, PRI_MIN);
	priority = MIN(priority, PRI_MAX);
	return priority;
}
```

`threads/thread.c/init_thread()`

```c
static void init_thread(struct thread *t, const char *name, int priority)
{
	...
	t->nice = 0;
	t->recent_cpu = 0;
	if (strcmp(name, "idle"))
		list_push_back(&all_list, &t->a_elem);
	...
}
```

`threads/thread.c/schedule()`

```c
static void schedule(void)
{
	...
	if (curr && curr->status == THREAD_DYING && curr != initial_thread)
	{
		ASSERT(curr != next);
		list_push_back(&destruction_req, &curr->elem);
		list_remove(&curr->a_elem);
	}
	...
}
```

`threads/synch.c/lock_acquire()`

```c
void lock_acquire (struct lock *lock) {
	...
	if (thread_get_priority() > lock->holder->priority && **!thread_mlfqs**)
	...
}
```

`threads/synch.c/lock_release()`

```c
void lock_release (struct lock *lock) {
	...
	if (!thread_mlfqs) {
		if (!list_empty(&lock_holder->donations)) {
			lock_holder->priority = list_entry(list_front(&lock_holder->donations), struct thread, d_elem)->priority;
		}
		else
			lock_holder->priority = lock_holder->original_priority;
	}
	...
}
```

<br/>

## Result

---

![img](assets/img/inpost/135.png)

<br/>

_참고_

- [https://casys-kaist.github.io/pintos-kaist/](https://casys-kaist.github.io/pintos-kaist/)

- [https://github.com/casys-kaist/pintos-kaist](https://github.com/casys-kaist/pintos-kaist)

- [https://ko.wikipedia.org/wiki/동기화](https://ko.wikipedia.org/wiki/동기화)

- [https://12bme.tistory.com/68](https://12bme.tistory.com/68)

- [https://www.youtube.com/watch?v=myO2bs5LMak&list=PLmQBKYly8OsWiRYGn1wvjwAdbuNWOBJNf&index=4](https://www.youtube.com/watch?v=myO2bs5LMak&list=PLmQBKYly8OsWiRYGn1wvjwAdbuNWOBJNf&index=4)

- [https://www.youtube.com/watch?v=4-OjMqyygss&list=PLmQBKYly8OsWiRYGn1wvjwAdbuNWOBJNf&index=2](https://www.youtube.com/watch?v=4-OjMqyygss&list=PLmQBKYly8OsWiRYGn1wvjwAdbuNWOBJNf&index=2)
