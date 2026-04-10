# Node Types 상세 스펙

## 목차

- [공통 타입](#공통-타입) — NodeTransitionData, GlobalNodeSettings, Edge 연결
- [begin](#begin) — 시작
- [conversation](#conversation) — 대화
- [tool](#tool) — 도구 실행
- [api](#api) — HTTP API 호출
- [sendSms](#sendsms) — SMS 발송
- [condition](#condition) — 조건 분기
- [extraction](#extraction) — 변수 추출
- [transferCall](#transfercall) — 통화 전환
- [transferAgent](#transferagent) — 에이전트 전환
- [endCall](#endcall) — 통화 종료
- [note](#note) — 메모
- [Deprecated](#deprecated) — function, knowledge

---

## 공통 타입

### NodeTransitionData

conversation, tool, api, sendSms, transferCall, transferAgent 노드가 사용하는 전환 조건 구조.

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | string | 전환 ID — edge의 `sourceHandle`과 매핑됨 |
| `condition` | string? | 자연어 전환 조건. `{{variable}}` 참조 가능 |
| `isSkipUserResponse` | boolean? | 유저 응답 없이 즉시 전환 |
| `isFallback` | boolean? | fallback 전환 여부 (tool/api/transfer 노드에서 자동 생성) |

### GlobalNodeSettings

conversation, endCall, sendSms 노드에서 사용. 활성화하면 flow 어디서든 이 노드로 이동 가능.

| 필드 | 타입 | 설명 |
|------|------|------|
| `isGlobalNode` | boolean | 글로벌 노드 활성화 |
| `transitionCondition` | string | 글로벌 전환 조건 (예: "통화 끊어달라고 하면") |

### Edge 연결 메커니즘

노드 간 연결은 `edge`로 표현된다. **핵심**: edge의 `sourceHandle`이 소스 노드의 `transition.id`와 매핑됨.

```
Node A (conversation)                Edge                    Node B
  transitions: [                    {
    { id: "tr-1",          ←——→       sourceHandle: "tr-1",
      condition: "예약 원하면" }        source: "node-a",
  ]                                    target: "node-b"
                                    }
```

- 하나의 transition에 하나의 edge만 연결 (1:1)
- condition 노드는 `logicalTransitions[].id`가 sourceHandle
- begin 노드는 transition 없이 직접 edge 연결

---

## begin

flow 시작점. flow당 1개 자동 생성, 삭제/추가 불가.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `firstLineType` | `"userFirst" \| "aiFirst"` | 첫 발화 주체 |
| `pauseBeforeSpeakingSeconds` | number? | AI 발화 전 대기 시간(초) |

- `aiFirst`: 에이전트가 먼저 인사. `userFirst`: 고객 발화 대기 후 시작.
- begin에서 나가는 edge는 1개만 허용.

---

## conversation

대화 수행 노드. flow의 핵심.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `promptType` | `"static" \| "dynamic"` | 발화 모드 |
| `prompt` | string | dynamic 모드 프롬프트 (LLM이 생성) |
| `staticSentence` | string | static 모드 고정 멘트 (TTS 직접 발화) |
| `firstMessage` | string? | 노드 진입 시 첫 발화 (prompt 실행 전) |
| `transitions` | NodeTransitionData[] | 전환 조건 목록 |
| `loopCondition` | string | 조건 충족까지 반복 |
| `isSkipUserResponse` | boolean | 유저 응답 없이 다음으로 |
| `globalNodeSettings` | GlobalNodeSettings | 글로벌 노드 설정 |
| `isAllowInterruption` | boolean? | 발화 중 끼어들기 허용 |
| `llm` | AgentLLM? | 노드별 LLM 오버라이드 |
| `knowledge` | NodeKnowledgeConfig? | 노드별 지식베이스 (ragEnabled, knowledgeIds) |

- `promptType: "dynamic"` — LLM이 prompt 기반으로 응답 생성
- `promptType: "static"` — staticSentence를 TTS로 그대로 읽음
- `transitions`: 자연어 condition으로 exit 조건 정의. `{{variable}}` 참조 가능.
- `loopCondition`: 비어 있으면 반복 없음. 값이 있으면 조건 불충족 시 현재 노드 유지.
- `knowledge`: `ragEnabled: true` + `knowledgeIds` 설정 시 해당 지식베이스에서 RAG 수행.

---

## tool

도구 실행 노드. vox.ai에 등록된 tool을 호출.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `promptType` | `"none" \| "static" \| "dynamic"` | 실행 전 발화 모드 |
| `prompt` | string | dynamic 프롬프트 |
| `staticSentence` | string | static 고정 멘트 |
| `transitions` | NodeTransitionData[] | 전환 조건 (+ fallback 자동 생성) |
| `toolId` | string? | 실행할 tool ID |

- fallback transition이 자동 추가됨 (편집/삭제 불가). tool 실행 실패 시 fallback edge로 진행.
- `promptType: "none"` — 발화 없이 바로 tool 실행.

---

## api

HTTP API 호출 노드.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `promptType` | `"none" \| "static" \| "dynamic"` | 실행 전 발화 모드 |
| `prompt` | string | dynamic 프롬프트 |
| `staticSentence` | string | static 고정 멘트 |
| `transitions` | NodeTransitionData[] | 전환 조건 (+ fallback 자동 생성) |
| `apiConfiguration` | APIConfiguration | API 설정 |
| `responseVariables` | APIResponseVariable[] | 응답 변수 추출 |

**APIConfiguration:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `method` | `GET \| POST \| PUT \| DELETE \| PATCH` | HTTP 메서드 |
| `url` | string | 요청 URL |
| `authorizationEnabled` | boolean | 인증 사용 여부 |
| `authType` | `None \| Basic \| Bearer` | 인증 방식 |
| `authCredentials` | string? | 인증 토큰/키 |
| `authEncodeRequired` | boolean | Basic Auth Base64 인코딩 필요 여부 |
| `headersEnabled` | boolean | 커스텀 헤더 사용 여부 |
| `headers` | Record<string, string> | 헤더 key-value |
| `bodyEnabled` | boolean | 요청 body 사용 여부 |
| `body` | string? | 요청 body (JSON string) |
| `timeoutSeconds` | number | 타임아웃(초) |

**APIResponseVariable:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `variableName` | string | 저장할 변수 이름 |
| `jsonPath` | string | JSONPath 표현식 (예: `$.data.user.id`) |

- fallback transition 자동 추가 (편집/삭제 불가).
- `responseVariables`로 추출한 변수는 flow 변수로 등록되어 이후 노드에서 `{{variable_name}}`으로 참조 가능.

---

## condition

조건 분기 노드. 변수 값에 따라 다른 edge로 진행.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `logicalTransitions` | LogicalTransition[] | 조건부 전환 목록 |

**LogicalTransition:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | string | 전환 ID |
| `condition` | LogicalCondition | 조건 그룹 |

**LogicalCondition:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `conditions` | SingleCondition[] | 개별 조건 목록 |
| `logicalOperator` | `and \| or` | 조건 결합 방식 |

**SingleCondition:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `variable` | string | 비교 대상 변수 |
| `operator` | OperatorEnum | 비교 연산자 |
| `value` | string? | 비교 값 (EXISTS/DOES_NOT_EXIST는 불필요) |

**OperatorEnum (10종):**

| Operator | 의미 | 값 필요 |
|----------|------|---------|
| `equals` | 같음 (=) | Yes |
| `not_equals` | 같지 않음 (≠) | Yes |
| `contains` | 포함 (∈) | Yes |
| `does_not_contain` | 미포함 (∉) | Yes |
| `greater_than` | 보다 큼 (>) | Yes |
| `less_than` | 보다 작음 (<) | Yes |
| `greater_than_or_equal` | 보다 크거나 같음 (≥) | Yes |
| `less_than_or_equal` | 보다 작거나 같음 (≤) | Yes |
| `exists` | 존재함 (∃) | No |
| `does_not_exist` | 존재하지 않음 (¬∃) | No |

- 조건 노드에는 별도 prompt가 없음 — 순수 논리 분기만 수행.
- 각 logicalTransition이 하나의 edge에 대응.
- 조건을 만족하는 첫 번째 transition으로 진행 (위→아래 순서).

---

## extraction

변수 추출 노드. LLM이 대화 컨텍스트에서 정보를 추출하여 flow 변수로 저장.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `promptType` | `"dynamic"` (고정) | 항상 dynamic |
| `prompt` | string | 추출 지시 프롬프트 |
| `extractionConfiguration` | ExtractionConfiguration | 추출 설정 |
| `isSkipUserResponse` | boolean | 항상 true (유저 응답 불필요) |
| `llm` | AgentLLM? | 노드별 LLM 오버라이드 |

**ExtractionConfiguration:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `extractionPrompt` | string | 추출 지시 프롬프트 |
| `variables` | VariableDefinition[] | 추출 대상 변수 목록 |

**VariableDefinition:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `variableName` | string | 변수 이름 (snake_case) |
| `variableType` | `"string" \| "number" \| "boolean"` | 변수 타입 |
| `variableDescription` | string | 변수 설명 (LLM 추출 가이드) |

- 유저 응답을 기다리지 않고 기존 대화 컨텍스트에서 즉시 추출.
- 추출된 변수는 flow 변수로 등록, 이후 노드에서 `{{variable_name}}`으로 참조.

---

## transferCall

통화 전환 노드. 외부 번호로 통화를 전환.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `promptType` | `"none" \| "static" \| "dynamic"` | 전환 전 발화 모드 |
| `prompt` | string | dynamic 프롬프트 |
| `transferConfiguration` | TransferConfigurationItem | 전환 대상 설정 |
| `transferType` | `"cold" \| "warm"` | 전환 방식 |
| `displayedCallerId` | `"agent" \| "user"` | 발신번호 표시 |
| `warmTransferPrompt` | string? | warm transfer 시 상담원에게 전달할 프롬프트 |
| `warmTransferStaticSentence` | string? | warm transfer static 멘트 |
| `sipHeaders` | SipHeaderItem[]? | SIP 헤더 |
| `transitions` | NodeTransitionData[] | 전환 조건 (+ fallback 자동 생성) |

- **cold transfer**: 고객을 바로 상담원에게 넘김 (에이전트 퇴장).
- **warm transfer**: 에이전트가 상담원에게 먼저 컨텍스트 전달 후 고객 연결.
- fallback transition 자동 추가. 전환 실패 시 fallback edge로 진행.

---

## transferAgent

에이전트 전환 노드. 다른 vox.ai 에이전트로 대화를 넘김.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `agentId` | number | 전환 대상 에이전트 ID |
| `agentVersion` | string? | 에이전트 버전 |
| `preserveChatContext` | boolean? | 대화 컨텍스트 유지 여부 |
| `transitions` | NodeTransitionData[] | 전환 조건 (+ fallback 자동 생성) |

- `preserveChatContext: true` — 이전 대화 내역을 새 에이전트에게 전달.
- fallback transition 자동 추가.

---

## endCall

통화 종료 노드.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `promptType` | `"none" \| "static" \| "dynamic"` | 종료 전 발화 모드 |
| `prompt` | string | dynamic 프롬프트 |
| `staticSentence` | string | static 고정 멘트 |
| `globalNodeSettings` | GlobalNodeSettings | 글로벌 노드 설정 |

- 종료 멘트 발화 후 통화 종료.
- global node로 설정 시 어디서든 "통화 끊어주세요" 등의 발화로 이 노드로 이동 가능.

---

## note

메모 노드. 실행되지 않으며 flow editor에서 설명/주석 용도.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `content` | string | 마크다운 내용 |
| `width` | number? | 노드 너비 |
| `height` | number? | 노드 높이 |

- 별도 addable 카테고리 (isAddable: false이지만 별도 UI로 추가).
- 실행 흐름에 영향 없음. 팀 커뮤니케이션용.

---

## sendSms

SMS 발송 노드. 통화 중 SMS 메시지를 전송.

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 노드 이름 |
| `promptType` | `"static" \| "dynamic"` | SMS 내용 생성 모드 |
| `prompt` | string | dynamic 모드 프롬프트 |
| `staticSentence` | string | static 모드 고정 메시지 |
| `transitions` | NodeTransitionData[] | 전환 조건 (성공 + fallback 자동 생성) |
| `globalNodeSettings` | GlobalNodeSettings | 글로벌 노드 설정 |

- SMS 발송 가능한 전화번호가 조직에 있어야 사용 가능.
- 자동으로 "요청 성공 시" + "요청 실패 시" 두 transition이 생성됨.

---

## Deprecated

아래 노드 타입은 더 이상 신규 flow에서 사용하지 않는다. 기존 flow에서는 동작하지만 대시보드에서 추가 불가.

### function (→ tool)

`tool` 노드로 대체됨. 기존 flow에서 `function` 타입이 보이면 `tool` 노드와 동일하게 동작한다.

### knowledge (→ conversation)

`conversation` 노드의 `knowledge` 설정으로 통합됨. `conversation` 노드에서 `ragEnabled: true` + `knowledgeIds`를 설정하면 동일한 기능.
