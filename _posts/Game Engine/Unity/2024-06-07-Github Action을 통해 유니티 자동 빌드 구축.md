---
title: "Github Action을 통해 유니티 자동 빌드 구축"
writer: Langerak
date: 2024-06-7 12:00:00 +0800
categories: [Unity]
tags: [Unity]
pin: false
math: true
mermaid: true
image:
  path: https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/e753266b-b0f8-4c4d-9361-f0e8802987d2
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
  alt: Unity
---

> 본 글은 제 개인적인 공부를 위해 작성한 글입니다. 틀린 내용이 있다면 언제든지 피드백을 주시면 감사하겠습니다. 참고로만 활용해주시길 바랍니다.

## 개요

---

Github Action을 사용하여 유니티 빌드 자동화를 쉽게 구축할 수 있다.

프로젝트를 진행하다 보면 필수적으로 빌드 파일에서 테스트를 해보아야 하는데, 수정 사항이 있을 때마다 에디터에서 직접 빌드를 하게 되면 **빌드 시간 동안 개발을 할 수 없다**.

따라서 빌드 자동화를 통해 **생산성**을 높힐 수 있다.

<br/><br/>

## 1. 유니티 프로젝트를 깃허브 레포지토리에 퍼블릭으로 등록

---

![image](https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/4a968278-f8de-4463-ba60-b506d816d9a8){: width="500" height="500" .center}

프라이빗 레포지토리의 경우 요금이 부과된다.

<br/><br/>

## 2. Secrets 등록

---

유니티를 빌드하기 위해선, **유니티 라이선스 정보와 유니티 이메일, 비밀번호**가 필요하다.

![image](https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/1ee91e95-1bfc-469f-a37b-33e0819989e4){: width="500" height="500" .center}

레포지토리의 `Settings` → `Secrets and Variables` → `Actions` → `New Repository Secret`에 등록해 **정보를 감추면서 Github Actions에서 사용**할 수 있다.

- `UNITY_LICENSE` - 라이선스 파일의 내용을 복사
- `UNITY_EMAIL` - 유니티 로그인에 사용한 이메일 주소
- `UNITY_PASSWORD` - 유니티 로그인에 사용한 비밀번호

위 3가지를 작성해주면 된다.

윈도우 기준 라이선스 파일은 아래 경로에서 확인할 수 있다.

- `C:\ProgramData\Unity\Unity_lic.ulf`

<br/><br/>

## 3. Actions 구성하기

---

![image](https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/63bad1c3-d04e-4235-8888-62b74b2a45fc){: width="500" height="500" .center}

![image](https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/9b1da453-7bad-4356-89ed-81c4de07de64){: width="500" height="500" .center}

```plaintext
name: Automated Build

on:
  push: # main 브랜치에 Push가 되면 빌드가 되도록 동작시킵니다.
    branches: [ main ]
    
jobs:
  buildWindows:
    name: Windows-64 Bit
    runs-on: windows-latest # 윈도우를 사용합니다.
    
    steps:
      # Checkout
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          lfs: true

      # 캐시파일을 생성하여 다음 빌드시 더 빠르게 빌드를 할 수 있도록 해줍니다.
      - uses: actions/cache@v4
        with:
          path: Library
          key: Library-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}
          restore-keys: |
            Library-

      # Build
      - name: Build project
        uses: game-ci/unity-builder@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
          UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
          UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}
        with:
          targetPlatform: StandaloneWindows64
          buildName: UnityBuild

      # Output
      - uses: actions/upload-artifact@v4
        with:
          name: UnityBuild
          path: build
```

위 내용의 `main.yml` 파일을 생성한다.

<br/><br/>

## 4. main 브랜치에 푸시

---

main 브랜치에 푸시가 될 때마다 자동으로 빌드가 되는 것을 확인할 수 있다.

![image](https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/835a4634-8451-4b35-a110-1bf040d92b12){: width="500" height="500" .center}

각 작업을 들어가서, 하단에 Artifact에 빌드 파일이 .zip로 올라와 있는 것을 확인할 수 있다.

![image](https://github.com/JeongJongMun/JeongJongMun.github.io/assets/101979073/8ef716d2-682a-4d83-9416-3409864d1599)

<br/><br/>

## + EC2 IP/Port 추가하기

---

내 프로젝트 같은 경우에는, 서버에 접속하기 위해 **EC2의 IP와 포트 번호**가 필요했다.

기존에는 팀원 내부적으로만 공유되는 json 파일 등을 사용해 깃허브에 공개적으로 올리지 않고 관리하였고, 유니티 에디터에서 빌드해서 문제가 없었다.

하지만 **Github Action을 통해 빌드**를 하게 된다면, 서버의 IP 주소와 포트 번호를 로컬에만 저장해서 할 수 없다.

깃허브에 공개적으로 IP를 올린다면 AWS 요금이 부과될 수 있으므로, 마찬가지로 `Secrets`에 등록하여 사용하였다.

Secrets에 서버의 IP와 Port 번호를 Json 형태로 등록해 사용한다.

- `SERVER_INFO` - Json 형태의 서버의 IP와 포트 번호

```json
{
    "ip": "0.0.0.0",
    "port": "80"
}
```

그리고 아래 코드를 `main.yml` 파일의 `# Build` 바로 위에 추가한다.

```yaml
# EC2 서버의 IP와 Port를 설정
- name: Secret Setting
  run: |
    New-Item -Path .\Assets\Resources\Json\ -Name 'ServerInfo.json' -ItemType 'file' -Value '${{ secrets.SERVER_INFO }}'
```

위와 같이 원하는 경로(ex: `Assets\Resources\Json`)에 json 파일을 생성하고, 유니티 내부에서 **파싱하여 사용**할 수 있다.

로컬에서도 동일한 경로에 json 파일을 넣어두어 사용하고, 

빌드 시에도 위 명령어를 통해 동일하게 생성되므로 문제 없이 사용할 수 있다.

로컬에서 관리하는 json 파일은 꼭 **gitignore에 등록**하여 깃허브에 올라가지 않도록 조심하자.

<br/><br/>

_참고_
- [https://velog.io/@bnm000215/유니티-자동화-빌드-Git-Action](https://velog.io/@bnm000215/유니티-자동화-빌드-Git-Action)
- [https://game.ci/](https://game.ci/)
