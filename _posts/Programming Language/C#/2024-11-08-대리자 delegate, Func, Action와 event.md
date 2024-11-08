---
title: "대리자 delegate, Func, Action와 event"
writer: Langerak
date: 2024-11-8 12:00:00 +0800
categories: [C#]
tags: [C#]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/e9c9f437-d76d-4f3b-b293-7f74db14e557
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: C#
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

## 개요

---

**대리자**는 **매개 변수와 반환 형식이 정해져 있으면, 그 메서드를 참조할 수 있게 해주는 형식**이다.

이를 통해 **대리자를 매개변수로 넘겨 메서드를 매개변수 형태로 전달**할 수 있다.

그리고 대리자에 참조되어 있는 함수들을 한번에 실행 할 수 있는 이벤트로도 사용할 수 있다.

다른 말로는 **콜백(Callback)**이라고 한다.

다시 정리하자면,

- **동일한 형(매개변수/반환 타입)을 가진 메서드들을 대리자가 묶어서 관리하고, 한번에 호출할 수 있다.**
- **대리자 타입을 통해 함수의 매개변수로 전달 할 수 있다.**

<br/>

대리자에는 delegate, Func, Action이 있고, 델리게이트 한정 키워드로 event가 있다.

간단하게 요약하자면,

- `delegate`

  **메서드의 매개변수와 반환 타입을 지닌 대리자 형식**

  사용자가 정의한 메서드를 참조할 수 있으며, 메서드의 시그니처(매개변수와 반환 타입)을 명시적으로 지정한다.

- `Func`

  **반환 타입이 void가 아닌 제네릭 delegate**

  마지막 매개변수는 반환 타입을 나타내며, 나머지 매개변수는 입력 매개변수의 타입이다.

  최대 16개의 매개변수까지 지원한다.

- `Action`

  **반환 타입이 void인 제네릭 delegate**

  모든 매개변수는 입력 매개변수의 타입을 나타낸다.

  최대 16개의 매개변수까지 지원한다.

<br/>

## 1. delegate

---

`delegate`는 **메서드의 매개변수와 반환 타입을 지닌 대리자 형식**이다.

이는 명시적으로 정의해줘야 한다.

`delegate`는 **이벤트 처리, 콜백 함수, 메서드를 매개변수로 전달**하는 데 유용하게 사용된다.

delegate는 명시적으로 정의되어야 하며, 호출하려는 메서드와 일치하는 시그니처를 가져야 한다.

가령, 두 개의 int 매개변수를 사용하고 반환 형이 void인 메서드를 참조하는 delegate를 정의하려면 아래와 같이 사용할 수 있다.

```csharp
private delegate void MyDelegate(int a, int b);
private MyDelegate _myDelegate;

// 기본 사용법 1
_myDelegate += new MyDelegate(PlusNumber);
// 기본 사용법 2
_myDelegate += PlusNumber;
// 람다식
_myDelegate += (int a, int b) =>
{
  Debug.Log(a * b);
};
// 익명 함수
_myDelegate += delegate(int a, int b)
{
  Debug.Log(a / b);
};

private void PlusNumber(int a, int b)
{
  Debug.Log(a + b);
}

// 반환형이 void가 아닌 delegate
private delegate int MyDelegateTwo(int a, int b);
private MyDelegateTwo _myDelegateTwo;

_myDelegateTwo += MultiplyNumber;

private int MultiplyNumber(int a, int b)
{
  return a * b;
}

private void Awake()
{
  _myDelegate?.Invoke(10, 5);
  int result = _myDelegateTwo?.Invoke(10, 5) ?? 0;
}
```

MyDelegate는 두 개의 int 매개변수를 받고, 반환 형이 void인 PlusNumber 메서드를 참조한다.

또한 **익명 함수와 람다 식**으로 메서드를 참조할 수도 있다.

`Invoke`를 호출하여 delegate에 등록된 메서드들을 호출할 수 있다.

위 코드 처럼 delegate에 동일한 시그니처를 가진 여러 메서드를 참조하는 것을 **Multicast Delegate**라고 한다.

<br/>

## 2. Func

---

`Func`는 **반환 타입이 void가 아닌** 0 ~ 16개의 매개변수를 가진 함수를 나타내는 제네릭 델리게이트다.

Func나 Action을 사용하면 delegate를 편리하게 사용할 수 있다.

**마지막 타입 매개변수는 반환 타입**을 나타내며, **나머지 매개변수는 입력 매개변수의 타입**이다.

```csharp
private Func<int, int, int> myFunc;

myFunc += MultiplyNumber;

private int MultiplyNumber(int a, int b)
{
  return a * b;
}

private void Awake()
{
  int result2 = myFunc?.Invoke(10, 5) ?? 0;
}

```

이 경우, `Func<int, int, int>`에서 첫 번째, 두 번째 int는 매개변수이고 마지막 int는 반환형이다.

<br/>

## 3. Action

---

`Action`은 **반환 타입이 void인** 0 ~ 16개의 매개변수를 가진 함수를 나타내는 제네릭 델리게이트이다.

**모든 타입 매개변수**는 **입력 매개변수의 타입**을 나타낸다.

```csharp
private Action<int, int> myAction;

myAction += (a, b) =>
{
  Debug.Log(a + b);
};

private void Awake()
{
  myAction?.Invoke(20, 5);
}

```

이 경우, `Action<int, int>`는 두 개의 int 매개변수를 받는 함수를 참조한다.

Action은 콜백으로 자주 사용하는데, 코루틴이 끝났을 때의 콜백으로 사용하는 예시를 작성해 보았다.

```cpp
private IEnumerator CO_MoveCircle(float duration, Action doneCallback = null)
{
    float elapsedTime = 0;
    Vector3 startPos = circle.transform.position;
    Vector3 endPos = new Vector3(5, 5, 5);
    
    while (elapsedTime < duration)
    {
        circle.transform.position = Vector3.Lerp(startPos, endPos, elapsedTime / duration);
        elapsedTime += Time.deltaTime;
        yield return null;
    }
    
    doneCallback?.Invoke();
}

private void Awake()
{
    StartCoroutine(CO_MoveCircle(3f, () => Debug.Log("[DoneCallback] Circle Move Done!!")));
}
```

코루틴이 끝난 시점에 매개변수로 넘겨받은 Action 타입의 doneCallback을 호출하여 코루틴이 끝났음을 확인하는 예시이다.

<br/>

## 4. event

---

delegate는 접근 한정자를 public으로 설정 시, delegate 객체를 대입 연산자(=)를 써서 바꾸거나, Invoke 멤버 함수를 통해 멋대로 호출 가능하다는 단점이 있다.

이를 보완하기 위해 `event`라는 델리게이트 한정 키워드를 제공한다.

```cpp
public delegate int MyEvent(int a, int b);
public event MyEvent myEvent;
```

기존 delegate와 동일하며, event 키워드만 추가된다.

이벤트 델리게이트 객체는 다음과 같은 특징이 있다.

- **클래스 외부에서 이벤트 델리게이트에게 대입 연산자(=)는 사용 불가**
- **클래스 외부에서 Invoke 호출 불가**
- **메서드를 추가하거나 제거하는 복합 연산자(+=, -=)만 사용 가능**
  
<br/>

~~들여쓰기가 킹받게 됐는데 못본척 해주세요~~

_참고_

- [[C#] Delegate, Func, Action 이해하기: 차이점 및 사용 사례](https://blog.joe-brothers.com/csharp-delegate-func-action/)
- [[Unity/C#] 대리자 (delegate, Func, Action)와 event](https://velog.io/@luz0415/%EB%8C%80%EB%A6%AC%EC%9E%90-delegate-Func-Action)
