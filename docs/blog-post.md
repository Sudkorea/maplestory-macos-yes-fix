# 맥북 메이플스토리 발열, YES 프로세스 CPU 100% 정리 방법

![메이플스토리가 켜진 맥북과 CPU 100% 표시. 증상 설명용 AI 생성 일러스트.](https://raw.githubusercontent.com/Sudkorea/maplestory-macos-yes-fix/main/docs/maplestory-macbook-heat.png)

메이플을 껐는데도 맥북이 계속 뜨거웠다. 활성 상태 보기를 보니 `YES`라는 프로세스가 CPU를 약 100%씩 쓰고 있었다. 게임을 껐다 켜다 보니 여러 개가 쌓이기도 했다.

매번 찾아서 끄기 번거로워서 더블클릭하면 정리되는 스크립트를 만들었다. **게임 파일이나 설정 파일은 건드리지 않는다.**

**[GitHub에서 다운로드](https://github.com/Sudkorea/maplestory-macos-yes-fix#readme-ov-file)**

실행이 걱정되면 [코드 설명](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/main/docs/script-guide.md)부터 보면 된다. 각 부분이 뭘 하는지, 받은 파일이 공개된 코드와 같은지 확인하는 방법을 적어 뒀다.

## 뭐가 문제인가

메이플은 게임 조작과 겹치지 않게 **맥의 단축키를 잠시 바꾼다.** 게임을 끄면 원래대로 돌려놔야 한다.

내 Mac에서는 이 과정에 오류가 생겨 `YES`라는 작업이 끝없이 돌고 있었다. **게임은 꺼졌는데 맥북은 계속 일하니 뜨거웠던 것.**

이 스크립트는 그 작업을 찾아 끄는 용도다.

## 사용 방법

1. 메이플스토리를 종료한다.
2. GitHub에서 ZIP을 받고 압축을 푼다.
3. `.command` 파일을 바탕화면에 두고 더블클릭한다.

해당 프로세스가 있으면 종료하고 다시 확인한다. 없으면 그대로 끝난다. 처음 실행이 안 될 때의 방법도 GitHub에 적어 뒀다.

## 고객센터 답변

고객센터에는 이미 문의했다. 베타 서비스 중이며 제보 내용을 전달했다는 답변을 받았고, 구체적인 수정 일정은 없었다. [받은 답변 보기](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/main/docs/support-response.png)

이 스크립트는 **남은 프로세스를 정리하는 임시 대응**이다. 다음 실행 때 재발할 수 있고, 단축키 설정을 복구해 주지는 않는다.

최초 증상은 macOS 15.7.7에서 확인했다. 현재 26.6.1에서는 오류 파일이 새로 만들어지는 과정을 재현하지 못했다. 자세한 원인과 테스트 범위는 [GitHub 분석 문서](https://github.com/Sudkorea/maplestory-macos-yes-fix/blob/main/docs/analysis.md)에 남겨 뒀다.
