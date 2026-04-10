---
name: vox-dash-guide
description: "Guide for using the vox.ai dashboard — agent settings (prompt, TTS, tools, extraction, deployment), web testing, bulk calling, and call data review. Also serves as a UI reference that other vox skills consult when explaining how to do something in the dashboard. Supports screen-guided mode via Chrome MCP extension when a dashboard URL is provided. Trigger on '대시보드 사용법 알려줘', '에이전트 설정 어떻게 해', '대량발신 방법', '통화 기록 어디서 봐', '테스트 어떻게 해', '화면 보여줘', '대시보드 같이 봐줘', 'UI에서 어떻게 해', or any dashboard usage question. Other vox skills should also reference this skill when they need to explain dashboard UI steps."
---

# vox.ai 대시보드 가이드

vox.ai 대시보드에서 에이전트를 설정하고, 테스트하고, 대량발신하고, 통화 데이터를 확인하는 방법을 안내한다.

## 레퍼런스 역할 분담

이 스킬은 라우터다. 실제 내용은 아래 레퍼런스에 있으므로, 작업 전에 해당 파일을 반드시 읽는다.

| 파일 | 주제 | 언제 읽나 |
|------|------|-----------|
| `references/agent-settings.md` | 에이전트 변경 (프롬프트, TTS, 툴, 추출, 배포) | 에이전트 **설정 방법** 안내 시 |
| `references/testing.md` | 테스트 (웹 테스트, 변수 프리셋) | **테스트 방법** 안내 시 |
| `references/bulk-calling.md` | 대량발신 (프로젝트 생성, 발신 설정) | **대량발신 방법** 안내 시 |
| `references/call-data.md` | 통화 데이터 조회 (기록, 추출 칼럼, 필터, 다운로드) | **통화 데이터 확인 방법** 안내 시 |

## 가이드 파트

4개 파트로 구성된다. 순서대로 진행하는 것을 권장하지만, 필요한 파트만 선택해도 된다.

| 파트 | 주제             | 핵심 내용                                                  |
| ---- | ---------------- | ---------------------------------------------------------- |
| 1    | 에이전트 변경    | 프롬프트, 목소리(TTS)/속도, 툴, 통화정보 추출, 버전 배포   |
| 2    | 테스트           | 웹 테스트, {{변수}} 프리셋 설정 후 테스트                  |
| 3    | 대량발신         | 프로젝트 생성(직접/파일업로드), 발신 설정, 예약, 완료 알림 |
| 4    | 통화 데이터 조회 | 대량발신 기록, 통화 기록, 추출 칼럼, 필터, 엑셀 다운로드   |

## 워크플로우

### 모드 A: 화면 보며 안내 (권장)

사용자가 대시보드 URL을 공유하면 이 모드로 진행한다. Claude chrome extension(MCP)이 필요하다. 미설치 시 사용자에게 설치를 안내한다.

1. 사용자가 대시보드 URL을 공유한다 (예: `https://www.tryvox.co/dashboard/`)
2. Chrome으로 해당 페이지를 연다
3. 스크린샷을 찍고, 화면에 보이는 UI 요소를 가리키며 해당 파트의 레퍼런스 내용을 설명한다
4. 설명이 끝나면 질문을 받는다
5. 질문이 없으면 다음 파트 페이지로 이동 → 스크린샷 → 설명을 반복한다
6. 마지막 파트(4) 완료 후 전체 요약과 추가 질문 여부를 확인한다

**파트별 페이지 경로:**

| 파트 | 이동할 페이지               | 네비게이션                                      |
| ---- | --------------------------- | ----------------------------------------------- |
| 1    | 에이전트 상세               | 사이드바 > 구축 > 에이전트 > 에이전트 클릭      |
| 2    | 에이전트 상세 (테스트 패널) | 같은 페이지에서 오른쪽 테스트 패널 + ( ) 아이콘 |
| 3    | 대량 발신                   | 사이드바 > 배포 > 발신 > 대량 발신              |
| 4    | 통화 기록                   | 사이드바 > 모니터링 > 통화 기록                 |

### 모드 B: 텍스트 안내

화면 없이 레퍼런스 기반으로 설명하는 모드. URL 없이 시작하면 이 모드로 진행한다.

1. 해당 파트의 레퍼런스를 읽고 핵심 내용을 설명한다
2. 사용자 질문에 답변한다
3. 질문이 없으면 다음 파트로 넘어간다
4. 마지막 파트(4) 완료 후 전체 요약과 추가 질문 여부를 확인한다
