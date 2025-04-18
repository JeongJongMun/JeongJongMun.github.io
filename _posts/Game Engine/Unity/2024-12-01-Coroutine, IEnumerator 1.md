---
title: "Coroutine, IEnumerator 1"
writer: Langerak
date: 2024-12-01 12:00:00 +0800
categories: [Game Engine, Unity]
tags: [Game Engine, Unity]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/user-attachments/assets/ff18fde7-a49a-4430-a495-7a546b4e6a5d
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Coroutine, IEnumerator
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

## Coroutine

---

**Coroutine이란 Co(함께) + Routine의 합성어이다.**

여러 루틴이 협력적으로 실행되면서 실행 지점을 주고받을 수 있는 프로그램 구성 요소를 의미한다.

일반 함수는 한번 실행되면 끝까지 실행되지만, 코루틴은 중간에 실행을 멈추고 다시 돌아올 수 있다.

코루틴을 사용한다면 필요한 순간에만 반복하고 필요하지 않을 때에는 사용하지 않음으로써 자원관리를 효과적으로 할 수 있다.

<br/>

## IEnumerator

---

**IEnumerator는 Interface + Enumerator이다.** IEnumerator를 보기 전에 다른 기초 지식을 공부해보자.

C#의 Enumerator(열거자)는 다른 언어에서 Iterator(반복자)라고 부르고, 열거자는 디자인 패턴 중 반복자 패턴을 구현해둔 것이다.

반복자 패턴을 간단하게 설명하면, 복잡하고 다양한 컬렉션 자료구조들의 내부 구조를 노출하지 않고 동일한 방법으로 요소들을 열거하는 것이다.

열거자는 리스트나 연결 리스트를 순회할 수 있게 도와주는 객체인 것이다.

하지만 코루틴은 컬렉션은 아니고 코루틴에서 실행 흐름 제어 용도로 활용된다. 위에서 코루틴은 중간에 실행을 멈추고 다시 돌아올 수 있다고 했는데, 이러한 **실행/중단 재개 기능을 구현하는 데에 열거자를 사용**하는 것이다.

(더 자세한 Enumerator와 Enumerable에 대한 내용은 다른 포스팅에서)

그리고 **IEnumerator**는 이러한 Enumerator를 인터페이스로 구현해둔 것이고 두 가지 핵심 용도가 있다.

1. 컬렉션 순회 도구
- Current로 현재 요소 접근
- MoveNext()로 다음 요소로 이동
- Reset()으로 초기화
2. **코루틴 제어 도구**
- yield return 으로 실행 중단점 지정
- MoveNext()로 다음 실행 지점으로 이동
- Current로 yield return 값 전달

```csharp
namespace System.Collections
{
  public interface IEnumerator
  {
    object Current { get; }

    bool MoveNext();

    void Reset();
  }
}
```

<br/>

## 코루틴 사용

---

```csharp
private void Start()
{
  StartCoroutine(nameof(MyCoroutine));
  StopCoroutine(nameof(MyCoroutine));
  
  StartCoroutine(MyNumCoroutine(1));
  StopCoroutine(MyNumCoroutine(1));
  
  var ienumerator = MyNumCoroutine(2);
  StartCoroutine(ienumerator);
  StopCoroutine(ienumerator);

  var coroutine = StartCoroutine(MyNumCoroutine(3));
  StopCoroutine(coroutine);
}

private IEnumerator MyNumCoroutine(int coNumber)
{
  Debug.Log($"Coroutine Start {coNumber}");;
  yield return new WaitForSeconds(1f);
  Debug.Log($"Coroutine End {coNumber}");
}

private IEnumerator MyCoroutine()
{
  Debug.Log("Coroutine Start");
  yield return new WaitForSeconds(1f);
  Debug.Log("Coroutine End");
}
```

MonoBehaviour 클래스의 `StartCoroutine()`과 `StopCoroutine()`을 호출하여 코루틴을 시작하고 종료할 수 있다.

각 함수의 매개 변수로 전달 가능한 것들은 아래와 같다.

- IEnumerator
- string (코루틴 메서드 이름)
- YieldInstruction

StartCoroutine의 반환형은 Coroutine 클래스이고, 이는 YieldInstruction을 상속받는다.

참고로 위 코드에서 다른 코루틴들은 모두 잘 멈추지만, 아래 코루틴은 정상적으로 정지되지 않는다.

```csharp
StartCoroutine(MyNumCoroutine(1));
StopCoroutine(MyNumCoroutine(1));
```

`StopCoroutine(MyNumCoroutine(1))`이 호출될 때 새로운 IEnumerator 인스턴스가 생성되고, 이 인스턴스는 `StartCoroutine` 함수 매개변수로 들어간 IEnumerator 인스턴스와 다른 객체이다.

> 2부에 이어서 작성
