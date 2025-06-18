---
title: "연결리스트 LinkedList"
writer: Langerak
date: 2025-03-21 13:00:00 +0800
categories: [Data Structure]
tags: [Data Structure]
pin: false
math: true
mermaid: true
image:
  path: https://1drv.ms/i/c/0feb846c92fbe54a/IQQ3z3L6GNd0RJ1zh52gfwlpAX0jHvZ7xFa1K-MBlodskbA?width=1920&height=1080
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: LinkedList
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

## 개요

---

연결 리스트란 **각 노드가 데이터와 다음 노드를 가리키는 포인터**로 구성된 선형 자료구조이다.

배열과 달리, 메모리에 연속적으로 저장되지 않고, 동적으로 크기를 조절할 수 있다.

또한 배열은 인덱스로 O(1) 시간에 접근 가능하지만, 연결 리스트는 특정 노드에 접근하려면 O(n) 시간이 필요하다.

배열보다 순차적 접근에는 불리하지만 삽입/삭제에 용이하다.

첫 번째 노드를 **Head**, 마지막 노드를 **Tail**이라고 한다.

<br/>

## 연결 리스트의 종류

---

- **단일 연결 리스트 (Singly Linked List)**

  각 노드가 다음 노드를 가리키는 포인터만 가진다.

- **이중 연결 리스트 (Doubly Linked List)**

  각 노드가 이전 노드와 다음 노드를 가리키는 포인터를 가진다.

- **원형 연결 리스트 (Circular Linked List)**

  마지막 노드가 첫 번째 노드를 가리켜 원형을 형성한다.

<br/>

## 연결 리스트의 장단점

---

- **장점**

  동적 크기 조정 가능하다.

  위치를 알고 있는 경우 삽입/삭제 연산이 O(1) 시간에 가능하다.

  메모리를 효율적으로 사용 가능하다.

- **단점**

  임의 접근이 O(n) 시간이 소요된다.

  포인터를 저장할 추가 메모리가 필요하다.

  캐시 친화적이지 않다.

<br/>

## 연결 리스트의 메모리 관리

---

연결 리스트의 메모리 관리 측면에서의 문제점으로는 메모리 누수와 댕글링 포인트가 있다.

연결 리스트에서 노드를 삭제할 때 메모리를 적절히 해제하지 않으면 메모리 누수가 발생할 수 있다.

또한, 삭제된 노드를 가리키는 포인터가 남아있다면 댕글링 포인터 문제가 발생한다.

> **댕글링 포인트**란, 메모리가 해제된 후에도 해당 메모리를 가리키는 포인터가 여전히 존재하는 현상이다. 이런 포인터를 역참조하면 예측할 수 없는 동작이나 프로그램 충돌이 발생한다.
>

이를 발생하기 위해 가비지 컬렉션이 있는 언어에서는 참조가 없어지면 자동으로 메모리가 해제되지만, C/C++와 같은 언어에서는 명시적으로 메모리를 해제해야 한다.

<br/>

## 연결 리스트의 캐시 적중률

---

연결 리스트는 배열과 달리, 각 노드가 메모리에 연속적으로 저장되지 않고 서로 다른 위치에 분산되어 저장된다.

이러한 비연속적 메모리 할당 특성은 캐시 성능에 상당한 영향을 미친다.

**문제점**

1. **공간 지역성(Spatial Locality) 부족**

   현대 컴퓨터 시스템은 데이터 접근 시 요청된 메모리 주소 뿐만 아니라 그 주변 메모리 블록도 함께 캐시에 가져온다.

   배열은 연속된 메모리에 저장되므로 하나의 요소에 접근할 때 이웃 요소들도 함께 불러올 확률이 높다.

   하지만 연결 리스트는 메모리 전체에 흩어져 있어, 한 노드에 접근할 때 다음 노드는 캐시에 없을 가능성이 높다.

2. **캐시 미스 증가**

   연결 리스트 순회 중 다음 노드에 접근할 떄마다 새로운 메모리 위치를 참조해야 하므로 캐시 미스가 자주 발생한다.

3. **메모리 프리페치(Prefetch) 효율 저하**

   현대 CPU는 메모리 접근 패턴을 예측하여 미리 데이터를 캐시로 가져오는 프리페치 메커니즘을 가지고 있다.

   배열의 순차적 접근은 예측 가능하므로 프레페치가 효과적이지만, 연결 리스트는 다음 노드 위치를 현재 노드를 읽기 전까지 알 수 없어 프리페치의 효과가 제한적이다.


**해결책**

1. **노드 클러스터링 (Node Clustering)**

   여러 데이터 요소를 하나의 노드에 저장하여 공간 지역성을 높힐 수 있다.

   가령, 단일 노드에 하나의 값 대신 8~16개의 값을 배열로 저장하는 것이다.

2. **메모리 풀(Memory Pool) 사용**

   연결 리스트의 모든 노드를 인접한 메모리 블록에 할당하는 사용자 정의 메모리 할당자를 사용한다.

   그렇다면 노드들이 메모리에서 서로 가까이 위치하게 되어 캐시 적중률을 높힐 수 있다.

3. **캐시 친화적 자료구조로 대체**

   특정 상황에서 B-트리나 벡터와 같은 캐시 친화적 자료구조를 사용하는 것이 더 효율적일 수 있다.

<br/>

## 단일 연결 리스트에서 중간 노드를 삭제하는 알고리즘

---

두 가지 방법이 가능하다.

- **삭제할 노드의 이전 노드에 접근 가능한 경우**

  이전 노드의 next 포인터를 삭제할 노드의 다음 노드로 업데이트 한다.

- **삭제할 노드의 이전 노드에 접근 불가능한 경우**

  현재 노드의 다음 노드의 값을 현재 노드로 복사한 후, 현재 노드의 next 포인터를 다음 노드의 next로 변경한다.


노드에 접근하는 시간을 제외한다면, 삭제 시간 복잡도는 O(1)이다.

<br/>

## 연결 리스트에서 사이클을 감지하는 방법

---

Floyd의 토끼와 거북이 알고리즘을 사용해 사이클을 찾을 수 있다.

느린 포인터와 빠른 포인터를 사용하여, 느린 포인터는 한 번에 한 노드씩, 빠른 포인터는 한 번에 두 노드씩 이동한다.

만약 사이클이 있다면, 빠른 포인터가 느린 포인터를 따라잡게 된다.

<br/>

## 연결 리스트를 역순으로 뒤집는 알고리즘

---

prev, current, next 세 개의 포인터를 사용하여 각 노드의 포인터 방향을 바꿀 수 있다.

```python
def reverse_list(head):
	prev = None
	current = head
	
	while current:
		next_temp = current.next
		current.next = prev
		prev = current
		current = next_temp
		
	return prev # 새로운 헤드
```

```cpp
ListNode* reverseList(ListNode* head)
{
	ListNode* prev = nullptr;
	ListNode* current = head;
	ListNode* next = nullptr;
	
	while (current != nullptr)
	{
		next = current->next; // 다음 노드 저장
		current->next = prev; // 현재 노드의 포인터 방향 바꾸기
		prev = current; // prev와 current 포인터 이동
		current = next;
	}
	
	return prev;
}
```

<br/>

## 연결 리스트에서 중간 노드를 찾는 효율적인 방법

---

한 칸을 움직이는 느린 포인터와 두 칸을 움직이는 빠른 포인터를 사용하여, 빠른 포인터가 리스트 끝에 도달했을 때 느린 포인터는 중간에 위치하게 된다.

<br/>

## 연결 리스트에서 팰린드롬을 확인하는 O(n) 시간복잡도와 O(1) 공간 복잡도를 가지는 알고리즘

---

1. 빠른/느린 포인터로 중간 지점 찾기
2. 두 번째 절반을 뒤집기
3. 첫 번째 절반과 뒤집힌 두 번째 절반 비교

```cpp
#include <iostream>

// 연결 리스트의 노드 구조체 정의
struct ListNode {
    int val;
    ListNode *next;
    ListNode() : val(0), next(nullptr) {}
    ListNode(int x) : val(x), next(nullptr) {}
    ListNode(int x, ListNode *next) : val(x), next(next) {}
};

// 연결 리스트를 역순으로 뒤집는 함수
ListNode* reverseList(ListNode* head) {
    ListNode* prev = nullptr;
    ListNode* current = head;
    ListNode* next = nullptr;
    
    while (current != nullptr) {
        next = current->next;
        current->next = prev;
        prev = current;
        current = next;
    }
    
    return prev;
}

// 연결 리스트가 팰린드롬인지 확인하는 함수
bool isPalindrome(ListNode* head) {
    if (head == nullptr || head->next == nullptr) {
        return true;
    }
    
    // 중간 지점 찾기
    ListNode* slow = head;
    ListNode* fast = head;
    
    while (fast->next != nullptr && fast->next->next != nullptr) {
        slow = slow->next;
        fast = fast->next->next;
    }
    
    // 두 번째 절반 뒤집기
    ListNode* secondHalfHead = reverseList(slow->next);
    
    // 비교
    ListNode* p1 = head;
    ListNode* p2 = secondHalfHead;
    bool result = true;
    
    while (result && p2 != nullptr) {
        if (p1->val != p2->val) {
            result = false;
        }
        p1 = p1->next;
        p2 = p2->next;
    }
    
    return result;
}
```

<br/>

## 시간 복잡도

---

- 탐색 $O(n)$
- 삽입 $O(1)$
- 삭제 $O(1)$
- 연결 리스트 중간에 삽입/삭제 시에 탐색 시간이 소요되기에 $O(n)$

<br/>

## 공간 복잡도

---

데이터 저장공간 + 포인터 저장 공간 = $O(n)+O(n)=O(n)$

<br/>

_참고_
- Claude
