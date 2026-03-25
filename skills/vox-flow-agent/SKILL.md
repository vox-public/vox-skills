---
name: vox-flow-agent
description: "This skill should be used when designing a vox.ai flow agent — selecting node types, planning branching logic, wiring transitions, extracting variables between nodes, configuring global nodes, converting a call-center script into flow nodes, visualizing scripts as Mermaid flowcharts, or reviewing flow designs. Trigger on 'flow vs single prompt 뭐가 나아?', 'node 연결 어떻게 해?', '스크립트를 노드로 변환해줘', 'condition node 설정', '플로우차트 그려줘', '스크립트 시각화', 'flow 리뷰해줘', '노드 설계 검토해줘', '플로우 검증', '설계 리뷰'."
---

# vox-flow-agent

여러 node를 연결해 대화 흐름을 제어하는 vox.ai 에이전트 유형을 설계한다.

- @xyflow/react 기반 visual flow editor
- Supabase에 `FlowData` (`ReactFlowJsonObject<Node, Edge>` = nodes + edges + viewport)로 저장
- 각 node는 고유 type, data, position을 가짐

## 스크립트 → Flow 변환 워크플로우

스크립트를 flow agent로 변환할 때 3단계로 진행한다:

1. **시각화 (flow-sketch)**: 스크립트 → Mermaid flowchart + 노드 요약 테이블. 전체 뼈대를 시각화하고 피드백으로 확정한다. See [references/flow-sketch.md](references/flow-sketch.md)
2. **상세 설계 (node creation)**: 확정된 차트의 각 노드 → flow node markdown. 프롬프트, 전환조건, 멘트를 상세하게 작성한다. See [references/node-creation.md](references/node-creation.md)
3. **리뷰 (flow review)**: 설계물을 체크리스트 기반 검증. CRITICAL/WARN/INFO로 분류한 리포트를 출력한다. See [references/flow-review.md](references/flow-review.md)

사용자가 "플로우차트 그려줘", "스크립트 시각화" 등 시각화만 요청하면 1단계만 수행한다.
사용자가 "스크립트를 노드로 변환해줘" 등 상세 설계를 요청하면 1→2단계를 순차 수행한다.
확정된 flowchart가 이미 있으면 2단계부터 시작한다.
사용자가 "flow 리뷰해줘", "설계 검토" 등 리뷰를 요청하면 3단계를 수행한다.
리뷰 지적사항 반영 시 해당 단계만 재수행한다.

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
- 특정 노드 타입의 필드/설정 상세가 필요할 때: See [references/node-types.md](references/node-types.md)

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

- 변수 naming, 추출 설정, 렌더링 위치 확인 시: See [references/variable-system.md](references/variable-system.md)

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

## 운영 규칙

1. 이 문서에 없는 node type이나 설정을 추측하지 않는다
2. deprecated node (`function`, `knowledge`)는 신규 flow에 사용하지 않는다
3. flow 설계 시 node 수는 최소화한다 — 불필요하게 쪼개면 edge 관리가 복잡해지고 유지보수 비용이 증가한다
4. 변수 이름은 snake_case, 의미가 명확한 이름 사용
5. 전환조건에 "다음 단계 이름"을 절대 쓰지 않는다 — exit 조건만 정의해야 노드 순서가 바뀌어도 LLM이 올바르게 판단한다
