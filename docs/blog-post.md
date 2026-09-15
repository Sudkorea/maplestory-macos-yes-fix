# 맥북 메이플스토리 발열, YES 프로세스 CPU 100% 정리 방법

메이플을 껐는데도 맥북이 계속 뜨거웠다. 활성 상태 보기를 보니 `YES`라는 프로세스가 CPU를 약 100%씩 쓰고 있었다. 게임을 껐다 켜다 보니 여러 개가 쌓이기도 했다.

매번 찾아서 끄기 번거로워서 더블클릭하면 정리되는 스크립트를 만들었다. **게임 파일이나 설정 파일은 건드리지 않는다.**

**[GitHub에서 다운로드](https://github.com/Sudkorea/maplestory-macos-yes-fix#readme)**

## 사용 방법

1. 메이플스토리를 종료한다.
2. GitHub에서 ZIP을 받고 압축을 푼다.
3. `.command` 파일을 바탕화면에 두고 더블클릭한다.

해당 프로세스가 있으면 종료하고 다시 확인한다. 없으면 그대로 끝난다. 처음 실행이 안 될 때의 방법도 GitHub에 적어 뒀다.

## 왜 생겼냐면

내 Mac에서는 게임의 단축키 복구 스크립트에 오류 문장과 `YES`가 잘못 기록돼 있었다. 이 `YES`가 별도 명령으로 실행되면서 CPU를 계속 쓰고 있었다.

고객센터에는 이미 문의했다. 베타 서비스 중이며 제보 내용을 전달했다는 답변을 받았고, 구체적인 수정 일정은 없었다. [받은 답변 보기](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/main/docs/support-response.png)

이 스크립트는 **남은 프로세스를 정리하는 임시 대응**이다. 다음 실행 때 재발할 수 있고, 단축키 설정을 복구해 주지는 않는다.

최초 증상은 macOS 15.7.7에서 확인했다. 현재 26.6.1에서는 오류 파일이 새로 만들어지는 과정을 재현하지 못했다. 자세한 원인과 테스트 범위는 [GitHub 분석 문서](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/main/docs/analysis.md)에 남겨 뒀다.
