---
title: "언리얼 리플렉션 시스템 Reflection"
writer: Langerak
date: 2025-04-18 12:00:00 +0800
categories: [Game Engine, Unreal]
tags: [Game Engine, Unreal]
pin: false
math: true
mermaid: true
image:
  path: https://1drv.ms/i/c/0feb846c92fbe54a/IQTzpBTme7qwSZ5zoY15bcI8Abc4xPSd_TuQiU0Mk325E6w?width=1920&height=1080
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Reflection
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

## 리플렉션

---

**리플렉션은 프로그램이 실행 시간에 자기 자신을 조사하는 기능이다.**

자기 자신이란 클래스, 구조체, 함수, 멤버 변수, 열거형 등을 의미한다

즉, 런타임에 객체의 타입을 보는 것을 포함해 구조와 행동까지 수정하는 것이 리플렉션이다.

언리얼 내의 여러가지 시스템들이 이 리플렉션에 의존한다.

- **에디터의 디테일 패널**
- **시리얼라이제이션**
- **가비지 컬렉션**
- **네트워크 리플리케이션**
- **블루프린트와 C++ 커뮤니케이션 등**

자바나 C#에서는 리플렉션을 지원하지만, C++에서는 리플렉션을 지원하지 않아, 언리얼에 자체적으로 구축되어 있다.

전형적으로 이러한 리플렉션은 **프로퍼티 시스템**이라고 부르는데, **리플렉션**은 그래픽 용어이기도 하기 때문이다.

리플렉션 시스템은 옵션이다.

리플렉션 시스템에 보이도록 했으면 하는 유형이나 프로퍼티에 매크로를 달아주면, Unreal Header Tool(UHT)가 그 프로젝트를 컴파일할 때 해당 정보를 수집한다.

<br/>

## **리플렉션 매크로 종류**

---

- UCLASS()
- UPROPERTY()
- UFUNCTION()
- UENUM()
- USTRUCT()
- UMETA() 등등

<br/>

## 리플렉션 사용 예제

---

언리얼 C++는 가비지 콜렉션을 제공하는데, 리플렉션되지 않은 프로퍼티에 대한 메모리 관리는 하지 않는다. 이를 조심해야 한다.

```cpp
// 리플렉션이 있는 타입은 이 헤더파일을 인클루드해서 UHT에 알린다.
#include "MyObject.generated.h"

// MyObject는 리플렉션 되는 클래스임을 나타낸다.
UCLASS()
class UMyObject : public UObject
{
    // 자동 생성된 코드가 여기에 삽입된다는 마커.
    GENERATED_BODY()
    
    // MyFunc는 리플렉션 되는 멤버 함수임을 나타낸다.
    UFUNCTION()
    void MyFunc(int, double) {}
    
    // MyData는 리플렉션 되는 멤버 변수임을 나타낸다.
    UPROPERTY()
    int32 MyData;
    
    // 리플렉션이 되지 않는 것을 섞어도 된다.
    // 하지만 리플렉션 시스템에 보이지 않으므로 주의해야한다.
    uint8 MyNum;
    // 예를 들면 리플렉션 되지 않는 UObject 포인터를 저장하는 것은 
    // 가비지 컬렉터가 레퍼런스를 확인할 수 없기 때문에 위험하다.
    UObject* MyObjectRef;
}

// MyEnum은 리플렉션 되는 열거형임을 나타낸다.
UENUM()
enum class EMyEnum
{
    ....
};

// MyStruct는 리플렉션 되는 구조체임을 나타낸다.
USTRUCT()
struct FMyStruct
{
    GENERATED_BODY()
    
    UPROPERTY()
    int32 MyData;
    
    // 구조체의 멤버함수는 UFUNCTION으로 지정할 수 없다!
    // UFUNCTION()
    void MyFunc(double) {}
}
```

리플렉션 시스템은 활용 방식이 너무 많고 방대하다…

모든 사용 방법을 외우기 보단 리플렉션 시스템이 어떤 기능이 가능한 지를 이해하고, 필요할 때마다 매크로 지정자를 검색해서 사용하는 방식이 나은 것 같다.

[https://dev.epicgames.com/documentation/ko-kr/unreal-engine/unreal-engine-uproperties](https://dev.epicgames.com/documentation/ko-kr/unreal-engine/unreal-engine-uproperties)

위 문서를 보면 UPROPERTY() 매크로에 사용 가능한 지정자들이 정리되어 있고, 메타 데이터 또한 정리되어 있다.

<br/>

__참고__

- [https://www.unrealengine.com/ko/blog/unreal-property-system-reflection](https://www.unrealengine.com/ko/blog/unreal-property-system-reflection)

- [https://dev.epicgames.com/documentation/ko-kr/unreal-engine/reflection-system-in-unreal-engine](https://dev.epicgames.com/documentation/ko-kr/unreal-engine/reflection-system-in-unreal-engine)

- [https://dev.epicgames.com/documentation/ko-kr/unreal-engine/unreal-engine-uproperties](https://dev.epicgames.com/documentation/ko-kr/unreal-engine/unreal-engine-uproperties)
