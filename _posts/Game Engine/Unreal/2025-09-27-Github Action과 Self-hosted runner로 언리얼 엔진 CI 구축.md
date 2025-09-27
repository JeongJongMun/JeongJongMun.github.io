---
title: "Github Action과 Self-hosted runner로 언리얼 엔진 CI 구축"
writer: Langerak
date: 2025-9-27 12:00:00 +0800
categories: [Game Engine, Unreal]
tags: [Game Engine, Unreal, CI]
pin: false
math: true
mermaid: true
---

> 이 글은 제 개인적인 공부를 위해 작성한 글입니다.   
> 틀린 내용이 있을 수 있고, 피드백은 환영합니다.

<br/>

<br/>

### 지속적 통합(Continuous Integration, CI)이란?

---

가장 쉽고 간단하게 설명하자면 CI는 게임을 빌드하고 패키징하는 프로세스를 자동화하는 것이다.

빌드와 일련의 자동 테스트를 통해 변경으로 인해 문제가 발생하지 않는지도 확인하는 것 또한 CI에 포함되어 있지만, 오늘은 빌드와 패키징만 다루겠다.

저장소에 푸시나 병합과 같은 이벤트가 발생했을 때 내 로컬에서 자동으로 패키징 후 zip파일로 압축까지만 할 것이다.

<br/>

### 전제 조건

--- 

1. 당신의 언리얼 프로젝트가 존재
2. 깃 계정
3. 적당히 명령줄 인터페이스 쓸 줄 알기

<br/>

### Github Actions workflow 구성

---

```yaml
name: Package Unreal Engine Project

on:
  push:
    branches:
      - main
    paths-ignore:
      - 'Windows/**' # windows 폴더 내 모든 파일 제외
      - 'Build/**'
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: self-hosted
    name: Package Unreal Engine Game
    steps:
      # 1. 코드 체크아웃
      - name: Checkout code
        uses: actions/checkout@v3

      # 2. Unreal Engine 프로젝트 패키징
      - name: Package Project
        env: 
          UE_PATH: 'D:\UE_5.5' # Path to your Unreal Engine installation
          PROJECT_PATH: 'D:\UnrealProjects\TromboneRumble\TromboneRumble.uproject' # Path to your Unreal project file
          OUTPUT_PATH: 'D:\UnrealProjects' # Path to where you want to store the packaged game
        run: |
          # Try to run empty UAT to check for correct path
          & $env:UE_PATH\Engine\Build\BatchFiles\RunUAT.bat BuildCookRun -project="$env:PROJECT_PATH" -noP4 -platform=Win64 -clientconfig=Development -serverconfig=Development -cook -allmaps -build -stage -pak -archive -archivedirectory="$env:OUTPUT_PATH"
        
      # 3. Windows 폴더 압축
      - name: Compress Windows Folder
        run: |
          cd "D:\UnrealProjects" # Path to your output directory
          if (Test-Path "Windows.zip") { Remove-Item "Windows.zip" } # 기존 zip 파일 삭제
          Compress-Archive -Path Windows -DestinationPath Windows.zip # Windows 폴더 압축
```

위와 같이 workflow를 작성해주면 된다.

깃허브 레포지토리 -> Actions -> New workflow -> set up a workflow yourself 순으로 들어가면 된다.

Package Project 단계에 있는 run: 에 있는 UAT(Unreal Automation Tool) 명령어의 옵션을 수정하여 빌드 옵션을 바꿀 수 있다.

- -clientconfig= : Development, Shipping, DebugGame 같은 빌드 설정 변경이 가능하다
- -platform= : Win64, Android, IOS 등 플랫폼 변경이 가능하다

원한다면 main 브랜치에 푸시될 때 최종 출시용 Shipping 빌드로 패키징하고, develop 브랜치에 푸시될 때는 Development 빌드로 패키징하는 것도 가능하다.

<br/>

### Self-hosted runner 설정

---

![img](assets/img/inpost/49.png)

먼저 레포가 public이라면 private으로 돌리도록 하자.
내 로컬 컴퓨터 자체에서 러너를 돌리기에 위험한 코드를 실행할 수 있다고 한다.

![img](assets/img/inpost/50.png)

레포지토리 Settings -> Actions -> Runners -> New self-hosted runner로 새로 생성해주자.

나는 이미 만들어놔서 하나가 있다.

![img](assets/img/inpost/51.png)

나는 윈도우를 사용하고 있어서 이 화면인데, 맥OS를 사용한다면 그거 따라서 하면 된다.

cmd 창에 명령어들을 위에서부터 순서대로 복사 붙혀넣기 해주면 된다.

너무 간단하죠?

<br/>

```shell
./config.cmd --url https://github.com/TromboneRumble/TromboneRumble --token YOUR_TOKEN
```

![img](assets/img/inpost/52.png)

한 가지 조심할 점은 중간에 아래와 같은 명령어를 실행하면, 
모두 Enter를 눌러 기본 값으로 세팅하면 되지만 'Would you like to run the runner as a service? (Y/N)'에서는 Y를 눌러야 한다.

<br/>

### Runner 서비스로 등록하기

---

이제 내 컴퓨터에서 Runner가 대기 중이고 연결한 레포지토리에 커밋이나 PR이 들어와 workflow가 생성된다면,
자동으로 패키징이 시작될 것이다.

하지만 컴퓨터를 재부팅하거나 끄게 된다면 Runner가 중지되기 때문에, 서비스로 등록해서 컴퓨터가 켜질 때마다 자동으로 실행되도록 하자.

![img](assets/img/inpost/53.png)

위 서비스 시작 명령어를 사용하여 러너를 윈도우 서비스로 등록할 수 있다.

서비스로 등록한다면, 컴퓨터가 켜질 때마다 자동으로 러너가 시작되고 레포지토리에 이벤트가 발생할 때마다 패키징이 자동으로 시작될 것이다.

<br/>

### 패키징된 파일을 구글 드라이브에 업로드하기

---

나는 이제 패키징된 파일을 팀원들과 함께 사용하는 구글 드라이브에 올리려고 시도했다.

[https://blog.teamelysium.kr/gha-google-drive](https://blog.teamelysium.kr/gha-google-drive)

위 블로그를 보고 시도하려고 했는데 결과부터 말하면

![img](assets/img/inpost/54.png)

**개인 구글 계정이 아닌 학교/기업 구글 계정을 가지고 있는 사람만 가능하다.**

나는 둘 다 없고, 기업 계정을 만들려면 월 6달러정도를 내야 했기에 그냥 수동으로 올리기로 했다.

학교/기업 구글 계정이 있다면 시도해보시길..

구글 드라이브에 개인 드라이브가 아닌 공유 드라이브로 만들어서 올리면 된다고 한다.

![img](assets/img/inpost/55.png)

만약 구글 클라우드 콘솔도 다 세팅하고, 이외 설정도 다 한다고 하더라도 runner 실행 중에 이런 에러가 뜨더라

[https://forum.rclone.org/t/google-drive-service-account-changes-and-rclone/50136](https://forum.rclone.org/t/google-drive-service-account-changes-and-rclone/50136)

위 글을 보면 2025년 4월 15일부터 서비스 계정은 저장소를 가질 수 없어서, 공유 드라이브를 사용해야 한다고 한다.

<br/>

### 어쨌든

---

![img](assets/img/inpost/56.png)

이제 내 컴퓨터가 켜져있고, 커밋 & PR이 설정한 브랜치에 올라온다면 자동으로 패키징이 된다.

혹시 구글 드라이브에 자동으로 올릴 수 있는 다른 방법을 아신다면 알려주세요..

<br/>

_참고_

- [https://dev.epicgames.com/community/learning/tutorials/1wVK/let-s-do-your-first-ci-with-unreal-engine](https://dev.epicgames.com/community/learning/tutorials/1wVK/let-s-do-your-first-ci-with-unreal-engine)

- [https://docs.github.com/ko/actions/how-tos/manage-runners/self-hosted-runners/add-runners](https://docs.github.com/ko/actions/how-tos/manage-runners/self-hosted-runners/add-runners)

- [https://docs.github.com/ko/actions/how-tos/manage-runners/self-hosted-runners/configure-the-application?platform=windows](https://docs.github.com/ko/actions/how-tos/manage-runners/self-hosted-runners/configure-the-application?platform=windows)

- [https://forum.rclone.org/t/google-drive-service-account-changes-and-rclone/50136](https://forum.rclone.org/t/google-drive-service-account-changes-and-rclone/50136)

- [https://blog.teamelysium.kr/gha-google-drive](https://blog.teamelysium.kr/gha-google-drive)
