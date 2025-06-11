---
title: "[algorithm] (find, binary_search, lower_bound, upper_bound, distance)"
writer: Langerak
date: 2024-12-21 12:00:00 +0800
categories: [Programming Language]
tags: [Programming Language]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/user-attachments/assets/27d63316-d0d7-4d23-bb0c-96c724992a13
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Algorithm 헤더
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

## 개요

---

C++의 algorithm 헤더에는 탐색 관련된 유용한 함수들이 많이 있다.

대표적으로 선형 탐색을 수행하는 **find**와 비 선형 탐색을 수행하는 **binary_search**, **lower_bound**, **upper_bound**가 있다.

<br/>

## find

---

**find** 함수는 **선형 탐색**($O(n)$)을 수행하여 컨테이너에서 원하는 값을 찾는 함수이다.

**first ~ last** 범위 내에서 **value**와 일치하는 **첫 번째 원소를 가리키는 반복자를 반환**한다.

만약 **일치하는 원소를 찾지 못하면 last 반복자를 반환**한다.

```cpp
// 함수 원형
template <class InputIterator, class T>
InputIterator find(InputIterator first, InputIterator last, const T& val);
```

```cpp
// 벡터에서 정수 찾는 예시
vector v = {1, 2, 3, 4, 5};
auto iter = find(v.begin(), v.end(), 3);

// Found: 3 at position 2
if (iter != v.end())
    cout << "Found: " << *iter << " at position " << (iter - v.begin()) << '\n';
else
    cout << "Not found\n";
```

```cpp
// 문자열에서 문자 찾는 예시
string str = "Hello";
auto iter = find(str.begin(), str.end(), 'e');

if (iter != str.end())
    cout << iter - str.begin() << '\n'; // 1
```

```cpp
// 구조체 벡터에서 찾는 예시
struct Person
{
    string name;
    int age;
    
    bool operator==(const Person& other) const
    {
        return name == other.name && age == other.age;
    }
};

vector<Person> people = {
    {"Alice", 20},
    {"Bob", 25},
    {"Charlie", 30}
};

auto iter = find(people.begin(), people.end(), Person{"Bob", 25});
if (iter != people.end())
    cout << iter->name << " " << iter->age << '\n'; // Bob 25
```

**find** 함수는 두 값이 같은지 판단할 때, `operator==`를 사용한다.

따라서 사용자 정의 타입의 객체를 비교하려면 해당 객체에 `==` 연산자를 오버로딩해야 한다.

<br/>

## binary_search

---

**binary_search**는 컨테이너에서 값을 선형 검색이 아닌 **이진 탐색**($O(logN)$)으로 찾는 함수이다.

이분 탐색의 특성 상 **컨테이너가 정렬되어 있어야 한다**.

**first ~ last** 범위 내에서 **value**와 일치하는 원소가 있다면 **true를 반환**하고, 아니라면 **false를 반환**한다.

```cpp
// 함수 원형
template <class ForwardIterator, class T>
bool binary_search(ForwardIterator first, ForwardIterator last, const T& val);

// 비교함수 사용 버전
template <class ForwardIterator, class T, class Compare>
bool binary_search(ForwardIterator first, ForwardIterator last, const T& val, Compare comp);
```

```cpp
// 벡터에서 정수 찾는 예시
vector v = {1, 3, 4, 5, 7, 9, 11};
bool exists = binary_search(v.begin(), v.end(), 5);
cout << boolalpha << exists; // true
```

```cpp
// 문자열에서 문자 찾는 예시
string str = "Hello";
auto exists = binary_search(str.begin(), str.end(), 'e');
cout << boolalpha << exists << '\n'; // true
```

```cpp
// 구조체 벡터에서 찾는 예시
struct Person
{
    string name;
    int age;
};
vector<Person> v =
{
    {"Alice", 20},
    {"Bob", 25},
    {"Charlie", 30},
    {"David", 35}
};

Person target = {"", 30};
auto comp = [](const Person& a, const Person& b) {
    return a.age < b.age;
};
sort(v.begin(), v.end(), comp);
auto exists = binary_search(v.begin(), v.end(), target, comp);
cout << boolalpha << exists << '\n'; // true
```

<br/>

## lower_bound

---

**lower_bound** 함수는 **찾으려는 값 이상**이 처음 나타나는 위치를 **이분 탐색**을 통해 찾는다.

찾으려는 값 이상이 존재한다면 처음 나타나는 위치의 반복자를 반환하고, 그렇지 않다면 **last**를 반환한다.

```cpp
// 함수 원형
template <class ForwardIterator, class T>
ForwardIterator lower_bound(ForwardIterator first, ForwardIterator last, const T& val);

// 비교함수 사용 버전
template <class ForwardIterator, class T, class Compare>
ForwardIterator lower_bound(ForwardIterator first, ForwardIterator last, const T& val, Compare comp);
```

```cpp
// 정수 벡터에서 찾는 예시
vector v = {1, 2, 2, 2, 3, 4, 5, 10};
auto iter = lower_bound(v.begin(), v.end(), 8);
cout << distance(v.begin(), iter) << '\n';  // 7
cout << *iter << '\n';  // 10
```

마찬가지로 사용자 정의 자료형에서 사용하려면 binary_search에서 본 것처럼 비교 함수를 정의해야 한다.

<br/>

## upper_bound

---

**upper_bound** 함수는 **찾으려는 값보다 큰 값이 처음 나타나는 위치**를 **이분 탐색**을 통해 찾는다.

찾으려는 값보다 큰 값이 존재한다면 처음 나타나는 위치의 반복자를 반환하고, 그렇지 않다면 **last**를 반환한다.

```cpp
// 함수 원형
template <class ForwardIterator, class T>
ForwardIterator upper_bound(ForwardIterator first, ForwardIterator last, const T& val);

// 비교함수 사용 버전
template <class ForwardIterator, class T, class Compare>
ForwardIterator upper_bound(ForwardIterator first, ForwardIterator last, const T& val, Compare comp);
```

```cpp
// 정수 벡터에서 찾는 예시
vector v = {1, 2, 2, 2, 3, 4, 5};
auto iter = upper_bound(v.begin(), v.end(), 2);
cout << distance(v.begin(), iter) << '\n'; // 4
cout << *iter << '\n'; // 3
```

<br/>

## equal_range

---

**equal_range**는 **lower_bound와 upper_bound의 쌍을 반환**한다.

이는 찾고자 하는 원소의 범위를 알 수 있어 유용하다.

```cpp
// 함수 원형
template <class ForwardIterator, class T>
pair<ForwardIterator,ForwardIterator> 
equal_range(ForwardIterator first, ForwardIterator last, const T& val);

// 비교함수 사용 버전
template <class ForwardIterator, class T, class Compare>
pair<ForwardIterator,ForwardIterator> 
equal_range(ForwardIterator first, ForwardIterator last, const T& val, Compare comp);
```

```cpp
vector v = {1, 2, 2, 2, 3, 4, 5};
auto range = equal_range(v.begin(), v.end(), 2);
auto start = distance(v.begin(), range.first);
auto end = distance(v.begin(), range.second);

cout << start << "~" << end << '\n';  // 1~4
```

<br/>

## distance

---

**distance** 함수는 두 반복자 사이의 요소 개수를 반환한다.

**begin**과의 거리를 구하면 **해당 반복자의 인덱스**를 구할 수 있기에 편리하다.

```cpp
// 함수 원형
template <class InputIterator>
typename iterator_traits<InputIterator>::difference_type
    distance(InputIterator first, InputIterator last);
```

```cpp
vector v = {1, 2, 3, 4, 5};
auto it = find(v.begin(), v.end(), 3);
auto index = distance(v.begin(), it); // 2

cout << index << '\n';
```

<br/>

_참고_
- [C++ STL Algorithm](https://velog.io/@seongcheoljeon/CPP-STL-Algorithm#%EB%B9%84%EC%84%A0%ED%98%95-%ED%83%90%EC%83%89-stdbinary_search)
