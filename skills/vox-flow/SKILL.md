---
name: vox-flow
description: "Use when the user is designing a vox.ai flow agent — selecting node types, planning branching logic, wiring transitions, extracting variables between nodes, configuring global nodes, converting a call-center script into flow nodes, visualizing scripts as Mermaid flowcharts, or reviewing flow designs. Flow agents are the multi-node extension of prompt agents for complex scenarios. Trigger on 'flow 설계', '스크립트를 노드로 변환해줘', 'flow vs single prompt', '플로우차트 그려줘', '노드 설계', 'flow 리뷰해줘', 'condition node 설정', '플로우 검증', '노드 연결 어떻게 해', or any vox.ai flow agent question."
---

# vox-flow

vox.ai **플로우 에이전트**를 설계하는 domain skill. 여러 node를 연결해 대화 흐름을 제어한다.

Flow는 prompt agent의 확장이므로, **공통 음성 UX 규칙은 `vox-agents`의 playbook을 따른다.** 새 flow 설계 시 `vox-agents/references/voice-ai-playbook.md`를 먼저 읽어야 한다.

## Flow vs Single Prompt 판단 기준

→ `vox-agents`의 Agent Type 판단 기준 테이블 참조. Single prompt로 충분한 경우 `vox-agents` 스킬로 handoff한다.

## References

- **default-flow-data.json** — flow 기본 스키마 (begin→conversation→endCall). **flow 구조를 이해할 때 읽기.** See [references/default-flow-data.json](references/default-flow-data.json)
- **flow-guide.md** — flow 설계 통합 가이드 (edge 메커니즘, 변수 흐름, 설계 원칙). **flow를 처음 설계할 때 읽기.** See [references/flow-guide.md](references/flow-guide.md)
- **flow-sketch.md** — 스크립트 → Mermaid flowchart 시각화. **1단계: 스크립트를 처음 받았을 때 읽기.** See [references/flow-sketch.md](references/flow-sketch.md)
- **node-creation.md** — flowchart/스크립트 → 노드 markdown 변환 workflow. **2단계 시작 시 먼저 읽기.** See [references/node-creation.md](references/node-creation.md)
- **conversation-markdown.md** — conversation 노드 static/generated 작성법. **대화 노드 문구와 exit 조건을 쓸 때 읽기.** See [references/conversation-markdown.md](references/conversation-markdown.md)
- **execution-node-markdown.md** — extraction/condition/api/transfer/sendSms/tool/endCall 작성법. **대화 외 노드를 쓸 때 읽기.** See [references/execution-node-markdown.md](references/execution-node-markdown.md)
- **node-examples.md** — 긴 예시 모음. **출력 톤이나 구조 예시가 필요할 때만 읽기.** See [references/node-examples.md](references/node-examples.md)
- **node-types.md** — 노드 타입 선택 기준 + schema endpoint 사용 규칙. **특정 노드의 JSON 설정 옵션이 필요하면 먼저 schema endpoint 를 호출하기.** See [references/node-types.md](references/node-types.md)
- **flow-review.md** — 설계물 체크리스트 기반 검증. **3단계: 설계 완료 후 또는 "리뷰해줘" 요청 시 읽기.** See [references/flow-review.md](references/flow-review.md)

공통 reference (`vox-agents`에 위치):
- **variable-system.md** — 변수 naming, 추출 설정, 렌더링 위치. **extraction/condition 변수 흐름을 설계할 때 읽기.**
- **voice-ai-playbook.md** — 음성 UX 핵심 규칙. **새 flow 설계 시 가장 먼저 읽기.**
- **default-agent-data.json** + **agent-data-reference.md** — agent.data 기본값 + MCP 동작 규칙. **MCP로 에이전트를 생성할 때 읽기.**
- **ivr-navigation-best-practice.md** — IVR/DTMF 패턴. **ARS/IVR 통과 시나리오에서 읽기.**
- **voice-ai-prompt-template.md** — 프롬프트 템플릿. **conversation 노드 프롬프트 작성 시 참고.**
- **voice-ai-prompt-diagnosis.md** — 실패 사례 진단. **flow 에이전트가 이상하게 동작할 때 읽기.**
- **voice-ai-prompt-revision.md** — 진단 기반 리팩터링. **diagnosis 후 노드 프롬프트를 수정할 때 읽기.**

## Workflow

스크립트 → flow 변환 시 4단계로 진행:

1. **시각화 (flow-sketch)**: 스크립트 → Mermaid flowchart + 노드 요약 테이블
2. **상세 설계 (node creation)**: 확정된 차트의 각 노드 → flow node markdown. `node-creation.md`를 시작점으로 읽고 필요한 노드 계열 reference만 추가로 읽는다.
3. **리뷰 (flow review)**: 체크리스트 기반 검증, CRITICAL/WARN/INFO 분류
4. **dry-run 검증 (validate_flow_data)**: JSON 산출물이 준비되면 MCP `validate_flow_data` 를 호출해 결과를 사용자에게 한두 줄로 요약하고, errors / warnings 처리는 [Response Handling](#response-handling) 을 따른다. errors 가 비었을 때에만 `create_agent` / `update_agent` 호출.

사용자가 시각화만 요청하면 1단계만. "노드로 변환해줘"면 1→2단계. "리뷰해줘"면 3단계. JSON 으로 보내려면 4단계까지.

## Node Type 요약

아래 표는 설계 대화를 위한 개념 요약이다. 실제 `flow_data` JSON 을 작성할 때는 이 표나 로컬 reference 를 schema source 로 쓰지 말고, 먼저 MCP `get_schema(namespace='flow-schema', schema_type='flow-data')` 를 호출해 현재 node type, field, enum, required 여부를 확인한다.

| Node | 용도 |
|------|------|
| `begin` | flow 시작점 |
| `conversation` | LLM 기반 대화 수행 |
| `tool` | vox.ai 등록 도구 실행 |
| `api` | HTTP API 호출 + 응답 변수 추출 |
| `sendSms` | SMS 발송 |
| `condition` | 변수 기반 조건 분기 (대화 없음) |
| `extraction` | 대화 컨텍스트에서 변수 추출 |
| `transferCall` | 통화 전환 (cold/warm) |
| `transferAgent` | 에이전트 전환 |
| `endCall` | 통화 종료 |
| `note` | 메모 (실행 없음) |

각 노드의 의미/사용 판단 → `node-types.md` 참조. Deprecated: `function` (→ `tool`), `knowledge` (→ conversation node-level). 정확한 schema 는 항상 MCP schema endpoint 결과를 따른다.

## 설계 패턴

**Linear**: `begin → 인사 → 본인확인 → 안내 → endCall`

**Branching**: `begin → 의도파악 → condition → 시나리오A/B/C → endCall`

**Data Collection**: `begin → extraction(이름) → extraction(번호) → api(조회) → condition → 안내 → endCall`

**Transfer Fallback**: `begin → 대화 → transferCall → (성공)종료 / (fallback)안내 → 재시도/endCall`

## Core Operating Rules

1. **공통 규칙 먼저** — flow에서도 실패 원인의 대부분은 음성 UX 위반(장문 발화, 부정확한 사실)이므로, `vox-agents`의 voice-ai-playbook 규칙(사실성 우선, 트레이드오프, 런타임 vs 개발 산출물 구분)이 flow에도 동일하게 적용된다.
2. node type, field, enum, required 여부를 추측하지 않는다 — `flow_data` 작성 직전에 `get_schema(namespace='flow-schema', schema_type='flow-data')` 를 호출하고 그 결과를 기준으로 JSON 을 만든다.
3. deprecated node(`function`, `knowledge`)는 신규 flow에 사용하지 않는다 — 대시보드에서 더 이상 추가할 수 없고, 향후 런타임 지원이 제거될 수 있다.
4. node 수는 최소화 — 불필요한 분할은 edge 관리를 복잡하게 하고 유지보수 비용이 증가한다.
5. 변수 이름은 snake_case, 의미가 명확한 이름 사용 — condition node와 변수 렌더러가 snake_case를 전제로 동작하며, 모호한 이름(val1, temp)은 노드 간 전달 시 혼동을 일으킨다.
6. 전환조건에 "다음 단계 이름"을 쓰지 않는다 — exit 조건만 정의해야 노드 순서가 바뀌어도 LLM이 올바르게 판단한다.
7. **산출물 경로는 두 가지** — (a) 대시보드 flow editor 에 사람이 직접 입력하는 노드 markdown, (b) v3 REST API (`PATCH /v3/agents/{id}` with `flow_data`) 또는 동등한 vox.ai MCP `create_agent` / `update_agent` 의 `flow_data` 파라미터로 보내는 JSON. JSON surface 는 schema endpoint 가 authoritative 하며, 수정은 항상 **전체 교체** 방식 — 기존 노드 일부만 patch 하지 않고 nodes/edges 전체를 다시 보낸다.
8. **Schema endpoint 우선** — `references/node-types.md` 는 node 선택과 실수 방지 playbook 이다. 실제 필드 목록을 복사하지 말고, 작업 중 받은 `get_schema` 결과를 기준으로 `flow_data` 를 작성한다. 전송 후 `get_agent` 로 round-trip 확인해 unknown field drop 을 잡는다.
9. **flow_data 전송 전 dry-run 먼저** — `create_agent` / `update_agent` 의 `flow_data` 를 보내기 전, MCP `validate_flow_data(flow_data=...)` 를 먼저 호출해 dry-run 한다. 응답의 `errors` 가 비었을 때만 진짜 호출하고, `warnings` 는 사용자에게 한두 줄로 요약 전달한다. 이걸 생략하면 (a) 차단 오류가 사용자에게 400/422 로 그대로 노출되고, (b) 자동 보정이 일어났음을 사용자가 알 길이 없다. dry-run 을 건너뛴 경우라도 `create_agent` / `update_agent` 응답 본문의 `result.message` 에 자동 보정 안내 텍스트가 실려오므로, 그 내용을 사용자에게 그대로 전달한다 (차단 오류 사전 차단만 안 될 뿐).
10. **nested config default 는 백엔드가 채운다** — `api_configuration` 의 인증/헤더/바디 옵션, `extraction_configuration`, `transfer_configuration`, `knowledge`, `message` 같은 nested 객체의 모든 필드를 LLM 이 외워 채울 필요 없다. `url`, `agent_id`, `tool_id` 처럼 누락 시 진짜 차단 오류가 나는 식별자만 명시하고, 나머지는 사용자가 의도적으로 지정한 키만 보낸다. 외운 default 를 강제로 채워 넣으면 schema 진화에 뒤처지고 dry-run warnings 만 늘어난다.

## Response Handling

`validate_flow_data` / `create_agent` / `update_agent` 의 검증 결과를 어떻게 다루는지 정리.

### `validate_flow_data` 응답

- `valid: true` + `warnings: []` → 안전. 그대로 `create_agent` / `update_agent` 호출.
- `valid: true` + `warnings: [...]` → 자동 보정이 적용되었거나 권장 사항이 있음. 사용자에게 한두 줄로 요약 후 진행 (예: "api 노드 X 에 실패 fallback 자동 추가됨"). 응답의 `fixed_flow_data` 가 있으면 그것을 그대로 보낸다.
- `valid: false` → `errors[]` 의 각 항목 (`rule`, `node_id`, `message`, `suggestion`) 을 읽고 1회 수정 후 재검증. 같은 rule 이 다시 나오면 사용자에게 보고하고 멈춘다.

### `create_agent` / `update_agent` 422 / 400 응답

응답 envelope 가 `{"error": {"code": "VALIDATION_ERROR", "details": {"source": "flow_validator", "errors": [...]}}}` 형태이면 `details.errors[]` 를 위 dry-run 과 동일한 룰별 처리로 다룬다. 그 외 (스키마 자체 검증 실패) 는 그래프 구조 위반이므로 nodes / edges 자체를 점검한다.

### `create_agent` / `update_agent` 200 응답의 `result.message`

응답 본문의 `result.message` 텍스트에 자동 보정 안내가 실려온다 (별도 변형 없이 그대로 전달됨). dry-run 을 생략하고 바로 보낸 경우에도 자동 보정 사실을 이 필드로 확인할 수 있다. 자동 보정이 일어났다는 사실을 사용자에게 한 줄로 알린다 — 모르고 지나가면 다음 작업 때 보정 결과를 사람이 다시 의도와 맞춰야 한다.

### 룰 ID 빠른 참조

차단 오류 (errors, 사전에 막아야 할 것):
- `transfer_agent_missing_agent` — transferAgent 노드의 `agent.agent_id` 누락
- `tool_missing_tool_id` — tool 노드의 `tool_id` 누락
- `no_terminal_reachable` — begin 으로부터 endCall / transferCall / transferAgent 도달 경로 없음
- `operator_value_type_mismatch` — logic operator 의 numeric value 가 비-numeric

경고 (warnings, 자동 보정 후 알림):
- `api_missing_failure_edge` — api 노드 fallback edge 자동 추가됨 (단, target 이 endCall 직행이라면 사용자 의도대로 안내 conversation 으로 다시 라우팅 권장)
- `condition_unknown_variable` — logic 변수 미정의 (오타 의심)
- `unreachable_node` — 도달 불가 노드
- `variable_naming_non_snake_case` — 변수명 권장 형식 위반

조용한 자동 보정 (silent, 알림 없음):
- `trim_variable_names` — 변수명 trailing 공백/개행 trim
- `inject_nested_defaults` — nested config 누락 필드 default 보충
- `add_missing_outgoing_edges` — 비-terminal 노드 누락 outgoing edge 자동 추가
- `add_skip_response_fallback` — `is_skip_user_response: true` 노드 fallback safety net 자동 추가
- `add_condition_fallback` — condition 노드 fallback edge 자동 추가

## Ownership Boundary

| Owns | Does Not Own |
|------|--------------|
| flow design / node conversion / review | prompt authoring / diagnosis / revision (→ vox-agents) |
| node types / transitions / patterns | tool management (→ vox-tools) |
| variable system (flow scope) | web app UI guide (→ vox-web-app) |
| flow sketch / Mermaid visualization | pricing / billing |
| global node configuration | phone number management |

## Related Resources

### MCP Tools (vox.ai)
- `create_agent` — flow 에이전트 생성 (`type: "flow"`)
- `update_agent` — 에이전트 설정 수정
- `get_agent` — 기존 에이전트 설정 확인 (flow_data 포함)
- `list_agents` — 에이전트 목록
- `get_schema(namespace='flow-schema', schema_type='flow-data')` — flow_data JSON Schema (node·edge·condition `$defs` 포함). `create_agent` / `update_agent` 의 `flow_data` 구성 전에 호출.
- `validate_flow_data(flow_data=...)` — flow_data dry-run. 응답: `{valid, fixed_flow_data, warnings, errors}`. `create_agent` / `update_agent` 직전에 호출해 차단 오류를 사전 차단하고 자동 보정 결과를 사용자에게 전달한다.

### Docs (vox.ai docs / vox-docs)
- `docs/build/flow/overview` — 플로우 에이전트 개요
- `docs/build/flow/nodes/overview` — 노드 타입 개요
- `docs/build/flow/nodes/begin-node` — 시작 노드
- `docs/build/flow/nodes/conversation-node` — 대화 노드
- `docs/build/flow/nodes/api-node` — API 노드
- `docs/build/flow/nodes/condition-node` — 조건 노드
- `docs/build/flow/nodes/extraction-node` — 추출 노드
- `docs/build/flow/nodes/tool-node` — 도구 노드
- `docs/build/flow/nodes/transfer-node` — 통화 전환 노드
- `docs/build/flow/nodes/transfer-agent-node` — 에이전트 전환 노드
- `docs/build/flow/nodes/end-node` — 종료 노드
- `docs/build/flow/transitions` — 전환 조건
- `docs/build/flow/advanced/global-node` — 글로벌 노드

### App URLs
- `https://www.tryvox.co/flow/{flowId}` — 플로우 에디터
- `https://www.tryvox.co/agent/{agentId}` — 에이전트 상세
- `https://www.tryvox.co/dashboard/{organizationId}/agents` — 에이전트 목록
