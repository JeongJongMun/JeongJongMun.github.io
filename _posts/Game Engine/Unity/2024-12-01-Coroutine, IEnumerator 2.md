---
title: "Coroutine, IEnumerator 2"
writer: Langerak
date: 2024-12-01 13:00:00 +0800
categories: [Unity]
tags: [Unity]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/user-attachments/assets/a4e0239c-2601-4ef2-8110-45968a3fa100
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Coroutine, IEnumerator
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

## Coroutine : YieldInstruction

---

### Coroutine

StartCoroutine 함수의 반환형인 Coroutine 클래스는 유니티에서 실행 중인 코루틴을 나타내는 클래스이다.

이 클래스는 코루틴의 현재 실행 상태를 추적하고 관리한다.

특정 코루틴의 참조를 저장하고 중지하고 재개할 수 있다.

```csharp
private Coroutine _coroutine;
private void OnDisable()
{
    if (_coroutine != null)
    {
        StopCoroutine(_coroutine);
        _coroutine = null;
    }
}

private void OnDestroy()
{
    if (_coroutine != null)
    {
        StopCoroutine(_coroutine);
        _coroutine = null;
    }
}

private void Start()
{
    _coroutine = StartCoroutine(MyNumCoroutine(3));
}
```

코루틴 클래스를 사용할 때, null 체크를 항상 하는 것이 안전하고 코루틴이 완료되면 참조를 null로 설정하는 것이 좋다.

그리고 OnDisable과 OnDestory 이벤트 함수 내에서 실행 중인 코루틴을 정리해야 한다.

OnDestroy는 항상 호출을 보장받는 것이 아니기에, OnDisable에서도 실행 중인 코루틴을 정리하자.

### YieldInstruction

Coroutine 클래스는 베이스 클래스인 YieldInstruction 클래스를 상속받는다.

YieldInstruction 클래스는 코루틴의 실행을 제어하기 위한 기본 클래스이다.

유니티에서는 아래와 같은 여러 YieldInstruction 타입을 제공한다.

```csharp
// 다음 Update 호출 시까지 대기
yield return null;
// time만큼의 시간(초)이 지난 후 첫 프레임까지 대기
yield return new WaitForSeconds(float time);
// time만큼의 시간(초)이 지난 후 첫 프레임까지 대기
// TimeScale의 영향을 받지 않음.
yield return new WaitForSecondsRealtime(float time);
// 다음 FixedUpdate 호출 시까지 대기
yield return new WaitForFixedUpdate();
// 모든 렌더링 작업이 완료되어 프레임이 끝날 때까지 대기
yield return new WaitForEndOfFrame();
// 조건이 참이 될 때까지 대기 (Func<bool> predicate)
yield return new WaitUntil(() => true);
// 조건이 거짓이 될 때까지 대기
yield return new WaitWhile(() => false);
```

<br/>

## 코루틴이 가지는 특징들

---

- 반드시 `IEnumerator`를 반환해야 한다.
- `yield return`을 만나는 순간마다 다음 구문이 실행되는 프레임으로 나뉘게된다.
- `yield break`를 만나면 바로 코루틴이 종료된다.
- 코루틴을 실행하려면 꼭 `MonoBehaviour`를 상속받는 객체가 있어야 한다.
- 코루틴을 다루는 메서드들은 모두 `MonoBehaviour` 클래스에 구현돼 있다.
- 코루틴에는 **소유권**이라는 개념이 있는데, 소유권을 가진 객체가 비활성화되거나 파괴되면 해당 객체가 소유한 모든 코루틴이 중단된다.
- 비활성화된 객체에 코루틴 시작을 요청하면 해당 코루틴은 실행되지 않는다.
- 코루틴은 메인 스레드에서 시작된다. 코루틴은 절대 멀티 스레드가 아니다.

위 특징들은 코루틴을 사용한다면 반드시 알아야 한다.

<br/>

## WaitForSeconds에 대한 오해

---

보통 `WaitForSeconds`를 사용한다고 하면 파라미터로 넘긴 시간이 정확하게 흐르기 전까지는 해당 코루틴에서는 아무런 연산도 수행되지 않는다고 생각하기 쉽다. 하지만 실상은 그렇지 않다.

```csharp
// 1초 대기
yield return new WaitForSeconds(1.0f);

// 사실 위의 코드는 아래의 코드와 동일한 동작을 수행
var elapsed    = 0.0f;
var timeLength = 1.0f;
while (elapsed < timeLength)
{
    yield return null;
    elapsed += Time.deltaTime;
}
```

실제로는 해당 조건이 내부적으로 충족될 때까지 매 프레임마다 위와 같은 연산을 수행하고 다시 조건을 검사하고 있었던 거다.

또한, 위 동작을 보고 추측할 수 있듯이 정확히 1초가 흐르는 것을 기다리는 것이 아니라, 연산을 수행한 이후 조건이 충족되는 해당 프레임에서 다음 코드가 실행된다. 그 결과, 거의 반드시 오차가 발생하게 된다.

즉, 정확하게 지정한 시간이 지나자마자 다음 코드가 실행되는 경우는 거의 없다.

<br/>

## MonoBehaviour를 상속받지 않는 클래스에서의 코루틴 실행과 메모리 최적화

---

개발을 하다 보면 매니저 단위를 MonoBehaviour를 상속 받지 않는 클래스에서 코루틴을 실행하고 싶을 때가 있다.

이 때 활용할 수 있는 테크닉이 코루틴을 대신 실행해주는 대리자 느낌의 클래스를 만들어 두는 것이다.

또한 new WaitForSeconds와 같이 자주 사용되는 YieldInstruction들을 캐싱하여 메모리 최적화를 할 수 있는 기법들이 있다.

```csharp
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class CoroutineHelper : MonoBehaviour
{
    private static CoroutineHelper instance;
    private static Dictionary<string, Coroutine> coroutineDict = new Dictionary<string, Coroutine>();

    private static readonly Dictionary<float, WaitForSeconds> waitForSecondsCache = new Dictionary<float, WaitForSeconds>();
    private static readonly WaitForEndOfFrame waitForEndOfFrame = new WaitForEndOfFrame();
    private static readonly WaitForFixedUpdate waitForFixedUpdate = new WaitForFixedUpdate();
    
    private static CoroutineHelper Instance
    {
        get
        {
            if (instance == null)
            {
                var go = new GameObject("CoroutineHelper");
                instance = go.AddComponent<CoroutineHelper>();
                DontDestroyOnLoad(go);
            }
            return instance;
        }
    }

    private void OnDisable()
    {
        StopAllCoroutines();
    }

    private void OnDestroy()
    {
        StopAllCoroutines();
        instance = null;
        waitForSecondsCache.Clear();
    }
    
    public static WaitForSeconds GetWaitForSeconds(float seconds)
    {
        if (!waitForSecondsCache.TryGetValue(seconds, out var wait))
        {
            wait = new WaitForSeconds(seconds);
            waitForSecondsCache[seconds] = wait;
        }
        return wait;
    }

    public static WaitForEndOfFrame GetWaitForEndOfFrame() => waitForEndOfFrame;
    
    public static WaitForFixedUpdate GetWaitForFixedUpdate() => waitForFixedUpdate;

    public static Coroutine StartCoroutine(string key, IEnumerator routine)
    {
        StopCoroutine(key);
        var coroutine = Instance.StartCoroutine(WrapCoroutine(key, routine));
        coroutineDict[key] = coroutine;
        return coroutine;
    }

    public static void StopCoroutine(string key)
    {
        if (coroutineDict.TryGetValue(key, out var coroutine))
        {
            if (instance != null)
            {
                instance.StopCoroutine(coroutine);
            }
            coroutineDict.Remove(key);
        }
    }

    public static void StopAllCoroutines()
    {
        if (instance != null)
        {
            ((MonoBehaviour)instance).StopAllCoroutines();
        }
        coroutineDict.Clear();
    }

    public static bool IsRunning(string key)
    {
        return coroutineDict.ContainsKey(key);
    }

    private static IEnumerator WrapCoroutine(string key, IEnumerator routine)
    {
        yield return routine;
        coroutineDict.Remove(key);
    }
}
```

위 CoroutineHelper 스크립트는 MonoBehaviour를 상속받지 않는 일반 클래스에서도 코루틴을 사용할 수 있게 해주는 유틸리티 클래스이다.

1. 코루틴 전역 관리
  - 싱글톤 패턴을 사용해 어디서든 접근 가능
  - DontDestroyOnLoad로 씬 전환에도 유지
  - Dictionary를 통한 체계적인 코루틴 관리
2. 메모리 최적화
  - WaitForSeconds 인스턴스를 캐싱하여 가비지 생성 최소화
  - WaitForEndOfFrame, WaitForFixedUpdate 인스턴스 재사용
  - WrapCoroutine을 사용하여 완료된 코루틴의 자동 정리

등의 목적과 장점이 있다.

<br/>

_참고_

---

- [유니티 기본기 : 코루틴(Coroutine)](https://medium.com/supercent-blog/%EC%9C%A0%EB%8B%88%ED%8B%B0-%EA%B8%B0%EB%B3%B8%EA%B8%B0-%EC%BD%94%EB%A3%A8%ED%8B%B4-coroutine-5048334a2e2f)
- Claude
