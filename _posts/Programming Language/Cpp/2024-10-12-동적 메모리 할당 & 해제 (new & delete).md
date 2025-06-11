---
title: "동적 메모리 할당 & 해제 (new & delete)"
writer: Langerak
date: 2024-10-12 12:00:00 +0800
categories: [Programming Language]
tags: [Programming Language]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/user-attachments/assets/2947e64d-278d-4cb8-8108-8f9980e1964c
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: new & delete
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.


### new & delete 키워드

---

new와 delete 키워드는 C++에서 동적 메모리 할당과 해제를 위해 사용되는 키워드이다.

**`new` 키워드**

- 메모리 공간을 동적으로 할당
- 메모리 할당 실패 시 `std::bad_alloc` 예외가 던져지고 프로그램이 종료된다.

  하지만 매개변수로 `std::nothrow`를 넘기면 메모리 할당 실패 시 예외가 던져지지 않고, 대신 `nullptr`이 반환된다.

- **함수 원형**

```cpp
// 1. 단일 객체 메모리를 동적으로 할당
void* operator new(size_t _Size)
void* operator new(size_t _Size, std::nothrow_t const&) noexcept

// 2. 배열을 동적으로 할당
void* operator new[](size_t _Size)
void* operator new[](size_t _Size, std::nothrow_t const&) noexcept
```

**`delete` 키워드**

- 동적으로 할당 받은 메모리 공간을 해제
- **함수 원형**

```cpp
// 1. 단일 객체 메모리 해제
void operator delete(void* _Block)

// 2. 배열 메모리 해제
void operator delete[](void* _Block)

// 아래 4개는 생성자에서 예외가 발생했을 때만 사용된다.
void operator delete(void* _Block, std::nothrow_t const&) noexcept
void operator delete[](void* _Block, std::nothrow_t const&) noexcept
void operator delete(void* _Block, size_t _Size)
void operator delete[](void* _Block, size_t _Size)
```

<br/>

### 사용법

---

**단일 객체 & 1차원 배열**

```cpp
#include <new>
using namespace std;

int main()
{
	// 단일 객체 메모리 할당 & 할당 실패 시 std::badalloc 예외
	int* ptr = new int;
	// 단일 객체 메모리 할당 & 할당 실패 시 예외 대신 nullptr 반환
	int* ptr = new(nothrow) int;
	
	// 배열 메모리 할당 & 할당 실패 시 std::badalloc 예외
	int* ptr = new int[5];
	// 배열 메모리 할당 & 할당 실패 시 예외 대신 nullptr 반환
	int* ptr = new(nothrow) int[5];

	// 단일 객체 메모리 해제
	delete ptr;
	
	// 배열 메모리 해제
	delete[] ptr;
}
```

**2차원 배열**

```cpp
int rows = 3;
int cols = 4;

int** arr = new int* [rows];
// auto arr = new int* [rows]; // C++ 11 이상부터는 auto 키워드 가능

for (int i = 0; i < rows; i++)
{
	arr[i] = new int[cols]();
}

for (int i = 0; i < rows; ++i) 
{
	for (int j = 0; j < cols; ++j) 
	{
		cout << arr[i][j] << ' ';
	}
	cout << endl;
}

for (int i = 0; i < rows; ++i) 
{
	delete[] arr[i]; // 각 행 메모리 해제
}
delete[] arr; // 포인터 배열 메모리 해제
```

<br/>

### 참고

---

- [메모리 할당/해제 연산자(new/delete) 오버로딩](https://velog.io/@jinh2352/메모리-할당해제-연산자newdelete-오버로딩)

- [C++ 07.20 - 이중 포인터와 동적 다차원 배열 (Pointers to pointers and dynamic multidimensional arrays)](https://boycoding.tistory.com/212)
