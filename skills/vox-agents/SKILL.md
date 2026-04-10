---
name: vox-agents
description: "Use whenever the user is building a vox.ai voice agent — writing or revising a system prompt, diagnosing agent behavior, designing a flow agent with nodes and transitions, converting a call-center script into flow nodes, or working with agent.data schema via MCP. Covers both single-prompt and flow agent types. Trigger on '프롬프트 작성해줘', '프롬프트 고쳐줘', '에이전트가 이상하게 답해', 'flow 설계', '스크립트를 노드로 변환해줘', 'flow vs single prompt', '플로우차트 그려줘', '노드 설계', 'flow 리뷰해줘', or any vox agent authoring question."
---

# vox-agents

vox.ai 음성 에이전트를 설계하는 domain skill. **프롬프트 에이전트**(single prompt)와 **플로우 에이전트**(flow)를 모두 다룬다. Flow는 prompt의 확장이므로 공통 규칙을 먼저 적용하고, 유형별 reference로 분기한다.

## Agent Type 판단 기준

| 기준 | Single Prompt | Flow |
|------|---------------|------|
| 대화 복잡도 | 단순 Q&A, 1~2 분기 | 3개 이상 분기, 복잡한 시나리오 |
| 결정적 흐름 제어 | prompt에 의존 | node 단위로 보장 |
| 조건부 분기 | 어려움 | condition node로 정확히 제어 |
| 외부 API 연동 | tool로 가능 | api node로 응답 변수 추출까지 |
| 변수 추적 | 어려움 | extraction → condition 체인 |
| 유지보수 | prompt 하나 수정 | node 단위 독립 수정 |

사용자가 유형을 명시하지 않으면 위 기준으로 판단하여 제안한다.

## References

### 공통 (양쪽 모두 적용)

- **voice-ai-playbook.md** — 음성 UX 핵심 규칙, 트레이드오프 우선순위. 새 에이전트 설계 시 먼저 읽기. See [references/voice-ai-playbook.md](references/voice-ai-playbook.md)
- **agent-data-reference.md** — MCP `create_agent`/`update_agent` 시 agent.data 스키마. See [references/agent-data-reference.md](references/agent-data-reference.md)
- **ivr-navigation-best-practice.md** — IVR 메뉴 패턴, DTMF 처리. See [references/ivr-navigation-best-practice.md](references/ivr-navigation-best-practice.md)

### Prompt Agent 전용

- **voice-ai-prompt-template.md** — 한국어 프롬프트 템플릿 (작성 시 복사해 사용). See [references/voice-ai-prompt-template.md](references/voice-ai-prompt-template.md)
- **voice-ai-prompt-diagnosis.md** — 실패 사례 원인 진단. See [references/voice-ai-prompt-diagnosis.md](references/voice-ai-prompt-diagnosis.md)
- **voice-ai-prompt-revision.md** — 진단 기반 리팩터링. See [references/voice-ai-prompt-revision.md](references/voice-ai-prompt-revision.md)

### Flow Agent 전용

- **flow-sketch.md** — 스크립트 → Mermaid flowchart 시각화 (1단계). See [references/flow-sketch.md](references/flow-sketch.md)
- **node-creation.md** — 확정된 차트의 각 노드 → 상세 설계 (2단계). See [references/node-creation.md](references/node-creation.md)
- **node-types.md** — 노드 타입별 필드/설정 상세. See [references/node-types.md](references/node-types.md)
- **flow-review.md** — 설계물 체크리스트 기반 검증 (3단계). See [references/flow-review.md](references/flow-review.md)
- **variable-system.md** — 변수 naming, 추출, 렌더링. See [references/variable-system.md](references/variable-system.md)

## Core Operating Rules

1. **작업 유형에 맞는 reference를 먼저 열고** 그 규칙을 적용한다.
2. **사실성 우선** — vox 플랫폼/도구/모델 관련 사실은 확인된 목록이 없으면 만들어내지 않는다. 잘못된 사실은 고객 신뢰를 손상시키고 실제 장애로 이어진다.
   - 목록이 없으면: (1) 확인 질문 1개, 또는 (2) `[[...]]` placeholder로 남긴다.
3. **트레이드오프 우선순위**: 사실성/정확성 > 음성 UX > 친절함/설명량
4. **"기본 1–2문장"** 같은 장문 방지 규칙은 에이전트의 **런타임 발화**에 적용된다. 개발 산출물(시스템 프롬프트, 진단 YAML, 패치 노트)은 필요한 만큼 길어도 된다.
5. **최소 변경 리팩터링** — 기존 프롬프트의 필수 섹션/도구 계약/변수/에러처리를 삭제하면 런타임 장애가 발생한다.
6. **진단 → 리팩터링 핸드오프**: diagnosis에 `failure_modes`와 `change_requests`가 반드시 포함, revision은 `change_requests`를 근거로만 변경한다.
7. **MCP 실행 주의** — 유저가 "적용/업데이트"를 명시했을 때만 실행. builtInTools/toolIds가 전체 교체 방식이라 실수로 실행하면 기존 설정이 날아간다.

## Prompt Agent Workflow

신규 작성:
1. `voice-ai-playbook.md` 읽기 → 규칙 숙지
2. `voice-ai-prompt-template.md` 복사 → 요구사항 반영
3. agent.data 스키마 참조하여 MCP로 생성

디버깅/개선:
1. `voice-ai-prompt-diagnosis.md` 읽기 → 실패 원인 진단
2. `voice-ai-prompt-revision.md` 읽기 → change_requests 기반 리팩터링

## Flow Agent Workflow

스크립트 → flow 변환 시 3단계로 진행:

1. **시각화 (flow-sketch)**: 스크립트 → Mermaid flowchart + 노드 요약 테이블
2. **상세 설계 (node creation)**: 확정된 차트의 각 노드 → flow node markdown
3. **리뷰 (flow review)**: 체크리스트 기반 검증, CRITICAL/WARN/INFO 분류

사용자가 시각화만 요청하면 1단계만. "노드로 변환해줘"면 1→2단계. "리뷰해줘"면 3단계.

### Node Type 요약 (Active 10종)

| Node | addable | 용도 | 핵심 설정 |
|------|---------|------|-----------|
| `begin` | No (자동) | flow 시작점 | firstLineType, pauseBeforeSpeaking |
| `conversation` | Yes | 대화 수행 | prompt, transitions, loopCondition, knowledge, llm |
| `tool` | Yes | 도구 실행 | toolId, prompt, fallback transition |
| `api` | Yes | HTTP API 호출 | method/url/auth/headers/body, responseVariables |
| `condition` | Yes | 조건 분기 | logicalTransitions (AND/OR, 10종 operator) |
| `extraction` | Yes | 변수 추출 | extractionPrompt, variables |
| `transferCall` | Yes | 통화 전환 | transferType, destination, SIP headers |
| `transferAgent` | Yes | 에이전트 전환 | agentId, preserveChatContext |
| `endCall` | Yes | 통화 종료 | prompt, globalNodeSettings |
| `note` | 별도 | 메모 (실행 없음) | content (markdown) |

Deprecated: `function` (→ `tool`), `knowledge` (→ `conversation` node-level knowledge)

### Flow 설계 패턴

**Linear**: `begin → 인사 → 본인확인 → 안내 → endCall`

**Branching**: `begin → 의도파악 → condition → 시나리오A/B/C → endCall`

**Data Collection**: `begin → extraction(이름) → extraction(번호) → api(조회) → condition → 안내 → endCall`

**Transfer Fallback**: `begin → 대화 → transferCall → (성공)종료 / (fallback)안내 → 재시도/endCall`

### Flow 운영 규칙

1. 이 문서에 없는 node type이나 설정을 추측하지 않는다
2. deprecated node는 신규 flow에 사용하지 않는다
3. node 수는 최소화 — 불필요한 분할은 edge 관리를 복잡하게 한다
4. 변수 이름은 snake_case
5. 전환조건에 "다음 단계 이름"을 쓰지 않는다 — exit 조건만 정의

## Ownership Boundary

| Owns | Does Not Own |
|------|--------------|
| prompt authoring / diagnosis / revision | tool management (built-in/custom) |
| flow design / node conversion / review | pricing / billing |
| agent.data schema | workspace |
| voice AI playbook rules | phone number management |
| flow sketch / node types / transitions | dashboard UI guide |
