---
description: 고객 대시보드 온보딩 가이드를 시작한다
argument-hint: "[대시보드 URL]"
allowed-tools:
  - Read
  - mcp__Claude_in_Chrome__navigate
  - mcp__Claude_in_Chrome__computer
  - mcp__Claude_in_Chrome__read_page
  - mcp__Claude_in_Chrome__find
  - mcp__Claude_in_Chrome__tabs_context_mcp
  - mcp__Claude_in_Chrome__tabs_create_mcp
---

고객 대시보드 온보딩을 진행한다. `dashboard-guide` 스킬을 참조하여 워크플로우를 따른다.

## 절차

1. URL이 전달되었으면 **모드 A (화면 보며 안내)**, 없으면 **모드 B (구두 안내)** 로 진행한다.

2. **파트 선택**: AskUserQuestion으로 안내할 범위를 질문한다.
   - 선택지:
     - "전체 (에이전트 변경 → 테스트 → 대량발신 → 통화 데이터)" — 순서대로 전부 진행
     - "에이전트 변경" — 프롬프트, TTS, 툴, 통화정보 추출, 배포
     - "테스트" — 웹 테스트, 변수 프리셋
     - "대량발신" — 프로젝트 생성, 발신 설정, 예약
     - "통화 데이터 조회" — 통화 기록, 추출 칼럼, 필터, 다운로드
   - multiSelect: true (여러 파트 선택 가능)

3. `dashboard-guide` 스킬의 레퍼런스 역할 분담표에 따라 선택된 파트의 레퍼런스를 읽고 안내한다.
