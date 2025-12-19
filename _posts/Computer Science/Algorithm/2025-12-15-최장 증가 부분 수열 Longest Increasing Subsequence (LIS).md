---
title: "최장 증가 부분 수열 Longest Increasing Subsequence (LIS)"
writer: Langerak
date: 2025-12-15 12:00:00 +0800
categories: [Computer Science, Algorithm]
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

어떠한 수열이 주어질 때, 그 수열에서 일부 원소를 뽑아내어 새로 만든 수열을 부분 수열이라고 한다.

그리고 그 부분 수열 중에서 요소들이 오름차순으로 정렬된 가장 긴 수열을 최장 증가 부분 수열이라고 한다.

크게 두 가지 $O(N^2)$ 방식과 $O(NlogN)$ 방식이 존재한다.

<br/>

### 방법 1 : 다이나믹 프로그래밍 (DP)

---

가장 직관적인 방법이다. 반복문을 사용하여 각 위치에서의 LIS 길이를 계산한다.

구현이 간단하고 LIS 수열을 역추적하여 구해내기 쉽다.

1. dp[i] : i번째 인덱스에서 끝나는 최장 증가 부분 수열의 길이
2. i보다 앞에 있는 모든 j (0 ≤ j < i)를 검사한다.
3. 만약 arr[j] < arr[i]라면, arr[i]를 arr[j] 뒤에 붙일 수 있다.
4. 점화식 : dp[i] = max(dp[i], dp[j] + 1)

<br/>

백준 2631번 : 줄세우기

[https://www.acmicpc.net/problem/2631](https://www.acmicpc.net/problem/2631)

```c++
#include <algorithm>
#include <iostream>
#include <vector>

int main()
{
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);
    std::cout.tie(nullptr);

    int N; 
    std::cin >> N;
    
    std::vector<int> arr(N);
    std::vector<int> dp(N, 1);
    
    for (int i = 0; i < N; i++)
    {
        std::cin >> arr[i];
    }
    
    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < i; j++)
        {
            if (arr[j] < arr[i])
            {
                dp[i] = std::max(dp[i], dp[j] + 1);
            }
        }
    }

    std::cout << N - *std::max_element(dp.begin(), dp.end());

    return 0;
}
```

<br/>

그렇다면 정답이 되는 LIS 배열까지 구해보자.

역추적을 위해 부모(이전) 인덱스를 저장할 별도의 배열을 하나 더 사용한다.

1. dp[i]가 갱신될 때(즉, 더 긴 수열을 발견했을 때), 그 수열을 이어준 직전 인덱스 j를 parent[i]에 저장한다.
2. DP 계산 완료 후, LIS의 끝점인 최대 값을 가진 인덱스를 찾는다.
3. parent 배열을 타고 시작점까지 거슬러 올라가며 LIS 배열을 복원한다.
4. 복원된 LIS 배열은 역순이므로, 최종적으로 뒤집어서 출력한다.

<br/>

백준 14002번 : 가장 긴 증가하는 부분 수열 4

[https://www.acmicpc.net/problem/14002](https://www.acmicpc.net/problem/14002)

```c++
#include <algorithm>
#include <iostream>
#include <vector>

int main()
{
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);
    std::cout.tie(nullptr);

    int n;
    std::cin >> n;
    
    std::vector arr(n, 0);
    std::vector dp(n, 1);
    std::vector parent(n, -1);
    
    for (int i = 0; i < n; ++i)
    {
        std::cin >> arr[i];
    }
    
    for (int i = 1; i < n; i++)
    {
        for (int j = 0; j < i; j++)
        {
            if (arr[j] < arr[i] && dp[j] + 1 > dp[i])
            {
                dp[i] = std::max(dp[i], dp[j] + 1);
                parent[i] = j;
            }
        }
    }
    
    auto iter = std::max_element(dp.begin(), dp.end());
    int last_idx = std::distance(dp.begin(), iter);
    
    std::vector<int> path;
    
    for (int i = last_idx; i != -1; i = parent[i])
    {
        path.push_back(arr[i]);
    }
    
    std::cout << *iter << "\n";
    for (int i = path.size() - 1; i >= 0; i--)
    {
        std::cout << path[i] << " ";
    }

    return 0;
}
```

<br/>

### 방법 2 : 이분 탐색 (Binary Search)

---

시간 복잡도가 $O(NlogN)$으로 DP 방법보다 더 효율적인 방법이다.

LIS의 길이만 구할 때 사용하기 쉽다. 실제 LIS 배열을 구하는 것은 다소 복잡하다.

핵심 아이디어는 LIS의 마지막 원소가 가능한 작을수록 더 긴 LIS를 생성할 수 있다이다.

1. 빈 배열 L을 만든다
2. 주어진 수열을 하나씩 순회하며 만난 원소를 E라고 해보자.
3. E가 L의 마지막 원소보다 크다면, L의 끝에 E를 추가한다.
4. E가 L의 마지막 원소보다 작거나 같다면, L에서 E보다 크거나 같은 원소 중 가장 왼쪽에 있는 원소를 E로 교체한다.
5. 최종적으로 L의 길이가 LIS의 길이가 된다.

<br/>

백준 12015번 : 가장 긴 증가하는 부분 수열 2

[https://www.acmicpc.net/problem/12015](https://www.acmicpc.net/problem/12015)

```c++
#include <algorithm>
#include <iostream>
#include <vector>

int main()
{
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);
    std::cout.tie(nullptr);

    int n;
    std::cin >> n;
    
    std::vector<int> arr(n);
    std::vector<int> dp;
    
    for (auto& elem : arr)
    {
        std::cin >> elem;
    }
    
    for (int i = 0; i < n; i++)
    {
        auto iter = std::lower_bound(dp.begin(), dp.end(), arr[i]);
        if (iter == dp.end())
        {
            dp.push_back(arr[i]);
        }
        else
        {
            *iter = arr[i];
        }
    }
    
    std::cout << dp.size() << "\n";
    
    return 0;
}
```

<br/>

하지만 위 방법은 길이만 구할 수 있고, DP 배열의 각 원소는 실제 LIS와 다를 수 있다.

3, 5, 2, 6, 1 배열로 해보면 DP 배열은 아래와 같이 변한다.

1. [3]
2. [3, 5]
3. [2, 5]
4. [2, 5, 6]
5. [1, 5, 6]

실제 LIS는 [3, 5, 6]이지만 DP 배열은 [1, 5, 6]이 된다.

<br/>

인덱스를 저장하는 추가적인 배열을 사용해서 해결할 수 있다.

dp 배열의 맨 뒤에 추가되거나 교체될 때마다 해당 인덱스를 기록하고, 역순으로 따가라며 답을 구할 수 있다.

<br/>

백준 14003번 : 가장 긴 증가하는 부분 수열 5

[https://www.acmicpc.net/problem/14003](https://www.acmicpc.net/problem/14003)

```c++
#include <algorithm>
#include <iostream>
#include <vector>

int main()
{
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(nullptr);
    std::cout.tie(nullptr);

    int n;
    std::cin >> n;
    
    std::vector<int> arr(n);
    std::vector<int> dp;
    std::vector idx(n, 0);
    
    for (auto& elem : arr)
    {
        std::cin >> elem;
    }
    
    for (int i = 0; i < n; i++)
    {
        auto iter = std::lower_bound(dp.begin(), dp.end(), arr[i]);
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
    
    std::vector<int> ans;
    int target = dp.size();
    for (int i = n - 1; i >= 0; i--)
    {
        if (idx[i] == target - 1)
        {
            ans.push_back(arr[i]);
            target--;
        }
    }
    
    std::cout << dp.size() << "\n";
    for (int i = ans.size() - 1; i >= 0; i--)
    {
        std::cout << ans[i] << " ";
    }
    
    return 0;
}
```
