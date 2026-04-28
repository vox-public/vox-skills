# Hidden Contracts: schema 표면만 보고는 알 수 없는 규칙

이 문서는 vox.ai flow_data 의 **schema endpoint 응답 표면만 보고는 알 수 없는 contract** 를 모은다. round-trip 은 통과하지만 web editor 가 깨지거나 통화가 `flow_error` 로 끝나는 함정이 여기에 해당한다.

> 이 갭 대부분은 **백엔드의 default + validation 작업으로 자동 처리될 예정** 이다. 이 문서는 그 작업이 들어가기 전까지 flow 작성자가 1차 시도에서 막히지 않게 하는 **현재 시점의 권장 세팅** 을 정리한다.
>
> 실제 schema 의 field/enum/required 여부는 `get_schema(namespace="flow-schema", schema_type="flow-data")` 결과를 따른다. 이 문서는 그 결과 위에 덮어쓰는 운영 규칙이다.

## 사용법

flow_data JSON 을 만들거나 수정할 때, 아래 12 항목을 빠르게 훑고 해당하는 노드/필드는 권장 세팅을 적용한다. 각 항목은:

- ⚠️ **현재 동작** — 함정의 원인 (1 줄)
- ✅ **권장 세팅** — 지금 시점에서 어떻게 보내면 안전한지
- 🔄 **개선 예정** — 백엔드가 자동화하면 사라질 가이드인지 표기

## 목차

1. [응답 비기대형 노드의 outgoing transition `skip_user_response=true`](#1-응답-비기대형-노드의-outgoing-transition-skip_user_responsetrue)
2. [LogicCondition `value` 는 string + boolean 비교 우회](#2-logiccondition-value-는-string--boolean-비교-우회)
3. [api 노드 `api_configuration` default 필드 모두 명시](#3-api-노드-api_configuration-default-필드-모두-명시)
4. [edge ↔ transition 매칭은 `sourceHandle == transition.id`](#4-edge--transition-매칭은-sourcehandle--transitionid)
5. [`fallback` 은 응답 비기대형 분기 노드에서만](#5-fallback-은-응답-비기대형-분기-노드에서만)
6. [flow_data PATCH 시 사용자 web editor 수정분 보존](#6-flow_data-patch-시-사용자-web-editor-수정분-보존)
7. [`transferAgent.agentId` 는 int (내부 ID)](#7-transferagentagentid-는-int-내부-id)
8. [변수명은 flow 전체에서 유일하게](#8-변수명은-flow-전체에서-유일하게)
9. [노드/transition id 는 nanoid 또는 UUID](#9-노드transition-id-는-nanoid-또는-uuid)
10. [sendSms 노드는 schema 검증이 약하므로 필수 필드 모두 명시](#10-sendsms-노드는-schema-검증이-약하므로-필수-필드-모두-명시)
11. [extraction 변수 정규화는 description + 후속 prompt 로 보정](#11-extraction-변수-정규화는-description--후속-prompt-로-보정)
12. [api plain text 응답은 `jsonPath="$"` + 후속 prompt 정제](#12-api-plain-text-응답은-jsonpath--후속-prompt-정제)

---

## 1. 응답 비기대형 노드의 outgoing transition `skip_user_response=true`

⚠️ **현재 동작**: extraction / condition / api / sendSms / tool / transferCall / transferAgent 노드 자체는 응답 비기대형 (`is_skip_user_response=true` 가 default 이거나 응답 자체를 받지 않음) 인데, **outgoing transition 의 `skip_user_response` 는 schema default 가 false**. 두 값이 일치하지 않으면 edge traversal 시 사용자 응답 대기 → `flow_error` 로 통화 비정상 종료.

✅ **권장 세팅**: 위 7개 노드 타입의 **outgoing transition 마다** `skip_user_response: true` 를 명시한다. conversation 노드의 outgoing 은 `false` (사용자 응답 기다림) 가 정상.

```json
{
  "source": "extract_score",
  "target": "branch_score",
  "condition": { "type": "fallback" },
  "skip_user_response": true
}
```

`begin → next` 는 transitions 자체를 사용하지 않고 **단일 edge 하나만**. 보내도 server 가 silently override 한다.

🔄 **개선 예정**: 노드 타입별 default 차등화 또는 server-side 자동 강제로 사라질 가이드.

---

## 2. LogicCondition `value` 는 string + boolean 비교 우회

⚠️ **현재 동작**:
- `LogicCondition.SingleCondition.value` 의 type 명시 없음. number/boolean 직접 보내면 web editor 가 `e.value.match is not a function` 으로 크래시 + 페이지 로드 실패.
- `value="true"` (string) ↔ 추출값 `true` (boolean) 비교 시 runtime 이 `"True" == "true"` 케이스 차이로 매치 실패 → boolean 변수 분기가 silent 로 안 잡힘.

✅ **권장 세팅**:
- `value` 는 **무조건 string** 으로 보낸다 (`"6"`, `"true"`, `"basic"` 등).
- **boolean 변수로 분기는 가능하면 피한다.** 분기가 critical 하면:
  - extraction 시 `variable_type="string"` 으로 추출 (LLM 이 `"yes"`/`"no"` 또는 `"true"`/`"false"` 로 채움)
  - 또는 conversation 노드의 out-edge 를 ai condition 으로 두고 LogicCondition 회피

```json
{
  "type": "logic",
  "op": "and",
  "conditions": [
    { "variable": "member_grade", "operator": "equals", "value": "premium" }
  ]
}
```

🔄 **개선 예정**: schema 의 value type 명시 + runtime 정규화로 boolean 비교가 정상 매치되면 우회 불필요.

---

## 3. api 노드 `api_configuration` default 필드 모두 명시

⚠️ **현재 동작**: api 노드의 `api_configuration` 안 optional 필드를 누락하면 응답에서도 누락된 채로 반환되고, web editor 가 `Cannot convert undefined or null to object` 로 크래시 — api 노드를 클릭하는 순간 페이지가 깨짐.

✅ **권장 세팅**: 아래 8개 default 필드를 **모두 명시** 한다. 사용 안 해도 false / null / 빈 객체로 채워보낸다.

```json
{
  "type": "api",
  "data": {
    "name": "fetch_x",
    "api_configuration": {
      "method": "GET",
      "url": "https://...",
      "authorization_enabled": false,
      "auth_type": "None",
      "auth_credentials": null,
      "auth_encode_required": false,
      "headers_enabled": false,
      "headers": {},
      "body_enabled": false,
      "body": null,
      "timeout_seconds": 10
    }
  }
}
```

🔄 **개선 예정**: server 가 응답 시 default 채워서 반환하면 누락해도 안전.

---

## 4. edge ↔ transition 매칭은 `sourceHandle == transition.id`

⚠️ **현재 동작**: edge 와 transition 은 별개 데이터 모델. **edge 의 source 노드에 정의된 transition 의 id 가 edge.sourceHandle 과 일치할 때만** 그 edge 가 살아있다고 인식된다. 매칭이 깨지면:
- web editor 캔버스에 edge 가 안 그려짐 — source 가 begin / extraction / api 인 경우 특히 자주
- 런타임이 매칭 안 되는 transition 을 silent 삭제

⚠️ schema endpoint 의 `EdgeCondition` 표면 (`type: "ai" | "logic" | "fallback"`) 은 내부적으로 source 노드의 transition 으로 매핑된다. 그래서 condition 만 만들고 transition 의 id / sourceHandle 매칭을 신경 안 쓰면 edge 가 silent 로 죽는 케이스가 발생.

✅ **권장 세팅**:
- **schema endpoint 가 노출하는 형태대로** edge.condition 만 구성하고 transitions 직접 만지지 않는다 (schema 가 transition 을 추상화함).
- 만약 schema 응답에 transition / sourceHandle 이 노출되면 **반드시 edge.sourceHandle 을 source 노드의 transition.id 와 일치** 시킨다.
- "사용자가 연결이 안 보인다" 라고 보고하면:
  1. `get_agent` 으로 round-trip 응답을 먼저 확인
  2. `condition.type="fallback"` 이면 web editor 시각화 버그 (M4) 가능성 → "데이터 정상이지만 web editor 가 안 그리는 케이스" 안내
  3. 데이터에 edge 자체가 빠졌으면 schema 어긋남 → schema 결과와 다시 대조

🔄 **개선 예정**: server 가 edge↔transition 매칭을 validate 해서 깨지면 schema error 로 즉시 거절. silent 삭제 사라짐.

---

## 5. `fallback` 은 응답 비기대형 분기 노드에서만

⚠️ **현재 동작**: schema 가 `EdgeCondition` 의 fallback 을 모든 source 노드에 허용. 하지만 conversation 노드의 out-edge 에 fallback 을 두면 의도치 않은 분기 동작 + web editor 표시 이슈가 섞인다.

✅ **권장 세팅**: `condition.type="fallback"` 은 다음 노드 타입의 out-edge 에서만 사용:
- `api`, `tool`, `function`, `sendSms`, `transferCall`, `transferAgent` — 실패 path
- `condition` — logic edge 들이 모두 안 맞을 때 default
- `begin` — 첫 노드로 가는 단일 edge

conversation 노드의 out-edge 는 항상 `condition.type="ai"` 또는 `condition.type="logic"` 만. 거절/예외도 ai condition 자연어로 표현한다 ("고객이 거절했거나 통화를 끊으려는 경우" 등).

🔄 **개선 예정**: schema 단계에서 conversation 노드의 fallback out-edge 거절.

---

## 6. flow_data PATCH 시 사용자 web editor 수정분 보존

⚠️ **현재 동작**: `update_agent(flow_data=...)` 는 **전체 교체** 방식. 그런데 사용자가 web editor 에서 직접 추가/수정한 노드/edge 도 server 에 저장되어 있어서, 이전 버전으로 PATCH 하면 사용자 작업분이 덮어써진다.

✅ **권장 세팅**: `update_agent` 직전 항상:

1. `get_agent(agent_id=...)` 으로 현재 flow_data 조회
2. 응답의 nodes / edges 와 우리가 만들 nodes / edges 를 diff
3. 사용자가 추가한 (id 가 우리 의도에 없는) 노드/edge 는 **그대로 보존** 한 채로 PATCH
4. PATCH 후 `get_agent` 다시 호출해 round-trip 확인

사용자 추가 edge 의 형식이 우리 형식과 다를 수 있다 (M7 — 사용자는 빈/짧은 prompt + `condition.type="fallback"` 으로, 에이전트는 자연어 prompt + ai condition 으로 작성). 이는 둘 다 정상이므로 형식 통일 시도하지 말고 그대로 둔다.

🔄 **개선 예정**: server 가 PATCH 시 user-modified 마커가 있는 항목을 자동 보존하면 diff/merge 부담 사라짐.

---

## 7. `transferAgent.agentId` 는 int (내부 ID)

⚠️ **현재 동작**: `TransferAgentNodeData.agentId` 는 `int` 타입. 그런데 `list_agents()` 응답의 `id` 는 string UUID. 두 값이 타입도 다르고 다른 ID 다.

✅ **권장 세팅**:
- `transferAgent` 노드를 만들 때 `agentId` 에 `list_agents` 의 UUID 를 그대로 넣지 않는다.
- 현재는 내부 int agent_id 가 별도 필요. MCP / API 만으로는 직접 채우기 어려움 → **transferAgent 노드 사용을 가능하면 미루거나 사용자가 web editor 에서 채우도록 안내** 한다.
- placeholder `agentId: 0` 같은 값으로 초기 생성 후 사용자가 web editor 의 agent 드롭다운으로 선택하도록 명시.

🔄 **개선 예정**: schema 가 `agentId` 를 string UUID 로 통일하면 `list_agents` 응답의 id 를 그대로 쓸 수 있게 됨. 이 가이드 사라짐.

---

## 8. 변수명은 flow 전체에서 유일하게

⚠️ **현재 동작**: `extraction_configuration.variables[].variable_name` 또는 `api` 노드의 `response_variables[].variable_name` 의 중복 검증이 없다. 같은 노드 안 또는 다른 노드 사이 중복 변수명을 보내도 schema 통과되지만 런타임에서 충돌 / 마지막 값으로 덮어씀.

✅ **권장 세팅**: flow 전체에서 변수명 유일. 변수가 같은 의미를 가진다면 한 곳에서만 추출하고 후속 노드들이 공유한다. 같은 의미인데 노드별 다른 이름 (`customer_name_a`, `customer_name_b`) 도 피한다.

🔄 **개선 예정**: schema validation 추가로 충돌 시 즉시 schema error.

---

## 9. 노드/transition id 는 nanoid 또는 UUID

⚠️ **현재 동작**: 노드 `id` / transition `id` 의 형식 검증이 없다. 임의 string ("greet_score" 등) 보내도 schema 통과. 그러나 web editor 는 nanoid (10-12자 `[a-zA-Z0-9_-]`) 를 생성하기 때문에, MCP / API 로 만든 임의 id 가 web editor import / edit 시 문제될 수 있다.

✅ **권장 세팅**:
- 노드 `id` 와 transition `id` 는 **nanoid 형식** (10-12자, `[a-zA-Z0-9_-]`) 또는 UUID 사용
- 의미 있는 이름은 `data.name` 에 한국어로 (예: `data.name="인사 및 본인확인"`)
- snake_case slug (`greet_score`) 도 동작하지만 향후 web editor 호환성 위해 nanoid 권장

🔄 **개선 예정**: schema description 에 권장 형식 명시 또는 regex validation.

---

## 10. sendSms 노드는 schema 검증이 약하므로 필수 필드 모두 명시

⚠️ **현재 동작**: agent-server 런타임은 `sendSms` 노드를 정상 지원하고 web editor 도 지원하지만, **MCP API schema 의 `_NODE_DATA_MODELS` 에 `sendSms` 가 누락** 되어있다. 즉 schema 에서 `extra="allow"` 정책으로 통과되지만 어떤 필드가 필수인지 검증되지 않는다.

✅ **권장 세팅**: sendSms 노드를 만들 때 다음 필드를 **모두 직접 명시** :
- `prompt_type`: `"static"` | `"dynamic"`
- `prompt`: dynamic 일 때 생성 프롬프트
- `static_sentence`: static 일 때 본문
- `static_title`: static 일 때 제목 (LMS/MMS)
- `transitions`: 성공/실패 분기 (응답 비기대형이므로 `skip_user_response=true`)

```json
{
  "type": "sendSms",
  "data": {
    "name": "예약확인SMS",
    "prompt_type": "static",
    "static_title": "예약 확정",
    "static_sentence": "{{customer_name}}님 예약이 확정되었습니다."
  }
}
```

🔄 **개선 예정**: schema 에 SendSmsNodeData 가 추가되면 누락 필드를 schema 단계에서 거절.

---

## 11. extraction 변수 정규화는 description + 후속 prompt 로 보정

⚠️ **현재 동작**: `extraction_configuration.variables[].variable_type` 은 `string` / `number` / `boolean` 만. `format` / `regex` / `parser` 같은 정규화 옵션이 노출되지 않는다. 결과적으로 `"이번 주 금요일 오후 2시"` 같은 자연어가 그대로 변수에 저장됨.

✅ **권장 세팅**:
- 추출 description 에 형식 + 예시를 명확히 포함:
  ```
  variable_description: "고객이 말한 새 예약 일시. ISO 8601 datetime 형식 (YYYY-MM-DDTHH:MM). 예: 2026-05-01T14:00. 자연어 표현은 절대 그대로 두지 말고 변환할 것."
  ```
- 후속 conversation 노드 또는 api 노드 prompt 에서 추가 보정 ("YYYY-MM-DD 가 아니면 다시 묻기" 등)
- API 호출 시 변수에 trailing whitespace 가능성 — 변수 사용 전 conversation prompt 에서 trim 지시

🔄 **개선 예정**: `format` enum (`date` / `datetime` / `phone_kr` / `email` / 등) 또는 `regex` 필드 추가되면 description 보정 불필요.

---

## 12. api plain text 응답은 `jsonPath="$"` + 후속 prompt 정제

⚠️ **현재 동작**: `response_variables[].json_path` 는 JSONPath 만 받음. plain text 응답 (예: `5\n`) 을 JSON 파싱하면 실패하거나 `"$"` 로 body 전체를 받으면 trailing newline / 공백이 변수에 들어감.

✅ **권장 세팅**:
- plain text API 의 응답을 변수로 받을 때 `json_path: "$"` 로 body 전체 수신
- 변수를 사용하는 conversation 노드 prompt 에 정제 지시 ("이 값에서 숫자만 읽어 자연스럽게 안내하세요")
- 가능하면 JSON 응답을 주는 API 사용을 우선 시도

🔄 **개선 예정**: `extractor` enum (`jsonpath` / `regex` / `raw_text` / `trim`) 또는 응답 Content-Type 자동 trim 추가되면 우회 불필요.

---

## 빠른 self-check

flow_data JSON 을 보내기 직전 12 항목을 다음 순서로 점검:

1. extraction / condition / api / sendSms / tool / transferCall / transferAgent 의 outgoing edge 마다 `skip_user_response=true` 가 있나? (§1)
2. LogicCondition.value 가 모두 string 인가? boolean 변수 분기를 ai condition 으로 우회했나? (§2)
3. api 노드의 api_configuration default 8 필드를 모두 명시했나? (§3)
4. edge 의 sourceHandle 이 source 노드의 transition.id 와 매칭되나? (§4)
5. fallback edge 가 응답 비기대형 분기 노드 또는 begin 에서만 출발하나? conversation 에 fallback 없나? (§5)
6. PATCH 직전 `get_agent` 으로 사용자 수정분 확인했나? (§6)
7. transferAgent 노드 만들었으면 agentId 는 int placeholder 이고 사용자에게 web editor 에서 선택해달라고 안내했나? (§7)
8. 변수명이 flow 전체에서 유일한가? (§8)
9. 노드/transition id 가 nanoid 또는 UUID 인가? (§9)
10. sendSms 노드 만들었으면 prompt_type / prompt 또는 static_sentence/title / transitions 모두 명시했나? (§10)
11. extraction 변수 description 에 형식 + 예시가 있나? (§11)
12. api plain text 응답 변수에 후속 prompt 정제 지시가 있나? (§12)

`get_agent` 으로 round-trip 확인 시 sent vs received diff 가 12 항목 중 어디서 발생하는지로도 빠르게 잡힌다.

## 관련 문서

- `flow-guide.md` — flow 전반, EdgeCondition / 변수 흐름
- `execution-node-markdown.md` — extraction / api / transfer / sendSms 작성 패턴
- `node-types.md` — 노드 타입 선택 + 노드별 high-risk 항목
- `flow-review.md` — 설계물 체크리스트 (위 12 항목과 매핑됨)
