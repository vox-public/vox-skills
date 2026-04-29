# Execution node markdown

이 문서는 conversation 외 노드의 **설계 markdown** 작성법을 다룬다. MCP/API `flow_data` JSON field 는 항상 `get_schema(namespace="flow-schema", schema_type="flow-data")` 결과를 따른다.

## Shared rules

- 실패, else, fallback path 가 필요하면 markdown 에 의도를 쓰고 JSON 변환 시 `edges` 로 명시한다.
- 과거 field 이름(`agentId`, `promptType`, `staticSentence`, node 내부 `transitions[]`)을 JSON field 로 복사하지 않는다.
- 각 노드는 `## name / ## content / ## transition conditions` 구조를 유지한다.
- **nested config default 는 백엔드가 채운다.** `api_configuration` 의 인증/헤더/바디 옵션, `extraction_configuration`, `transfer_configuration`, `knowledge`, `message` 같은 nested 객체의 모든 필드를 LLM 이 외워 채울 필요 없다. 사용자가 의도적으로 지정한 키만 보내면 누락 필드는 백엔드가 default 로 보충한다 — 단, 식별자 (`url`, `agent.agent_id`, `tool_id`) 는 백엔드가 추측할 수 없으므로 누락 시 차단된다.
- **JSON 보내기 전 dry-run.** 모든 `flow_data` 변경은 `create_agent` / `update_agent` 직전에 MCP `validate_flow_data(flow_data=...)` 로 dry-run 한다. `errors` 가 비었을 때만 진짜 호출하고, `warnings` 는 사용자에게 한 줄로 전달한다. SKILL.md 의 [Response Handling](../SKILL.md#response-handling) 참조.

## extraction

대화 컨텍스트에서 값을 추출한다. 고객에게 새 질문을 하지 않는다.

```md
## name
[노드 이름]

## content
### 목적
1. [추출 소스]에서 [추출 대상]을 추출한다.

### 추출 변수
- [variable_name] ([type]): [추출 소스] + [추출 대상 설명] + [포맷 규칙]
  ex) [기대 출력 예시]

## transition conditions
(조건 없이 다음 노드로 진행. JSON 변환 시 현재 schema 의 skip/edge field 를 확인하고 edge 를 명시.)
```

작성 규칙:
- 추출 소스를 명시한다: 직전 대화, DTMF 입력, API 응답 설명 등.
- 전화번호, 주문번호처럼 형식이 있는 값은 포맷을 적는다.
- 변수명은 snake_case 로 쓴다.
- 여러 값을 추출해야 하면 각 변수의 기대 출력 예시를 둔다.

## condition

이미 만들어진 변수 값을 deterministic logic 으로 분기한다. 고객 발화를 직접 해석하지 않는다.

```md
## name
[노드 이름]

## content
### 목적
1. [분기 판단 목적]

### 분기 조건
- {{variable_name}} == "값A" → [결과 라벨]
- {{variable_name}} == "값B" → [결과 라벨]
- default → [결과 라벨]

## transition conditions
(변수 기반 분기. JSON 변환 시 edge condition union 과 operator enum 을 schema endpoint 로 확인한다.)
```

작성 규칙:
- 앞선 extraction/api 에서 만든 변수만 소비한다.
- else/default 분기를 둔다.
- 실제 JSON operator 이름은 schema endpoint 결과를 따른다.

## api

외부 HTTP API를 호출하고 응답 변수 추출 의도를 정의한다.

```md
## name
[노드 이름]

## content
### 목적
1. [API 호출 목적]

### 호출 전 발화
- 발화 모드: [none/static/generated]
- 대기 멘트: "[필요할 때만]"

### API 설정
- method: [schema endpoint enum 확인]
- url: [요청 URL. {{variable_name}} 사용 가능]
- body: [필요 시]
- auth: [필요 시]

### 응답 변수
- [variable_name]: [JSONPath 표현식] — [설명]

## transition conditions
- 성공: API 응답 정상 수신 시 다음 노드로 진행. ai-edge 또는 logic-edge — 응답 변수 (`{{response_var}}`) 가 채워졌는지 기준으로 판단.
- 실패: API 호출 실패 시 [실패 안내 노드]로 진행. fallback edge. **endCall 직행 금지** — 사용자에게 사정 안내 후 재시도 또는 정중한 마무리.
```

작성 규칙:
- 성공 분기와 **명시적 실패 분기** 를 항상 한 쌍으로 설계한다. api 노드는 timeout, 5xx, 응답 형식 오류 등 실패 가능성이 일상이므로 silent termination(=fallback → endCall) 으로 처리하면 사용자가 갑자기 끊긴 듯한 경험을 한다.
- 실패 분기는 보통 conversation 노드(예: "지금 시스템이 잠시 어렵네요, 다시 안내드릴게요")로 받아서 양해 멘트 → 마무리 흐름으로 흡수한다.

**Anti-pattern (피하기):**

```json
{ "source": "node_api", "target": "node_end",
  "condition": { "type": "fallback" }, "skip_user_response": false }
```

→ 호출 실패 시 안내 한마디 없이 endCall. 사용자는 갑자기 끊긴 인상을 받는다.

**권장 패턴:**

```json
{ "source": "node_api", "target": "node_api_failure_apology",
  "condition": { "type": "fallback" }, "skip_user_response": false }
```

`node_api_failure_apology` 는 짧은 사과/안내 conversation 노드 — "조회가 어려워서 확인 후 다시 안내드릴게요" 정도. 그 다음에 endCall 로 마무리.

## endCall

통화를 종료한다. 종료 직전 발화를 할 수도 있고 즉시 종료할 수도 있다.

```md
## name
[노드 이름]

## content
### 목적
1. [종료 목적]

### 종료 멘트
- message mode: [static/generated/none]
- 멘트: "[필요할 때만]"

### Global Node 설정
- global enter condition: "[언제든 이 종료로 진입해야 하는 조건. 필요할 때만]"

## transition conditions
(통화 종료. 전환 없음.)
```

## transferCall

외부 전화번호 또는 SIP 대상으로 통화를 전환한다.

```md
## name
[노드 이름]

## content
### 목적
1. [전환 이유]

### 전환 전 발화
- 발화 모드: [none/static/generated]
- 멘트: "[필요할 때만]"

### 전환 설정
- transfer type: [cold/warm]
- transfer target: [전화번호 또는 SIP URI]
- displayed caller id: [agent/user]

### warm transfer 설정
- transfer message mode: [static/generated]
- 멘트/프롬프트: "[상담원에게 전달할 브리핑]"

## transition conditions
- 성공: 전환 성공 시 에이전트 퇴장.
- 실패: 전환 실패 시 fallback edge로 진행. (JSON 변환 시 edge 명시)
```

## transferAgent

같은 조직 내 다른 vox.ai 에이전트로 대화를 넘긴다.

```md
## name
[노드 이름]

## content
### 목적
1. [전환 이유]

### 전환 설정
- target agent: [전환 대상 에이전트 ID/버전. JSON shape 는 schema endpoint 확인]
- preserve chat context: [true/false]

## transition conditions
- 성공: 에이전트 전환 성공 시 현재 에이전트 퇴장.
- 실패: 전환 실패 시 fallback edge로 진행. (JSON 변환 시 edge 명시)
```

작성 규칙:
- **`agent.agent_id` (UUID) 는 필수**. 누락 시 dry-run / create / update 가 `transfer_agent_missing_agent` 로 차단된다. `agent_version` 도 함께 명시 권장 — 미지정 시 latest 가 어떤 버전인지 알기 어려워 운영 추적이 힘들다.
- 과거 flat `agentId` 표현은 사용하지 않는다. 현재 schema 의 nested `agent.{agent_id, agent_version}` shape 를 따른다.

## sendSms

통화 중 SMS/LMS/MMS 를 발송한다.

```md
## name
[노드 이름]

## content
### 목적
1. [SMS 발송 이유]

### SMS 내용
- SMS mode: [static/dynamic]
- 멘트: "[SMS 내용 또는 생성 프롬프트]"

### 발신 설정
- sender: [기본값 사용 또는 발신 가능 번호. JSON shape 는 schema endpoint 확인]

## transition conditions
- 성공: SMS 발송 성공 시 다음 노드로 진행.
- 실패: SMS 발송 실패 시 fallback edge로 진행. (JSON 변환 시 edge 명시)
```

## tool

custom tool 실행 node 와 agent `data.builtInTools` 설정은 schema surface 가 다르다. JSON 변환 전 schema endpoint 로 현재 shape 를 확인한다.

```md
## name
[노드 이름]

## content
### 목적
1. [도구 실행 이유]

### 발화 모드
- 발화 모드: [none/static/generated]
- 멘트: "[필요할 때만]"

### 도구 설정
- tool: [custom tool 또는 built-in tool 여부를 명시]
- 입력: [필요 시]

## transition conditions
- 성공: 도구 실행 성공 시 다음 노드로 진행.
- 실패: 도구 실행 실패 시 fallback edge로 진행. (JSON 변환 시 edge 명시)
```

작성 규칙:
- **`tool_id` 는 필수**. 누락 시 dry-run / create / update 가 `tool_missing_tool_id` 로 차단된다. 등록되지 않은 custom tool 을 가리키지 않도록 `list_tools` 결과의 ID 를 사용한다.
- built-in tool (end_call, transfer_call, transfer_agent, send_sms, send_dtmf) 설정은 agent `data.builtInTools` schema surface 다 — tool 노드 안에 직접 넣지 않는다.

## Global node

통화 종료 요청, 상담원 연결 요청처럼 어디서든 발생할 수 있는 예외는 global node 후보가 될 수 있다.

작성 규칙:
- 보통 conversation 또는 endCall 에 설계한다. 정확한 허용 shape 는 schema endpoint 결과를 따른다.
- global enter condition 은 고객 발화 기반으로 쓴다.
- 2-3개 이내로 제한한다. 너무 많으면 전환 충돌 위험이 커진다.
