---
title: "[Effective C++] 8. new와 delete를 내 맘대로 [2/2]"
description: >-
  이 글은 제 개인적인 공부를 위해 작성한 글입니다. 틀린 내용이 있을 수 있고, 피드백은 환영합니다.
writer: Langerak
date: 2026-06-18 12:00:00 +0800
categories: [Programming Language]
tags: [Programming Language]
pin: false
math: true
mermaid: true
published: true
---

### 항목 51 : new 및 delete를 작성할 때 따라야 할 기존의 관례를 잘 알아 두자

---
항목 50을 읽었다면 사용자 정의 버전의 operator new 함수와 operator delete 함수를 언제 만들어 쓰는지에 대해 이제 어느 정도는 이해가 되었을 것이다.
실제로 사용자 정의 버전을 작성해 보려고 했을 때 도대체 어떤 관례를 따라야 하는지에 대해서는 아직 막막할 것이다. 보면 사실 따르기 힘든 규칙은 없다.
그러나 일부는 이해하기에 살짝 구린?게 있기 때문에, 이런 부분이 무엇인지에 대해 유념해 둘 필요가 있다.

우선 operator new부터 시작하자. 기존의 관례에 잘 맞는 operator new를 구현하려면 다음의 요구사항만큼은 기본으로 지켜야 한다. 
일단 반환 값이 제대로 되어 있어야 하고, 가용 메모리가 부족할 경우에는 new 처리자 함수를 호출해야 하며(항목 49 참조),
크기가 없는 0바이트 메모리 요청에 대한 대비책을 갖춰야 한다. 끝으로, 실수로 "기존(normal)" 형태의 new가 가려지지 않도록 하자.
사실 이 부분은 구현 요구사항이라기보다는 클래스 인터페이스에 관한 문제이긴 하지만 대단히 중요하다. 항목 52에서 자세히 다루어 두었으니 참고하자.

operator new의 반환 값 부분은 지극히 간단하다. 요청된 메모리를 마련해 줄 수 있으면 그 메모리에 대한 포인터를 반환하는 것으로 끝이다.
메모리를 마련해 줄 수 있으면 그 메모리에 대한 포인터를 반환하는 것으로 끝이다. 메모리를 마련해 줄 수 없는 경우가 문제인데,
이 경우에는 항목 49에서 이야기한 규칙을 따라서 bad_alloc 타입의 예외를 던지게 하면 된다.

구현도 이렇게 말처럼 쉬우면 좋겠는데, 간단하지는 않다. 
사실 operator new는 메모리 할당이 실패할 때마다 new처리자 함수를 호출하는 식으로 메모리 할당을 2회 이상 시도하기 때문이다.
그러니까, 어떻게든 어떤 메모리를 해제하는 데 실마리가 되는 동작을 new 처리자 함수 쪽에서 할 수 있는 것으로 가정하는 것이다.
operator new가 예외를 던지게 되는 경우는 오직 new 처리자 함수에 대한 포인터가 널일 때뿐이다.

그리고 이번 항목을 시작할 때 말한 어색한 요구사항을 이야기해 보자. 
바로 0바이트가 요구되었을 때조차도 operator new 함수는 적법한 포인터를 반환해야 한다는 것이다
(이런 동적이 요구사항으로 있는 덕택에 다른 부분들이 좀 더 간단해지긴 하다).
어쨌든 지금까지의 요구사항을 모으고 정리해서, 비멤버 버전의 operator new 함수를 의사 코드로 만들어 보면 다음과 같다.

```c++
// 우리의 operator new 함수는 다른 매개변수를 추가로 가질 수 있다.
void* operator new(std::size_t size) throw(std::bad_alloc)
{
    using namespace std;
    
    if (size == 0)
    {
        size = 1; // 0바이트 요청이 들어오면 1바이트 요구로 간주하고 처리
    }
    
    while (true)
    {
        // size바이트를 할당해 보자
        if (할당 성공)
        {
            return (할당된 메모리에 대한 포인터);
        }
        
        // 할당 실패 시, 현재의 new 처리자 함수가 어느 것으로 설정되어 있는지 찾아낸다.
        new_handler globalHandler = set_new_handler(0);
        set_new_handler(globalHandler);
        
        if (globalHandler) (*globalHandler)();
        else throw std::bad_alloc();        
    }
}
```

외부에서 0바이트를 요구했을 때 1바이트 요구인 것으로 간주하고 처리하는 수법은 어쩐지 무척 비굴해 보이기도 하고 얍삽해 보이기도 하다.
하지만 일단 간단하고 규칙을 어긴 것도 아니며, 제대로 돌아간다. 그리고 0바이트가 우리 평생 동안 진짜 몇 번이나 요구될 것 같은가?

new 처리자 함수의 포인터를 널로 설정하고 바로 뒤에 원래의 처리자 함수로 되돌려 놓는 코드도 눈에 자꾸 거슬린다.
눈뜨고 못 볼 수준은 아니지만 그다지 예뻐 보이진 않는다.
안타까운 일이지만, 현재의 전역 new 처리자 함수를 얻어오는 직접적인 방법은 없다.

set_new_handler 함수를 호출하고 그 반환 값을 가져오는 방법밖에 없기 떄문에, 위와 같이 할 수 밖에 없었던 것이다.
뭔가 다른 방법이 있으면 당장 바꾸고 싶은 마음이 솓구치지만 현장에서도 효과적인 코드이다.
최소한 단일스레드에서 동작하는 환경이라면 이렇게 해도 될 것이다.
반면, 다중스레드 환경에서는 new 처리자 함수를 둘러싼 전역 자료구조들이 조작될 때 스레드 안정성이 보장되어야 하기 때문에 스레드 잠금을 걸어야 한다.

operator new 함수에는 무한 루프가 들어 있다는 이야기를 항목 49에서 했는데, 위의 코드를 보면 그 루프를 볼 수 있다.
while (true) 루프를 빠져나오는 유일한 조건은 메모리 할당이 성공하든지 아니면 항목 49에서 이야기한 동작들 중 한 가지를 new 처리자
함수 쪽에서 해 주던지 둘 중 하나이다. new 처리자 함수는 가용 메모리를 늘려 주든가, 다른 new 처리자를 설치하든가,
new 처리자의 설치를 제거하든가, bad_alloc 혹은 bad_alloc에서 파생된 타입의 예외를 던지든가, 아예 함수 복귀를 포기하고 도중 중단을 시켜야 한다.
new 처리자 함수 쪽에서 이런저런 네 가지 동작들 중 하나는 반드시 해 주어야 하는 이유를 이제는 확실히 이해했을 것이다.
new 처리자에서 직무유기를 해 버릴 경우, operator new의 내부 루프는 절대로 스스로 끝나지 않는다.

사실, operator new 멤버 함수는 파생 클래스 쪽으로 상속이 되는 함수이다. 상당히 많은 사람들이 이 점을 간과하고 있는데, 정말 우스운 꼴을 당할 수 있으니 주의하자. 
위에 나온 operator new 함수의 의사 코드를 보면, 할당을 시도하는(size가 0이 아니면 말이다) 메모리의 크기가 size바이트로 되어 있다.
이 코드는 틀린 게 하나도 없는 100점 코드이다. 이 함수에 전달되는 인자가 size이니까. 그런데 특정 클래스 전용의 할당자를 만들어서
할당 효율을 최적화하기 위해 사용자 정의 메모리 관리자를 작성할 수 있다는 이야기는 항목 50을 읽은 사람이라면 기억하고 있을 것이다.
여기서 특정 클래스란 '그' 클래스 하나를 가리킬 뿐, '그 클래스 혹은 그 클래스로부터 파생된 다른 클래스들' 모두를 통칭하는 것은 아니다.
그러니까 어떤 X라는 클래스를 위한 operator new 함수가 있다면, 이 함수의 동작은 크기가 sizeof(X)인 객체에 맞추어져 있는 것이다.
더도 덜도 아니고 딱 sizeof(X)란 말이다. 그런데 상속이라 불리는 요상한 녀석 때문에 파생 클래스 객체를 담을 메모리를 할당하는 데
기본 클래스의 operator new 함수가 호출되는 웃지 못 할 일이 생긴다는 것이다.

```c++
class Base
{
public:
    static void* operator new(std::size_t size) throw(std::bad_alloc);
    ...
};

// 파생 클래스에서는 operator new가 선언 X
class Derived : public Base
{ ... };


Derived* p = new Derived; // Base::operator new가 호출된다.
```

만약 Base 클래스 전용의 operator new가 이런 상황에 대해 어떤 조치를 취하도록 설계되지 않았다면 전체 설계를 바꾸지 않고 쓸 수 있는
가장 좋은 해결 방법은 "틀린" 메모리 크기가 들어왔을 때를 시작부분에서 확인한 후에 표준 operator new를 호출하는 쪽으로 살짝 비껴가게 만드는 것이다.
아래처럼 말이다.

```c++
void* Base::operator new(std::size_t size) throw(std::bad_alloc)
{
    if (size != sizeof(Base))
        return ::operator new(size);
        
    ...
}
```

근데 이렇게 하면 함수 앞 부분에서 0바이트 상황을 점검하지 않는다. 저자가 넣지 않아서 그렇지, 사실 0바이트 점검 코드는 있다.
단지 sizeof(Base)와 size를 비교하는 코드에 합쳐져 있을 뿐이다. C++에는 모든 독립 구조의 객체는 반드시 크기가 0이 넘어야 한다는
요상한 금기사항 같은 것이 있다(항목 39 참조).
이런 정의 덕택에 sizeof(Base)가 0이 될 일은 절대 일어나지 않는다. 따라서 size가 0이면 if문이 거짓이 되어 메모리 처리 요구가
::operator new 쪽으로 넘어가는 것이다. 그러니까 위의 코드는 메모리 요구에 대한 처리를 제대로 한 것이다.

만약에 배열에 대한 메모리 할당을 클래스 전용 방식으로 하고 싶다면, operator new의 사촌격인 operator new[] 함수를 구현하면 된다.
operator new[]를 직접 구현하는 것은 우리 결심이니 말리진 않겠지만 지금 하는 이야기를 꼭 잊지 말자.
operator new[] 안에서 해 줄 일은 단순히 원시 메모리의 덩어리를 할당하는 것밖엔 없다는 것이다.
이 시점에서는 배열 메모리에 아직 생기지도 않은 클래스 객체에 대해서 아무것도 할 수 없다.
사실, 배열 안에 몇 개의 객체가 들어갈지 계산하는 것조차도 안 된다.

첫째, 객체 하나가 얼마나 큰지를 확정할 방법이 없다. 앞에서도 언급한 바 있는 상속 때문에, 파생 클래스 객체의 배열을 할당하는 데
기본 클래스의 operator new[] 함수가 호출될 수 있다. 그리고 파생 클래스 객체는 대체적으로 기본 클래스 객체보다 더 크다는 것이 문제다.
그렇기 때문에, Base::operator new[] 안에서조차 배열에 들어가는 객체 하나의 크기가 sizeof(Base)라는 가정을 할 수 없다.
이 말을 풀이해 보면, Base::operator new[]에서 할당한 배열 메모리에 들어가는 객체의 개수를 (요구된 바이트 수/sizeof(Base))로
계산할 수 없다는 뜻이다.

둘째, operator new[]에 넘어가는 size_t 타입의 인자는 객체들을 담기에 딱 맞는 메모리 양보다 더 많게 설정되어 있을 수 있다.
동적으로 할당된 배열에는 배열 원소의 개수를 담는 자투리 공간이 추가로 들어간다고 항목 16에서 이야기 했었다.

<br/>

operator new를 작성할 경우에 지켜야 하는 관례에 대한 이야기는 이것으로 끝이다. 적지 않은 이야기를 한 것 같다.
다음은 operator delete를 작성할 때의 관례인데, operator new의 경우보다 더 간단하다.
c++는 널 포인터에 대한 delete 적용이 항상 안전하도록 보장한다는 사실만 잊지 않으면 만사 OK이다.
우리가 할 일은 이 보장을 유지하는 것뿐이다. 그럼, 간단히 작성해 본 비멤버 버전 operator delete의 의사 코드를 보자.

```c++
void operator delete(void* rawMemory) throw()
{
    // 널 포인터가 delete되려고 할 경우에 아무것도 하지 않는다.
    if (rawMemory == 0) return;
    
    // rawMemory가 가리키는 메모리를 해제
}
```

operator delete의 클래스 전용 버전도 단순하기는 매한가지이다.
삭제될 메모리의 크기를 점검하는 코드를 넣어 주어야 한다는 점만 빼면 말이다.
클래스 전용의 operator new가 "틀린" 크기의 메모리 요청을 ::operator new 쪽으로 넘기도록 구현되었다고 가정하면,
클래스 전용의 operator delete 역시 "틀린 크기로 할당된" 메모리의 삭제 요청을 ::operator delete 쪽으로 전달하는 식으로 구현하면 된다.

```c++
class Base
{
public:
    static void* operator new(std::size_t size) throw(std::bad_alloc);
    static void operator delete(void* rawMemory, std::size_t size) throw();
    ...
}


void Base::operator delete(void* rawMemory, std::size_t size) throw()
{
    if (rawMemory == 0) return;
    
    if (size != sizeof(Base))
    {
        ::operator delete(rawMemory);
        return;
    }
    
    // rawMemory가 가리키는 메모리를 해제
    return;
}
```

마지막으로 재미있는 이야기를 하나 더 해보자.
가상 소멸자가 없는 기본 클래스로부터 파생된 클래스의 객체를 삭제하려고 할 경우에는 operator delete로 C++가 넘기는 size_t 값이 엉터리일 수 있다.
이것만으로도 기본 클래스에 가상 소멸자를 꼭 두어야 하는 충분한 이유가 선다고 말할 수 있다.
하기야 항목 7을 보면 확실히 더 괜찮은 이유도 확인할 수 있긴 하다.
어쨌든, 기본 클래스에서 가상 소멸자를 빼먹으면 operator delete 함수가 똑바로 동작하지 않을 수 있다는 사실만 머리에서 놓치지 말자.

> 관례적으로, operator new 함수는 메모리 할당을 반복해서 시도하는 무한 루프를 가져야 하고,
> 메모리 할당 요구를 만족시킬 수 없을 때 new 처리자를 호출해야 하며,
> 0바이트에 대한 대책도 있어야 한다.
> 클래스 전용 버전은 자신이 할당하기로 예정된 크기보다 더 큰(틀린) 메모리 블록에 대한 요구도 처리해야 한다.

> operator delete 함수는 널 포인터가 들어왔을 떄 아무 일도 하지 않아야 한다.
> 클래스 전용 버전의 경우에는 예정 크기보다 더 큰 블록을 처리해야 한다.

<br/>

### 항목 52 : 위치지정 new를 작성한다면 위치지정 delete도 같이 준비하자

---

위치지정 new와 위치지정 delete은 이 항목을 읽기 전까지 잘 모르고 있었다 해도 그다지 걱정할 것은 아니다.
그 대신, 다음과 같은 new 표현식을 썼을 때 호출되는 함수가 두 개라고 이야기한 항목 16 및 항목 17의 내용부터 머리에 올려두고 시작하자.

```c++
Widget* pw = new Widget;
```

위에서는 함수 두 개가 호출된다. 우선 메모리 할당을 위해 operator new가 호출되고, 그 뒤를 이어 Widget의 기본 생성자가 호출된다.

여기서, 첫 번째 함수 호출은 무사히 지나갔는데 두 번째 함수 호출이 진행되다가 예외가 발생한다고 가정해 보자.
이렇게 사고가 나 버렸을 경우, 첫 단계에서 이미 끝난 메모리 할당을 어떻게 해서든 취소하지 않으면 안 된다.
그냥 뒀다간 메모리 누출이 뻔하기 때문이다. 사용자 코드에서는 이 메모리를 해제할 수 없다.
Widget 생성자에서 예외가 튀어나오면 pw에 포인터가 대입될 일은 절대로 안 생기기 때문이다.
어떻게든 해제해야 하는 이 메모리에 대한 포인터를 사용자 코드에서 물어 올릴 방법은 이리 보고 저리 보고 다시 봐도 또 없을 것 같다.
따라서 1단계의 메모리 할당을 안전하게 되돌리는 중대 임무는 C++ 런타임 시스템에서 처리해야 하는 것이다.

이때 C++ 런타임 시스템이 해주어야 하는 일은 1단계에서 자신이 호출한 operator new 함수와 짝이 되는 버전의 operator delete 함수를
호출하는 것인데, 하지만 이게 제대로 되려면 operator delete 함수들 가운데 어떤 것을 호출해야 하는지를 런타임 시스템이 제대로 알고 있어야 가능하다.
하지만 우리가 상대하고 잇는 new/delete가 기본형 시그니처로 되어 있는 한 이 부분은 그다지 대수로운 사안은 아니다.
왜냐하면 기본형 operator new는

```c++
void* operator new(std::size_t size) throw(std::bad_alloc);
```

역시 기본형 operator delete와 짝을 맞추기 때문이다.

```c++
// 전역 유효범위에서의 기본형 시그니처
void operator delete(void* rawMemory) throw();

// 클래스 유효범위에서의 전형적인 기본형 시그니처
void operator delete(void* rawMemory, std::size_t size) throw();
```

따라서 표준 형태의 new 및 delete만 사용하는 한, 런타임 시스템은 new의 동작을 되돌릴 방법을 알고 있는 delete를 찾아내는 데 있어서
아무런 고민을 하지 않는다. 그런데 operator new의 기본형이 아닌 형태를 선언하기 시작하면서 이 new에 어떤 delete를 짝맞춰야 하는지에 대한
문제가 피어나게 된다. 비기본형이란 바로 다른 매개변수를 추가로 갖는 operator new 함수를 뜻한다.

예를 하나 들어보자. 어떤 클래스에 대해 전용으로 쓰이는 operator new를 만들고 있는데, 메모리 할당 정보를 로그로 기록해 줄 ostream을
지정받는 꼴로 만든다고 가정하자. 그리고 클래스 전용 operator delete는 기본형으로 만든다고 가정하자.

```c++
class Widget
{
public:
    static void* operator new(std::size_t size, std::ostream& logStream) throw(std::bad_alloc);
    static void operator delete(void* rawMemory, std::size_t size) throw();
};
```

이미 예상한 사람도 있겠지만 이 설계에는 문제가 있다. 그렇지만 어째서 문제가 있는지는 조금 뒤에 알아보도록 하자.
우선 용어를 정리해 보자.

operator new 함수는 기본형과 달리 매개변수를 추가로 받는 형태로도 선언할 수 있다.
이런 형태의 함수를 가리키는 말이 따로 있는데, 이것이 바로 **위치지정(placement)** new이다.
위에서 본 operator new는 그러니까 위치지정 버전이라고 부르면 된다.
말했듯이 위치지정 new는 개념적으로 그냥 추가 매개변수를 받는 new이므로 위치지정 new는 가지각색일 수 있지만,
이들 중 특히 유용한 놈이 하나 있다. 어떤 객체를 생성시킬 메모리 위치를 나타내는 포인터를 매개변수로 받는 것이 바로 그 주인공인데,
생김새는 다음과 같다.

```c++
void* operator new(std::size_t size, void* pMemory) throw();
```

이렇게 포인터를 추가로 받는 형태의 위치지정 new는 그 유용성을 인정받아 이미 C++ 표준 라이브러리의 일부로도 들어가 있다.
<new>만 #include하면 우리도 바로 쓸 수 있다. 이 버전의 new 함수는 표준 라이브러리의 여러 군데에서 쓰이고 있는데,
특히 vector의 경우에는 해당 벡터의 미사용 공간에 원소 객체를 생성할 때 이 위치지정 new를 쓰고 있다.
또한 위치지정 new의 원조이기도 하다. 매개변수를 추가로 받는 위치지정 new를 위치지정 new라고 부르게 된 것도 사실 이 원조 버전 때문이다.
어떻게 보면 이 위치지정 new라는 용어도 오버로딩된 셈이다. 사람들이 위치지정 new를 이야기 주제로 꺼낸다면 아마도 원조 버전,
그러니까 void* 타입의 매개변수 하나를 추가로 받는 operator new를 뜻하는 경우가 대부분일 것이다.
원조 버전 이야기인지 아닌지는 전후관계로 쉽게 알 수 있으니 헷갈리진 않을 테지만, 어쨌든 일반적인 의미의 위치지정 new라는 용어는
어떤 매개변수라도 추가로 받아들이는 operator new를 나타낸다는 사실을 유념해두자.
왜냐하면 위치지정 delete가 또 이 개념에서 갈라져 나오기 때문이다.

다시 Widget 클래스로 돌아와, 이 클래스는 메모리 누출을 유발할 수 있다. 이 클래스를 사용한 사용자 코드를 하나 보자.
Widget 객체 하나를 동적 할당할 때 cerr에 할당 정보를 로그로 기록하는 코드이다.

```c++
// operator new를 호출하는 데 cerr을 ostream 인자로 넘기는데, 이때 Widget 생성자에서 예외가 발생하면 메모리가 누출된다.
Widget* pw = new (std::cerr) Widget;
```

메모리 할당은 성공했지만 Widget 생성자에서 예외가 발생했을 경우, 앞에서 말한대로 operator new에서 저지른 할당을 되돌리는 일은
C++ 런타임 시슽메이 책임지고 해야 한다. 그런데 런타임 시스템 쪽에는 호출된 operator new가 어떻게 동작하는지 알아낼 방법이 없으므로,
자신이 할당 자체를 되돌릴 수 없다. 그 대신, 런타임 시슽메은 호출된 operator new가 받아들이는 **매개변수의 개수 및 타입이 똑같은** 버전의
operator delete를 찾고, 찾아냈으면 그 녀석을 호출한다. 지금 경우에 호출된 operator new는 ostream& 타입의 매개변수를 추가로 받아들이므로,
이것과 짝을 이루는 operator delete 역시 똑같은 시그니처를 가진 것이 마련되어 있어야 한다.

```c++
void operator delete(void*, std::ostream&) throw();
```

매개변수를 추가로 받아들인다는 면에서 위치지정 new와 비슷하므로, 이런 형태의 operator delete를 가리켜 위치지정 delete라고 한다.
그런데 지금의 Widget에는 operator delete의 위치지정 버전이 마련되이 있지 않기 때문에, 런타임 시스템 쪽에서는 위치지정 new로
저질러버린 메모리 할당을 어떻게 되돌려야 할지 갈팡질팔할 수밖에 없다. 어쩌겠는가 결국 아무것도 하지 않는다.
그러니까, 앞에서 본 코드에서 Widget 생성자가 예외를 던지면 **어떤 operator delete도 호출되지 않는다**는 말이다.

복잡해보이지만 정말 단순한 규칙이다. 추가 매개변수를 취하는 operator new 함수가 있는데 그것과 똑같은 추가 매개변수를 받는
operator delete가 짝으로 존재하지 않으면, 이 new에 해당 매개변수를 넘겨서 할당한 메모리를 해제해야 하는 상황이 오더라도
어떤 operator delete도 호출되지 않는다는 점만 기억하면 된다. 위의 코드에서 생길 수 있는 메모리 누출을 제거하려면,
로그 기록용 인자를 받는 위치지정 new와 짝이 되는 위치지정 delete를 Widget 클래스에 넣어 주어야 한다는 결론이 나오는거다.

```c++
class Widget
{
public:
    static void* operator new(std::size_t size, std::ostream& logStream) throw(std::bad_alloc);
    static void operator delete(void* pMemory, std::size_t size) throw();
    static void operator delete(void* pMemory, std::ostream& logStream) throw();
};
```

이렇게 바꿔 두면, 아래의 문장이 실행되다가 Widget 생성자에서 예외가 발생되더라도,

```c++
// 이전과 같은 사용자 코드이지만, 메모리 누출이 없다.
Widget* pw = new (std::cerr) Widget;
```

이제는 위치지정 new와 짝이 되는 위치지정 delete가 런타임 시스템에 의해 자동으로 호출된다.
Widget으로 하여금 메모리 누출을 막을 수 있도록 길을 만들어 주는 것이다.

그런데 위의 문장에서 Widget 생성자가 예외를 던지지 않았고 사용자 코드의 delete 문까지 다다랐다고 하면 어떤 일이 생길까?

```c++
delete pw; // 기본형의 operator delete가 호출된다.
```

주석에 써두었듯이, 이 경우에는 런타임 시스템이 기본형의 operator delete를 호출한다. 위치지정 버전을 호출하지 않는다는 것이다.
위치지정 delete가 호출되는 경우는 위치지정 new의 호출에 '묻어서' 함께 호출되는 생성자에서 예외가 발생할 때뿐이다.
그러니까, pw 같은 포인터에 delete를 적용했을 때 **절대로** 위치지정 delete를 호출하는 쪽으로 가지 않는다.

결국 이 말은 이렇게 풀이할 수 있다. 어떤 위치지정 new 함수와 조금이라도 연관된 모든 메모리 누출을 사전에 봉쇄하려면,
표준 형태의 operator delete를 기본으로 마련해 두어야 하고 그와 함께 위치지정 new와 똑같은 추가 매개변수를 받는 위치지정 delete도
빼먹지 말아야 한다고 말이다. 최소한 원인조차 찾기 힘든 이런 메모리 누출만큼은 확실히 안 생긴다고 장담한다.

단, 실수로 뺴먹지 말아야 하는 부분이 하나 있다. 바깥쪽 유효범위에 있는 어떤 함수의 이름과 클래스 멤버 함수의 이름이 같으면
바깥쪽 유효범위의 함수가 '이름만 같아도' 가려지게 되어 있단 말이다(항목 33 참조).
때문에 우리는 사용자 자신이 쓸 수 있다고 생각하는 다른 new들(표준 버전도 포함해서)을 클래스 전용의 new가 가리지 않도록
각별히 신경을 써야 한다. 예를 들어 달랑 위치지정 new만 선언된 기본 클래스가 버젓이 사용자에게 제공될 경우,
사용자 쪽에서는 표준 형태의 new를 써 보려다가 안 되는 것을 발견하고 황당한 슬픔에 빠질 수 있다.

```c++
class Base
{
public:
    // 이 new가 표준 형태의 전역 new를 가린다.
    static void* operator new(std::size_t size, std::ostream& logStream) throw(std::bad_alloc);
    ...
};

// 에러! 표준 형태의 전역 operator new가 가려진다.
Base* pb = new Base;

// 이건 문제없다. Base의 위치지정 new를 호출한다.
Base* pb = new (std::cerr) Base;
```

이건 기본 클래스를 상속받은 파생 클래스에서는 더 한다는 걸 알고 있을 것이다.
전역 operator new는 물론이고 자신이 상속받은 기본 클래스의 operator new까지 가려 버린다.

```c++
class Derived : public Base
{
public:
    ...
    // 기본형 new를 클래스 전용으로 다시 선언
    static void* operator new(std::size_t size) throw(std::bad_alloc);
    ...
};

// 에러! Base의 위치지정 new가 가려져 있다.
Derived* pd = new (std::clog) Derived;

// 문제없다. Derived의 operator new를 호출한다.
Derived* pd = new Derived;
```

이러한 이름 가리기에 대해서는 항목 33에서 자세히 다루어 놓았지만, 메모리 할당 함수를 작성하는 것만 신경 쓴다면 굳이 억지로 볼 필요는 없다.
기본적으로 C++가 전역 유효범위에서 제공하는 operator new의 형태는 다음의 세 가지가 표준이라는 점만 기억해두면 된다.

```c++
// 기본형 new
void* operator new(std::size_t) throw(std::bad_alloc);
// 위치지정 new
void* operator new(std::size_t, void*) throw();
// 예외불가 new
void* operator new(std::size_t, const std::nothrow_t&) throw();
```

어떤 형태이든 간에 operator new가 클래스 안에 선언되는 순간, 앞의 예제에서 보았듯 위의 표준 형태들이 몽땅 가려지는 것이다.
사용자가 이들 표준 형태를 쓰지 못하게 막자는 것이 원래 의도가 아니었다면, 우리 나름대로 넣어 준 사용자 정의 operator new 형태 외에
표준 형태들도 사용잦가 접근할 수 있도록 길을 열어 주도록 하자. 물론, operator new를 만들었다면 operator delete도 만드는 걸 잊지 말자.
클래스의 울타리 안에서 이런저런 할당/해제 함수들이 여느때와 똑같은 방식으로 동작했으면 하는 경우에는, 
그냥 클래스 전용 버전이 전역 버전을 호출하도록 구현해 두면 된다.

이것을 쉽게 할 수 있으면 더 좋을텐데, 한 가지 방법이 있다. 기본 클래스 하나를 만들고, 이 안에 new 및 delete의 기본 형태를 전부 넣어두자.

```c++
class StandardNewDeleteForms
{
public:
    // 기본형 new/delete
    static void* operator new(std::size_t size) throw(std::bad_alloc)
    { return ::operator new(size); }
    
    static void operator delete(void* pMemory) throw()
    { ::operator delete(pMemory); }
    
    // 위치지정 new/delete
    static void* operator new(std::size_t size, void* ptr) throw()
    { return ::operator new(size, ptr); }
    
    static void operator delete(void* pMemory, void* ptr) throw()
    { ::operator delete(pMemory, ptr); }
    
    // 예외불가 new/delete
    static void* operator new(std::size_t size, const std::nothrow_t& nt) throw()
    { return ::operator new(size, nt); }
    
    static void operator delete(void* pMemory, const std::nothrow_t&) throw()
    { ::operator delete(pMemory); }
};
```

표준 형태에 덧붙여 사용자 정의 형태를 추가하고 싶다면, 이제는 이 기본 클래스를 축으로 넓혀 가면 된다.
상속과 using 선언을 2단 콤보로 사용해서 표준 형태의 파생 클래스 쪽으로 끌어와 외부에서 사용할 수 있게 만든 후에,
원하는 형태의 사용자 정의 형태를 선언해 주자.

```c++
class Widget : public StandardNewDeleteForms
{
public:
    // 표준 형태가 보이도록 만든다/
    using StandardNewDeleteForms::operator new;
    using StandardNewDeleteForms::operator delete;
    
    // 사용자 정의 위치지정 new를 추가한다.
    static void* operator new(std::size_t size, std::ostream& logStream) throw(std::bad_alloc);
    // 앞의 것과 짝이 되는 delete를 추가한다.
    static void operator delete(void* pMemory, std::ostream& logStream) throw();
    ...
};
```

> operator new 함수의 위치지정 버전을 만들 때는 이 함수와 짝을 이루는 위치지정 버전의 operator delete 함수도 꼭 만들자.
> 이 일을 빼먹엇다가는, 찾아내기도 힘들며 또 생겼다가 안 생겼다가 하는 메모리 누출 현상을 경험하게 된다.

> new 및 delete의 위치지정 버전을 선언할 때는, 의도한 바도 아닌데 이들의 표준 버전이 가려지는 일이 생기지 않도록 주의하자.

<br/>

### 추가로

---

본문에서 현재 설정된 전역 new 처리자를 알아내는 직접적인 방법이 없어서,

```c++
new_handler globalHandler = set_new_handler(0);
set_new_handler(globalHandler);
```

이런 불편한 코드를 사용하였는데, C++11에서는 get_new_handler 함수가 추가되었다.

```c++
std::new_handler globalHandler = std::get_new_handler();
if (globalHandler) (*globalHandler)();
else throw std::bad_alloc();
```

<br/>

_참고_
- [Effective C++ 제3판](https://www.yes24.com/product/goods/17525589)
