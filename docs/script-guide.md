# 이 스크립트가 하는 일

**실행 중인 작업을 확인하고, 메이플 단축키 복구 작업으로 확인된 것만 종료합니다.**

아래는 [v1.0.0에 배포된 코드 전체 121줄](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/19c60ca505512714f83494cdb5f2df5634e8a3bf/kill-maplestory-hotkey-loop.command)의 설명입니다. 링크는 이후 수정에도 내용이 바뀌지 않는 특정 커밋을 가리킵니다.

## 먼저 확인할 것

| 궁금한 점 | 이 버전의 코드 |
| --- | --- |
| 무엇을 읽나요? | 실행 중인 작업의 이름, 번호, 부모 작업, 사용자, 시작 시각 |
| 실제로 바꾸는 건 뭔가요? | 조건이 맞는 작업 세 개를 강제 종료 |
| 파일을 지우거나 설정을 바꾸나요? | 그런 명령 없음 |
| 인터넷에 뭔가 보내나요? | 통신·다운로드 명령 없음 |
| 관리자 권한이 필요한가요? | 필요 없음. `sudo`로 실행하면 중단 |

파일 내용을 확인하려면 위 링크에서 읽거나, 받은 `.command` 파일을 텍스트 편집기로 열면 됩니다. 내용을 읽는 데 스크립트를 실행할 필요는 없습니다.

## 코드 블록별 설명

### 1. 찾을 작업의 이름을 정합니다

[1~5줄 보기](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/19c60ca505512714f83494cdb5f2df5634e8a3bf/kill-maplestory-hotkey-loop.command#L1-L5)

`#!/bin/bash`는 macOS에 있는 Bash로 이 글을 실행하라는 표시입니다. 그 아래 세 줄은 **찾을 작업에 쓰이는 파일 경로를 글자로 저장**합니다. `$HOME`은 내 사용자 폴더를 뜻합니다.

여기 적힌 게임 파일이나 설정 파일을 열어서 수정하거나 실행하는 것은 아닙니다. 뒤에서 작업 이름을 비교할 때 사용합니다.

### 2. 작업 하나의 정보를 읽습니다

[7~9줄 보기](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/19c60ca505512714f83494cdb5f2df5634e8a3bf/kill-maplestory-hotkey-loop.command#L7-L9)

```bash
ps -ww -p "$2" -o "$1" 2>/dev/null
```

`ps`는 활성 상태 보기처럼 실행 중인 작업 정보를 보여주는 macOS 명령입니다. `$2`는 작업 번호, `$1`은 읽을 정보의 종류입니다. `-ww`는 긴 이름도 잘리지 않게 합니다.

`2>/dev/null`은 조회 도중 작업이 이미 끝났을 때 생기는 오류 문구를 숨깁니다. 조회 성공 여부는 호출한 코드에서 따로 확인합니다.

### 3. 해당 YES 작업을 찾습니다

[11~23줄 보기](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/19c60ca505512714f83494cdb5f2df5634e8a3bf/kill-maplestory-hotkey-loop.command#L11-L23)

먼저 실행 중인 전체 작업 목록을 읽습니다. `awk`는 그 목록에서 조건이 맞는 줄을 고르는 명령입니다.

`YES`라는 이름뿐 아니라 **내 단축키 설정 파일 경로까지 정확히 같은 작업**을 후보로 고릅니다. 대소문자와 `/usr/bin/` 경로 표기 차이 네 가지를 허용합니다. 후보의 작업 번호만 다음 단계로 넘기고, 여기서는 종료하지 않습니다.

### 4. 정말 메이플에서 생긴 작업인지 확인합니다

[25~45줄 보기](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/19c60ca505512714f83494cdb5f2df5634e8a3bf/kill-maplestory-hotkey-loop.command#L25-L45)

작업을 시작시킨 쪽을 '부모 작업'이라고 합니다. 코드에서는 부모를 두 단계 따라가 아래 관계가 맞는지 확인합니다.

```text
메이플 단축키 처리 → 단축키 복구 → YES
```

작업 번호가 숫자인지, 두 부모의 실행 경로가 정확한지, 세 작업이 모두 내 사용자 소유인지 검사합니다. 하나라도 맞지 않으면 건너뜁니다. `return 1`은 이 확인에 실패했다는 뜻입니다.

### 5. 확인된 세 작업만 강제 종료합니다

[47~64줄 보기](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/19c60ca505512714f83494cdb5f2df5634e8a3bf/kill-maplestory-hotkey-loop.command#L47-L64)

**실제로 작업을 종료하는 부분은 여기입니다.**

```bash
kill -KILL "${pids[$i]}"
```

`kill -KILL`은 지정한 번호의 작업을 강제 종료합니다. 앞에서 찾은 세 작업의 사용자, 시작 시각, 실행 명령과 부모 관계를 다시 확인한 다음 사용합니다. 조회 사이에 다른 작업으로 바뀌었으면 중단합니다.

복구용 작업 둘을 먼저 종료하고 마지막에 `YES`를 종료합니다. `YES`만 먼저 끄면 남아 있는 복구 작업이 다음 명령으로 진행할 수 있기 때문입니다. 같은 이름의 작업 전부나 프로세스 그룹 전체를 끄는 명령은 없습니다.

### 6. 검사만 할지, 종료할지 결정합니다

[66~95줄 보기](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/19c60ca505512714f83494cdb5f2df5634e8a3bf/kill-maplestory-hotkey-loop.command#L66-L95)

macOS인지 확인하고, 관리자 권한으로 실행한 경우 중단합니다. 옵션 없이 실행하면 위의 확인과 종료를 진행합니다.

`--check`를 붙이면 **확인 결과만 보여주고 강제 종료 부분을 실행하지 않습니다.** 조건이 맞지 않는 후보는 `Skip PID`로 알립니다.

### 7. 끝났는지 다시 봅니다

[96~114줄 보기](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/19c60ca505512714f83494cdb5f2df5634e8a3bf/kill-maplestory-hotkey-loop.command#L96-L114)

종료한 작업이 있다면 1초 기다렸다가 다시 확인합니다. 이미 끝나서 정리만 기다리는 작업은 실행 중으로 세지 않습니다. 해당 `YES`가 더 있는지도 다시 찾습니다.

남은 작업이나 실패가 있으면 메시지를 보여주고, 정상 완료했을 때만 `Done`을 표시합니다. 반복 감시하는 상주 프로그램은 아닙니다.

### 8. 이 파일을 직접 실행했을 때 시작합니다

[116~121줄 보기](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/19c60ca505512714f83494cdb5f2df5634e8a3bf/kill-maplestory-hotkey-loop.command#L116-L121)

파일을 직접 실행했을 때 `main`을 시작합니다. 테스트에서 불러오기만 했을 때는 자동 실행하지 않습니다.

`set -u`는 정의되지 않은 변수를 쓰면 오류를 내게 합니다. `PATH`는 명령을 찾을 위치를 macOS 기본 폴더로 한정하고, `LC_ALL=C`는 조회 결과의 언어 형식을 일정하게 맞춥니다. 이 값들은 이 실행과 자식 작업에만 적용되며 시스템 설정 파일에 저장하지 않습니다.

## 받은 파일이 같은 코드인지 확인하기

스크립트를 바탕화면에 뒀다면 터미널에서 아래 명령을 실행합니다. **이 명령은 스크립트를 실행하지 않고 파일의 SHA-256 해시를 계산합니다.** 해시는 파일 내용으로 만드는 식별값입니다.

```bash
shasum -a 256 "$HOME/Desktop/kill-maplestory-hotkey-loop.command"
```

v1.0.0의 결과는 아래 값과 같아야 합니다.

```text
209873c8797f6d0129b7ec289ab66c41a22082b559d6a5808391e3af0f6e872e
```

ZIP과 스크립트의 값은 [릴리스의 SHA256SUMS](https://github.com/Sudkorea/maplestory-macos-yes-fix/releases/download/v1.0.0/SHA256SUMS)에도 있습니다. **일치한다는 것은 설명한 파일과 같은 파일이라는 뜻이지, 안전성을 인증받았다는 뜻은 아닙니다.**

내용과 파일을 확인한 뒤, 종료 없이 검사만 하려면:

```bash
/bin/bash "$HOME/Desktop/kill-maplestory-hotkey-loop.command" --check
```

`--check`는 이 공개 코드에서 제공하는 옵션입니다. 출처가 다른 임의의 파일에 붙인다고 안전하게 실행되는 장치는 아닙니다.

## 확인된 범위와 한계

모의 프로세스 검사에서 다른 사용자·다른 경로·끊어진 부모 관계를 건너뛰는지, 검사 모드에서 종료하지 않는지, 종료 순서와 실패 처리를 확인했습니다. [검사 코드](../test-hotkey-loop.sh)와 [검증 기록](analysis.md#검증-범위)을 공개했습니다.

종료는 강제 종료이고 단축키 복구를 대신 완료하지는 않습니다. 현재 공개 버전의 실제 장애 종료는 모의 검사로 검증했으며, 제3자 보안 감사나 넥슨의 사용 승인을 받은 도구는 아닙니다. 이 문서는 그 사실까지 포함해 코드를 직접 판단할 수 있도록 작성했습니다.
