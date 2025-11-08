---
title: "깊이 우선 탐색(DFS, Depth First Search)"
writer: Langerak
date: 2025-11-07 12:00:00 +0800
categories: [Algorithm]
tags: [Algorithm]
pin: false
math: true
mermaid: true
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

### 개요

---

- **깊이 우선 탐색(DFS, Depth First Search)**은 그래프 탐색 방법 중 하나이다.
- 특정 노드에서 시작해서 다음 분기로 넘어가기 전에 해당 분기를 완벽하게 탐색하는 방법이다.
- **재귀 함수나 스택**으로 구현하다.
- **백트래킹**과 같이 사용 가능하다.
  - 깊이 제한에 도달할 때까지 목표 노드가 발견되지 않으면 최근에 추가된 노드의 부모 노드로 돌아와서(백트래킹) 부모 노드에 이전과는 다른 동작자를 적용하여 새로운 자식 노드 생성할 수 있다.
- 무한 루프 방지를 위해 노드 방문 시 방문 여부를 반드시 검사해야 한다.
- 탐색 과정이 시작 노드에서 한없이 깊이 진행되는 것을 막기 위해 깊이 제한을 사용한다.
- 장점
  - 단지 현 경로 상의 노드만 기억하면 되기에 저장 공간이 적게 필요
  - 목표 노드가 깊은 단계에 있을 경우 빠르게 구할 수 있다.
- 단점
  - 해가 없는 경로에 깊이 빠질 가능성이 있다.
  - 얻어진 해가 최단 경로가 된다는 보장이 없다.

<br/>

### 과정

---

![img](assets/img/inpost/102.png)

1. 탐색을 시작할 노드를 방문하고, 스택에 넣은 후 방문했음을 표시한다.
2. 스택의 최상단 노드에서 방문하지 않은 인접 노드 중 하나를 선택한다.
3. 선택된 인접 노드를 스택에 넣고 방문 처리한 뒤, 이 노드에서 다시 탐색을 계속한다.
4. 더 이상 방문할 인접 노드가 없는 노드에 도달하면, 스택에서 해당 노드를 꺼내고 이전 노드로 돌아가 다른 경로를 탐색한다.
5. 모든 노드를 방문할 때까지 이 과정을 반복한다.

<br/>

### 시간 복잡도

---

- **인접 행렬 :** $O(v^2)$
- **인접 리스트 :** $O(v+e)$

<br/>


### 구현

---

```cpp
void dfs_recursive(int node, 
                   std::vector<std::vector<int>>& adj, 
                   std::vector<bool>& visited) 
{
    visited[node] = true;
    
    for (int neighbor : adj[node]) 
    {
        if (!visited[neighbor]) {
            dfs_recursive(neighbor, adj, visited);
        }
    }
}
```

```cpp
void dfs_stack(int startNode, 
               std::vector<std::vector<int>>& adj, 
               std::vector<bool>& visited) 
{
    std::stack<int> s;

    s.push(startNode);
    visited[startNode] = true;

    while (!s.empty()) 
    {
        int node = s.top();
        s.pop();

        for (int neighbor : adj[node]) 
        {
            if (!visited[neighbor]) 
            {
                visited[neighbor] = true;
                s.push(neighbor);
            }
        }
    }
}
```
