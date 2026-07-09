---
title: "[Effective C++] 7. 템플릿과 일반화 프로그래밍 [3/4]"
description: >-
  이 글은 제 개인적인 공부를 위해 작성한 글입니다. 틀린 내용이 있을 수 있고, 피드백은 환영합니다.
writer: Langerak
date: 2026-05-30 12:00:00 +0800
categories: [Book, Effective C++]
tags: [C++]
pin: false
math: true
mermaid: true
published: true
---

### 항목 45 : "호환되는 모든 타입"을 받아들이는 데는 멤버 함수 템플릿이 직방!

---

알다시피 스마트 포인터는 그냥 포인터처럼 동작하면서도 포인터가 주지 못하는 상큼한 기능을 덤으로 갖고 있는 객체를 일컫는다.
이를테면, 항목 13에서 힙 기반 자원을 삭제를 제때 수행하게 하는 표준 라이브러리의 auto_ptr 및 tr1::shared_ptr 객체를 이용하는 예를 보았을 것이다.

> 현대 C++에서는 auto_ptr는 unique_ptr로 대체되었으며, tr1::shared_ptr C++11 이후로는 사용되지 않습니다. 대신 std::shared_ptr가 널리 사용되고 있습니다.

STL 컨테이너의 반복자도 스마트 포인터나 마찬가지이다. 포인터에데가 "++" 연산을 적용해서 연결 리스트의 한 노드에서 다른 노드로 이동하는 것을 상상이나 할 수 있었겠는가?
그렇지만 list::iterator는 그게 된단 말이다.

포인터에도 스마트 포인터로 대신할 수 없는 특징이 있다. 그 중 하나가 암시적 변환(implicit conversion)을 지원한다는 점이다.
파생 클래스 포인터는 암시적으로 기본 클래스 포인터로 변환되고, 비상수 객체에 대한 포인터는 상수 객체에 대한 포인터로의 암시적 변환이 가능하고, 기타 등등 말이다.
예를 들어, 아래와 같이 세 레벨으로 구성된 클래스 계통이 주어졌다면 그 아래에 나온 것처럼 몇 가지의 타입 변환이 가능할 것이다.

```c++
class Top { ... };
class Middle : public Top { ... };
class Bottom : public Middle { ... };
Top* pt1 = new Middle; // Middle* -> Top*의 변환
Top* pt2 = new Bottom; // Bottom* -> Top*의 변환
const Top* pct2 = pt1; // Top* -> const Top*의 변환
```

이런 식의 타입 변환을 사용자 정의 스마트 포인터를 써서 흉내 내려면 무척 까다롭다. 이를테면 다음과 같은 코드를 컴파일러에 통과시키고 싶은데 말이다.

```c++
template <typename T>
class SmartPtr
{
public:
    explicit SmartPtr(T* realPtr); // 스마트 포인터는 대개 기본제공 포인터로 초기화된다.
    ...
};

SmartPtr<Top> pt1 = SmartPtr<Middle>(new Middle);   // SmartPtr<Middle> -> SmartPtr<Top>의 변환
SmartPtr<Top> pt2 = SmartPtr<Bottom>(new Bottom);   // SmartPtr<Bottom> -> SmartPtr<Top>의 변환
SmartPtr<const Top> pct2 = pt1;                     // SmartPtr<Top> -> SmartPtr<const Top>의 변환
```

같은 템플릿으로부터 만들어진 다른 인스턴스들 사이에는 어떤 관계도 없기 때문에, 컴파일러의 눈에 비치는 `SmartPtr<Middle>`과 `SmartPtr<Top>`은 완전히 별개의 클래스이다.
따라서 SmartPtr 클래스들 사이에 어떤 변환을 하고 싶다고 생각했다면, 변환이 되도록 직접 프로그램을 만들어야 한다는 것이다.

위의 SmartPtr 예제 코드를 보면, 모든 문장이 하나같이 new를 써서 스마트 포인터 객체를 만들고 있다.
그런 의미에서, 스마트 포인터의 생성자를 우리가 원하는 대로 동작하게끔 작성하는 쪽에 일단 초점을 맞추자.
생성자 함수를 직접 만드는 것으로는 우리에게 필요한 모든 생성자를 만들어내기란 불가능하다.
위의 클래스 계통에서는 `SmartPtr<Middle>` 혹은 `SmartPtr<Bottom>`으로부터 `SmartPtr<Top>`을 생성할 수 있지만,
나중에 클래스 계통이 더 확장된다든지 하면 확장된 다른 스마트 포인터 타입으로부터 `SmartPtr<Top>` 객체를 만들 방법도 마련되어야 하니까이다.
쉽게 말해서, 나중에 다음과 같은 클래스를 추가했다면

```c++
class BelowBottom : public Bottom { ... };
```

`SmartPtr<BelowBottom>`으로부터 `SmartPtr<Top>` 객체를 생성하는 부분도 우리가 지원해야 한다는 이야기이다.
이것 때문에 SmartPtr 템플릿까지 수정하는 것은 분명 제정신인 사람으로서 할 일이 아닌 것 같다.

원칙적으로 지금 우리가 원하는 생성자의 개수는 무제한이다. 그런데 템플릿을 인스턴스화하면 무제한 개수의 함수를 만들어 낼 수 있다.
그러니까 SmartPtr에 생성자 **함수**를 둘 필요가 없을 것 같다. 바로 생성자를 만들어내는 **템플릿**을 쓰는 것이다.
이 생성자 템플릿은 이번 항목에서 이야기할 **멤버 함수 템플릿(멤버 템플릿이라고도 함)**의 한 예인데,
멤버 함수 템플릿은 간단히 말해서 어떤 클래스의 멤버 함수를 찍어내는 템플릿을 일컫는다.

```c++
template <typename T>
class SmartPtr
{
public:
    template <typename U>
    SmartPtr(const SmartPtr<U>& other); // "일반화된 복사 생성자"를 만들기 위해 마련한 멤버 템플릿
    ...
};
```

위의 코드를 간단히 말로 풀어 보면 이렇다.
모든 T 타입 및 모든 U 타입에 대해서, `SmartPtr<T>` 객체가 `SmartPtr<U>`로부터 생성될 수 있다는 이야기이다.
그 이유는 `SmartPtr<U>`의 참조자를 매개변수로 받아들이는 생성자가 `SmartPtr<T>` 안에 들어 있기 때문이다.
이런 꼴의 생성자(같은 템플릿을 써서 인스턴스화되지만 타입이 다른 타입의 객체로부터 원하는 객체를 만들어 주는 생성자)를 가리켜
**일반화 복사 생성자(generalized copy constructor)**라고 부른다.

위의 예제에 나온 일반화 복사 생성자는 explicit로 선언되지 않았다.
생각 없이 그렇게 한 것이 아니니 잘 보자.
기본제공 포인터는 포인터 타입 사이의 타입 변환이 암시적으로 이루어지며 캐스팅이 필요하지 않기 때문에,
스마트 포인터도 이런 형태로 동작하도록 흉내 내는게 맞는다고 생각한다.
그래서 여기서는 템플릿으로 만든 생성자 앞에 explicit 키워드를 빼면 딱 그렇게 되는 거다.

보면 알겠지만, 지금 SmartPtr에 선언된 일반화 복사 생성자는 실제로 우리가 원하는 것보다 더 많은 것을 해 준다.
우리는 `SmartPtr<Bottom>`으로부터 `SmartPtr<Top>`을 만들 수 있기만을 원했지, 
반대로 `SmartPtr<Top>`으로부터 `SmartPtr<Bottom>`을 만들 수 있는 것까지는 바라지 않았단 말이다.
이것은 public 상속의 의미에 역행하는 것이다.
게다가 지금의 생성자로는 심지어 `SmartPtr<double>`로부터 `SmartPtr<int>`를 만든다든지 하는 것도 가능해서, 뭔가 대책이 필요하다.
이에 대응되는 기본제공 포인터 타입으로 바꿔 봤을 때 int*에서 double*로 진행되는 암시적 변환이 가능하지 않기 때문이다.
바람직스러움과 거리가 먼 이런 멤버 함수들이 멤버 템플릿으로부터 태어나 어지럽히기 전에, 어떻게 해서든 이들을 막아야 한다.

auto_ptr 및 tr1::shared_ptr에서 쓰는 방법을 그대로 따라서 SmartPtr도 get 멤버 함수를 통해 
해당 스마트 포인터 객체에 자체적으로 담긴 기본제공 포인터의 사본을 반환한다고 가정하면(항목 15 참조), 
이것을 이용해서 생성자 템플릿에 우리가 원하는 타입 변환 제약을 줄 수 있을 것 같다. 아래를 보자.

```c++
template <typename T>
class SmartPtr
{
public:
    template <typename U>
    SmartPtr(const SmartPtr<U>& other)
    : heldPtr(other.get()) { ... }
    
    T* get() const { return heldPtr; }
    ...
    
private:
    T* heldPtr;
```

보다시피 멤버 초기화 리스트를 사용해서, `SmartPtr<T>`의 데이터 멤버인 T* 타입의 포인터를 `SmartPtr<U>`에 들어 있는 U* 타입의 포인터로 초기화했다.
이렇게 해 두면 U*에서 T*로 진행되는 암시적 변환이 가능할 때만 컴파일 에러가 나지 않는다.
우리가 원했던 바를 그대로 코드로 옮긴 것이다. 위와 같은 제약을 가했을 경우 얻어지는 실제 효과는 이렇게 정리할 수 있다.
이제 `SmartPtr<T>`의 일반화 복사 생성자는 효환되는 타입의 매개변수를 넘겨받을 때만 컴파일되도록 만들어졌다고.

멤버 함수 템플릿의 활용은 비단 생성자에만 그치지 않는다. 가장 흔히 쓰이는 예를 하나 더 말하자면 대입 연산이다.
예를 들면 TR1의 shared_ptr 클래스 템플릿은 호환되는 모든 기본제공 포인터, tr1::shared_ptr, auto_ptr, tr1::weak_ptr 객체들로부터
생성자 호출이 가능한데다가, 이들 중 tr1:weak_ptr을 제외한 나머지를 대입 연산에 쓸 수 있도록 만들어져 있다.
말이 나온 김에 TR1 에서 tr1::shared_ptr 템플릿이 어떻게 나와 있는지 짤막하게 잘라서 보자.
템플릿 매개변수를 선언할 때 typename 대신 class를 쓰는 원제작자의 취향도 함께 볼 수 있다.

```c++
template <class T>
class shared_ptr
{
public:
    template <class Y>
    explicit shared_ptr(Y* p);
    
    template <class Y>
    shared_ptr(shared_ptr<Y> const& r);
    
    template <class Y>
    explicit shared_ptr(weak_ptr<Y> const& r);
    
    template <class Y>
    explicit shared_ptr(auto_ptr<Y>& r);
    
    template <class Y>
    shared_ptr& operator=(shared_ptr<Y> const& r);
    
    template <class Y>
    shared_ptr& operator=(auto_ptr<Y>& r);
    ...
};
```

일반화 복사 생성자를 제외하고 모든 생성자가 explicit로 선언되어 있는 게 보일 것이다.
무슨 뜻인고 하니, shared_ptr로 만든 어떤 타입으로부터 또 다른 타입으로 진행되는 암시적 변환은 허용되지만
기본제공 포인터 혹은 다른 스마트 포인터 타입으로부터 변환되는 것은 막겠다는 뜻이다.
(단, 캐스팅과 같은 명시적 변환은 오케이다)
한 가지 더 재미있는 부분은 tr1::shared_ptr 생성자와 대입 연산자에 넘겨지는 auto_ptr이 const로 선언되지 않은 것인데,
이와 대조적으로 tr1::shared_ptr 및 tr1::weak_ptr은 const로 넘겨지도록 되어 있다.
다 이유가 있다.
auto_ptr는 복사 연산으로 인해 객체가 수정될 때 오직 복사된 쪽 하나만 유효하게 남는다는 사실을 반영한 것이다.

멤버 함수 템플릿은 코드 재사용만큼이나 기특하고 훌륭한 기능이지만, C++ 언어의 기본 규칙까지는 바꾸지는 않는다.
개발자가 가만 내버려 두면 컴파일러가 멋대로 만들어내는 클래스 멤버 함수 네 개 중 기본 생성자와 소멸자를 제외한 두 개가
복사 생성자와 복사 대입 연산자라는 이야기를 항목 5에서 말했었다.
tr1::shared_ptr에는 분명히 일반화 복사 생성자가 선언되어 있는데, T 타입과 Y 타입이 동일하게 들어온다면
이 일반화 복사 생성자는 분명 "보통의" 복사 생성자를 만드는 쪽으로 인스턴스화 될 것이다.
자, 그럼 어떤 tr1::shared_ptr 객체가 자신과 동일한 타입의 다른 tr1::shared_ptr 객체로부터 생성되는 상황에서,
컴파일러는 tr1::shared_ptr의 복사 생성자를 만들까? 아니면 일반화 복사 생성자 템플릿을 인스턴스화할까?

앞에서 말한 대로 멤버 템플릿은 언어의 규칙을 바꾸지는 않는다.
이때의 규칙이란 바로, '복사 생성자가 필요한데 프로그래머가 직접 선언하지 않으면 컴파일러가 자동으로 하나 만든다'라는 것이다.
그러나 일반화 복사 생성자를 어떤 클래스 안에서 선언하는 행위는 컴파일러 나름의 복사 생성자를 만드는 것을 막는 요소가 아니다.
일반화 복사 생성자는 일반화 복사 생성자일 뿐, 보통의 복사 생성자가 아니라는 거다.
따라서 어떤 클래스의 복사 생성을 모두 우리 손에서 관리하고 싶으면, 일반화 복사 생성자는 물론이고 "보통의" 복사 생성자까지 우리가 직접 선언해야 한다.
대입 연산자도 마찬가지이다. 그럼, tr1::shared_ptr은 이 부분을 어떤 식으로 처리했는지 보자.

```c++
template <class T>
class shared_ptr
{
public:
    shared_ptr(shared_ptr const& r); // 복사 생성자
    
    template <class Y>
    shared_ptr(shared_ptr<Y> const& r); // 일반화 복사 생성자
    
    shared_ptr& operator=(shared_ptr const& r); // 복사 대입 연산자
    
    template <class Y>
    shared_ptr& operator=(shared_ptr<Y> const& r); // 일반화 대입 연산자
    ...
};
```

> 호환되는 모든 타입을 받아들이는 멤버 함수를 만들려면 멤버 함수 템플릿을 사용하자.

> 일반화된 복사 생성 연산과 일반화된 대입 연산을 위해 멤버 템플릿을 선언헀다 하더라도,
> 보통의 복사 생성자와 복사 대입 연산자는 여전히 직접 선언해야 한다.

<br/>

### 항목 46 : 타입 변환이 바람직할 경우에는 비멤버 함수를 클래스 템플릿 안에 정의해 두자.

---

모든 매개변수에 대해 암시적 타입 변환이 되도록 만들기 위해서는 비멤버 함수밖에 방법이 없다는, 
이번 항목과 조금 비슷한 이야기는 이전에 항목 24에서 이유까지 말한 바 있다.
그 당시, Rational 클래스의 operator* 함수가 예제로 나왔었다. 이번 항목에서는 이 예제를 다시 활용하기에 다시 한번 보고 오도록 하자.
어떻게 할 거냐면, Rational 클래스와 operator* 함수를 템플릿으로 만들 것이다.

```c++
template <typename T>
class Rational
{
public:
    Rational(const T& numerator = 0, const T& denominator = 1);
    
    const T numerator() const;
    const T denominator() const;
    ...
};

template <typename T>
const Rational<T> operator*(const Rational<T>& lhs, const Rational<T>& rhs)
{ ... }
```

항목 24에서도 그랬듯, 혼합형 수치 연산은 여전히 필요하다. 다음의 코드가 컴파일되어야 하는 거다.
그런데 이미 항목 24에서 동작하는 코드를 그대로 가져왔기 때문에, 컴파일이 안 되는 게 더 이상할 것 같다.
차이점이라면 Rational 및 operator* 부분이 이제는 템플릿이라는 것밖엔 없다.

```c++
Rational<int> onehalf(1, 2);

Rational<int> result = onehalf * 2; // 에러! 컴파일이 안 된다.
```

컴파일이 되지 않는다는 사실을 미루어 볼 때, 템플릿 버전의 Rational에는 템플릿이기 전의 버전과 다른 무언가가 있지 않을까 싶다.
실제로 있다. 항목 24에서는 우리가 호출하려고 하는 함수가 무엇인지를 컴파일러가 알고 있지만(Rational 객체 두 개를 받는 operator* 함수),
지금의 경우에는 어떤 함수를 호출하려는지에 대해 컴파일러로서는 아는 바가 전혀 없다.
단지, 컴파일러는 operator*라는 이름의 템플릿으로부터 인스턴스화할 함수를 결정하기 위해 온갖 계산을 동원할 뿐이다.
이 시점에서 컴파일러가 정확히 아는 것은 `Rational<T>` 타입의 매개변수를 두 개 받아들이는 operator*라는 이름의 함수를
자신이 어떻게든 인스턴스로 만들긴 해야 한다는 점이다. 그러나 이 인스턴스화를 제대로 하려면 '대체 T가 무엇이냐?'에 대한 수수께끼를 풀어야 한다.
문제는 바로, 컴파일러 스스로는 이 수수께끼를 풀 능력이 없다는 것이다.

T의 정체를 파악하기 위해, 컴파일러는 우선 operator* 호출 시에 넘겨진 인자의 모든 타입을 살핀다.
지금의 경우에는 `Rational<int>` 및 int이다. 컴파일러는 이들을 하나씩 각개 격파해 간다.

oneHalf 쪽은 의외로 공략이 쉽다. operator*의 첫 번째 매개변수는 `Rational<T>` 타입으로 선언되어 있고,
지금 operator*에 넘겨진 첫 번째 매개변수가 마침 또 `Rational<int>` 타입이기 때문에, T는 int일 수밖에 없다.

하지만 애석하게도 두 번째 매개변수 쪽은 타입을 유추해내기가 어렵다.
operator*의 선언을 보면 두 번째 매개변수가 `Rational<T>` 타입으로 선언되어 있는데, 지금 operator*에 넘겨진 두 번째 매개변수는 int 타입이다.
이때 컴파일러는 어떻게 해야 T의 정체를 벗겨낼 수 있을까?

`Rational<int>`에는 explicit로 선언되지 않은 생성자가 들어있다는 것을 확인한 사람이라면,
혹시 컴파일러가 이 생성자를 써서 2를 `Rational<int>`로 변환하고 이릍 통해 T가 int라고 유추할 수 있지 않을까 하고 예상할 것 같은데,
컴파일러는 그렇게 동작하지 못한다.
**그 이유는, 템플릿 인자 추론(template argument deduction) 과정에서는 암시적 타입 변환이 고려되지 않기 때문이다.**
절대로 안된다. 이런 타입 변환은 함수 호출이 진행될 때 쓰이는 것은 맞다.
그러나 우리가 함수를 호출할 수 있으려면 어떤 함수가 있는지를 우리가 미리 알고 있어야 한다.
게다가 호출되는 상황에 맞는 함수 템플릿을 넣어 줄 매개변수 타입을 추론하는 일도(함수를 인스턴스화해야 하니 말이다) 우리가 해야 한다.
**하지만, 다시 말하지만 템플릿 인자 추론이 진행되는 동안에는 생성자 호출을 통한 암시적 타입 변환 자체가 고려되지 않는다.**
사실 항목 24에서는 템플릿이 거론되지 않았기 때문에, 템플릿 인자 추론 문제가 불거지지 않은 것 뿐이다.
지금은 C++의 템플릿 부분에 와 있으므로, 이것은 아주 중대한 문제이다.

이처럼 힘든 처지에서 템플릿 인자 추론을 해야 하는 수고로부터 컴파일러를 해방시킬 수 있는 방법이 있다.
클래스 템플릿 안에 프렌드 함수를 넣어 두면 함수 템플릿으로서의 성격을 주지 않고 특정한 함수 하나를 나타낼 수 있다는 사실을 이용하는 것이다.
다시 말해, `Rational<T>` 클래스에 대해 operator*를 프렌드 함수로 선언하는 것이 가능하다는 이야기이다.
클래스 템플릿은 템플릿 인자 추론 과정에 좌우되지 않으므로(템플릿 인자 추론은 함수 템플릿에만 적용되는 과정이다),
T의 정확한 정보는 `Rational<T>` 클래스가 인스턴스화될 당시에 바로 알 수 있다.
그렇기 때문에, 호출 시의 정황에 맞는 operator* 함수를 프렌드로 선언하는 데 별 어려움이 없는 것이다.

```c++
template <typename T>
class Rational
{
public:
    ...
friend
    const Rational operator*(const Rational& lhs, const Rational& rhs);
};

template <typename T>
const Rational<T> operator*(const Rational<T>& lhs, const Rational<T>& rhs)
{ ... }
```

이제 우리는 혼합형 operator* 호출이 컴파일되는 코드를 보고 있다.
oneHalf 객체가 'Rational<int>' 타입으로 선언되면 'Rational<int>' 클래스가 인스턴스로 만들어지고,
이때 그 과정의 일부로서 'Rational<int>' 타입의 매개변수를 받는 프렌드 함수인 operator*도 자동으로 선언되기 때문이다.
이전과 달리 지금은 **함수**가 선언된 것이므로(함수 **템플릿**이 아니라),
컴파일러는 이 호출문에 대해 암시적 변환 함수(Rational의 비명시 호출 생성자 등)를 적용할 수 있게 되는 것이다.
컴파일에 성공하는 이유는 이게 전부이다.

하지만 이 코드는 컴파일은 되지만, 링크가 안 된다.
이 문제는 조금 있다가 바로 잡겠지만, 우선 필자는 Rational 안에 operator*를 선언하는 데 사용한 문법에 대해 몇 가지 말하고자 한다.

클래스 템플릿 내부에서는 템플릿의 이름(<> 뗀 것)을 그 템플릿 및 매개변수의 줄임말로 쓸 수 있다.
그러니까 `Rational<T>` 안에서는 Rational이라고만 써도 `Rational<T>`로 먹힌다는 거다.
위의 예제에서야 몇 자 덜 치는 정도이지만, 매개변수가 여러 개이거나 매개변수 이름이 길거나 할 경우에는 이처럼 고마운 것도 없다.
손가락도 덜 피곤해지고 코드도 깔끔해지기에 위의 예제에서 이걸 써먹어 봤다.
operator* 함수의 선언부를 보면 매개변수 타입과 반환 타입이 `Rational<T>`가 아니라 `Rational`으로 되어 있다.
사실 다음과 같이 선언하더라도 똑같은 의미이다.

```c++
template <typename T>
class Rational
{
public:
    ...
friend
    const Rational<T> operator*(const Rational<T>& lhs, const Rational<T>& rhs);
    ...
};
```

다시 링크 문제로 돌아오자. 지금의 혼합형 호출 코드는 컴파일까지는 잘 된다.
우리가 어떤 함수를 호출하려는지 컴파일러가 알 수 있게 됐으니까(`Rational<int>` 두 개를 받아들이는 operator* 함수).
그런데 이 함수는 Rational 안에서 **선언**만 되어 있지, 거기에서 **정의**까지 되어 있는 것은 아니다.
클래스 외부에 있는 operator* 템플릿에서 함수 정의를 제공하도록 만들고 싶은 것이 우리들 의도였지만, 바람대로 일이 풀리지는 않았다.
어떤 함수를 우리들이 직접 선언했으면, 그 함수를 정의하는 일도 우리가 책임져야 한다.
그런데 함수 정의는커녕 코빼기도 보이지 않으니, 링커가 못 찾는 게 당연하다.

가장 간단하게 해결하려면, operator* 함수의 본문을 선언부와 붙이면 된다.

```c++
template <typename T>
class Rational
{
public:
    ...
    friend const Rational operator*(const Rational& lhs, const Rational& rhs)
    {
        return Rational(lhs.numerator() * rhs.numerator(), lhs.denominator() * rhs.denominator());
    }
};
```

드디어 끝까지 돌아가는 코드가 나왔다. operator* 함수의 혼합형 호출 코드가 이제는 컴파일도 되고, 링크도 되고, 실행도 된다.

이번 항목에서 필자가 보여준 이 방법에는 재미있는 이야깃거리가 하나 숨어 있다.
프렌드 함수를 선언하긴 했지만, 클래스의 public 영역이 아닌 부분에 접근하는 것과 프렌드 권한은 아무런 상관이 없다는 게 바로 그것이다.
모든 인자에 대해 타입 변환이 가능하도록 만들기 위해 비멤버 함수가 필요하고(항목 24 내용),
호출 시의 상황에 맞는 함수를 자동으로 인스턴스화하기 위해서는 그 비멤버 함수를 클래스 안에 선언해야 한다.
공교롭게도, 클래스 안에 비멤버 함수를 선언하는 유일한 방법이 '프렌드'였을 뿐이다.
그래서 그렇게 한 것이고, 효과적이다.

항목 30에서 클래스 안에 정의된 함수는 암시적으로 인라인으로 선언된다. 지금의 operator* 같은 프렌드 함수도 예외는 아니다.
클래스 바깥에서 정의된 헬퍼 함수만 호출하는 식으로 operator*를 구현하면 이러한 암시적 인라인 선언의 영향을 최소화할 수도 있다.
물론 이번 항목에서 보여준 예제에서는 그렇게 해 봤자 얻는 점수가 그다지 많지 않다. 이미 한 줄 함수로 구현되어 있기 때문이다.
하지만 꽤 복잡하게 작성된 함수 본문이 이런 식으로 끼어들어가 있다면 한 번 해 봄 직하다.
이른바 "프렌드 함수는 헬퍼만 호출하게 만들기" 방법이다. 잘 기억해 두자.

Rational이 템플릿이란 사실을 놓고 살짝만 머리를 돌려보면 헬퍼 함수도 대개 템플릿일 것이라는 말도 된다.
그러고 보면, Rational을 정의하는 헤더 파일에 들어 있는 코드는 아마 다음과 같은 형태가 아닐까?

```c++
template <typename T> class Rational;

template <typename T> // 헬퍼 함수
const Rational<T> doMultiply(const Rational<T>& lhs, const Rational<T>& rhs);

template <typename T>
class Rational
{
public:
    ...
    friend const Rational operator*(const Rational& lhs, const Rational& rhs)
    { return doMultiply(lhs, rhs); } // 프렌드 함수가 헬퍼 함수를 호출하도록 만들기
    ...
};
```

대다수의 컴파일러에서 템플릿 정의를 헤더 파일에 전부 넣을 것을 사실상 강제로 강요하다시피 하고 있으니,
doMultiply도 헤더 파일 안에 정의해 넣어야 할 것이다
(항목 30에서도 이야기했지만, 이런 템플릿은 인라인일 필요가 없다).
아마 다음과 같은 형태일 것이다.

```c++
template <typename T>
const Rational<T> doMultiply(const Rational<T>& lhs, const Rational<T>& rhs)
{
    return Rational<T>(lhs.numerator() * rhs.numerator(), lhs.denominator() * rhs.denominator());
}
```

물론 doMultiply는 템플릿으로서 혼합형 곱셈을 지원하지 못하겠지만, 지원할 필요가 없다.
이 템플릿을 사용하는 고객은 operator*밖에 없을 텐데, operator*가 이미 혼합형 연산을 지원하고 있으니 말이다.
operator* **함수**는 자신이 받아들이는 매개변수가 제대로 곱해지도록 어떤 타입도 Rational 객체로 바꿔 주고,
이렇게 바꾼 Rational 객체 두 개는 doMultiply **템플릿**의 인스턴스가 날름 받아서 실제 곱셈에 써먹는단 말이다.
손발이 착착 맞는다.

> 모든 매개변수에 대해 암시적 타입 변환을 지원하는 템플릿과 관계가 있는 함수를 제공하는 클래스 템플릿을 만들려고 한다면,
> 이런 함수는 클래스 템플릿 안에 프렌드 함수로 정의하자.

<br/>

_참고_
- [Effective C++ 제3판](https://www.yes24.com/product/goods/17525589)
