---
title: "[Effective C++] 2. 생성자, 소멸자 및 대입 연산자 [1/4]"
writer: Langerak
date: 2026-03-18 12:00:00 +0800
categories: [Programming Language]
tags: [Programming Language]
pin: false
math: true
mermaid: true
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.


### 개요

---

우리가 만드는 거의 모든 C++ 클래스에 한 개 이상 꼭 들어 있는 것들이 **생성자와 소멸자, 대입 연산자**이다. 이상할 게 없다.
이들은 C++ 프로그램에 있어서 일용할 양식과 같이 중요한 함수이다.
생성자는 새로운 객체를 메모리에 만드는 데 필요한 과정을 제어하고 객체의 초기화를 맡는 함수이고,
소멸자는 객체를 없앰과 동시에 그 객체가 메모리에서 적절히 사라질 수 있도록 하는 과정을 제어하는 함수이며,
대입 연산자는 기존의 객체에 다른 객체의 값을 줄 때 사용하는 함수이다.
일용할 양식을 잘 못 차려 먹으면 종일 속이 불편한 것처럼, 이들 함수에 대해 개발자가 저지르는 실수는 그 클래스 전체에 걸쳐 큰 영향을 미칠 수 있다.
따라서 클래스를 제대로 쓰려면 이들이 잘 갖추어져 있어야 한다.

<br/>

### 항목 5 : C++가 은근슬쩍 만들어 호출해 버리는 함수들에 촉각을 세우자

---

클래스가 비어 있지만 비어 있는 게 아닌 때가 있다.
언제일까?
일단은 C++(컴파일러)가 빈 클래스를 훑고 지나갈 떄라고 말할 수 있다.
c++의 어떤 멤버 함수는 우리가 클래스 안에 직접 선언해 넣지 않으면 저절로 선언해 주도록 되어 있다.
바로 **복사 생성자(copy constructor), 복사 대입 연산자(copy assignment operator), 그리고 소멸자(destructor)**인데,
좀더 자세히 말하면 이때 컴파일러가 만드는 함수의 형태는 모두 기본형이다.
게다가, 생성자조차도 선언되어 있지 않으면 역시 컴파일러가 우리 대신에 **기본 생성자**를 선언해 놓는다.
이들은 모두 public 멤버이며 inline 함수이다.

그러니까 우리가 다음과 같이 썼다면,

```c++
class Empty() {};
```

다음과 같이 쓴 것과 똑같다는 말이다.

```c++
class Empty()
{
public:

  /** 기본 생성자 */ 
  Empty() { ... }
  
  /** 복사 생성자 */
  Empty(const Empty& rhs) { ... }
  
  /** 소멸자 */
  ~Empty() { ... }
  
  /** 복사 대입 연산자 */
  Empty& operator=(const Empty& rhs) { ... }
    
};
```

이들은 꼭 필요하다고 컴파일러가 판단한다면 만들어지지만, 필요한 조건은 간단하다.
조건은 아래와 같다.

```c++
Empty e1;       // 기본 생성자와 소멸자
Empty e2(e1);   // 복사 생성자
e2 = e1;        // 복사 대입 연산자
```

이렇게 컴파일러가 우리 대신에 함수를 만들어 준다.
그렇다면 컴파일러가 만드는 함수가 하는 일이 무엇일까?
기본 생성자와 소멸자가 하는 일은 일차적으로 컴파일러에게 "배후의 코드"를 깔 수 있는 자리를 마련하는 것이다.
기본 클래스 및 비정적 데이터 멤버의 생성자와 소멸자를 호출하는 코드가 여기서 생기는 것이다.
**이때 소멸자는 이 클래스가 상속한 기본 클래스의 소멸자가 가상 소멸자로 되어 있지 않으면 역시 비가상 소멸자로 만들어진다는 점을 꼭 짚고 가야 한다.**

복사 생성자와 복사 대입 연산자의 경우에는 어떨까?
컴파일러가 몰래 만들어낸 복사 생성자/복사 대입 연산자가 하는 일은 아주 단순하다.
원본 객체의 비정적 데이터를 사본 객체 쪽으로 전부 복사하는 것이 전부이다.
이해를 돕는 의미에서, 임의의 이름을 T 타입의 객체에 연결시켜주는 NamedObject라는 템플릿을 예제로 준비해 보았다.

```c++
template <typename T>
class NamedObject
{

public:

  NamedObject(const char* name, const T& value);
  
  NamedObject(const std::string& name, const T& value);
    
private:

  std::string nameValue;
  
  T objectValue;
    
};
```

**이 NamedObject 템플릿 안에는 생성자가 선언되어 있으므로, 컴파일러는 기본 생성자를 만들어내지 않을 것이라는게 중요하다.**
다시 말하면, 만약 생성자 인자가 꼭 필요한 클래스를 만드는 것이 우리의 결정이라면, 
인자를 받지 않는 생성자를 컴파일러가 눈치 없이 만들어서 우리의 의도와는 다르게 행동하는 것을 걱정할 필요가 없다는 말이다.

반면, 복사 생성자나 복사 대입 연산자는 NamedObject에 선언되어 있지 않기 떄문에,
이 두 함수의 기본형이 컴파일러에 의해 필요하다면 만들어진다.
그러니까 복사 생성자의 사용 예는 다음과 같이 나오게 된다.

```c++
NamedObject<int> no1("Smallest prime number", 2);
NamedObject<int> no2(no1);  // 복사 생성자 호출
```

컴파일러가 만들어낸 복사 생성자는 no1.nameValue와 no1.objectValue를 사용해서 no2.nameValue와 no2.objectValue를 각각 초기화해야 한다.
nameValue의 타입은 string인데, 표준 string 타입은 자체적으로 복사 생성자를 갖고 있으므로 
no2.nameValue의 초기화는 string의 복사 생성자에 no1.nameValue를 인자로 넘겨 호출함으로써 이루어지게 된다.
한편, NamedObject<int>::objectValue의 타입은 int인데, int는 기본제공 타입이므로 
no2.objectValue의 초기화는 no1.objectValue의 각 비트를 그대로 복사해 오는 것으로 끝난다.

컴파일러가 만들어 주는 NamedObject<int>의 복사 대입 연산자도 근본적으로는 동작 원리가 똑같다.
하지만 일반적인 것만 놓고 보면, 이 복사 대입 연산자의 동작이 필자가 설명한 대로 되려면 최종 결과 코드가 적법해야 하고 합리적이어야 한다.
둘 중 어느 검사도 통과하지 못하면 컴파일러는 operator=의 자동 생성을 거부해 버린다.

예를 들어, NamedObject가 다음과 같이 정의되어 있다고 가정해 보자.
nameValue는 string에 대한 참조자이고 objectValue는 const T로 되어 있다.

```c++
template <typename T>
class NamedObject
{
public:

  NamedObject(std::string& name, const T& value);

private:

  std::string& nameValue;  // 참조자
  
  const T objectValue;     // 상수
  
};
```

자, 그럼 다음과 같은 코드에서 어떤 일이 일어날 지 생각해 보자.

```c++

std::string newDog("페르세포네");
std::string oldDog("사치");

NamedObject<int> p(newDog, 2);
NamedObject<int> s(oldDog, 36);

p = s;  // p에 들어 있는 데이터 멤버에서 어떤 일이 일어나야 할까?
```

대입 연산이 일어나기 전, p.namedValue 및 s.nameValue는 다른 string 객체를 참조하고 있다.
이때 대입 연산이 일어나면 p.nameValue가 어떻게 되어야 할까?
s.nameValue가 참조하는 string을 가리켜야 할까?
다시 말해, 참조자 자체가 바뀌어야 할까?
**C++의 참조자는 원래 자신이 참조하고 있는 것과 다른 객체를 참조할 수 없다.**

만약 p.nameValue가 참조하는 string 객체 자체가 바뀐다면, 그 string에 대한 포인터나 참조자를 품고 있는 다른 객체들,
즉 실제 대입 연산에 직접적으로 관여하지 않는 객체들까지 영향을 받게 된다.
컴파일러가 저절로 만들어낸 복사 대입 연산자가 하기에는 너무나도 복잡한 일이다.

이 문제에 대해 C++는 컴파일 거부를 해 버린다.
그렇기 때문에, 참조자를 데이터 멤버로 갖고 있는 클래스에 대입 연산을 지원하려면 우리가 직접 복사 대입 연산자를 정의해 주어야 한다.
데이터 멤버가 상수 객체인 경우에도 C++ 컴파일러가 비슷하게 동작하니 주의하자.
상수 멤버를 수정하는 것은 문법에 어긋나기 때문에, 자동으로 만들어진 암시적 복사 대입 연산자 내부에서는 상수 멤버를 어떻게 처리해야 할지가 애매해진다.

복사 대입 연산자를 private으로 선언한 기본 클래스로부터 파생된 클래스의 경우,
컴파일러가 거부하기에 이 클래스는 암시적 복사 대입 연산자를 가질 수 없다.
어쨌든, 파생 클래스에 대해 컴파일러가 만들어 주는 복사 대입 연산자는 기본 클래스 부분을 맡도록 되어 있긴 하지만,
이렇게 하더라도 파생 클래스 쪽에서 호출할 권한이 없는 멤버 함수는 암시적 복사 대입 연산자가 어떻게 호출할 수는 없다.

> 컴파일러는 경우에 따라 클래스에 대해 기본 생성자, 복사 생성자, 복사 대입 연산자, 소멸자를 암시적으로 만들어 놓을 수 있다.

<br/>

### 가상 소멸자 virtual destructor

---

위에서 잠깐

**이때 소멸자는 이 클래스가 상속한 기본 클래스의 소멸자가 가상 소멸자로 되어 있지 않으면 역시 비가상 소멸자로 만들어진다는 점을 꼭 짚고 가야 한다.**

라고 언급하고 지나갔는데, 이 부분에 대해서 좀더 자세히 알아보자.

아래와 같이 부모 클래스를 상속 받는 자식 클래스가 있고, 부모 클래스의 소멸자가 가상 소멸자로 되어 있지 않다고 가정해 보자.

```c++
class ItemBase
{
    
public:
    
    ~ItemBase()
    {
        std::cout << "Base destructor called\n";
    }
    
};

class Item : public ItemBase
{
    
public:
    
    Item()
    {
        data = new int[1000000];
    }
    
    ~Item()
    {
        delete[] data;
        std::cout << "Derived destructor called\n";
    }
    
private:
    
    int* data;
};

```

이 상태에서 부모 클래스의 포인터로 자식 클래스의 객체를 가리키는 상황에서 소멸자가 호출되면 어떤 일이 일어날까?

```c++
ItemBase* p = new Item();
delete p;

// output : Base destructor called
```

부모 클래스의 소멸자가 가상 소멸자로 되어 있지 않기에, 부모 클래스의 소멸자만 호출되고 자식 클래스의 소멸자는 호출되지 않는다.
가상 함수로 정의되지 않은 자식 클래스의 오버라이딩 된 함수를 선언하면 부모 클래스의 멤버 함수가 호출되기 때문이다.
이렇게 되면 자식 클래스의 소멸자에서 해제해야 하는 자원들이 제대로 해제되지 않게 된다.

자식 클래스에서 메모리 해제가 필요하다면 반드시 부모 클래스에 소멸자를 가상 함수로 작성하자.

```c++
class ItemBase
{
    virtual ~ItemBase()
    {
        std::cout << "Base destructor called\n";
    }    
};

ItemBase* p = new Item();
delete p;

// output : 
// Derived destructor called
// Base destructor called
```

<br/>

### 항목 6: 컴파일러가 만들어낸 함수가 필요 없으면 확실히 이들의 사용을 금해 버리자

---

객체의 사본을 만들면 안되는 클래스가 있다고 가정해보자.
이 객체를 복사하려는 코드는 컴파일이 되지 않았으면 한다.

```c++
class SomeObject { ... };

SomeObject nc1;
SomeObject nc2;

SomeObject nc3(nc1);   // 컴파일이 되지 않았으면 함
nc1 = nc2;              // 컴파일이 되지 않았으면 함
```

아쉽지만 주석으로는 컴파일을 막을 수 없다.
이전에 배웠지만, 복사 생성자와 복사 대입 연산자는 우리가 선언하지 않고 외부에서 이를 호출하려고 하면
컴파일러가 우리 대신에 이들을 선언해 버린다.

해결하는 방법은 다음과 같다.
바로 컴파일러가 생성하는 함수는 모두 public 멤버가 된다는 사실이다.
복사 생성자와 복사 대입 연산자가 저절로 만들어지는 것을 막기 위해 우리가 직접 선언해야 한다는 점은 맞지만,
이것들을 public 멤버로 선언해야 한다고 생각할 필요는 없다.
**이들을 private으로 선언해 버리면, 일단 클래스 멤버 함수가 명시적으로 선언되기 때문에 컴파일러는 자신의 기본 버전을 만들 수 없게 되고 외부로부터의 호출을 차단할 수 있다.**

private 함수는 그 클래스의 멤버 함수 및 친구(friend) 함수가 호출할 수 있다는 점이 여전히 허점이다.
**이것까지 막으려면 정의(define)을 안해버리는건 어떨까?**
정의되지 않은 함수를 누군가가 어쩌다 실수로 호출하려 했다면 분명히 링크 시점에 에러를 보게 될 테니 괜찮다.

실제로 이 꼼수 (멤버 함수를 private으로 선언하고 일부러 정의(구현)하지 않는 방법)는 꽤 널리 퍼지면서 하나의 '기법'으로 굳어지기까지 했다.
C++의 iostream 라이브러리에 속한 몇몇 클래스에서도 복사 방지책으로 쓰이고 있다.
시간이 된다면 우리가 쓰는 표준 라이브러리 구현환경에서 ios_base, basic_ios, sentry가 어떻게 만들어져 있는지 확인해보라.
복사 생성자와 복사 대입 연산자 모두가 private 멤버로 선언된 동시에 정의되어 있지도 않을 것이다.

이제 이 꼼수를 SomeObject에 사용해 보자.

```c++
class SomeObject
{
private:

  SomeObject(const SomeObject&);  // 선언만 있다.
  SomeObject& operator=(const SomeObject&);
}
```

매개변수의 이름이 빠져 있는 게 살짝 거슬릴 수도 있겠지만, 선언 시 매개변수 이름은 필수사항이 아니다.
그냥 읽기 편하라고 해 주는 관례일 뿐이다.
어찌 되었든 이들은 앞으로 구현될 예정이 없고, 사용될 일도 없기에 매개변수 이름을 넣을 이유가 없다.

SomeObject 클래스는 이렇게 정의가 되었다.
사용자가 SomeObject 객체의 복사를 시도하려고 하면 컴파일러가 에러를 발생시킬 것이고,
멤버 함수 혹은 프렌드 함수에서 그렇게 하면 링커 에러가 발생할 것이다.

한 가지 더 덧붙이면, 링크 시점 에러를 컴파일 시점 에러로 옮길 수도 있다.
(에러 탐지는 나중으로 미루는 것보다 미리 하는 것이 좋다.)
복사 생성자와 복사 대입 연산자를 private으로 선언하되, 이것을 SomeObject 자체에 넣지 말고
별도의 기본 클래스에 넣고 이것으로부터 SomeObject를 파생시키는 것이다.
그리고 그 별도의 기본 클래스는 복사 방지만 맡는다는 특별한 의미를 부여한다.
거창하게 들리지만 이 기본 클래스는 정말로 간단하다.

```c++
class Uncopyable
{
protected:
  Uncopyable() {}
  ~Uncopyable() {}
  
private:
  Uncopyable(const Uncopyable&);
  Uncopyable& operator=(const Uncopyable&);
}
```

복사를 막고 싶은 객체는 이제 이렇게 바꿀 수 있다. Uncopyable로부터 상속받는 것이다.

```c++
class SomeObject : private Uncopyable
{
};
// 복사 생성자도, 복사 대입 연산자도 이제는 선언되지 않는다.
```

원하는 바를 깔끔하게 이루어 주는 코드이다.

> 컴파일러에서 자동으로 제공하는 기능을 허용치 않으려면, 대응되는 멤버 함수를 private로 선언한 후에 구현은 하지 않은 채로 두라.
> Uncopyable과 비슷한 기본 클래스를 쓰는 것도 한 방법이다.

<br/>

### 객체의 복사를 막으려면 복사 생성자와 복사 대입 연산자를 private으로 선언하고 정의하지도 말자.

위에서 객체의 복사를 막기 위해 복사 생성자와 복사 대입 연산자를 private으로 선언하고 정의하지도 말자고 했는데, 이 방법은 C++11에서 새로 추가된 기능인 delete를 이용해서 더 깔끔하게 할 수 있다.

```c++
class SomeObject
{
public:
  SomeObject() = default;  // 기본 생성자는 컴파일러에게 만들어 달라고 요청한다.
  
  SomeObject(const SomeObject&) = delete;  // 복사 생성자 삭제
  SomeObject& operator=(const SomeObject&) = delete;  // 복사 대입 연산자 삭제
};
```

위처럼 delete를 이용하면, 복사 생성자와 복사 대입 연산자가 아예 존재하지 않는 것처럼 컴파일러가 인식하게 된다.
따라서 복사 생성자나 복사 대입 연산자를 호출하려고 하면 컴파일 시점에서 에러가 발생하게 된다.

```c++

class SomeObject
{
public:
  SomeObject() = default;
  
  SomeObject(const SomeObject&) = delete;
  SomeObject& operator=(const SomeObject&) = delete;
  
  SomeObject Copy(SomeObject& other)
  {
    return SomeObject(other);  // 컴파일 에러: 복사 생성자가 삭제되었음
  }
};
SomeObject nc1;
SomeObject nc2(nc1);  // 컴파일 에러: 복사 생성자가 삭제되었음
nc1 = nc2;           // 컴파일 에러: 복사 대입 연산자가 삭제되었음
```

Effective C++은 C++11이 나오기 전에 쓰여진 책이기 때문에 delete 키워드를 이용한 방법은 언급되지 않았다.

<br/>

_참고_
- [Effective C++ 제3판](https://www.yes24.com/product/goods/17525589)
