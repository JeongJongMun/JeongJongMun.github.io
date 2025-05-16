---
title: "싱글톤 패턴 Singleton Pattern"
writer: Langerak
date: 2025-05-16 12:00:00 +0800
categories: [Design Pattern]
tags: [Design Pattern]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/user-attachments/assets/689a524c-46bf-47c6-972e-671795e4305e
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Singleton Pattern
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

## 개요

---

**싱글톤(Singleton) 패턴**은 디자인 패턴 중, 사용하기 간단하고 많이 사용되는 패턴 중 하나이다.

싱글톤 패턴을 따르는 클래스는 생성자가 여러 차례 호출되더라도 **실제로 생성되는 객체는 하나**이고

**최초 생성 이후에 호출된 생성자는 최초의 생성자가 생성한 객체를 반환**한다.

즉, 클래스의 인스턴스화를 단일 인스턴스로 제한한다.

시스템 전체에서 정확히 하나의 객체가 필요하거나, 공통적으로 사용하는 전역 변수나 자원, 데이터, 게임 전체를 관장하는 매니저 클래스에서 유용하게 사용할 수 있다.

<br/>

## 유니티에서의 싱글톤 패턴 구현

---

유니티에서 싱글톤을 구현할 때 순수 클래스로 구현할 수도 있고 Monobehaviour를 상속받은 유니티 객체로 구현할 수도 있다.

아래는 순수 C# 클래스로 구현한 간단한 싱글톤 클래스이다.

```csharp
public abstract class SingletonBase<T> where T : class, new()
{
    private static T instance = null;

    public static T Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new T();
            }
            return instance;
        }
    }
}

```

위 SingletonBase 클래스를 상속받아 원하는 싱글톤 클래스를 구현할 수 있다.

구현한 싱클톤 클래스 이름이 TestSingleton 이라고 할 때,

외부에서 TestSingleton.Instance.FuncName() 와 같이 접근 가능하다.

```csharp
using Unity.VisualScripting;
using UnityEngine;

public abstract class MonoBehaviourSingletonBase<T> : MonoBehaviour where T : MonoBehaviour
{
    private static T instance = null;

    public static T Instance
    {
        get
        {
            if (instance == null)
            {
                var go = GameObject.Find(typeof(T).Name);
                if (go == null)
                {
                    go = new GameObject(typeof(T).Name);
                    instance = go.GetOrAddComponent<T>();
                }
            }
            return instance;
        }
    }
    
    protected virtual void Awake()
    {
		    if (Instance != null && Instance != this)
		    {
				    Destroy(gameObject);
				    return;
		    }
		    
		    Instance = this as T;
		    DontDestoryOnLoad(gameObject);
    }
}

```

아래와 같은 경우에 MonoBehaviour 싱글톤을 사용해야 할 수도 있다.

1. 싱글톤 내에서 Start, Update 등 MonoBehaviour 함수를 사용해야 할 경우
2. 코루틴을 사용해야 할 경우

<br/>

## 문제점

---

하지만 MonoBehaviour 싱글톤을 사용할 때 발생하는 빈번한 문제 중 하나는 싱글톤 오브젝트가 중복으로 생성될 수 있다는 점이다.

이는 특히 유니티에서 씬을 전환 시에 자주 발생하는 문제이다.

유니티는 씬을 전환할 때 기본적으로 모든 게임 오브젝트를 파괴하고 새로운 씬을 로드한다.

이 때 새 씬이 로드될 때 싱글톤을 포함한 오브젝트가 다시 생성될 수 있다.

또는 싱글톤이 포함된 프리팹을 여러 신에 배치하거나 같은 씬에 여러 개 배치할 경우도 중복으로 생성될 수 있다.

싱글톤 오브젝트가 중복 생성된다면 각 싱글톤의 Start, Update와 같은 함수가 중복으로 호출 될 수 있고, 비정상적인 동작이 실행될 수 있다.

따라서 싱글톤에 DonDestoryOnLoad를 설정하고, 인스턴스 생성 시에 인스턴스를 꼭 체크하여야 한다.

싱글톤 패턴은 작은 단위의 프로젝트에서 매니저 단위를 만들 때 정말 편리하지만, 객체 간 결합도가 높아 프로젝트가 커질 수록 유지보수가 어렵다는 점이 있다.

무조건 좋은 것은 아니기에 조심하며 사용하자.

<br/>

_참고_

- [Unity에서의 Singleton 1편 - 싱글턴 클래스 만들기](https://velog.io/@the_paper__/Unity에서의-Singleton-1편-싱글턴-클래스-만들기)

- [Unity에서의 Singleton 2편 - MonoBehaviour Singleton의 문제점](https://velog.io/@the_paper__/Unity에서의-Singleton-2편-MonoBehaviour-Singleton의-문제점)
