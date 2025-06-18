---
title: "동적계획법 Dynamic Programming"
writer: Langerak
date: 2024-11-10 12:00:00 +0800
categories: [Algorithm]
tags: [Algorithm]
pin: false
math: true
mermaid: true
image:
  path: https://1drv.ms/i/c/0feb846c92fbe54a/IQS6mnwQAOfaRI_weqt3dPBOAQllTEdQXyWvOUjL6HV8vOI?width=1920&height=1080
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Dynamic Programming
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.


## 개요

---

> 하나의 큰 문제를 여러 개의 작은 문제로 나누어서 그 결과를 저장하여 다시 큰 문제를 해결할 때 사용

**동적 계획법(Dynamic Programming)**은 **복잡한 문제를 간단한 여러 개의 문제로 나누어 푸는 방법**으로 특정한 알고리즘이 아닌 하나의 문제해결 패러다임으로 볼 수 있다.

이것은 **부분 반복 문제**와 **최적 부분 구조**를 가지고 있는 알고리즘을 일반적인 방법에 비해 더욱 적은 시간 내에 풀 때 사용한다.

똑같은 연산이 반복되어 비효율적인 계산을 하지 않도록 만들어준다.

<br/>

## 조건

---

### **중복 부분 문제 (Overlapping Subproblems)**

DP는 기본적으로 문제를 나누고 그 문제의 결과 값을 재활용해서 전체 답을 구한다.

그래서 **동일한 작은 문제들이 반복하여 나타나는 경우**에 사용이 가능하다.

![Overlapping Subproblems](https://github.com/user-attachments/assets/4a6ae555-a429-43d3-ae4c-764846d4a8ff)
_피보나치 수열에서 f(5)를 구한다고 할 때, f(3), f(2), f(1)과 같이 동일한 부분 문제가 중복된다._

### **최적 부분 구조 (Optimal Substructure)**

**부분 문제의 최적 해를 사용해 전체 문제의 최적 해를 낼 수 있는 경우**를 의미한다.

![Optimal Substructure](https://github.com/user-attachments/assets/49a359a8-1f0c-40d3-9bca-5e1a75e7cc7e)
_A-B의 최단 경로를 찾고자 할 때, A-X / X-B가 많은 경로 중 가장 짧은 경로라면 전체 최적 경로도 A-X-B가 정답이 된다._

이 두 가지 조건이 충족한다면, 동적 계획법을 이용하여 문제를 풀 수 있다.

<br/>

## 구현 방식

---

1. **DP로 풀 수 있는 문제인지 확인**

   현재 직면한 문제가 작은 문제들로 이루어진 하나의 함수로 표현될 수 있는지 판단

   즉, 위에 쓴 조건들이 충족되는 문제인지를 한 번 체크

2. **문제의 변수 파악**

   현재 변수에 따라 그 결과 값을 찾고 그것을 전달하여 재사용하는 것을 거친다.

   가령 피보나치 수열에서는 $n$번째 숫자를 구하는 것이므로 $n$이 변수가 된다.

3. **변수 간 관계식 만들기 (점화식)**

   점화식을 반복/재귀를 통해 자동으로 해결되도록 구축한다.

   가령 피보나치 수열에서는 $f(n)=f(n-1)+f(n-2)$이다.

4. **메모하기 (Memoization or Tabulation)**

   변수의 값에 따른 결과를 저장하고, 저장된 값을 재사용한다.

5. **기저 상태 파악하기**

   **가장 작은 문제의 상태를 알아야 한다.**

   가령 피보나치 수열에서는 $f(0)=0,\;f(1)=1$

6. **구현하기**

   DP는 2가지 방식으로 구현할 수 있다.
   1. Tabulation 방식 (Bottom-Up) - 반복문 사용
   2. Memoization 방식 (Top-Down) - 재귀 사용

<br/>

## 구현

---

### Tabulation 방식 (Bottom-Up) - 반복문 사용

**아래에서 부터 계산을 수행하고 누적시켜서 전체 큰 문제를 해결하는 방식**

dp[0]이 기저 상태이고 dp[n]을 목표 상태라고 하자.

dp[0]부터 시작해서 반복문을 통해 점화식으로 결과를 내서 dp[n]까지 그 값을 전이시켜 재활용하는 방식

```python
def fibo_tabulation(n):
    if n < 2:
        return n
    
    fib = [0, 1]
    for i in range(2, n + 1):
        fib.append(fib[i - 1] + fib[i - 2])
        
    return fib[n]
```

### Memoization 방식 (Top-Down) - 재귀 사용

dp[n]의 값을 찾기 위해 n에서 바로 호출을 시작하여 dp[0]의 상태까지 내려간 다음 해당 **결과 값을 재귀를 통해 전이시켜 재활용하는 방식**이다.

```python
def fibo_memoization(n, memo):
    if n < 2:
        return n
    
    if memo[n] == 0:
        memo[n] = fibo_memoization(n - 1, memo) + fibo_memoization(n - 2, memo)
        
    return memo[n]
```

<br/>

## 분할 정복(Divide and Conqure)과의 비교

---

DP와 분할 정복은 큰 문제를 작은 여러 개의 **부분 문제**로 나누어 해결하는 비슷한 방식을 가지고 있다.

하지만 부분 문제로 만드는 과정에서 중복 여부에 대한 차이점이 존재한다. **DP는 부분 문제가 중복되어 해를 재사용하지만, 분할 정복은 부분 문제가 중복될 수 없다.**

분할 정복 방식이 사용되는 병합 정렬을 살펴보면, 정렬 시에 부분 문제로 쪼개어지지만 중복하여 부분 문제가 발생하지 않으므로 부분 문제는 모두 독립적이다.

<br/>

## 욕심쟁이 기법(Greedy Algorithm)과의 비교

---

DP는 가능한 모든 방법을 고려해야 한다는 단점이 있기에 이러한 단점을 극복하기 위해, 욕심쟁이 기법이 등장했다.

욕심쟁이 기법이 항상 최적해를 구해주지는 않지만, 최소 신장 트리와 같은 문제에서는 최적해를 구할 수 있다.

A 노드에서 B 노드로 가는 최단 경로를 구하고 싶을 때 DP와 욕심쟁이 기법을 비교해보면, DP는 모든 노드와 에지와 가중치를 감안하여 최적 해를 찾아내지만, 그리디 알고리즘은 현재 노드에서의 가장 짧은 에지를 선택할 것이다.

DP는 욕심쟁이 기법에 비해 약간 시간이 더 걸리겠지만 최적 해를 보장받을 수 있고, 욕심쟁이 기법은 항상 최적 해임을 보장받을 수 없다.

<br/>

_참고_

- [알고리즘 - Dynamic Programming(동적 계획법)](https://hongjw1938.tistory.com/47)
- [[Kotlin] 동적 계획법 (Dynamic Programming, DP) (+ 분할 정복과의 차이)](https://hungseong.tistory.com/42)
- [동적 계획법](https://ko.wikipedia.org/wiki/%EB%8F%99%EC%A0%81_%EA%B3%84%ED%9A%8D%EB%B2%95)
