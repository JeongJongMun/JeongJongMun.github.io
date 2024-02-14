---
title: "시스템 콜 System Call"
writer: Langerak
date: 2024-02-14 12:00:00 +0800
categories: [Computer Science, Operating System]
tags: [Computer Science, Operating System]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/17607422-85bd-4fc2-b0bb-6465ab4d41fb
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Operating System
---

> 본 글은 제 개인적인 공부를 위해 작성한 글입니다. 틀린 내용이 있다면 언제든지 피드백을 주시면 감사하겠습니다. 참고로만 활용해주시길 바랍니다.



## 시스템 콜(System Call)

---

`시스템 콜(System Call)`은 **응용 프로그램이 운영체제의 기능을 사용**할 수 있도록 **커널 모드**에 접근하는 **인터페이스**이다.

시스템 콜은 응용 프로그램이 운영체제의 커널에게 서비스를 요청하거나 하드웨어와 상호작용하기 위해 사용된다.

시스템 콜이 생성되면 CPU는 **사용자 모드**에서 **커널 모드**로 전환하고 시스템 콜에 의해 정의된 특정 작업을 수행한다.

### 시스템 콜의 특징들:

1. 다양한 작업을 수행하기 위한 다양한 유형의 시스템 콜이 있다.
    
    가령, 파일 시스템 접근, 네트워크 통신, 메모리 관리, 프로세스 관리 등 **하드웨어 자원에 접근해서 작업을 수행**할 때 시스템 콜을 호출한다.
    
2. 시스템 콜은 커널이 제공하는 시스템 자원의 사용과 연관된 함수라고 볼 수 있다. 일반적으로 고급 프로그래밍 언어를 사용할 때 제공하는 **라이브러리 함수를 통해 호출**되기 때문이다. 라이브러리 함수는 사용자 모드에서 실행되며, 해당 기능을 수행하기 위해 운영체제의 커널 모드로 전환된다.
    
    대부분의 프로그래밍 언어에서는 시스템 콜을 추상화하여 **사용하기 쉽게 라이브러리 함수 형태로 제공**한다.
    
3. 시스템 콜은 운영체제의 핵심적인 기능에 접근하는 역할을 하므로, 보안과 안정성이 매우 중요하다. **운영체제의 자원과 기능은 시스템 콜을 통해서만 제공**한다.


*참고*
- [https://jerryjerryjerry.tistory.com/172](https://jerryjerryjerry.tistory.com/172)
- [https://cstaleem.com/user-mode-vs-kernel-mode-trap-vs-interrupt](https://cstaleem.com/user-mode-vs-kernel-mode-trap-vs-interrupt)