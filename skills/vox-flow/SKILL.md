---
name: vox-flow
description: "Use when the user is designing a vox.ai flow agent — selecting node types, planning branching logic, wiring transitions, extracting variables between nodes, configuring global nodes, converting a call-center script into flow nodes, visualizing scripts as Mermaid flowcharts, or reviewing flow designs. Flow agents are the multi-node extension of prompt agents for complex scenarios. Trigger on 'flow 설계', '스크립트를 노드로 변환해줘', 'flow vs single prompt', '플로우차트 그려줘', '노드 설계', 'flow 리뷰해줘', 'condition node 설정', '플로우 검증', '노드 연결 어떻게 해', or any vox flow agent question."
---

# vox-flow

vox.ai **플로우 에이전트**를 설계하는 domain skill. 여러 node를 연결해 대화 흐름을 제어한다.

Flow는 prompt agent의 확장이므로, **공통 음성 UX 규칙은 `vox-agents`의 playbook을 따른다.** 새 flow 설계 시 `vox-agents/references/voice-ai-playbook.md`를 먼저 읽어야 한다.

## Flow vs Single Prompt 판단 기준

| 기준 | Single Prompt | Flow |
|------|---------------|------|
| 대화 복잡도 | 단순 Q&A, 1~2 분기 | 3개 이상 분기, 복잡한 시나리오 |
| 결정적 흐름 제어 | prompt에 의존 | node 단위로 보장 |
| 조건부 분기 | 어려움 | condition node로 정확히 제어 |
| 외부 API 연동 | tool로 가능 | api node로 응답 변수 추출까지 |
| 변수 추적 | 어려움 | extraction → condition 체인 |
| 유지보수 | prompt 하나 수정 | node 단위 독립 수정 |

Single prompt로 충분한 경우 → `vox-agents` 스킬로 handoff한다.

## References

- **flow-sketch.md** — 스크립트 → Mermaid flowchart 시각화. **1단계: 스크립트를 처음 받았을 때 읽기.** See [references/flow-sketch.md](references/flow-sketch.md)
- **node-creation.md** — 확정된 차트의 각 노드 → 상세 설계. **2단계: flowchart 확정 후 읽기.** See [references/node-creation.md](references/node-creation.md)
- **node-types.md** — 노드 타입별 필드/설정 상세. **특정 노드의 설정 옵션이 필요할 때 읽기.** See [references/node-types.md](references/node-types.md)
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

스크립트 → flow 변환 시 3단계로 진행:

1. **시각화 (flow-sketch)**: 스크립트 → Mermaid flowchart + 노드 요약 테이블
2. **상세 설계 (node creation)**: 확정된 차트의 각 노드 → flow node markdown
3. **리뷰 (flow review)**: 체크리스트 기반 검증, CRITICAL/WARN/INFO 분류

사용자가 시각화만 요청하면 1단계만. "노드로 변환해줘"면 1→2단계. "리뷰해줘"면 3단계.

## Node Type 요약 (Active 10종)

| Node | 용도 |
|------|------|
| `begin` | flow 시작점 (자동 생성) |
| `conversation` | LLM 기반 대화 수행 |
| `tool` | vox 등록 도구 실행 |
| `api` | HTTP API 호출 + 응답 변수 추출 |
| `condition` | 변수 기반 조건 분기 (대화 없음) |
| `extraction` | 대화 컨텍스트에서 변수 추출 |
| `transferCall` | 통화 전환 (cold/warm) |
| `transferAgent` | 에이전트 전환 |
| `endCall` | 통화 종료 |
| `note` | 메모 (실행 없음) |

각 노드의 필드/설정 상세 → `node-types.md` 참조. Deprecated: `function` (→ `tool`), `knowledge` (→ conversation node-level)

## 설계 패턴

**Linear**: `begin → 인사 → 본인확인 → 안내 → endCall`

**Branching**: `begin → 의도파악 → condition → 시나리오A/B/C → endCall`

**Data Collection**: `begin → extraction(이름) → extraction(번호) → api(조회) → condition → 안내 → endCall`

**Transfer Fallback**: `begin → 대화 → transferCall → (성공)종료 / (fallback)안내 → 재시도/endCall`

## Core Operating Rules

1. **공통 규칙 먼저** — `vox-agents`의 voice-ai-playbook 규칙(사실성 우선, 트레이드오프, 런타임 vs 개발 산출물 구분)이 flow에도 동일하게 적용된다.
2. 이 문서에 없는 node type이나 설정을 추측하지 않는다 — 존재하지 않는 설정을 안내하면 사용자가 대시보드에서 찾을 수 없어 디버깅에 시간을 낭비한다.
3. deprecated node(`function`, `knowledge`)는 신규 flow에 사용하지 않는다.
4. node 수는 최소화 — 불필요한 분할은 edge 관리를 복잡하게 하고 유지보수 비용이 증가한다.
5. 변수 이름은 snake_case, 의미가 명확한 이름 사용.
6. 전환조건에 "다음 단계 이름"을 쓰지 않는다 — exit 조건만 정의해야 노드 순서가 바뀌어도 LLM이 올바르게 판단한다.
7. **산출물은 대시보드 입력용** — flow 설계 결과물은 대시보드 flow editor에서 수동 입력한다. MCP로 flow를 직접 생성/수정하는 API는 현재 없으므로, 노드 markdown을 사람이 읽고 UI에 옮길 수 있는 형태로 출력한다.

## Ownership Boundary

| Owns | Does Not Own |
|------|--------------|
| flow design / node conversion / review | prompt authoring / diagnosis / revision (→ vox-agents) |
| node types / transitions / patterns | tool management (→ vox-tools) |
| variable system (flow scope) | dashboard UI guide (→ vox-dash-guide) |
| flow sketch / Mermaid visualization | pricing / billing |
| global node configuration | phone number management |

## Related Resources

### MCP Tools (vox)
- `create_agent` — flow 에이전트 생성 (agent_type: "flow")
- `get_agent` — 기존 에이전트 설정 확인
- `list_agents` — 에이전트 목록

### Docs (vox-docs search)
- `docs/build/flow/overview` — 플로우 에이전트 개요
- `docs/build/flow/nodes/overview` — 노드 타입 개요
- `docs/build/flow/nodes/conversation-node` — conversation 노드
- `docs/build/flow/nodes/api-node` — api 노드
- `docs/build/flow/nodes/condition-node` — condition 노드
- `docs/build/flow/nodes/extraction-node` — extraction 노드
- `docs/build/flow/nodes/tool-node` — tool 노드
- `docs/build/flow/transitions` — 전환 조건
- `docs/build/flow/advanced/global-node` — 글로벌 노드

### App URLs
- `https://www.tryvox.co/flow/{flowId}` — 플로우 에디터
- `https://www.tryvox.co/agent/{agentId}` — 에이전트 상세
- `https://www.tryvox.co/dashboard/{organizationId}/agents` — 에이전트 목록
