---
description: 고객사용 에이전트 프롬프트 작성을 시작한다
argument-hint: [고객사명 또는 용도]
allowed-tools:
  - mcp__e67ad035-2e8a-4e16-a8c6-d7bccb952bb1__create_agent
  - mcp__e67ad035-2e8a-4e16-a8c6-d7bccb952bb1__update_agent
  - mcp__e67ad035-2e8a-4e16-a8c6-d7bccb952bb1__get_agent
  - mcp__e67ad035-2e8a-4e16-a8c6-d7bccb952bb1__list_agents
  - mcp__e67ad035-2e8a-4e16-a8c6-d7bccb952bb1__list_built_in_tools
  - mcp__e67ad035-2e8a-4e16-a8c6-d7bccb952bb1__list_custom_tools
  - Read
  - Write
---

고객사용 vox.ai 에이전트의 system prompt를 작성하는 워크플로우를 시작한다.

## 절차

1. 먼저 고객사 정보를 확인한다:
   - 고객사명
   - 에이전트 용도 (인바운드 CS, 아웃바운드 세일즈, 예약 등)
   - 에이전트 유형: single prompt / flow
   - 이미 수집된 자료가 있는지 (매뉴얼, 통화녹음, 시나리오 등)

2. **에이전트 유형에 따라 스킬을 사용한다:**

   ### Single Prompt 에이전트
   - `vox-best-practice` 스킬의 워크플로우를 따른다.
   - 8단계 체크리스트:
     1. 입력 질문 수집 (업무/컨텍스트/성공정의/도구/데이터/변수/대화형태)
     2. 변수(`{{...}}`) 목록 및 미주입 시 대체 표현 확정
     3. 말투/필러 설정
     4. 템플릿을 채워 system prompt 초안 작성
     5. 도구 사용/실패 처리/무음 액션 규칙 추가
     6. 정규화(Spoken/Written) 규칙 추가
     7. 가드레일/에러 처리/에스컬레이션 기준 추가
     8. 테스트 시나리오 5개 제안

   ### Flow 에이전트
   - 전체 흐름 설계는 `vox-best-practice` 스킬을 따른다.
   - 각 노드의 프롬프트/전환조건은 `flow-node-creator` 스킬을 사용한다.
   - flow-node-creator는 "한 구간의 스크립트 → 노드"를 변환하는 스킬이다.
     전체 에이전트를 한 번에 만들지 않고, 구간별로 나누어 노드를 생성한다.

3. **vox MCP로 에이전트 생성/업데이트:**
   - 프롬프트 완성 후 `create_agent` 또는 `update_agent`로 vox 플랫폼에 반영한다.
   - 도구(end_call, transfer_call 등)가 필요하면 `update_agent`로 장착한다.
   - 유저가 "적용해줘" / "업데이트해줘"라고 명시했을 때만 실행한다.
