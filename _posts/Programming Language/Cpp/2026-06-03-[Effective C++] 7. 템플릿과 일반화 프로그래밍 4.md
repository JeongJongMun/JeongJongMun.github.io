---
title: "[Effective C++] 7. 템플릿과 일반화 프로그래밍 [4/4]"
description: >-
  이 글은 제 개인적인 공부를 위해 작성한 글입니다. 틀린 내용이 있을 수 있고, 피드백은 환영합니다.
writer: Langerak
date: 2026-06-03 12:00:00 +0800
categories: [Programming Language]
tags: [Programming Language]
pin: false
math: true
mermaid: true
published: false
---

### 항목 47 : 타입에 대한 정보가 필요하다면 특성정보 클래스를 사용하자

---

STL은 기본적으로 컨테이너 및 반복자, 알고리즘의 템플릿으로 구성되어 있지만, 이 외에 유틸리티라고 불리는 템플릿도 몇 개 들어 있다.
이들 중 하나가 advance라는 이름의 템플릿인데, 이 템플릿이 하는 일은 지정된 반복자를 지정된 거리만큼 이동시키는 것이다.

```c++
// iter를 d 단위만큼 전진시킨다. d < 0이면 iter를 후진시킨다.
template <typename IterT, typename DistT>
void advance(IterT& iter, DistT d);
```
간단히 개념만 놓고 볼 때 advance는 그냥 iter += d만 하면 될 것 같지만, 사실 이렇게 구현할 수는 없다.
+= 연산을 지원하는 반복자는 임의 접근 반복자밖에 없기 때문이다.
임의 접근 반복자보다 기능적으로 떨어지는 다른 반복자 타입의 경우에는 ++ 혹은 -- 연산을 d번 적용하는 것으로 advance를 구현해야 한다.

STL 반복자에 여러 종류가 있다는 사실을 잊지말자. STL 반복자는 각 반복자가 지원하는 연산에 따라 다섯 개의 범주로 나뉜다.

- **입력 반복자(input iterator)**

입력 반복자는 전진만 가능하고, 한 번에 한 칸씩만 이동하며, 자신이 가리키는 위치에서 읽기만 가능한데다가, 그것도 읽을 수 있는 횟수가 한 번뿐이다.
이 입력 반복자는 입력 파일에 대한 읽기 전용 파일 포인터를 본떠서 만들었고, C++ 표준 라이브러리의 istream_iterator가 대표적인 입력 반복자이다.

<br/>

- **출력 반복자(output iterator)**

출력 반복자는 입력 반복자와 비슷하지만 출력용인 점만 다르다.
즉, 오직 앞으로만 가고, 한 번에 한 칸씩만 이동하며, 자신이 가리키는 위치에서 쓰기만 가능한데다가 쓸 수 있는 횟수가 딱 한 번뿐이다.
이 출력 반복자는 출력 파일에 대한 쓰기 전용 파일 포인터를 본떠서 만들었고, ostream_iterator가 이 부류의 대표주자이다.

입력 반복자와 출력 반복자는 STL의 5대 반복자 범주 가운데 기능적으로 가장 처진다.
앞으로만 갈 수 있고 자신이 가리키는 위치에서 딱 한 번만 읽거나 쓸 수 있기 때문에, 단일 패스(one-pass) 알고리즘에만 제대로 쓸 수 있다.

<br/>

- **순방향 반복자(forward iterator)**
 
이것들보다 기능이 조금 강력한 반복자 범주가 순방향 반복자이다.
순방향 반복자는 입력 반복자와 출력 반복자가 하는 일은 기본적으로 다 할 수 있고,
여기에 덧붙여 자신이 가리키고 있는 위치에서 읽기와 쓰기를 동시에 할 수 있으며, 그것도 여러 번이 가능하다.
따라서 이 반복자에 속하는 녀석들은 다중 패스(multi-pass) 알고리즘에 문제없이 쓸 수 있다.
STL은 원칙적으로 단일 연결 리스트를 제공하지 않지만 몇몇 라이브러리를 보면 제공하는 것들이 있는데(대게 이름이 slist이다),
이 컨테이너에 쓰는 반복자가 바로 순방향 반복자이다. TR1의 해시 컨테이너(항목 54 참조)를 가리키는 반복자도 아마 순방향 반복자의 범주에 들어갈 것이다.

<br/>

- **양방향 반복자(bidirectional iterator)**

양방향 반복자는 순방향 반복자에 뒤로 갈 수 있는 기능을 추가한 것이다. STL의 list에 쓰는 반복자가 바로 이 범주에 들어간다.
set, multiset, map, multimap 등의 컨테이너에도 양방향 반복자를 쓴다.

<br/>

- **임의 접근 반복자(random access iterator)**

다섯 개 반복자 범주 중 가장 센 녀석은 임의 접근 반복자이다. 양방향 반복자에 "반복자 산술 연산(iterator arithmetic)" 수행 기능을 추가한 것이다.
쉽게 말해 주어진 반복자를 임의의 거리만큼 앞뒤로 이동시키는 일을 상수 시간 안에 할 수 있다는 것이다.
이러한 산술 연산은 포인터 산술 연산과 비슷하다.
사실 놀랄 만한 거리로 보기도 힘든 것이, 기본제공 포인터를 본떠서 임의 접근 반복자를 만들었기 때문이다.
기본제공 포인터는 임의 접근 반복자의 기능을 그대로 지니고 있다.
C++ 표준 라이브러리의 vector, deque, string에 사용하는 반복자는 임의접근 반복자이다.

<br/>

C++ 표준 라이브러리에는 지금까지 말한 다섯 개의 반복자 범주 각각을 식별하는 데 쓰이는 "태그(tag) 구조체"가 정의되어 있다.

```c++
struct input_iterator_tag {};
struct output_iterator_tag {};
struct forward_iterator_tag : public input_iterator_tag {};
struct bidirectional_iterator_tag : public forward_iterator_tag {};
struct random_access_iterator_tag : public bidirectional_iterator_tag {};
```

구조체들 사이의 상속 관계를 보면 is-a 관계인 것을 알 수 있는데, 딱 적합한 의미이다.
이를테면 모든 순방향 반복자는 입력 반복자도 될 수 있다. 이렇게 만들어진 public 상속을 어디에 쓰는지는 잠시후에 확인하자.

이제 advance로 돌아오자. 이렇듯 반복자들이 종류마다 가능한 것이 있고 불가능한 것이 있다는 점을 안 이상, 구현할 때 조금 신경을 써야 할 것 같다.
한 가지 방법이라면 소위 최소 공통 분모(lowest-common-denominator) 전략을 들 수 있다.
반복자를 주어진 횟수만큼 반복적으로 한 칸씩 증가시키거나 감소시키는 루프를 돌리는 것이다.
하지만 이 방법을 쓰면 선형 시간이 걸린다는 것은 쉽게 예측할 수 있다. 
상수 시간의 반복자 산술 연산을 쓸 수 있는 임의 접근 반복자 입장에서는 분명 손해이다.
그래서 임의 접근 반복자가 주어졌을 때는 상수 시간 연산을 이용할 수 있는 방법이 있었으면 좋겠다는 생각이다.

그러니까, 우리가 진짜로 하고 싶은 일은 advance를 다음과 같이 구현하는 거란 말이다.

```c++
template<typename IterT, typename DistT>
void advance(IterT& iter, DistT d)
{
    if (iter가 임의 접근 반복자이다)
    {
        iter += d;
    }
    else
    {
        if (d >= 0) { while (d--) ++iter; }
        else { while (d++) --iter; }
    }
}
```

알겠지만, 위의 코드가 제대로 되려면 iter 부분이 임의 접근 반복자인지 판단할 수 있는 수단이 있어야 한다.
그러니까, 이 iter의 타입이 IterT가 임의 접근 반복자 타입인지를 알아야 한다는 거다. 즉, 어떤 타입에 대한 정보를 얻어낼 필요가 있다.
어떻게 해야 하냐면, 바로 **특성정보(traits)**이다. 
특성정보란, 컴파일 도중에 어떤 주어진 타입의 정보를 얻을 수 있게 하는 객체를 지칭하는 개념이다.

특성정보는 C++에 미리 정의된 문법구조가 아니며, 키워드도 아니다. 그냥 C++ 프로그래머들이 따르는 구현 기법이며, 관례이다.
특성정보가 되려면 몇 가지 요구사항이 지켜져야 하는데, 특성 정보는 기본제공 타입과 사용자 정의 타입에서 모두 돌아가야 한다는 점이 그 중 하나이다.
이를테면 advance는 포인터(const char* 등) 및 int를 받아서 호출될 때도 제대로 동작할 수 있어야 한다.
하지만 이것의 정확한 의미는 '특성정보 기법을 포인터 등의 기본제공 타입에 적용할 수 있어야 한다'라는 것이다.

'특성정보는 기본제공 타입에 대해서 쓸 수 있어야 한다'라는 사실을 뒤집어 생각하면,
어떤 타입 내에 중첩된 정보 등으로는 구현이 안 된다는 말로도 풀이할 수 있다. 포인터만 봐도, 포인터 안에 정보를 넣을 방법이 없지 않는가.
결국, 어떤 타입의 특성정보는 그 타입의 외부에 존재하는 것이어야 한다.
특성정보를 다루는 표준적인 방법은 해당 특성정보를 템플릿 및 그 템플릿의 1개 이상의 특수화 버전에 넣는 것이다.
반복자의 경우, 표준 라이브러리의 특성정보용 템플릿이 iterator_traits라는 이름으로 준비되어 있다.

```c++
// 반복자 타입에 대한 정보를 나타내는 템플릿
template<typename IterT>
struct iterator_traits;
```

보다시피, iterator_traits는 구조체(어차피 클래스) 템플릿이다.
예전부터 이어져 온 관례에 따라, 특성정보는 항상 구조체로 구현하는 것으로 굳어져 있다.
관례가 하나 더 있는데, 위처럼 특성정보를 구현하는 데 사용한 구조체를 가리켜 '특성정보 **클래스**'라고 부르낟.

iterator_traits 클래스가 동작하는 방법은 이렇다.
iterator_traits<IterT> 안에는 IterT 타입 각각에 대해 iterator_category라는 이름의 typedef 타입이 선언되어 있다.
이렇게 선언된 typedef 타입이 바로 IterT의 반복자 범주를 가리키는 것이다.

iterator_traits 클래스는 이 반복자 범주를 두 부분으로 나누어 구현한다.
첫 번째 부분은 사용자 정의 반복자 타입에 대한 구현인데, 사용자 정의 반복자 타입으로 하여금
iterator_category라는 이름의 typedef 타입을 내부에 가질 것을 요구사항으로 둔다.
이때 이 typedef 타입은 해당 태그 구조체에 대응되어야 한다.
예를 들어, deque의 반복자는 임의 접근 반복자이므로, deque 클래스(템플릿)에 쓸 수 있는 반복자는 다음과 같은 형태일 것이다.

```c++
template < ... >
class deque
{
public:
    class iterator
    {
    public:
        typedef random_access_iterator_tag iterator_category;
        ...
    };
    ...
};
```

다른 예로, list의 반복자는 양방향 반복자이기 때문에 다음과 같이 되어 있다.

```c++
template < ... >
class list
{
public:
    class iterator
    {
    public:
        typedef bidirectional_iterator_tag iterator_category;
        ...
    };
    ...
};
```

이 iterator 클래스가 내부에 지닌 중첩 typedef 타입을 앵무새처럼 똑같이 재생한 것이 iterator_traits이ㅏㄷ.

```c++
template <typename IterT>
struct iterator_traits
{
    typedef typename IterT::iterator_category iterator_category;
    ...
};
```

위의 코드는 확실히 사용자 정의 타입에 대해서는 잘 돌아가지만, 반복자의 실제 타입이 포인터인 경우에는 전혀 안 돌아간다.
포인터 안에 typedef 타입이 중첩된다는 것부터가 도무지 말이 안 되기 때문이다.
iterator_traits 구현의 두 번재 부분은 바로 반복자가 포인터인 경우의 처리이다.

포인터 타입의 반복자를 지원하기 위해, 

@@ 336페이지부터







<br/>

_참고_
- [Effective C++ 제3판](https://www.yes24.com/product/goods/17525589)
