---
name: vox-flow-agent
description: "Use when the user asks about vox.ai flow agent design, node type selection, flow structure planning, transition logic, variable passing between nodes, global node configuration, when to use flow vs single-prompt agent, script-to-node conversion, or any question about building and organizing multi-node conversation flows."
---

# vox-flow-agent

여러 node를 연결해 대화 흐름을 제어하는 vox.ai 에이전트 유형을 설계한다.

- @xyflow/react 기반 visual flow editor
- Supabase에 `FlowData` (`ReactFlowJsonObject<Node, Edge>` = nodes + edges + viewport)로 저장
- 각 node는 고유 type, data, position을 가짐

## Flow vs Single Prompt 판단 기준

| 기준 | Single Prompt | Flow |
|------|--------------|------|
| 대화 복잡도 | 단순 Q&A, 1~2 분기 | 3개 이상 분기, 복잡한 시나리오 |
| 결정적 흐름 제어 | prompt에 의존 | node 단위로 보장 |
| 조건부 분기 | 어려움 | condition node로 정확히 제어 |
| 외부 API 연동 | tool로 가능 | api node로 응답 변수 추출까지 |
| 변수 추적 | 어려움 | extraction → condition 체인 |
| 유지보수 | prompt 하나 수정 | node 단위 독립 수정 |

## Node Type 요약 (Active 10종)

| Node | addable | 용도 | 핵심 설정 |
|------|---------|------|----------|
| `begin` | No (자동) | flow 시작점 | firstLineType (AI/user), pauseBeforeSpeaking |
| `conversation` | Yes | 대화 수행 | prompt (static/dynamic), transitions, loopCondition, knowledge, llm |
| `tool` | Yes | 도구 실행 | toolId, prompt, fallback transition |
| `api` | Yes | HTTP API 호출 | method/url/auth/headers/body, responseVariables (JSONPath) |
| `condition` | Yes | 조건 분기 | logicalTransitions (AND/OR, 10종 operator) |
| `extraction` | Yes | 변수 추출 | extractionPrompt, variables (name/type/desc) |
| `transferCall` | Yes | 통화 전환 | transferType (cold/warm), destination, SIP headers |
| `transferAgent` | Yes | 에이전트 전환 | agentId, preserveChatContext |
| `endCall` | Yes | 통화 종료 | prompt (static/dynamic), globalNodeSettings |
| `note` | 별도 | 메모 (실행 없음) | content (markdown), resizable |

- **Deprecated**: `function` (→ `tool`로 대체), `knowledge` (→ `conversation` node-level knowledge로 대체)
- 상세 스펙: See [references/node-types.md](references/node-types.md)

## Transition 설계 규칙

`NodeTransitionData { id, condition?, isSkipUserResponse?, isFallback? }`

- **조건 기반 전환**: conversation/knowledge node에서 자연어 condition 작성. `{{variable}}` 구문으로 변수 참조 가능.
- **Fallback 전환**: tool/api/function/transfer 노드에 자동 생성 (편집/삭제 불가). 실행 실패 시 이 edge로 진행.
- **Skip User Response**: 유저 응답 안 기다리고 다음 노드로 (conversation/knowledge). `isSkipUserResponse: true`.
- **Loop Condition**: 조건 충족까지 현재 노드 반복. conversation node의 `loopCondition` 필드.

## Global Node (인터럽트 포인트)

- `isGlobalNode: true` → 어떤 노드에서든 조건 충족 시 이 노드로 전환 가능
- `transitionCondition` — 글로벌 진입 조건
- 적용 가능: conversation, endCall (+ deprecated function, knowledge)
- 사용 예: "통화 종료 요청", "상담원 연결 요청" 등 어디서든 빠져나가야 하는 시나리오

## 변수 시스템 요약

| 카테고리 | 생성 위치 | 예시 |
|---------|---------|------|
| system | 플랫폼 자동 | `{{current_time}}`, `{{call_from}}`, `{{call_to}}`, `{{call_id}}`, `{{agent_id}}` |
| agent | 에이전트 설정 | `{{customer_name}}`, `{{order_id}}` 등 에이전트 prompt/설정에서 `{{...}}`로 선언 |
| flow | extraction/api node | extraction: LLM이 대화에서 추출, api: JSONPath로 응답에서 추출 |

- 상세: See [references/variable-system.md](references/variable-system.md)

## Flow 설계 패턴

**Linear** — 순차 진행
```
begin → 인사 → 본인확인 → 안내 → endCall
```

**Branching** — 의도 분기
```
begin → 의도파악 → condition
                    ├→ 시나리오A → endCall
                    ├→ 시나리오B → endCall
                    └→ 시나리오C → endCall
```

**Data Collection** — 정보 수집 후 조건 처리
```
begin → extraction(이름) → extraction(전화번호) → api(조회)
        → condition(결과) → 안내 → endCall
```

**Transfer Fallback** — 전환 실패 처리
```
begin → 대화 → transferCall
               ├→ (성공) 종료
               └→ (fallback) 안내 → 재시도/endCall
```

## Node 생성 (스크립트 → flow node 변환)

콜센터/OB/CS 스크립트를 flow node markdown으로 변환하는 기능을 내장한다.

- 입력: 원본 스크립트, 필수 수집 항목, 재권유/재시도 제한, 운영 제약, `{{...}}` 변수
- 출력 포맷: `## name / ## content / ## transition conditions` (고정 3섹션)
- 상세 규칙 (포맷, 턴 운영, 전환조건 작성법, 자가 점검): See [references/node-creation.md](references/node-creation.md)

## Operating Rules

1. 이 문서에 없는 node type이나 설정을 추측하지 않는다
2. deprecated node (`function`, `knowledge`)는 신규 flow에 사용하지 않는다
3. flow 설계 시 node 수는 최소화한다 — 하나의 conversation node로 충분하면 쪼개지 않는다
4. 변수 이름은 snake_case, 의미가 명확한 이름 사용
5. 전환조건에 "다음 단계 이름"을 절대 쓰지 않는다 — exit 조건만 정의
