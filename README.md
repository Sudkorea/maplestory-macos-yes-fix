# 메이플스토리 YES 정리

맥북에서 메이플스토리를 껐는데도 발열이 계속될 때, CPU를 쓰는 `YES` 프로세스를 찾아 종료합니다.

**[macOS용 다운로드](https://github.com/Sudkorea/maplestory-macos-yes-fix/releases/latest/download/maplestory-hotkey-cleanup.zip)**

게임 파일과 설정 파일은 수정하지 않습니다.

## 사용 방법

1. 메이플스토리를 종료합니다.
2. 받은 ZIP을 풀고 `.command` 파일을 바탕화면에 둡니다.
3. 파일을 **더블클릭**합니다.

대상이 있으면 종료하고 다시 확인합니다. 없으면 그대로 끝납니다.

> 재발할 수 있는 임시 대응입니다. 단축키 설정은 복구하지 않습니다.

<details>
<summary>실행이 안 될 때</summary>

**권한 오류**가 나면 터미널에서 한 번 실행합니다.

```bash
chmod +x "$HOME/Desktop/kill-maplestory-hotkey-loop.command"
```

**개발자를 확인할 수 없다고 나오면**, 코드를 확인한 뒤 [Apple 안내](https://support.apple.com/ko-kr/102445)에 따라 해당 파일의 실행을 허용할 수 있습니다.

**`Skip PID` 또는 `remain`이 나오면** 자동 처리하지 못한 대상이 있습니다. [문제 제보](https://github.com/Sudkorea/maplestory-macos-yes-fix/issues)에 오류 메시지를 남겨 주세요. 개인정보는 가려 주세요.

</details>

---

[원인 분석·고객센터 답변](docs/analysis.md) · [코드 보기](kill-maplestory-hotkey-loop.command) · [문제 제보](https://github.com/Sudkorea/maplestory-macos-yes-fix/issues)

<sub>개인이 만든 비공식 도구입니다. [검증 범위](docs/analysis.md#검증-범위) · [MIT License](LICENSE)</sub>
