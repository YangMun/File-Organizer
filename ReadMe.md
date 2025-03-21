# File Organizer

파일을 종류별로 자동 정리해주는 Ios 앱입니다.

## 📌 주요 기능

- 파일 자동 분류 및 정리
- 파일 종류별 관리 (PDF, 워드, 한글, 엑셀, PPT)
- 최근 업로드된 파일 목록 제공
- 파일 드래그 앤 드롭 지원
- 사용자 설정 기능

## 🛠 개발 환경

- **Language**: Swift
- **Framework**: SwiftUI
- **IDE**: Xcode 16.0+

## 📱 스크린샷

> 추후 앱 스크린샷 추가 예정

## 🔍 현재 구현된 기능

- [x] 기본 UI 구조 구현
- [x] 파일 타입별 메뉴 구현
- [x] 탭 기반 네비게이션
- [ ] 파일 업로드 기능
- [ ] 파일 자동 분류 기능
- [ ] 설정 기능

## 🚀 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/YOUR_USERNAME/File-Organizer.git
```

2. Xcode로 프로젝트 열기
3. Build 및 실행

## 📂 프로젝트 구조

⌘K to generate a command
해당 탭을 누르면 해당 페이지가 떠야 한다. "홈" 페이지는 지금 현재 보이는 페이지로 됐고 나머지 파일과 설정의 대한 기본 구조로 해달라.

네, "파일"과 "설정" 페이지를 위한 새로운 뷰를 만들고, TabView에서 페이지 전환이 되도록 수정하겠습니다.
먼저 "파일"과 "설정" 페이지를 위한 새로운 뷰를 만들고, MainView를 수정하겠습니다.
먼저 FileView.swift 파일을 생성하여 파일 페이지를 만듭니다:
SettingsView.swift 파일을 생성하여 설정 페이지를 만듭니다:
MainView.swift를 수정하여 탭 전환이 되도록 구현합니다:
주요 변경사항:
각 탭에 해당하는 별도의 뷰를 생성했습니다.
TabView 내부 구조를 수정하여 각 탭이 해당하는 뷰를 표시하도록 했습니다.
홈 탭은 기존 구현을 유지하고, 파일과 설정 탭은 새로 만든 뷰를 사용합니다.
이제 탭을 클릭하면:
"홈" 탭에서는 파일 업로드와 최근 업로드 목록을 보여줍니다.
"파일" 탭에서는 파일 종류별 목록을 보여줍니다.
"설정" 탭에서는 앱 설정 옵션들을 보여줍니다.
각 탭의 세부 기능은 필요에 따라 추가로 구현하실 수 있습니다.
@FileView.swift 해당 페이지의 디자인은 이미지에 보이는 것 처럼 하고 싶다.  각 항목에 대한 아이콘은 Assets에 저장했다. 
pdf 항목은 :PDF.png,
워드 항목은 : Word.png
한글 항목은 : HWP.png
엑셀 항목은: Excel.png
PPT 항목은 : PPT.png 
해당 디자인에 맞게 UI를 그려달라

네, 이미지처럼 그리드 형태의 파일 타입 메뉴를 구현하겠습니다.
주요 구현 사항:
FileTypeItem 구조체를 만들어 각 파일 타입의 정보를 관리합니다.
LazyVGrid를 사용하여 2열 그리드 레이아웃을 구현했습니다.
각 아이템은 흰색 배경의 카드 형태로 표시됩니다.
상단에 네비게이션 타이틀과 새로고침 버튼을 추가했습니다.
각 카드는 그림자 효과와 둥근 모서리를 가집니다.
Assets에 저장된 이미지를 사용합니다.
디자인 특징:
각 카드는 흰색 배경에 그림자 효과를 주어 입체감을 표현했습니다.
아이콘과 텍스트의 간격과 크기를 적절히 조절했습니다.
전체 배경은 밝은 회색으로 설정했습니다.
2열 그리드로 배치하여 이미지와 동일한 레이아웃을 구현했습니다.
각 파일 타입 버튼을 클릭했을 때의 동작은 Button의 action 클로저에 구현하시면 됩니다.
우선 모든 UI를 구현한 것은 아니지만 지금까지 한 내용을 깃허브에 먼저 올릴려고 한다.

깃허브에 프로젝트를 올리기 위한 기본적인 단계를 안내해드리겠습니다:
먼저 .gitignore 파일을 생성합니다. Xcode 프로젝트를 위한 기본적인 .gitignore 내용입니다:
Apply to ReadMe.md
/
터미널에서 다음 명령어들을 순서대로 실행하세요:
Apply to ReadMe.md
Run
main
README.md 파일을 생성하여 프로젝트에 대한 기본 설명을 추가하는 것을 추천드립니다:
Apply to ReadMe.md
네비게이션
README.md 파일을 추가하고 커밋:
Apply to ReadMe.md
Run
push
이렇게 하면 기본적인 프로젝트 구조가 깃허브에 업로드됩니다. 추후 개발이 진행되면서 새로운 기능이나 수정사항이 생길 때마다 commit과 push를 통해 업데이트하시면 됩니다.
참고사항:
커밋 메시지는 한글로 작성하셔도 됩니다.
깃허브에 저장소를 먼저 생성하셔야 합니다.
필요한 경우 브랜치를 만들어서 작업하실 수 있습니다.
라이센스 파일이 필요한 경우 깃허브에서 추가하실 수 있습니다.
@.gitignore 여기에 File-Organizer-Info.plist도 추가하고 싶다.

.gitignore 파일에 File-Organizer-Info.plist를 추가하겠습니다. 파일 끝부분에 다음 내용을 추가하면 됩니다:
Apply
# Custom ignores
File-Organizer-Info.plist
이렇게 하면 File-Organizer-Info.plist 파일이 git 버전 관리에서 제외됩니다. 만약 이미 git에 추가된 상태라면 다음 명령어를 실행하여 캐시에서 제거해야 합니다:
Apply to ReadMe.md
Run
git rm --cached File-Organizer-Info.plist
그 후 변경사항을 커밋하시면 됩니다:
Apply to ReadMe.md
Run
"
remote까지 했다. 먼저 브랜치를 만들고 하고 싶다. develop 브랜치와 Filefunction 브랜치 2개로

네, develop 브랜치와 Filefunction 브랜치를 생성하고 설정하는 과정을 안내해드리겠습니다:
먼저 develop 브랜치 생성 및 설정:
Apply to ReadMe.md
Run
develop
develop 브랜치에서 Filefunction 브랜치 생성:
Apply to ReadMe.md
Run
Filefunction
브랜치 확인:
Apply to ReadMe.md
Run
a
이제 브랜치 구조는 다음과 같이 됩니다:
main (기본 브랜치)
develop (개발 브랜치)
Filefunction (파일 기능 구현을 위한 브랜치)
작업 순서:
Filefunction 브랜치에서 파일 관련 기능을 개발
개발이 완료되면 develop 브랜치로 merge
develop 브랜치에서 테스트 후 문제가 없으면 main 브랜치로 merge
필요한 경우 다음 명령어들을 사용하실 수 있습니다:
Apply to ReadMe.md
Run
Filefunction
@ReadMe.md 추후 사용자가 보기 좋도록 양식을 적어달라.

File-Organizer/
├── Views/
│ ├── MainView.swift
│ ├── FileView.swift
│ ├── FileUpLoadView.swift
│ ├── RecentUpLoadView.swift
│ └── SettingsView.swift
├── Models/
├── ViewModels/
└── Resources/
└── Assets.xcassets/