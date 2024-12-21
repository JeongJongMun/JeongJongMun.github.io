---
title: "최장 증가 부분 수열 Longest Increasing Subsequence (LIS)"
writer: Langerak
date: 2024-12-20 12:00:00 +0800
categories: [Algorithm, Dynamic Programming]
tags: [Algorithm, Dynamic Programming]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/user-attachments/assets/5b9fd04d-a4da-4f1c-aa28-1a5fefce4307
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Dynamic Programming
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

## 개요

---

**최장 증가 부분 수열(LIS)이란?**

어떠한 수열이 주어질 때, 그 수열에서 일부 원소를 뽑아내어 새로 만든 수열을 **부분 수열**이라고 하며, 이 수열이 오름차순이면 **증가하는 부분 수열**이 된다.

그러므로 어떤 수열에서 만들 수 있는 부분 수열 중 가장 길면서 오름차순을 유지하는 수열이 **LIS**이다.

<br/>

## $O(n^2)$ 알고리즘

---

[백준 11053번 가장 긴 증가하는 부분 수열](https://www.acmicpc.net/problem/11053)

```python
n = int(input())
arr = list(map(int, input().split()))
dp = [1] * n

for i in range(n):
    for j in range(i):
        if arr[i] > arr[j]:
            dp[i] = max(dp[i], dp[j] + 1)

print(max(dp))
```

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main()
{
    ios::sync_with_stdio(false); cin.tie(nullptr);

    int N; cin >> N;
    vector arr(N, 0);
    vector dp(N, 1);
    for (int i = 0; i < N; i++)
        cin >> arr[i];

    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < i; j++)
        {
            if (arr[j] < arr[i])
                dp[i] = max(dp[i], dp[j] + 1);
        }
    }

    cout << *max_element(dp.begin(), dp.end());
    
    return 0;
}
```

```
6
10 20 10 30 20 50
```

_LIS = 최장 증가부분수열_

_IS = 증가부분수열_

_X = 현재 원소_

**X**가 어떤 **IS**의 마지막 값이 되기 위해서는 **X**가 추가되기 전 **IS**의 마지막 값이 **X**보다 작은 값이어야 한다.

**X**를 마지막 값으로 가지는 **LIS**의 길이는 **X**가 추가될 수 있는 **IS** 중 가장 긴 **IS**의 길이에 1을 더한 값이 된다.

- 원소를 하나씩 확인
- 현재 원소보다 작은 인덱스의 원소들을 확인하면서 값이 작은 경우 업데이트
- **max(dp[j] + 1, dp[i])**
  1. **arr[j]**에서 끝나는 증가부분수열의 **arr[i]**를 추가했을 때의 LIS 길이
  2. 추가하지 않고 기존의 **dp[i]** 값

### 수열까지 같이 구하기

[백준 14002번 가장 긴 증가하는 부분 수열 4](https://www.acmicpc.net/problem/14002)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main()
{
    ios::sync_with_stdio(false); cin.tie(nullptr);

    int N; cin >> N;
    vector arr(N, 0);
    vector dp(N, 1);
    vector prev(N, -1);
    for (int i = 0; i < N; i++)
    {
        cin >> arr[i];
    }

    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < i; j++)
        {
            if (arr[j] < arr[i] && dp[i] < dp[j] + 1)
            {
                dp[i] = dp[j] + 1;
                prev[i] = j;
            }
        }
    }

    auto iter = max_element(dp.begin(), dp.end());
    auto idx = iter - dp.begin();
    
    vector<int> ans;
    for (int i = idx; i != -1; i = prev[i])
        ans.push_back(arr[i]);
    sort(ans.begin(), ans.end());

    cout << *iter << '\n';
    for (auto &elem : ans)
        cout << elem << ' ';
    
    return 0;
}
```

이 문제는 LIS의 길이와 정답 수열을 같이 출력해야 한다.

추가적인 배열을 하나 더 두어서 **LIS를 이루는 이전 원소의 인덱스를 저장**하고, 이 배열을 역으로 따라가 출력하는 방법을 사용할 수 있다.

추가로 배열을 -1로 초기화하여 이전 원소가 없음을 명시하였다.

<br/>

## $O(nlogn)$ 알고리즘

---

[백준 12015번 가장 긴 증가하는 부분 수열 2](https://www.acmicpc.net/problem/12015)

```python
import sys
from bisect import bisect_left
input = sys.stdin.readline

n = int(input().strip())
arr = list(map(int, input().split()))
dp = [arr[0]]
for i in range(1, n):
    if dp[-1] < arr[i]:
        dp.append(arr[i])
    else:
        dp[bisect_left(dp, arr[i])] = arr[i]
    
print(len(dp))
```

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main()
{
    int N; cin >> N;
    vector<int> arr(N);
    vector<int> dp;
    
    for (auto &elem : arr)
        cin >> elem;

    dp.push_back(arr[0]);
    
    for (int i = 1; i < N; i++)
    {
        auto iter = lower_bound(dp.begin(), dp.end(), arr[i]);
        if (iter == dp.end())
            dp.push_back(arr[i]);
        else
            *iter = arr[i];
    }

    cout << dp.size() << '\n';
    
    return 0;
}
```

$O(n^2)$ 알고리즘은 배열의 원소를 하나씩 탐색하면서, 그 이전의 원소들을 모두 탐색한다.

대신, 이분 탐색을 사용하여 이전 원소들을 탐색하는 과정을 $O(logn)$으로 줄일 수 있다.

핵심 아이디어는, **LIS의 마지막 원소가 가능한 작을수록 더 긴 LIS를 생성할 수 있다**이다.

<br/>

_A 배열 = 기존 배열_

_DP 배열 = LIS의 길이를 구할 배열_

_X = 현재 방문한 A 배열의 원소_

_E = DP 배열의 맨 마지막 원소_

<br/>

A 배열의 원소(**X**라고 하자)를 하나씩 방문하며 아래 조건에 따라 DP 배열에 추가하거나, 대체한다.

1. X가 E보다 크다면, DP 배열에 추가하여 LIS의 길이를 1만큼 늘릴 수 있다.
2. X가 E보다 작거나 같다면, 앞으로 더 긴 LIS 배열을 만들 수 있도록 적당한 위치에 대체해야 한다.

   이 때, 이분 탐색으로 DP 배열에서 X 다음으로 큰 원소 위치에 대체한다.


**위 방법대로 하면, 길이만 구할 수 있고, DP 배열의 각 원소는 실제 LIS와 다를 수 있다!**

3, 5, 2, 6, 1 배열로 해보면, DP 배열은 아래와 같이 변한다.

1. 3
2. 3, 5
3. 2, 5
4. 2, 5, 6
5. 1, 5, 6

**실제 LIS는 3, 5, 6이지만, DP 배열에는 1, 5, 6이 들어가게 된다.**

### 수열까지 같이 구하기

[백준 14003번 가장 긴 증가하는 부분 수열 5](https://www.acmicpc.net/problem/14003)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main()
{
    int N; cin >> N;
    vector<int> arr(N);
    vector<int> dp;
    vector idx(N, 0);
    
    for (auto &elem : arr)
        cin >> elem;

    dp.push_back(arr[0]);
    
    for (int i = 1; i < N; i++)
    {
        auto iter = lower_bound(dp.begin(), dp.end(), arr[i]);
        if (iter == dp.end())
        {
            idx[i] = dp.size();
            dp.push_back(arr[i]);
        }
        else
        {
            idx[i] = iter - dp.begin();
            *iter = arr[i];
        }
    }

    vector<int> ans;
    int target = dp.size() - 1;
    for (int i = N - 1; i >= 0; i--)
    {
        if (idx[i] == target)
        {
            ans.push_back(arr[i]);
            target--;
        }
    }

    cout << dp.size() << '\n';
    for (int i = ans.size() - 1; i >= 0; i--)
        cout << ans[i] << ' ';
    
    return 0;
}
```

위 알고리즘에서 인덱스를 저장하는 추가적인 배열을 사용한다.

**dp 배열의 맨 뒤에 추가되거나, 기존 dp 배열의 대체되는 해당 인덱스를 저장하여 역순으로 따라가면 답을 구할 수 있다.**

**10 20 10 30 20 50**를 입력해보면,

LIS의 길이는 4이고, LIS 배열은 10 20 30 50, 인덱스 배열은 **0 1 0 2 1 3** 이 나온다.

이 인덱스 배열을 역순으로 순회하면서 3→2→1→0 순으로 출력하면 된다.

<br/>

_참고_

- [LIS (Longest Increasing Subsequence) - 최장 증가 부분 수열](https://rebro.kr/33)

- [[알고리즘] Lower Bound와 Upper Bound](https://duckracoon.tistory.com/entry/알고리즘-Lower-Bound와-Upper-Bound)
