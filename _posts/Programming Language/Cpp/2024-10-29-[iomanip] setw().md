---
title: "<iomanip> setw()"
writer: Langerak
date: 2024-10-29 12:00:00 +0800
categories: [Programming Language, Cpp]
tags: [Cpp]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/user-attachments/assets/db21d175-d6bc-4ff2-9501-9d66db9c6821
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: struct
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.


## 개요

---

`#include<iomanip>`에 포함되어 있다.

출력하는 데이터의 칸을 지정한 수만큼 정렬 시켜주는 편리한 함수이다.

<br/>

## 사용법

---

```cpp
cout << setw(3) << 1 << '\n';
// '  1' 출력
```

`setw(n)` 이후에 출력하는 데이터의 너비를 `n`으로 정렬해준다.

즉, `n`만큼의 너비를 확보하고, 데이터를 오른쪽 칸부터 채워넣게 해준다.

```cpp
cout << left << setw(3) << 1 << "#" << '\n';
// '1  #' 출력
```

만약 데이터를 왼쪽부터 출력하고 싶으면, `left`를 사용하면 된다. (`right`도 있다.)

이 설정은 sticky하므로 이후에 쓰는 `setw`에 모두 적용된다.

```cpp
const int N = 100;
const int K = 3;
for (int i = 1; i <= N; i *= 10)
	cout << setw(K) << i << '\n';

for (int i = 1; i <= N; i *= 10)
	cout << left << setw(K) << i << "#" << '\n';

for (int i = 1; i <= N; i *= 10)
	cout << setw(K) << i << "#" << '\n';

for (int i = 1; i <= N; i *= 10)
	cout << right << setw(K) << i << '\n';

/* 
출력
  1
 10
100
1  #
10 #
100#
1  #
10 #
100#
  1
 10
100
*/
```

<br/>

### 참고

---

- [setw() 함수](https://ryeom2.tistory.com/5)

- [[C++] width(), setw()](https://xclass.tistory.com/111)
