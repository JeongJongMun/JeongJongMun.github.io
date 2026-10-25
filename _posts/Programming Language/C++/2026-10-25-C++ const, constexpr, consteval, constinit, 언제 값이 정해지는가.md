---
title: "C++ const, constexpr, consteval, constinit"
slug: cpp-const-constexpr-consteval-constinit
description: "const, constexpr, consteval, constinit에 대해 정리했습니다."
writer: Langerak
date: 2026-10-25 12:00:00 +0800
categories: [Programming Language, C++]
tags: [C++]
pin: false
math: true
mermaid: true
---

### 개요

---

C++ 프로그램에서 변수의 값이 정해지는 시점은 크게 셋이다.

1. 컴파일 타임
   
    컴파일러가 빌드 중에 값을 계산한다. 결과는 기계어에 상수로 박히거나 실행 파일의 데이터 영역에 들어간다. 

2. 프로그램 시작 전 (정적 초기화)

    전역 변수나 static 변수가 main 전에 초기화된다. 값을 컴파일 타임에 알 수 있으면 실행 파일에 미리 기록해 두고, 
    프로그램이 메모리에 올라오는 순간 이미 그 값을 갖고 있다. 초기화 코드가 실행되지 않는다.
  
3. 실행 중 (동적 초기화)

    함수 호출 결과처럼 실행해 봐야 아는 값이다. 전역 변수라도 main 전에 초기화 코드가 실제로 실행되어야 하고, 지역 
    변수는 그 줄에 도달했을 때 정해진다.

const, constexpr, consteval, constinit 키워드는 이름이 비슷하지만 서로 다른 두 가지 성질을 다룬다.

- 바꿀 수 있는가 (불변성)
- 언제 정해지는가 (결정 시점)

const는 불변성을 보장하고, constinit은 결정 시점을 보장한다. constexpr은 둘 다 보장한다. consteval은 변수가 아니라 함수 호출이
언제 계산되는지를 정한다.

| 키워드      | 붙는 대상          | 바꿀 수 있는가 | 언제 정해지는가                                 | 도입  |
|-------------|--------------------|----------------|-------------------------------------------------|-------|
| `const`     | 변수, 멤버 함수 등 | 없음           | 보장 안 함 (컴파일 타임일 수도, 실행 중일 수도) | C++98 |
| `constexpr` | 변수               | 없음           | 컴파일 타임 (보장)                              | C++11 |
| `constexpr` | 함수               | -              | 컴파일 타임에 계산될 수도 있음                  | C++11 |
| `consteval` | 함수               | -              | 호출이 반드시 컴파일 타임에 계산됨              | C++20 |
| `constinit` | 정적 변수          | 있음           | 프로그램 시작 전 (보장)                         | C++20 |

```c++
int runtimeValue();
consteval int square(int x) { return x * x; }

const int a = 10;              // 바꿀 수 없음. 값은 컴파일 타임에 정해짐
const int b = runtimeValue();  // 바꿀 수 없음. 값은 실행 중에 정해짐
constexpr int c = 10;          // 바꿀 수 없음. 컴파일 타임에 정해지지 않으면 컴파일 에러
constexpr int d = square(4);   // square 호출은 반드시 컴파일 타임에 계산됨 (16)
constinit int e = 10;          // 프로그램 시작 전에 정해짐. 이후 e = 20; 가능
```

- 여기서 보면 a와 b는 둘 다 `const`인데 정해지는 시점이 다르다. `const`는 시점을 보장하지 않는다.
- c는 컴파일 타임에 정해지지 않으면 컴파일 에러가 난다.
- square는 `consteval`이라서 실행중에 호출하는 코드를 쓰면 컴파일 에러가 난다.
- e는 시작 전에 값이 정해지지만 `const`가 아니라서 나중에 바꿀 수 있다. 키워드 이름에 `const`가 들어가 있지만 불변성과는 
  관계가 없다.

<br/>

왜 시점이 중요하냐면,

- 컴파일 타임 값이 필요한 자리(배열 크기, 템플릿 인자, case 레이블, static_assert 등)에는 컴파일 타임에 정해진 값만 
  받는다. b 같은 값은 넣을 수 없다.
- 실행 비용이 안든다. 컴파일 타임에 계산된 값은 실행 중에 계산하지 않는다. 게임에서 문자열 에셋 ID를 해시로 바꾸는 
  작업을을 빌드 때 끝내두는 경우가 예시이다.
- 초기화 순서 문제를 피할 수 있다. 서로 다른 소스 파일의 전역 변수끼리는 동적 초기화 순서가 정해져 있지 않다. 한 전역 
  변수수가 아직 초기화되지 않은 다른 전역 변수를 읽는 버그가 생길 수 있다. 정적 초기화로 끝나는 변수는 이 문제에서 
  벗어나고, `constinit`이 그걸 보장한다.

<br/>

정리하자면, const는 바꿀 수 없다는 약속일 뿐, 언제 정해지는지는 말하지 않는다. `constexpr`, `consteval`, `constinit`은
각각 변수의 값, 함수 호출, 정적 변수의 초기화가 언제 일어나는지를 보장하려고 추가되었다.

<br/>

### const

---

`const`는 **타입에 붙어 수정할 수 없음을 나타내는 한정자(cv-qualifier)**이다. const 타입으로 접근하는 객체는 수정할 수
없고, 수정하려는 코드는 컴파일 에러가 난다. 값이 언제 정해지는지는 정하지 않는다.

- 변수 : 선언 이후 값을 바꿀 수 없다.
- 참조, 포인터 : 그 경로로는 대상을 바꿀 수 없다.
- 멤버 함수 : 함수 안에서 객체(this)를 수정할 수 없다.

```c++
const int hp = 100;
hp = 50; // 에러
```

여기서 주의할 점이 두 가지 있다.

객체 자체가 `const`인 경우엔 해당 객체를 `const_cast`로 억지로 바꾸면 정의되지 않은 동작이다. 컴파일러는 이런 객체를 
읽기 전용 메모리에 두거나, 값을 상수로 바꿔 넣는 최적화를 할 수 있다.

```c++
const int x = 10;
int* p = const_cast<int*>(&x);
*p = 20; // 정의되지 않은 동작
``` 

const 참조나 const 포인터는 이 경로로는 바꿀 수 없다는 뜻일 뿐, 대상이 안 바뀐다는 보장은 아니다.

```c++
int v = 10;
const int& r = v;
v = 20; // r로는 값을 바꿀 수 없지만, r이 보는 값은 20이 된다
```

<br/>

const는 언제 값이 정해지는지에 대한 보장은 하지 않는다.

```c++
int runtimeValue();

const int n = 10;              // 컴파일 타임에 정해짐
const int m = runtimeValue();  // 실행 중에 정해짐
```

둘 다 `const`이고 둘 다 바꿀 수 없다. 하지만 n은 컴파일러가 값을 알고, m은 실행해 봐야 안다. 선언만 봐서는 구분이 안 
되고, 초기화 식에 따라 달라진다.

<br/>

이렇게 언제 정해지는지 차이가 중요한 이유는 C++에 컴파일 타임에 값을 알아야만 쓸 수 있는 자리가 있기 때문이다.

- 배열 크기 : `int arr[N];`
- 템플릿 인자 : `std::array<int, N>`
- case 레이블 : `case N:`
- `static_assert(조건)`
- 열거자 값, 비트 필드 폭, `alignas`

이런 자리에 쓸 수 있는 식(컴파일 타임에 값을 계산할 수 있는 식)을 **상수 표현식(constant expression)**이라고 한다. 10, 
3 + 4 같은 리터럴 연산은 상수 표현식이고 runtimeValue()는 아니다.

```c++
std::array<int, n> a1; // 된다
std::array<int, m> a2; // 컴파일 에러
```

<br/>

n처럼 const 변수를 상수 표현식에 쓸 수 있는건 표준이 정한 특별한 규칙 때문이다. 조건은 두 가지다.
1. 타입이 정수나 열거형이다.
2. 상수 표현식으로 초기화되었다.

```c++
const int n  = 10;              // 조건 충족 → 상수 표현식에 쓸 수 있다
const int m  = runtimeValue();  // 2번 불충족 → 쓸 수 없다
const double pi = 3.14;         // 1번 불충족 → 쓸 수 없다

static_assert(n == 10);    // 된다
static_assert(pi > 3.0);   // 표준상 에러
```

pi는 GCC/Clang에서는 컴파일 에러인데 MSVC는 통과된다. 표준상으로는 에러가 맞다고 한다. MSVC는 조금 더 너그러운가 보다.
이러한 경우로 윈도우 빌드(MSVC)로는 잘 빌드되던 코드가 Clang(콘솔, 안드로이드 등)에서 빌드가 깨진다면, 컴파일 타임 
상수가 필요하므로 `constexpr`을 써야 한다.

어쨌든 const로 컴파일 타임 상수를 만들 때는 이렇게 문제가 발생할 수 있다.
- 의도를 표현할 수 없다. `const int m = runtimeValue();`라고 써도 에러가 나지 않는다. 컴파일 타임 상수를 의도했는데 
  실수로 실행 중에 정해지는 값을 넣어도, 그 변수를 상수 표현식에 쓰는 곳에 가서야 에러가 난다.
- 정수와 열거형만 된다. (표준 기준)
- 함수로 계산한 값은 컴파일 타임 상수가 될 수 없다. `const int size = calcSize(4);`는 컴파일 되지만, size는 실행 중에
  정해지는 값이라 배열 크기나 템플릿 인자에 쓸 수 없다.

```c++
const int size = calcSize(4);
int arr[size];
```

위 코드도 MSVC에서는 컴파일 에러지만, GCC와 Clang에서는 컴파일된다. size가 컴파일 타임 상수라서가 아니라, 두 컴파일러가
표준에 없는 확장 기능으로 허용하기 때문이라고 한다.

정리하자면 const는 바꿀 수 없다는 약속이고, 언제 정해지는지는 초기화 식에 달려 있다. const 변수는 정수나 열거형이면서
상수 표현식으로 초기화된 경우에만 컴파일 타임 상수로 쓸 수 있다.

<br/>

### constexpr (C++11)

---

`constexpr`은 **변수나 함수를 상수 표현식에서 쓸 수 있다고 선언하는 지정자(specifier)**이다. 즉 그 값이나 호출 결과를 
컴파일 타임에 계산할 수 있다고 선언한다. 변수에 붙을 때와 함수에 붙을 때 보장하는 내용이 다르다.

변수에 붙으면 `const`이면서 반드시 상수 표현식으로 초기화되어야 한다. 값이 컴파일 타임에 정해진다는 것이 보장된다.

함수에 붙으면 상수 표현식 안에서 호출될 수 있다. 컴파일 타임에 계산될 수도 있고, 실행 중에 계산될 수도 있다.

<br/>

`constexpr` 변수는 컴파일 타임 값을 보장한다. `const`이면서 반드시 상수 표현식으로 초기화되어야 한다. 그렇지 않으면
컴파일 에러가 난다.

```c++
int runtimeValue();

constexpr int a  = 10;              // 된다
constexpr double pi = 3.14;         // 된다. const와 달리 정수가 아니어도 된다
constexpr int b  = runtimeValue();  // 에러. runtimeValue()는 constexpr 함수가 아니다

static_assert(pi > 3.0);            // 된다
```

const 절 마지막에서 말한 세 가지 문제 중 두 가지가 여기서 해결된다.

- 의도를 표현할 수 없다 -> `constexpr`을 쓰면 컴파일 타임 상수라는 의도가 선언에 드러나고, 지키지 않으면 선언에서 에러가 
  난다. 
- 정수와 열거형만 된다 -> double도, 조건을 만족하는 사용자 정의 타입(리터럴 타입)도 된다. const double에서 MSVC와 GCC, 
  Clang의 결과가 갈리던 문제도 사라진다.

```c++
struct Vec2 { float x, y; };
constexpr Vec2 up{ 0.0f, 1.0f };   // 사용자 정의 타입도 컴파일 타임 상수가 된다
```

<br/>

constexpr 함수는 컴파일 타임에 계산될 **"수도"** 있다. **남은 문제는 함수로 계산한 값은 컴파일 타임에 상수가 될 수 
없다**였다. `constexpr` 함수는 상수 표현식 안에서 호출할 수 있는 함수, 즉 컴파일 타임에 실행할 수 있는 함수이다.

```c++
constexpr int calcSize(int n) { return n * n; }

constexpr int s = calcSize(4);      // 컴파일 타임에 계산 (16)
std::array<int, calcSize(3)> arr;   // 컴파일 타임에 계산 (9)

int input = runtimeValue();
int r = calcSize(input);            // 실행 중에 계산. 에러가 아니다
```

여기서 핵심은 "될 수도 있다"이다. 인자가 상수 표현식이고 컴파일 타임 값이 필요한 자리(constexpr 변수 초기화 등)에서
호출하면 컴파일 타임에 계산된다. 하지만 인자가 실행 중에 정해지는 값이면 일반 함수처럼 실행 중에 계산된다. 같은 함수를
두 용도로 쓸 수 있다는 게 장점이다. `int x = calcSize(4);`처럼 인자는 상수지만 결과를 일반 변수에 받으면, 컴파일 타임에
계산된다는 보장이 없다. 최적화로 컴파일 타임에 계산될 수는 있지만 컴파일러의 선택이다.

즉, `constexpr` 함수는 컴파일 타임에 계산할 수 있다는 자격을 줄뿐, 실제로 언제 계산할지는 호출하는 자리가 정한다.

게임에서 문자열 ID 해시를 예시로 보면,

```c++
constexpr std::uint32_t HashString(std::string_view str)
{
    std::uint32_t hash = 2166136261u;
    for (char c : str)
    {
        hash ^= static_cast<unsigned char>(c);
        hash *= 16777619u;
    }
    return hash;
}

constexpr std::uint32_t playerId = HashString("Player");   // 빌드할 때 계산됨
std::uint32_t id = HashString(name);                       // 실행 중에 받은 문자열은 실행 중에 계산됨
```

에셋 이름처럼 미리 아는 문자열은 빌드 때 해시로 바꾸고, 실행 중에 들어오는 문자열은 같은 함수로 실행 중에 계산한다.

`constexpr`은 C++ 버전마다 변화가 많은데, 표로 정리하면 다음과 같다.

| 버전  | 주요 변화                                                                                               |
|-------|---------------------------------------------------------------------------------------------------------|
| C++11 | 도입. 함수 본문은 사실상 `return` 문 하나                                                               |
| C++14 | 지역 변수, `if`, 반복문 사용 가능. 멤버 함수가 더 이상 자동으로 `const`가 아님                          |
| C++17 | 람다가 조건을 만족하면 자동으로 `constexpr`                                                             |
| C++20 | 가상 함수, `try` 블록, `new`/`delete`(계산 안에서 해제해야 함), `std::vector`와 `std::string` 사용 가능 |
| C++23 | 함수 안에 `static constexpr` 변수, 리터럴 타입이 아닌 변수, `goto`와 레이블 사용 가능                   |

C++14의 멤버 함수 변화는 앞에서 말한 "`constexpr`과 `const`는 다른 질문에 답한다"를 보여준다.

```c++
struct Counter
{
    int n = 0;
    constexpr void Increase() { ++n; }        // 객체를 수정하는 constexpr 함수
    constexpr int Get() const { return n; }   // 수정하지 않으려면 const를 따로 붙인다
};
```

`constexpr` 함수는 "컴파일 타임에 계산될 수도 있다"라서, 반드시 컴파일 타임에 계산되어야 하는 함수는 만들 수 없다. 이
문제를 해결하는 것이 `consteval`이다.

정리하자면, `constexpr`은 변수나 함수를 상수 표현식에서 쓸 수 있다고 선언하는 지정자다. 변수는 컴파일 타임에 정해진다는 
것이 선언에서 보장되고, 정수가 아닌 타입에도 쓸 수 있다. 함수는 컴파일 타임에 계산될 수 있는 자격을 얻을 뿐, 실제로
언제 계산되는지는 호출하는 자리가 정한다.

<br/>

### consteval (C++20)

---

`consteval`은 **함수를 즉시 함수(immediate function)로 선언하는 지정자**이다. 즉시 함수는 모든 호출이 상수 표현식이어야 
한다. 즉 호출이 반드시 컴파일 타임에 계산되고, 컴파일 타임에 계산할 수 없는 호출은 컴파일 에러가 난다. `constexpr`과 
달리 함수에만 붙고 변수에는 붙지 않는다.

<br/>

constexpr 함수와의 차이를 보면,

```c++
consteval int square(int x) { return x * x; }

constexpr int a = square(4);   // 된다. 컴파일 타임에 계산
int b = square(4);             // 된다. 일반 변수에 받아도 컴파일 타임에 계산된다

int n = runtimeValue();
int c = square(n);             // 에러. n은 상수 표현식이 아니다
```

`constexpr` 함수의 호출은 컴파일 타임에 계산될 수도 있지만, `consteval` 함수의 호출은 반드시 컴파일 타임에 계산된다.

- b처럼 결과를 일반 변수에 받아도 컴파일 타임 계산이 보장된다. 같은 코드를 `constexpr` 함수로 썼다면 보장이 없다.
- c처럼 실행 중에 정해지는 값을 넘기면 컴파일 에러다. `constexpr` 함수라면 조용히 실행 중 계산으로 넘어갔을 거다.

|                         | `constexpr` 함수                  | `consteval` 함수           |
|-------------------------|-----------------------------------|----------------------------|
| 컴파일 타임 계산        | 호출하는 자리에 따라 될 수도 있음 | 항상                       |
| 실행 중에 정해지는 인자 | 받을 수 있음 (실행 중에 계산)     | 받을 수 없음 (컴파일 에러) |
| 함수 포인터로 받기      | 가능                              | 불가 (`&square`는 에러)    |

함수 포인터를 받을 수 없는 것도 같은 이유다. 포인터로 받으면 나중에 실행 중에 호출될 수 있기 때문이다.

`constexpr` 변수로 받으면 `constexpr` 함수로도 컴파일 타임 계산이 보장된다. `consteval`이 필요한 건 그렇게 받을 수 없는
자리(함수 인자 등)이거나 빌드 때 입력을 검사해서 잘못된 사용을 컴파일 에러로 만들고 싶을 때다(`std::format`의 포맷 
문자열 검사 등)

<br/>

만약 하나의 `constexpr` 함수 안에서 지금 컴파일 타임에 계산되는 중인지에 따라 구현을 나누고 싶을 때가 있다.
`if consteval`(C++23)은 그 분기를 만들어 준다.

```c++
constexpr double Power(double base, int exp)
{
    if consteval
    {
        // 컴파일 타임: 직접 계산
        double result = 1.0;
        for (int i = 0; i < exp; ++i)
            result *= base;
        return result;
    }
    else
    {
        // 실행 중: 표준 라이브러리 사용
        return std::pow(base, exp);
    }
}

static_assert(Power(2.0, 10) == 1024.0);    // 컴파일 타임 분기 사용
double p = Power(2.0, runtimeValue());      // 실행 중 분기 사용
```

`std::pow`는 C++23까지 `constexpr` 함수가 아니라서 컴파일 타임에 부를 수 없다. 그래서 컴파일 타임에는 직접 계산하고, 
실행 중에는 최적화된 라이브러리 함수를 쓴다. `if consteval`의 컴파일 타임 분기 안에서는 `consteval` 함수도 호출할 수 
있다.

C++20에도 같은 판별을 하는 `std::is_constant_evaluated()`가 있다. 하지만 그 if 분기 안에서는 `consteval` 함수를 호출할
수 없어서, C++23에서 `if consteval`이 문법으로 추가되었다. 중괄호 { }는 생략할 수 없다.

<br/>

정리하자면, `consteval` 함수를 즉시 함수로 선언하는 지정자로, 모든 호출이 컴파일 타임에 계산되어야 한다. `constexpr`
함수의 "될 수도 있다"를 "반드시"로 바꾸며, 실행 중에 정해지는 인자로 호출하면 컴파일 에러가 난다. 하나의 함수 안에서
컴파일 타임과 실행 중의 구현을 나누려면 C++23의 `if consteval`을 쓴다.

<br/>

### constinit (C++20)

---

`constinit`은 **정적 또는 스레드 저장 기간을 가진 변수가 상수 초기화(constant initialization)된다는 것을 보장하는 
지정자**이다. 상수 초기화란 초기값을 컴파일 타임에 계산해서 실행 파일에 미리 기록해 두는 초기화다. 상수 초기화가 
불가능하면 컴파일 에러가 난다. 이름에 `const`가 들어 있지만 `const`를 뜻하지 않으며, 값은 이후에 바꿀 수 있다.

<br/>

배경을 이해하기 위해 정적 초기화와 동적 초기화를 다시 짚고가자. 전역 변수, static 변수, thread_local 변수처럼 프로그램 
내내 사는 변수는 두 단계로 초기화된다.

- 정적 초기화 : 초기값을 컴파일 타임에 알 수 있으면 실행 파일에 미리 기록해 둔다. 프로그램이 메모리에 올라오는 순간 이미
  값이 들어 있고, 초기화 코드는 실행되지 않는다. 상수 초기화와, 초기값이 없을 때의 0 초기화가 여기에 해당한다.
- 동적 초기화 : 함수 호출 결과처럼 실행해 봐야 아는 값은 초기화 코드가 실제로 실행된다. 전역 변수는 main 전에, 함수 안의
  static 변수는 그 선언에 처음 도달할 때 실행된다. 그 전까지 변수는 0으로 초기화된 상태이다.

문제는 초기화 순서이다. 같은 소스 파일 안의 전역 변수는 선언 순서대로 동적 초기화된다. 하지만 서로 다른 소스 파일의 
전역 변수끼리는 동적 초기화 순서가 정해져 있지 않다.

```c++
// Config.cpp
int LoadMaxPlayers();                 // 설정 파일을 읽는 함수
int gMaxPlayers = LoadMaxPlayers();   // 동적 초기화

// Server.cpp
extern int gMaxPlayers;
int gSlots = gMaxPlayers * 2;         // 동적 초기화. gMaxPlayers가 아직 0일 수 있다
```

`Server.cpp`의 초기화가 먼저 실행되면 `gSlots`는 아직 0인 `gMaxPlayers`를 읽어서 0이 된다. 빌드할 때마다, 링크 순서에
따라 결과가 달라질 수 있어 찾기 어려운 버그이다. 이를 흔히 정적 초기화 순서 문제(static initialization order fiasco)라고
부른다.

정적 초기화는 모든 동적 초기화보다 먼저 끝난다. 그래서 상수 초기화되는 변수는 다른 파일의 초기화 코드가 언제 읽어도 이미
올바른 값을 가지고 있다. 문제는 C++20 전에는 변수가 상수 초기화되는지 확인할 방법이 없었다는 점이다. 누군가 초기값을
함수 호출로 바꾸면 조용히 동적 초기화로 바뀌고, 순서 문제가 다시 생긴다.

<br/>

그래서 `constinit`으로 보장한다.

```c++
constinit int gMaxPlayers = 64;         // 상수 초기화 보장
constinit int gBad = LoadMaxPlayers();  // 에러. 상수 초기화가 아니다

gMaxPlayers = 100;                      // 된다. const가 아니므로 바꿀 수 있다
```

`constinit`으로 선언된 변수는 초기 값이 상수 표현식이 아니면 선언에서는 바로 컴파일 에러가 난다. 나중에 누가 초기값을
바꿔도 동적 초기화로 조용히 바뀌지 않는다. `constinit`은 정적/스레드 저장 기간 변수에만 붙는다. 일반 지역 변수에 붙이면
에러이고, 함수 안에서는 `static constinit int calls = 0;`처럼 쓴다.

<br/>

게임 코드에서는 전역 상태를 다른 전역 객체의 생성자가 읽는 경우가 많다. 예를 들어 로그용 전역 뮤텍스는 다른 전역 객체가
생성자에서 로그를 남길 때 이미 준비되어 있어야 한다. `std::mutex`는 `constexpr` 생성자를 가지고 있어 상수 초기화가 
가능하다.

```c++
constinit std::mutex gLogMutex; // 어떤 전역 객체의 생성자보다 먼저 준비된다.
```

<br/>

`constexpr` 변수와 `constinit` 변수는 둘 다 초기값이 컴파일 타임에 정해지지만, 이후의 성질이 다르다.

|                      | `constexpr` 변수                | `constinit` 변수                   |
|----------------------|---------------------------------|------------------------------------|
| 초기값               | 컴파일 타임에 정해짐            | 컴파일 타임에 정해짐 (상수 초기화) |
| 이후 값 변경         | 불가 (`const`)                  | 가능                               |
| 붙는 대상            | 매개변수, 비정적 멤버를 뺀 변수 | 정적/스레드 저장 기간 변수만       |
| 상수 표현식에서 사용 | 가능                            | 불가                               |

`constinit` 변수는 상수 표현식에서 사용 불가능하다는게 중요하다. 나중에 값이 바뀔 수 있기 때문에, 초기값이 컴파일 타임에
정해졌어도 상수 표현식에서 쓸 수 없다.

```c++
constinit int gOk = 10;
static_assert(gOk == 10);   // 에러. gOk는 실행 중에 바뀔 수 있다
```

바꿀 필요가 없는 상수는 `constexpr`, 실행 중에 바뀌어야 하지만 시작 시점의 값은 보장되어야 하는 전역 상태는 
`constinit`을 쓴다.

<br/>

정리하자면, `constinit`은 정적 또는 스레드 저장 기간 변수가 상수 초기화된다는 것을 보장하는 지정자다. 초기값이 프로그램
시작 전에 정해져서 정적 초기화 순서 문제를 피할 수 있고, `const`가 아니므로 값은 이후에 바꿀 수 있다.


<br/>

### 정리

---

| 키워드           | 붙는 대상                       | 보장하는 것                        | 값 변경 | 상수 표현식에 사용                     | 도입  |
|------------------|---------------------------------|------------------------------------|---------|----------------------------------------|-------|
| `const`          | 변수, 멤버 함수 등              | 바꿀 수 없음                       | 불가    | 정수/열거형이고 상수로 초기화된 경우만 | C++98 |
| `constexpr` 변수 | 매개변수, 비정적 멤버를 뺀 변수 | 컴파일 타임에 값이 정해짐          | 불가    | 가능                                   | C++11 |
| `constexpr` 함수 | 함수                            | 컴파일 타임에 계산될 수 있음       | -       | 가능                                   | C++11 |
| `consteval`      | 함수                            | 호출이 반드시 컴파일 타임에 계산됨 | -       | 가능                                   | C++20 |
| `constinit`      | 정적/스레드 저장 기간 변수      | 프로그램 시작 전에 초기화됨        | 가능    | 불가                                   | C++20 |

- `const`: 바꿀 수 없다는 약속이다. 언제 정해지는지는 초기화 식에 달려 있다.
- `constexpr`: 변수는 컴파일 타임에 값이 정해지고, 함수는 컴파일 타임에 계산될 수 있다. 실제로 언제 계산할지는 호출하는
  자리가 정한다.
- `consteval`: 함수 호출이 반드시 컴파일 타임에 계산된다. 실행 중에 정해지는 값으로 호출하면 컴파일 에러다.
- `constinit`: 정적 변수가 프로그램 시작 전에 초기화된다. 값은 이후에 바꿀 수 있다.


고르는 기준

| 상황                                                          | 쓸 것            |
|---------------------------------------------------------------|------------------|
| 바뀌지 않는 상수                                              | `constexpr`      |
| 바뀌지 않지만 실행 중에 정해지는 값                           | `const`          |
| 실행 중에 바뀌지만 시작 시점의 값이 보장되어야 하는 전역 상태 | `constinit`      |
| 컴파일 타임에도, 실행 중에도 쓰는 함수                        | `constexpr` 함수 |
| 반드시 컴파일 타임에만 계산되어야 하는 함수                   | `consteval` 함수 |

<br/>

_참고_
- [cppreference - constexpr specifier](https://en.cppreference.com/w/cpp/language/constexpr)
- [cppreference - consteval specifier](https://en.cppreference.com/w/cpp/language/consteval)
- [cppreference - constinit specifier](https://en.cppreference.com/w/cpp/language/constinit)
- [cppreference - Constant expressions](https://en.cppreference.com/w/cpp/language/constant_expression)
- [cppreference - Initialization](https://en.cppreference.com/w/cpp/language/initialization)
- [cppreference - Named requirements: LiteralType](https://en.cppreference.com/w/cpp/named_req/LiteralType)
- [cppreference - if statement (if consteval)](https://en.cppreference.com/w/cpp/language/if)
- [cppreference - std::is_constant_evaluated](https://en.cppreference.com/w/cpp/types/is_constant_evaluated)
- [cppreference - Static initialization order fiasco](https://en.cppreference.com/w/cpp/language/siof)
