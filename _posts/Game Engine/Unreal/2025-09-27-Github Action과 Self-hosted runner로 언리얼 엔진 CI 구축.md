---
title: "Github Action과 Self-hosted runner로 언리얼 엔진 CI 구축"
writer: Langerak
date: 2025-10-06 12:00:00 +0800
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

### 2025-10-06 개발/CI 용 디렉토리 구분

--- 

이전 워크플로우를 사용하다 보니 한가지 문제가 있었다.
내가 main이 아닌 작업 브랜치에서 프로젝트를 열고 작업 하는 도중에 main 브랜치에 커밋이 올라와 CI가 동작하면,
빌드 프로세스가 작업 브랜치를 바라보고 있는 프로젝트에서 빌드를 시도하게 되면서 꼬이게 되는 것이다.

내 작업 프로젝트 폴더에서 작업과 CI 둘 다 하게 되니 오류가 발생하게 된 것이다.

이 문제를 해결하기 위해, 개발용, CI 빌드용 디렉토리를 분리하였다.
1. 개발용 디렉토리 D:\UnrealProjects\TromboneRumble
2. CI 빌드용 디렉토리 D:\UnrealProjects\TromboneRumble_for_workflow

두 프로젝트 모두 같은 레포지토리에서 클론을 따왔고 이름만 다를 뿐이다.
TromboneRumble_for_workflow 디렉토리는 CI 빌드용으로 항상 최신 main 브랜치를 바라보고 있어야 한다.
이를 위해서 기존 워크플로우에서 패키징 전 단계로 메인 브랜치로 업데이트하는 단계를 추가하였다.

pull을 받는 과정에서 권한 문제가 발생하여서 Personal Access Token(PAT)를 사용하여 pull을 받도록 하였다.
PAT는 깃허브 레포지토리 Settings -> Secrets and variables -> Actions -> Repository secrets에 추가하면 된다.

또한 빌드 파일을 따로 저장하는 디렉토리를 만들어두었고, 빌드 전에 해당 디렉토리를 깨끗하게 비우는 단계도 추가하였다.

main.yml 코드는 아래와 같이 수정하였다.

```yaml
name: Package Unreal Engine Project

on:
  push:
    branches:
      - main
    paths-ignore:
      - 'Windows/**'
      - 'Build/**'
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: self-hosted
    name: Package Unreal Engine Project
    steps:
      - name: Checkout code
        uses: actions/checkout@v5

      - name: Sync Workflow Directory to latest Main Branch
        shell: powershell
        run: |
          git config --global --add safe.directory "D:/UnrealProjects/TromboneRumble_for_workflow"
          $workflowPath = "D:\UnrealProjects\TromboneRumble_for_workflow"
          cd $workflowPath
          git reset --hard HEAD
          git pull https://x-access-token:${{ secrets.GH_PAT }}@github.com/${{ github.repository }} main
          git log -1

      - name: Clean Build Directory
        shell: powershell
        run: |
          $buildPath = "D:\UnrealProjects\Build"
          if (Test-Path $buildPath) {
            Get-ChildItem -Path $buildPath | Remove-Item -Recurse -Force
          }

      - name: Package Project
        env: 
          UE_PATH: 'D:\UE_5.5'
          PROJECT_PATH: 'D:\UnrealProjects\TromboneRumble_for_workflow\TromboneRumble.uproject'
          OUTPUT_PATH: 'D:\UnrealProjects\Build'
        shell: powershell
        run: |
          & $env:UE_PATH\Engine\Build\BatchFiles\RunUAT.bat BuildCookRun -project="$env:PROJECT_PATH" -noP4 -platform=Win64 -clientconfig=Development -serverconfig=Development -cook -allmaps -build -stage -pak -archive -archivedirectory="$env:OUTPUT_PATH" -buildargs="-NoLiveCoding"
      
      - name: Compress Packaged Folder with Date-Time
        run: |
          $buildPath = "D:\UnrealProjects\Build"
          $sourceFolder = Join-Path $buildPath "Windows"
          
          if (-not (Test-Path $sourceFolder)) {
              Write-Error "Packaged folder '$sourceFolder' not found. Aborting compression."
              exit 1
          }

          $dateTime = Get-Date -Format "yyyyMMdd_HHmm"
          $zipFileName = "${dateTime}_${{ github.event.repository.name }}.zip"
          $destinationZipPath = Join-Path $buildPath $zipFileName

          Compress-Archive -Path $sourceFolder -DestinationPath $destinationZipPath -Force
```

흐름을 정리하면 아래와 같다.
1. 내 로컬 컴퓨터를 키면 자동으로 self-hosted runner 서비스가 시작된다.
2. 누군가가 main 브랜치에 커밋을 푸시하거나 PR을 병합하면 워크플로우가 시작된다.
3. self-hosted runner가 워크플로우를 감지하고, CI를 시작한다.
4. 워크플로우는 TromboneRumble_for_workflow 디렉토리로 이동하여, main 브랜치의 최신 커밋을 pull 받는다.
5. 빌드 파일을 저장하는 D:\UnrealProjects\Build 디렉토리를 깨끗하게 비운다.
6. UAT 명령어로 TromboneRumble_for_workflow 프로젝트를 패키징한다.
7. 패키징된 Windows 폴더를 날짜_시간_레포지토리이름.zip 형식으로 압축한다.
8. 압축된 zip 파일은 D:\UnrealProjects\Build 디렉토리에 저장된다.
9. 압축된 파일을 수동으로 구글 드라이브에 업로드한다.

아직까지 세 가지 개선사항을 생각하고 있다.
1. 내 컴퓨터가 꺼져있다면 CI가 동작하지 않는다.
2. 패키징된 파일을 수동으로 구글 드라이브에 업로드해야 한다.
3. gitignore에 등록되어 있는 Plugins 폴더 같은 서드파티 플러그인이 설치되어 있다면 패키징이 실패하기에, 수동으로 해당 파일을 옮겨줘야 한다.

1번은 언리얼 프로젝트 크기 상 호스팅 서비스를 이용하는 것이 비용적으로 부담이 될 것 같고,
2번은 구글 드라이브에 자동 업로드하는 방법이 개인 계정에서는 불가능하다고 한다.
3번은 서드파티 플러그인을 레포지토리에 포함시키는 방법은 용량 때문에 사실 상 불가능하고, 다른 방법을 생각 중이다.

<br/>

_참고_

- [https://dev.epicgames.com/community/learning/tutorials/1wVK/let-s-do-your-first-ci-with-unreal-engine](https://dev.epicgames.com/community/learning/tutorials/1wVK/let-s-do-your-first-ci-with-unreal-engine)

- [https://docs.github.com/ko/actions/how-tos/manage-runners/self-hosted-runners/add-runners](https://docs.github.com/ko/actions/how-tos/manage-runners/self-hosted-runners/add-runners)

- [https://docs.github.com/ko/actions/how-tos/manage-runners/self-hosted-runners/configure-the-application?platform=windows](https://docs.github.com/ko/actions/how-tos/manage-runners/self-hosted-runners/configure-the-application?platform=windows)

- [https://forum.rclone.org/t/google-drive-service-account-changes-and-rclone/50136](https://forum.rclone.org/t/google-drive-service-account-changes-and-rclone/50136)

- [https://blog.teamelysium.kr/gha-google-drive](https://blog.teamelysium.kr/gha-google-drive)
