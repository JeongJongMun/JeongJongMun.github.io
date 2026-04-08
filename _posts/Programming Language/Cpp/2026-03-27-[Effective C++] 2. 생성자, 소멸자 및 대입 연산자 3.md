---
title: "[Effective C++] 2. 생성자, 소멸자 및 대입 연산자 [3/4]"
writer: Langerak
date: 2026-03-23 12:00:00 +0800
categories: [Programming Language]
tags: [Programming Language]
pin: false
math: true
mermaid: true
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

### 항목 9 : 객체 생성 및 소멸 과정 중에는 절대로 가상 함수를 호출하지 말자

---

이유를 미리 알려주자면 호출 결과가 우리가 원하는 대로 돌아가지 않을 것이다.
자바나 C#을 하다가 C++을 공부하고 있는 입장이라면 이번 항목을 열심히 읽어보자.

주식 거래를 본떠 만든 클래스 계통이 있다고 가정하자.
이를테면 매도 주문, 매수 주문 등등이 있을 것이다.
이러한 거래를 모델링하는 데 있어서 중요한 포인트라면 감사(audit) 기능이 있어야 한다는 점이다.
그렇기 때문에 주식 거래 객체가 생성될 때마다 감사 로그(audit log)에 적절한 거래 내역이 만들어지도록 해야 한다.
결국, 다음과 같은 클래스 정도가 나와 주는 게 맞을 것 같다.

```cpp
class Transaction 
{
public:
    Transaction();
    virtual void logTransaction() const = 0;
    ...
};

Transaction::Transaction() 
{
    ...
    logTransaction();
}

class BuyTransaction : public Transaction
{
public:
    virtual void logTransaction() const;
    ...
};

class SellTransaction : public Transaction
{
public:
    virtual void logTransaction() const;
};

```

이제 아래의 코드가 실행될 때 어떻게 되는지 생각해 보자.

```cpp
BuyTransaction b;
```

BuyTransaction 생성자가 호출되는 것은 어쨌든 맞다.
그러나 우선은 Transaction 생성자가 호출되어야 한다.
파생 클래스 객체가 생성될 때 그 객체의 기본 클래스 부분이 파생 클래스 부분보다 먼저 호출되는 것이 정석이니까 말이다.
Transaction 생성자의 마지막 줄을 힐끗 보면 가상 함수인 logTransaction을 호출하는 문장이 보이는데,
당혹스러운 부분이다.
여기서 호출되는 logTransaction 함수는 BuyTransaction의 것이 아니라 Transaction의 것이란 사실이다.
지금 생성되는 객체의 타입이 BuyTransaction인데 말이다.
잘 새겨두자.
기본 클래스의 생성자가 호출될 동안에는, 가상 함수는 절대로 파생 클래스 쪽으로 내려가지 않는다.
그 대신, 객체 자신이 기본 클래스 타입인 것처럼 동작한다.
기본 클래스 생성 과정에서는 가상 함수가 먹히지 않는다.

그냥 생각하기에도 그다지 직관적이지 않긴 하다.
이 같은 동작에는 다 이유가 있다.
알다시피 기본 클래스 생성자는 파생 클래스 생성자보다 앞서서 실행되기 때문에,
기본 클래스 생성자가 돌아가고 있을 시점에는 파생 클래스 데이터 멤버는 아직 초기화된 상태가 아니라는 것이 핵심이다.
이때 기본 클래스 생성자에서 어쩌다 호출된 가상 함수가 파생 클래스 쪽으로 내려간다면 어떻게 될까?
파생 클래스 버전의 가상 함수는 파생 클래스만의 데이터 멤버를 건드릴 것이 뻔한데,
방금 말했듯이 이들은 아직 초기화되지 않았다.
어떤 객체의 초기화되지 않은 영역을 건드린다는 것은 치명적인 위험을 내포하기 떄문에,
C++는 우리가 이런 실수를 하지 못하도록 막은 것이다.

지금 한 이야기보다 더 중요한 이야기가 있다.
파생 클래스 객체의 기본 클래스 부분이 생성되는 동안은,
그 객체의 타입은 바로 기본 클래스이다.
호출되는 가상 함수는 모두 기본 클래스의 것으로 결정될 뿐만 아니라,
런타임 타입 정보를 사용하는 언어 요소(dynamic_cast나 typeid 같은 것)를 사용한다고 해도
이 순간엔 모두 기본 클래스 타입의 객채로 취급한다.

위의 예제를 가지고 설명해 보자.
BuyTransaction 객체의 기본 클래스 부분을 초기화하기 위해 Transaction 생성자가 실행되고 있는 동안에는,
그 객체의 타입이 Transaction이라는 이야기이다.
이런 식의 처리는 C++ 언어의 다른 모든 기능에서 이루어지고 있고, 타당성도 아주 충분하다.
BuyTransaction 클래스만의 데이터는 아직 초기화된 상태가 아니기 때문에,
아예 없었던 것처럼 취급하는 편이 가장 안전하다.
그러니까, 파생 클래스의 생성자의 실행이 시작되어야만 그 객체가 비로소 파생 클래스 객체의 면모를 갖게 된다.

소멸자가 호출되어 객체가 소멸될 때는 어떻게 될까?
똑같이 생각하면 된다.
파생 클래스의 소멸자가 일단 호출되고 나면 파생 클래스만의 데이터 멤버는 정의되지 않은 값으로 가정하기 때문에,
이제부터 C++는 이들을 없는 것처럼 취급하고 진행한다.
기본 클래스 소멸자에 진입할 당시의 객체는 기본 클래스 객체가 되며,
모든 C++ 기능들 역시 기본 클래스 객체의 자격으로 처리한다.

위의 예제 코드를 다시 보자.
Transaction 생성자에서 가상 함수를 직접 호출하는 코드가 있었다.
이번 항목의 지침을 위반한 것이다.
이런 위반은 누가 보더라도 발견이 쉽기 때문에, 이런 경우에 대해 경고 메세지를 내어 주는 컴파일러도 꽤 있다.
컴파일러 경고가 나오지 않더라도 프로그램 실행 전에 문제가 드러날 수도 있다.
logTransaction 함수가 Transaction 클래스에서 순수 가상 함수로 선언되어 있기 때문이다.
이 함수의 정의가 존재하지 않으면 링크 단게에서 에러가 생긴다.
링크가 제대로 되려면 Transaction::logTransaction의 구현 코드를 찾아야 하는데, 찾아질 리가 없기 때문이다.

생성자 혹은 소멸자 안에서 가상 함수가 호출되는지를 잡아내는 일이 항상 쉬운 것은 아니다.
Transaction의 생성자가 여러 개 된다고 가정해 보자.
각 생성자에서 하는 일이 조금씩은 다르겠지만 몇 가지 작업은 똑같을 것이다.
똑같은 작업을 모아 공동의 초기화 코드로 만들어 두면 코드 판박이 현상을 막을 수 있을 것이다.
대개 이런 설계로 private 멤버인 비가상 초기화 함수가 만들어지는데, 이 함수 안에서 logTransaction을 호출한다고 가정해 보자.

```cpp
class Transaction
{
public:
    Transaction()
    { init(); }
    virtual void logTransaction() const = 0;
    ...
private:
    void init()
    {
        logTransaction(); // 비가상 함수에서 가상 함수를 호출하고 있다.
    };
};
```

이 코드는 앞의 코드와 비교해서 볼 때 개념적으로는 똑같은 코드이지만, 더 위험한 코드이다.
왜냐하면 앞의 코드와 달리 컴파일도 잘 되고 링크도 말끔하게 되기 떄문이다.
이 코드가 실행된다고 생각해 보자.
logTransaction은 Transaction 클래스 안에서 순수 가상 함수이기 때문에,
고맙게도 대부분의 시스템은 순수 가상 함수가 호출될 때 프로그램을 바로 끝내버린다.

logTransaction 함수가 순수 가상이 아닌 보통 가상 함수이며 Transaction의 멤버 버전이 구현되어 있을 경우엔 머리가 아프다.
앞에서 말한대로 Transaction의 버전이 호출될 것이고, 프로그램은 돌아갈 것이다.
하지만 파생 클래스 객체가 생성되는데 호출되는 logTransaction 함수는 Transaction의 버전이 될 것이다.
이런 문제를 피하는 방법은 다른게 없다.
생성 중이거나 소멸 중인 객체에 대해 생성자나 소멸자에서 가상 함수를 호출하는 다른 코드를 철저히 솎아내고,
생성자와 소멸자가 호출하는 모든 함수들이 똑같은 제약을 따르도록 만드는 일 이외엔 말이다.

그러나 Transaction 클래스 계통에 속해 있는 많고 많은 클래스 중 하나로 만들어진 객체가 생성될 때마다 
logTransaction 가상 함수의 호출이 제대로 이루어지도록 맞추는 일도 결고 만만한 일이 아니다.
어쨌든 Transaction 생성자에서 가상 함수를 호출하는 것은 이런 바람직한 일과 확실히 거리가 멀다.

이 문제의 대처 방법에 대해 이야기 해보자.
방법은 여러 가지이지만 한 가지만 소개하자.
logTransaction을 Transaction 클래스의 비가상 멤버 함수로 바꾸는 것이다.
그리고 나서 파생 클래스의 생성자들로 하여금 필요한 로그 정보를 Transaction의 생성자로 넘겨야 한다는 규칙을 만든다.
logTransaction이 비가상 함수이기 때문에 Transaction의 생성자는 이 함수를 안전하게 호출할 수 있다.

```c++
class Transaction
{
public:
    explicit Transaction(const std::string& logInfo);
    void logTransaction(const std::string& logInfo) const;
    ...
};

Transaction::Transaction(const std::string& logInfo)
{
    ...
    logTransaction(logInfo);
}

class BuyTransaction : public Transaction
{
public:
    BuyTransaction( parameters )
    : Transaction(createLogString(parameters)) { ... }
    ...
private:
    static std::string createLogString( parameters );
    
};
```

기본 클래스 부분이 생성될 때는 가상 함수를 호출한다 해도 기본 클래스의 울타리를 넘어 내려갈 수 없기 때문에,
필요한 초기화 정보를 파생 클래스쪽에서 기본 클래스 생성자로 올려주도록 만듦으로써 부족한 부분을 역으로 채울 수 있다.

> 생성자 혹은 소멸자 안에서 가상 함수를 호출하지 말자.
> 가상 함수라고 해도, 지금 실행 중인 생성자나 소멸자에 해당되는 클래스의 파생 클래스 쪽으로는 내려가지 않는다.

<br/>

### 항목 10 : 대입 연산자는 *this의 참조자를 반환하게 하자

---

C++의 대입 연산은 여러 개가 사슬처럼 엮일 수 있는 재미있는 성질을 갖고 있다.

```cpp
int x, y, z;
x = y = z = 15;
```

대입 연산이 가진 또 하나의 재미있는 특성은 바로 우측 연관(right-associative) 연산이라는 점이다.
즉, 위의 대입 연산 사슬은 다음과 같이 분석된다.

```cpp
x = (y = (z = 15));
```

위의 코드를 풀어보면, 15가 z에 대입되고, 그 대입 연산의 결과가 y에 대입된 후에, y에 대한 대입 연산의 결과가 x에 대입되는 것이다.
이렇게 대입 연산이 사슬처럼 엮이려면 대입 연산자가 좌변 인자에 대한 참조자를 반환하도록 구현되어 있을 것이다.
이런 구현은 일종의 관례인데, 우리도 나름대로 만드는 클래스에 대입 연산자가 혹시 들어간다면 이 관례를 따르는 것이 좋다.

```c++
class Widget
{
public:
    // 반환 타입은 현재 클래스에 대한 참조자
    Widget& operator=(const Widget& rhs)
    {
        ...
        // 좌변 객체의 참조자를 반환한다.
        return *this;
    }
};
```

"좌변 객체의 참조자를 반환하게 만들자"라는 규약은 위에서 본 단순 대입형 연산자 말고도 모든 형태의 대입 연산자에서 지켜져야 한다.
다시 아래 코드를 보자.

```c++
class Widget
{
public:
    // +=, -=. *= 등에도 동일한 규약이 적용된다.
    Widget& operator+=(const Widget& rhs)
    {
        ...
        return *this;
    }
    
    // 대입 연산자의 매개변수 타입이 일반적이지 않은 경우에도 동일한 규약을 적용한다.
    Widget& operator=(int rhs)
    {
        ...
        return *this;
    }
    ...
};
```

이것은 관례이기에 따르지 않고 코드를 작성하더라도 컴파일이 안되거나 하지는 않는다.
하지만 이 관례는 모든 기본제공 타입들이 따르고 있을 뿐만 아니라 표준 라이브러리에 속한 모든 타입에서도 따르고 있다는 점은 무시 못한다.

> 대입 연산자는 *this의 참조자를 반환하도록 만들자

<br/>

_참고_
- [Effective C++ 제3판](https://www.yes24.com/product/goods/17525589)
