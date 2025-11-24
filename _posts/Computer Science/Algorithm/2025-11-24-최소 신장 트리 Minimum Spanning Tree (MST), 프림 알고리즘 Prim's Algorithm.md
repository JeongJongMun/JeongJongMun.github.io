---
title: "최소 신장 트리 Minimum Spanning Tree (MST), 프림 알고리즘 Prim's Algorithm"
writer: Langerak
date: 2025-11-24 12:00:00 +0800
categories: [Algorithm]
tags: [Algorithm]
pin: false
math: true
mermaid: true
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

### 신장 트리 Spanning Tree

---

신장 트리는 그래프에서 사이클 없이 모든 노드를 연결하는 최소한의 부분 그래프를 의미한다.

즉, 그래프의 모든 정점을 포함하는 트리이다.

정점의 개수가 n개이면 간선의 개수는 n-1개이다.

하나의 그래프에 여러 개의 신장 트리가 존재할 수 있다.

<br/>

### 최소 신장 트리 Minimum Spanning Tree (MST)

---

최소 신장 트리는 간선에 가중치가 있을 때, 만들 수 있는 여러 신장 트리 중 간선 가중치의 합이 가장 작은 것을 말한다.

대표적인 알고리즘으로는 크루스칼과 프림 알고리즘이 있다.

<br/>

### 프림 알고리즘 Prim's Algorithm

---

프림 알고리즘은 최소 신장 트리를 구하는 대표적인 알고리즘이다.

프림 알고리즘은 시작점 하나를 정해서, 가장 가까운 노드를 하나씩 추가해 나가는 방식으로 작동한다.

1. 임의의 시작 노드를 선택하고, 해당 노드를 MST에 추가한다.
2. MST에 포함된 노드와 인접한 노드들 중에서 가장 가중치가 작은 간선을 선택한다.
3. 선택한 간선의 도착 노드를 MST에 추가한다. (만약 도착 노드가 이미 MST에 포함되어 있다면, 사이클 방지를 위해 다른 간선을 선택한다.)
4. 모든 노드가 MST에 포함될 때까지 2-3단계를 반복

우선순위 큐를 사용하여 프림 알고리즘을 구현할 수 있다.

<br>

### 백준 1647번 : 도시 분할 계획

---

```cpp
#include <iostream>
#include <vector>
#include <queue>

// 비용, 정점 번호
using edge = std::pair<int, int>;

int main()
{
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);
    std::cout.tie(nullptr);

    int n, m;
    std::cin >> n >> m;

    std::vector visited(n + 1, false);
    std::vector graph(n + 1, std::vector<edge>());
    std::priority_queue<edge, std::vector<edge>, std::greater<edge>> pq;

    int a, b, c;
    for (int i = 0; i < m; i++)
    {
        std::cin >> a >> b >> c;
        graph[a].emplace_back(c, b);
        graph[b].emplace_back(c, a);
    }

    pq.emplace(0, 1);

    int ans = 0;
    int max_edge_weight = 0;
    
    while (!pq.empty())
    {
        int weight = pq.top().first;
        int node = pq.top().second;
        pq.pop();

        if (visited[node]) continue;
        
        visited[node] = true;
        ans += weight;
        max_edge_weight = std::max(weight, max_edge_weight);

        for (const auto& next_edge : graph[node])
        {
            int next_weight = next_edge.first;
            int next_node = next_edge.second;

            if (!visited[next_node])
            {
                pq.emplace(next_weight, next_node);
            }
        }
    }

    std::cout << ans - max_edge_weight;
    
    return 0;
}
```













