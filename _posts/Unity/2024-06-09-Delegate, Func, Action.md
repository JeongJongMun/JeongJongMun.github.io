---
title: "Delegate, Func, Action"
writer: Langerak
date: 2024-06-9 06:00:00 +0800
categories: [Unity]
tags: [Unity]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/e753266b-b0f8-4c4d-9361-f0e8802987d2
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Unity
---

> 본 글은 제 개인적인 공부를 위해 작성한 글입니다. 틀린 내용이 있다면 언제든지 피드백을 주시면 감사하겠습니다. 참고로만 활용해주시길 바랍니다.

<br/><br/>

## 개요

---

C#에서 `Delegate`, `Func`, `Action`은 이벤트 처리, 비동기 프로세스 처리 등을 위해 유연하고 재사용 가능한 코드를 작성하는 데 필수적인 요소이다.

간단하게 요약해보자면,

- `Delegate`
    
    **사용자가 정의한 메서드 참조를 위한 델리게이트이다.**
    
    메서드의 시그니처(입력 매개변수와 반환 타입)을 명시적으로 정의하며,
    
    **이벤트 처리 및 콜백 함수**에 유용하게 사용된다.
    
    모든 타입의 매개변수는 입력 매개변수의 타입을 나타내거나 반환 타입을 지정할 수 있다.
    
- `Func`
    
    **반환 값이 있는 메서드를 참조**하는 **제네릭 델리게이트**이다.
    
    **마지막 타입 매개변수는 반환 타입**을 나타내며, **나머지 매개변수는 입력 매개변수의 타입**이다.
    
- `Action`
    
    반환 타입이 없는(void) 메서드를 참조하는 제네릭 델리게이트이다.
    
    **모든 타입 매개변수**는 **입력 매개변수의 타입**을 나타낸다.
    
<br/><br/>

## 1. Delegate

---

`Delegate`는 **메서드를 참조하는 객체**로, **메서드의 시그니처**(입력 매개변수와 반환 타입)**에 대한 정보를 포함**한다.

이를 통해 런타임에 해당 시그니처를 갖는 메서드를 호출할 수 있다.

`Delegate`는 **이벤트 처리, 콜백 함수, 메서드를 매개변수로 전달**하는 데 유용하다.

Delegate는 명시적으로 정의되어야 하며, 호출하려는 메서드와 일치하는 시그니처를 가져야 한다.

가령, 두 개의 `int` 매개변수를 사용하고 `float`를 반환하는 메서드를 참조하는 Delegate를 정의하려면 다음과 같이 사용할 수 있다.

```csharp
public delegate float CustomDelegate(int a, int b);

public class MyClass
{
    public static float Divide(int a, int b)
    {
        return (float)a / b;
    }
}

public class MainClass
{
    public static void Main()
    {
        CustomDelegate del = MyClass.Divide;
        float result = del(10, 5);
        Console.WriteLine("Result: " + result);
    }
}
```

이 경우, `CustomDelegate` 델리게이트는 두 개의 `int` 입력 매개변수를 받아들이고 `float` 값을 반환하는 `MyClass.Divide` 메서드를 참조한다.

델리게이트는 메서드 참조를 저장하는 데 사용되며, 호출 시 해당 메서드를 실행한다.

델리게이트는 단일 메서드 참조 뿐만 아니라, **동일한 시그니처를 가진 여러 메서드를 참조**하는 데도 사용할 수 있다. (멀티캐스팅 델리게이트)

<br/><br/>

## 2. Func

---

`Func`는 반환 타입이 void가 아닌 0 ~ n개의 매개변수를 가진 함수를 나타내는 제네릭 델리게이트다.

- 제네릭(Generic)이란 프로그래밍 언어에서 타입에 종속되지 않고, 재사용 가능한 코드를 작성하는 방법이다.

**마지막 타입 매개변수는 반환 타입**을 나타내며, **나머지 매개변수는 입력 매개변수의 타입**이다.

```csharp
public class MyClass
{
    public static int GetNumber()
    {
        return 42;
    }

    public static string ToString(int number)
    {
        return "Number: " + number;
    }
}

public class MainClass
{
    public static void Main()
    {
        Func<int> numberFunc = MyClass.GetNumber;
        int number = numberFunc();
        Console.WriteLine("Number: " + number);

        Func<int, string> toStringFunc = MyClass.ToString;
        string result = toStringFunc(42);
        Console.WriteLine(result);
    }
}
```

이 경우, `Func<int>`는 매개변수가 없고 `int` 값을 반환하는 `MyClass.GetNumber` 메서드를 참조한다.

그리고 `Func<int, string>`은 하나의 `int` 매개변수를 받고 `string`을 반환하는 `MyClass.ToString` 메서드를 참조한다.

<br/><br/>

## 3. Action

---

`Action`은 반환 타입이 void인 메소드를 위해 특별히 설계된 제네릭 델리게이트이다.

Action은 Func와 마찬가지로 사용자 정의 델리게이트 대신 사용할 수 있어 코드를 간소화하고 표현력을 높일 수 있다.

**모든 타입 매개변수**는 **입력 매개변수의 타입**을 나타낸다.

```csharp
public class MyClass
{
    public static void PrintHello()
    {
        Console.WriteLine("Hello!");
    }

    public static void PrintSum(float a, float b)
    {
        Console.WriteLine("Sum: " + (a + b));
    }
}

public class MainClass
{
    public static void Main()
    {
        Action helloAction = MyClass.PrintHello;
        helloAction();

        Action<float, float> sumAction = MyClass.PrintSum;
        sumAction(3.5f, 5.5f);
    }
}
```

이 경우, `Action`은 매개변수가 없는 `MyClass.PrintHello` 메서드를 참조한다.

그리고 `Action<float, float>`는 두 개의 `float` 매개변수를 받는 `MyClass.PrintSum` 메서드를 참조한다.

<br/><br/>

_참고_

- [https://blog.joe-brothers.com/csharp-delegate-func-action/](https://blog.joe-brothers.com/csharp-delegate-func-action/)