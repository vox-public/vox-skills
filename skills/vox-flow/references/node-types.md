# Node Types 상세 스펙 (v3 API schema)

본 파일은 vox.ai 의 v3 flow schema (vox MCP `create_agent`/`update_agent` 의 `flow_data`, REST `/v3/agents` 와 동일) 의 노드 타입별 필드를 정의한다. 모든 필드는 **snake_case**. 노드 사이의 분기 조건은 노드 안이 아니라 **edge** 에 위치한다 (구 v2 모델의 `transitions[]` / `logicalTransitions[]` / `sourceHandle` 폐지) — edge schema 는 [flow-guide.md](flow-guide.md) 의 "EdgeCondition" 섹션 참조.

알려지지 않은 필드는 서버가 validation error 없이 silently drop. 보낸 필드가 응답에 없으면 schema 어긋남이다.

## 목차

- [공통 value objects](#공통-value-objects) — Message, GlobalConfig, NodeKnowledgeConfig, ExtractionConfiguration, VariableDef, ApiConfiguration, ApiResponseVariable, TransferConfiguration, SipHeader, AgentMapping
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

모든 노드의 `data` 는 두 공통 필드를 가질 수 있다.

| 필드 | 타입 | 설명 |
|---|---|---|
| `name` | string? | 에디터 표시용 라벨. |
| `global` | GlobalConfig? | 값이 있으면 global node — 조건 일치 시 어디서든 진입. 값이 없으면 일반 노드. |

---

## 공통 value objects

### Message

conversation / endCall 노드의 발화 표현. 구 v2 의 `promptType` + `prompt` + `staticSentence` 3 필드를 단일화한 형태.

| 필드 | 타입 | 설명 |
|---|---|---|
| `mode` | `"generated" \| "static" \| "none"` | LLM 생성 / 고정 발화 / 발화 없음 |
| `content` | string | mode 에 따라 (generated → prompt, static → 고정 문장, none → "") |

- conversation 노드의 `message.mode = "none"` 은 runtime 거부.
- endCall 노드는 `mode = "none"` 허용 (즉시 종료).

### GlobalConfig

```
{ "enter_condition": "통화 끊어달라고 한 경우" }
```

global node 활성화는 노드 `data.global` 에 위 객체를 넣는다. 값 자체가 없으면 (`data` 에 `global` 키 부재) 일반 노드. 자연어 진입 조건만 갖는다.

### NodeKnowledgeConfig

conversation 노드의 RAG 설정.

| 필드 | 타입 | 기본값 |
|---|---|---|
| `rag_enabled` | bool | false |
| `knowledge_ids` | int[] | null |

### ExtractionConfiguration

extraction 노드의 추출 설정.

| 필드 | 타입 | 기본값 |
|---|---|---|
| `extraction_prompt` | string | "" |
| `variables` | VariableDef[] | [] |

### VariableDef

```
{ "variable_name": "preferred_time", "variable_type": "string", "variable_description": "고객이 원하는 예약 시간" }
```

| 필드 | 타입 | 제약 |
|---|---|---|
| `variable_name` | string | 정규식 `^[a-zA-Z][a-zA-Z0-9_]{0,39}$` (snake_case 권장) |
| `variable_type` | `"string" \| "number" \| "boolean"` | 기본 `"string"` |
| `variable_description` | string | LLM 추출 가이드. 기본 "" |

### ApiConfiguration

api 노드의 HTTP 호출 설정.

| 필드 | 타입 | 기본값 / 비고 |
|---|---|---|
| `method` | `"GET" \| "POST" \| "PUT" \| "DELETE"` | 기본 `"GET"`. (PATCH 미지원) |
| `url` | string | `{{var}}` 치환 지원 |
| `authorization_enabled` | bool | 기본 false |
| `auth_type` | `"None" \| "Basic" \| "Bearer"` | 기본 `"None"` |
| `auth_credentials` | string? | 인증 토큰/키 |
| `auth_encode_required` | bool | Basic Auth Base64 인코딩 필요 여부, 기본 false |
| `headers_enabled` | bool | 기본 false |
| `headers` | dict[str, str] | 기본 `{}` |
| `body_enabled` | bool | 기본 false |
| `body` | string? | JSON string |
| `timeout_seconds` | int (>0) | 기본 10 |

### ApiResponseVariable

api 응답에서 추출할 변수 매핑.

| 필드 | 타입 | 설명 |
|---|---|---|
| `variable_name` | string | 저장할 변수 이름 |
| `json_path` | string | JSONPath 표현식 (예: `$.data.user.id`) |

### TransferConfiguration

transferCall 노드의 전환 대상 설정.

| 필드 | 타입 | 기본값 |
|---|---|---|
| `transfer_to` | string | 대상 번호 또는 SIP URI |
| `transfer_type` | `"phone" \| "sip"` | 기본 `"phone"` |
| `transfer_condition` | string? | 전환 조건 설명 (선택) |

### SipHeader

transferCall 의 SIP REFER 헤더 (옵션).

| 필드 | 타입 |
|---|---|
| `name` | string |
| `value` | string |

### AgentMapping

transferAgent 노드의 대상 에이전트 매핑.

| 필드 | 타입 | 설명 |
|---|---|---|
| `agent_id` | string (UUID) | 전환 대상 에이전트의 UUID |
| `agent_version` | `"current" \| "production" \| "v{n}"` | 기본 `"current"`. `v{n}` 은 `n>=1`. null 거부. |

---

## begin

flow 시작점. flow 당 1 개 자동 생성, 삭제 불가.

| 필드 | 타입 | 기본값 |
|---|---|---|
| `name` | string? | |
| `global` | GlobalConfig? | |
| `first_line_type` | `"aiFirst" \| "userFirst"` ? | null 이면 agent 의 `data.prompt.first_line_type` 상속 |
| `pause_before_speaking_seconds` | float (0..5) | 0.0 |

- `aiFirst`: 에이전트가 먼저 인사. `userFirst`: 고객 발화 대기 후 시작.
- begin 의 out-edge 는 보통 1 개, condition 은 `{type:"fallback"}`.

---

## conversation

대화 수행 노드. flow 의 핵심.

| 필드 | 타입 | 기본값 |
|---|---|---|
| `name` | string? | |
| `global` | GlobalConfig? | |
| `message` | Message? | 발화. `mode="none"` 거부 |
| `first_message` | string? | 노드 진입 시 첫 발화 (message 실행 전) |
| `loop_condition` | string? | 조건 충족까지 노드 안에서 반복 |
| `is_skip_user_response` | bool | 기본 false |
| `is_allow_interruption` | bool | 기본 true |
| `knowledge` | NodeKnowledgeConfig? | RAG 설정 |
| `knowledge_ids` (deprecated) | int[]? | v2 legacy. 신규는 `knowledge.knowledge_ids` 사용. |
| `rag_enabled` (deprecated) | bool? | v2 legacy. 신규는 `knowledge.rag_enabled` 사용. |

- conversation 노드의 out-edge condition 은 보통 `{type:"ai", prompt:"…"}`. 자연어 exit 조건. 여러 개 + 보통 마지막에 `{type:"fallback"}` 1 개.
- `loop_condition` 은 비어 있으면 반복 없음. 값이 있으면 조건 불충족 시 같은 노드 반복.
- `knowledge.rag_enabled = true` + `knowledge.knowledge_ids` 설정 시 RAG.

---

## tool

도구 실행 노드. vox.ai 에 등록된 tool 호출.

| 필드 | 타입 |
|---|---|
| `name` | string? |
| `global` | GlobalConfig? |
| `tool_id` | string? — UUID (신규) 또는 legacy function id 문자열 |
| `prompt` | string? — 실행 전 발화 프롬프트 (선택) |

- 호출 실패 시 path 는 out-edge 에 `{type:"fallback"}` edge 로 표현.
- legacy `agentToolId` (int) 는 v3 API 노출 안 됨 — 보내도 drop, 내부 reference 로만 보존.

---

## api

HTTP API 호출 노드.

| 필드 | 타입 |
|---|---|
| `name` | string? |
| `global` | GlobalConfig? |
| `api_configuration` | ApiConfiguration (필수) |
| `response_variables` | ApiResponseVariable[] (기본 `[]`) |
| `prompt` | string? — 호출 전 발화 프롬프트 (선택) |

- 호출 실패 path 는 out-edge `{type:"fallback"}`.
- `response_variables` 의 변수는 flow 변수로 등록되어 이후 노드에서 `{{variable_name}}` 으로 참조.

---

## sendSms

SMS 발송 노드. 통화 중 SMS 메시지를 전송. 다른 conversation/endCall 과 다르게 **flat 구조** (Message 객체 사용 안 함) — DB / runtime / web editor schema 와 일치.

| 필드 | 타입 | 기본값 |
|---|---|---|
| `name` | string? | |
| `global` | GlobalConfig? | |
| `prompt_type` | `"static" \| "dynamic"` | 기본 `"dynamic"` |
| `prompt` | string? | `prompt_type="dynamic"` 일 때 SMS body 생성 프롬프트 |
| `static_sentence` | string? | `prompt_type="static"` 일 때 고정 메시지 본문 |
| `static_title` | string? | static LMS/MMS 제목 (선택) |
| `static_image_file_keys` | string[] (max 3) | static MMS 첨부 — `POST /v2/files` 가 반환한 opaque `file_key` 만 (storage path / public URL 금지) |
| `sms_from_number` | string? | 발신번호 override. SMS 가능 번호여야 하고 미지정 시 통화 컨텍스트 default 사용 |

- SMS 가능 전화번호가 조직에 있어야 사용 가능.
- 성공 / 실패 path 는 out-edge 에 각각 `{type:"ai"}` (또는 logic) 와 `{type:"fallback"}` 으로 표현.

---

## condition

조건 분기 노드. **`data` 에 `name` / `global` 외 어떤 필드도 들어가지 않는다.** 분기는 100% out-edge 에 위치.

| 필드 | 타입 |
|---|---|
| `name` | string? |
| `global` | GlobalConfig? |

분기는 out-edge 의 `condition` 으로:
- `{type:"logic", op:"and"|"or", conditions:[SingleCondition,...]}` edge 여러 개 (각각 한 분기)
- 마지막에 `{type:"fallback"}` edge 1 개 (Else)

`SingleCondition` / `ConditionOperator` 상세 → [flow-guide.md](flow-guide.md) 의 "EdgeCondition" 섹션.

> 구 v2 의 `logicalTransitions[]` / `LogicalCondition` / 노드 내부 분기 필드는 **모두 사라짐**. condition 노드의 data 안에 분기 필드를 넣어 보내면 silently drop.

---

## extraction

변수 추출 노드. LLM 이 대화 컨텍스트에서 정보를 추출하여 flow 변수로 저장.

| 필드 | 타입 | 기본값 |
|---|---|---|
| `name` | string? | |
| `global` | GlobalConfig? | |
| `extraction_configuration` | ExtractionConfiguration | (필수, 기본은 빈 config) |
| `prompt` | string? | extraction 추가 컨텍스트 (선택) |
| `is_skip_user_response` | bool | 기본 true (응답 대기 안 함) |

- 유저 응답을 기다리지 않고 기존 대화 컨텍스트에서 즉시 추출.
- 추출된 변수는 flow 변수로 등록되어 이후 노드에서 `{{variable_name}}` 으로 참조.
- out-edge 는 보통 단일 `{type:"fallback"}` (begin 과 동일 패턴).

---

## transferCall

통화 전환 노드. 외부 번호로 통화를 전환.

| 필드 | 타입 | 기본값 |
|---|---|---|
| `name` | string? | |
| `global` | GlobalConfig? | |
| `transfer_configuration` | TransferConfiguration (필수) | 대상 번호 / SIP / 조건 |
| `transfer_type` | `"cold" \| "warm"` | 기본 `"cold"` |
| `transfer_message_type` | `"static" \| "dynamic"` ? | warm 안내 메시지 모드. 기본 `"static"` |
| `warm_transfer_prompt` | string? | warm transfer 시 상담원에게 전달할 프롬프트 |
| `warm_transfer_static_sentence` | string? | warm static 멘트 |
| `displayed_caller_id` | `"agent" \| "user"` | 기본 `"agent"` |
| `sip_headers` | SipHeader[]? | SIP REFER 헤더 (선택) |
| `prompt` | string? | 전환 전 발화 프롬프트 (선택) |

- **cold transfer**: 고객을 바로 상담원에게 넘김 (에이전트 퇴장).
- **warm transfer**: 에이전트가 상담원에게 먼저 컨텍스트 전달 후 고객 연결.
- 전환 실패 path 는 out-edge `{type:"fallback"}`.

---

## transferAgent

에이전트 전환 노드. 다른 vox.ai 에이전트로 대화를 넘김.

| 필드 | 타입 | 기본값 |
|---|---|---|
| `name` | string? | |
| `global` | GlobalConfig? | |
| `agent` | AgentMapping? | `{agent_id: UUID, agent_version: "current"\|"production"\|"v{n}"}` 객체. **flat `agent_id`/`agent_version` 으로 보내면 안 됨.** |
| `preserve_chat_context` | bool | 기본 false |
| `prompt` | string? | 전환 전 발화 프롬프트 (선택) |

- `preserve_chat_context: true` — 이전 대화 내역을 새 에이전트에게 전달.
- 전환 실패 path 는 out-edge `{type:"fallback"}`.

---

## endCall

통화 종료 노드.

| 필드 | 타입 |
|---|---|
| `name` | string? |
| `global` | GlobalConfig? |
| `message` | Message? — 종료 직전 발화. `mode="none"` 허용 (즉시 종료) |

- global node 로 설정 시 (`data.global = {enter_condition: "고객이 통화 종료를 요청한 경우"}`) 어디서든 이 노드로 진입 가능.

---

## note

메모 노드. 실행되지 않으며 flow editor 에서 설명/주석 용도.

| 필드 | 타입 | 설명 |
|---|---|---|
| `name` | string? | |
| `global` | GlobalConfig? | (사실상 의미 없음, runtime 미실행) |
| `content` | string? | 노트 본문 |
| `width` | float? | 에디터 resize 너비 (px) — runtime 무관 |
| `height` | float? | 에디터 resize 높이 (px) — runtime 무관 |
| `prompt` | string? | legacy 필드 — `content` 우선 |

- 실행 흐름에 영향 없음.
- 보통 in-edge / out-edge 도 없는 floating node 로 둠.

---

## Deprecated

아래 노드 타입은 더 이상 신규 flow 에서 사용하지 않는다. 기존 flow 에서는 동작하지만 대시보드에서 추가 불가.

### function (→ tool)

`tool` 노드로 대체됨. DB 에 `type=function` + `functionId` 인 노드는 v3 API 가 `type=tool` + `tool_id=functionId` 로 노출.

### knowledge (→ conversation)

`conversation` 노드의 `knowledge` 설정으로 통합됨. `conversation.data.knowledge.rag_enabled = true` + `knowledge.knowledge_ids` 로 동일 기능.
