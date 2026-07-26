---
title: "PowerShell: Set-Location: A positional parameter cannot be found that accepts argument '-'"
description: "PowerShell에서 하이픈이 포함된 경로로 이동할 때 발생하는 오류의 원인과, 따옴표로 감싸 해결한 방법을 정리했습니다."
writer: Langerak
date: 2024-02-20 12:00:00 +0800
categories: [Trouble Shooting]
tags: [Trouble Shooting]
pin: false
math: true
mermaid: true
---

> 호스팅으로 올려둔 이미지를 복구할 수가 없네요. 글이라도 도움되시길
{: .prompt-warning }

## 문제점

---

위와 같이 - 문자가 있는 경로로 이동하려 할 때 에러가 발생했다.

## 해결

---

따옴표로 경로를 묶어주어 해결하였다.
<br/> <br/>
*참고*
- [https://stackoverflow.com/questions/51459313/cd-program-files-error-positional-parameter-cannot-be-found](https://stackoverflow.com/questions/51459313/cd-program-files-error-positional-parameter-cannot-be-found)
