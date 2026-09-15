# 맥북 메이플스토리 발열: YES 프로세스 CPU 100% 임시 해결

**게임을 껐는데도 `YES`가 CPU를 계속 사용하나요?** macOS 메이플스토리의 단축키 복구 작업에서 확인한 문제와, 해당 작업을 찾아 종료하는 더블클릭 스크립트입니다.

[다운로드 및 실행 파일](https://github.com/Sudkorea/maplestory-macos-yes-fix/releases/latest) · [스크립트 전체 코드](kill-maplestory-hotkey-loop.command) · [원인과 확인 근거](docs/analysis.md) · [문제 제보](https://github.com/Sudkorea/maplestory-macos-yes-fix/issues)

게임 설치 파일과 사용자 설정 파일을 수정하지 않습니다. 이미 발생한 프로세스를 정리하는 **임시 대응**이며, 다음 게임 실행 때 재발할 수 있습니다. 넥슨 공식 도구가 아닙니다.

## 사용 방법

1. 메이플스토리를 종료합니다.
2. [최신 릴리스](https://github.com/Sudkorea/maplestory-macos-yes-fix/releases/latest)에서 `maplestory-hotkey-cleanup.zip`을 받습니다.
3. 압축을 풀고 `kill-maplestory-hotkey-loop.command`를 바탕화면에 둡니다.
4. 파일을 더블클릭합니다. 대상이 없으면 바로 끝나고, 있으면 종료한 뒤 다시 확인합니다.

정상 완료 시 터미널에 아래 문장이 표시됩니다. 터미널 창은 설정에 따라 남을 수 있습니다.

```text
Done. No matching MapleStory hotkey CPU loop is running.
```

`Skip PID` 또는 `remain`이 나오면 자동으로 처리하지 못한 항목이 있다는 뜻입니다. 활성 상태 보기에서 확인하고, [이슈](https://github.com/Sudkorea/maplestory-macos-yes-fix/issues)에 메시지를 남겨 주세요. 계정명 등 개인정보는 가려 주세요.

### 처음 실행이 안 되는 경우

`permission denied`가 나오면 바탕화면에 둔 파일에 한 번 실행 권한을 줍니다.

```bash
chmod +x "$HOME/Desktop/kill-maplestory-hotkey-loop.command"
```

macOS가 개발자를 확인할 수 없다고 차단하면 코드를 검토한 뒤, [Apple의 앱 열기 안내](https://support.apple.com/ko-kr/102445)에 따라 시스템 설정 > 개인정보 보호 및 보안에서 해당 파일의 실행을 허용할 수 있습니다.

터미널에서 직접 실행할 수도 있습니다. `Users/...`로 시작하는 경로는 앞의 `/`가 빠진 잘못된 경로입니다.

```bash
/bin/bash "$HOME/Desktop/kill-maplestory-hotkey-loop.command"
```

종료하지 않고 검사만 하려면:

```bash
/bin/bash "$HOME/Desktop/kill-maplestory-hotkey-loop.command" --check
```

## 어떤 프로세스를 종료하나요?

아래 관계와 현재 사용자 소유 여부를 모두 확인한 작업만 처리합니다. `$HOME`은 실행한 사용자의 홈 폴더입니다.

```text
/bin/bash .../MapleStory.app/.../bin/set_hotkeys
  -> /bin/bash $HOME/Library/Application Support/MapleStory/.hotkey-cache.sh
     -> YES $HOME/Library/Preferences/com.apple.symbolichotkeys.plist
```

각 프로세스의 번호(PID), 시작 시각, 사용자, 실행 명령을 다시 확인한 뒤 **위 세 프로세스에만 `SIGKILL`을 보냅니다.** 복구 스크립트가 다음 줄로 진행하지 않도록 셸 두 개부터 종료합니다. 같은 프로세스 그룹 전체를 종료하지 않습니다.

`YES`라는 이름만으로 종료하지 않으며, 관계가 끊긴 프로세스나 다른 설치 경로는 건너뜁니다. macOS 기본 Bash만 사용하고 관리자 권한, 상주 작업, 네트워크 통신이 필요 없습니다. 종료 코드 `0`은 검사/처리 성공, `1`은 미확인 또는 남은 대상/실패, `2`는 사용법/실행 환경 오류입니다. `--check`에서는 대상을 찾아도 검사에 성공하면 `0`입니다.

**단축키 원상 복구는 하지 않습니다.** 중단된 복구 작업 때문에 키보드 설정이 달라져 있다면 시스템 설정에서 확인해야 합니다. 실행 중인 게임을 먼저 종료해 주세요.

## 원인 요약

확인한 로컬 파일에서는 Spotlight 단축키 항목을 읽는 과정의 오류 문장과 기본값 `YES`가 줄바꿈을 포함해 복구 스크립트에 기록돼 있었습니다. 그 결과 `YES`가 별도 명령이 됐습니다. 확인한 Mac에서는 `/usr/bin/YES`와 `/usr/bin/yes`가 같은 파일로 해석됐습니다. `yes`는 입력받은 문자열을 반복 출력하는 명령이라 계속 CPU를 사용했습니다.

초기 조사에서 해당 프로세스 여러 개가 각각 CPU 약 100%를 사용하고, 게임 종료 후에도 남는 현상을 관찰했습니다. 현재 macOS 26.6.1에서 읽기 명령을 따로 확인했을 때는 오류 문장과 `YES`가 함께 캡처되는 현상이 재현되지 않았습니다. 예전 오류 캐시는 남아 있었지만, 지금 새로 같은 문제가 발생하는지는 확인하지 않았습니다. 자세한 구분은 [분석 문서](docs/analysis.md)에 정리했습니다.

## 고객센터 답변

직접 문의 후 받은 답변은 MAC 버전이 베타 서비스 중이며, 안정성 테스트와 최적화를 진행하고 제보 내용을 참고할 수 있도록 전달했다는 내용입니다. 구체적인 원인 확인, 패치 일정, 이 스크립트의 사용 승인에 대한 답변은 포함돼 있지 않습니다.

<img src="docs/support-response.png" width="389" alt="메이플스토리 고객센터 답변: 베타 서비스, 안정성 테스트 및 최적화, 제보 내용 전달 안내">

## 검증 범위

2026-09-15에 macOS 26.6.1 / Apple Silicon에서 Bash 문법 검사, 회귀 검사, 실제 프로세스가 없는 상태의 검사/실행을 확인했습니다. 최초 발열 조사 환경은 macOS 15.7.7 / Apple Silicon이었습니다. 공개 버전의 종료 분기는 모의 프로세스로 검증했으며, 현재 게임을 다시 실행해 실제 장애를 유발하는 검증은 하지 않았습니다.

```bash
/bin/bash -n kill-maplestory-hotkey-loop.command
/bin/bash test-hotkey-loop.sh
```

게임 업데이트로 파일 경로나 프로세스 구조가 바뀌면 자동 판별이 작동하지 않을 수 있습니다. 설치된 클라이언트가 최신인지, 서버 측 수정이 배포됐는지는 확인하지 않았습니다.

## English

A macOS MapleStory workaround for runaway `YES` / `yes` processes left by the hotkey restore script. It checks the exact command, ownership and parent chain, kills only the three identified processes, and checks again. No game files or preferences are edited. Use after closing the game. This is an unofficial cleanup tool, not a permanent fix or a vendor-approved utility.

## 라이선스

직접 작성한 코드와 문서는 [MIT License](LICENSE)로 공개합니다. `docs/support-response.png`의 고객센터 답변과 이미지, 메이플스토리 및 넥슨의 상표는 해당 권리자에게 속하며 MIT 라이선스 대상이 아닙니다.
