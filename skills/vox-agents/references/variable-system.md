# 변수 시스템

vox.ai 에이전트에서 사용하는 변수 시스템. prompt agent와 flow agent 모두에서 사용된다.

flow agent 의 정확한 variable 관련 field 이름과 edge condition shape 는 MCP schema endpoint 결과를 따른다.

```text
get_schema(namespace="flow-schema", schema_type="flow-data")
get_schema(namespace="agent-schema", schema_type="agent-data-create")
get_schema(namespace="agent-schema", schema_type="agent-data-update")
```

---

## 공통

### system — 시스템 변수

vox.ai 플랫폼에서 자동으로 제공하는 읽기 전용 변수.

| 변수 | 설명 |
|------|------|
| `{{current_time}}` | 현재 시각 |
| `{{call_from}}` | 발신자 전화번호 |
| `{{call_to}}` | 수신자 전화번호 |
| `{{call_id}}` | 통화 고유 ID |
| `{{agent_id}}` | 에이전트 ID |

- 선언 불필요 — 모든 에이전트에서 자동 사용 가능.
- 값 변경 불가 (읽기 전용).

### agent — 에이전트 설정 변수

에이전트 설정 페이지 또는 API payload 에서 정의한 변수. 에이전트 프롬프트, 통화 정보 추출 등에서 사용.

- 현재 agent data 에서는 사전 주입 변수로 `presetDynamicVariables` 를 사용한다. 정확한 shape 는 `agent-schema` endpoint 를 확인한다.
- 런타임에 외부 시스템 또는 API 호출 시 주입.
- 예: `{{customer_name}}`, `{{order_id}}`, `{{campaign_code}}`

### 변수 Naming Convention

- **snake_case** 사용: `customer_name`, `order_id`, `payment_method`
- 의미가 명확한 이름: `phone` 대신 `customer_phone_number`
- boolean은 `is_` / `has_` 접두사: `is_verified`, `has_order`
- 약어 금지: `cust_nm` 대신 `customer_name`

---

## Flow 전용

아래는 flow agent에서만 사용되는 변수 기능이다. prompt agent에서는 해당 없음.

### flow — 플로우 변수

현재 flow 실행 중에 생성되는 변수. 두 가지 소스:

**1. extraction node (LLM 추출)**

LLM이 대화 컨텍스트에서 정보를 추출하여 변수로 저장.

정확한 extraction configuration field, variable type enum, required 여부는 `flow-schema/flow-data` 결과를 따른다.

**2. api node (JSONPath 추출)**

API 응답에서 JSONPath로 값을 추출하여 변수로 저장.

정확한 response variable field 와 JSONPath 설정 shape 는 `flow-schema/flow-data` 결과를 따른다.

## 변수 흐름 패턴

가장 일반적인 패턴: extraction → condition → api 체인.

```
conversation     extraction       condition         api            conversation
(정보 수집) --> (변수 추출) --> (조건 분기) --> (외부 조회) --> (결과 안내)
    |               |               |              |              |
    |          customer_name    customer_name   order_status   order_status
    |          phone_number     == "홍길동"     (JSONPath)     {{order_status}}
    |                           phone_number
    |                           exists?
```

1. **conversation** 노드에서 고객과 대화하며 정보 수집
2. **extraction** 노드에서 대화 컨텍스트로부터 변수 추출 (customer_name, phone_number)
3. **condition** 노드에서 추출된 변수 값으로 분기 판단
4. **api** 노드에서 변수를 사용해 외부 API 호출, 응답에서 새 변수 추출
5. **conversation** 노드에서 `{{order_status}}` 등으로 결과 안내

## 조건 노드에서 변수 소비

condition node는 node 내부 `LogicalTransition`이 아니라 outgoing edge 의 condition 으로 변수 값을 평가한다. 정확한 edge condition union, operator enum, value 필요 여부는 `flow-schema/flow-data` 결과를 따른다.

- AND: 모든 조건 충족 시 해당 edge로 진행.
- OR: 하나라도 충족 시 해당 edge로 진행.

## 변수 렌더링

`{{variable_name}}` 구문으로 다음 위치에서 사용 가능:

- conversation/endCall node의 발화 content
- conversation node의 loop condition
- edge condition
- api node의 `url`, `headers`, `body`
- extraction node의 extraction prompt
- transferCall node의 warm transfer prompt

변수 사용 가능 위치와 정확한 field 이름은 `flow-schema/flow-data` 결과를 따른다.
