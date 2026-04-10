# 변수 시스템

flow에서 노드 간 데이터를 전달하는 변수 시스템. 3종 카테고리로 분류된다.

## 카테고리

### system — 시스템 변수

vox.ai 플랫폼에서 자동으로 제공하는 읽기 전용 변수.

| 변수 | 설명 |
|------|------|
| `{{current_time}}` | 현재 시각 |
| `{{call_from}}` | 발신자 전화번호 |
| `{{call_to}}` | 수신자 전화번호 |
| `{{call_id}}` | 통화 고유 ID |
| `{{agent_id}}` | 에이전트 ID |

- 선언 불필요 — 모든 flow에서 자동 사용 가능.
- 값 변경 불가 (읽기 전용).

### agent — 에이전트 설정 변수

에이전트 설정 페이지에서 정의한 변수. 에이전트 프롬프트, 통화 정보 추출 등에서 사용.

- 에이전트 설정의 `{{...}}` 패턴으로 선언.
- 런타임에 외부 시스템 또는 API 호출 시 주입.
- 예: `{{customer_name}}`, `{{order_id}}`, `{{campaign_code}}`

### flow — 플로우 변수

현재 flow 실행 중에 생성되는 변수. 두 가지 소스:

**1. extraction node (LLM 추출)**

LLM이 대화 컨텍스트에서 정보를 추출하여 변수로 저장.

```
ExtractionConfiguration {
  extractionPrompt: string     // 추출 지시
  variables: [
    { variableName, variableType, variableDescription }
  ]
}
```

- `variableType`: `string | number | boolean`
- `variableDescription`: LLM이 무엇을 추출할지 판단하는 가이드.

**2. api node (JSONPath 추출)**

API 응답에서 JSONPath로 값을 추출하여 변수로 저장.

```
APIResponseVariable {
  variableName: string    // 저장할 변수 이름
  jsonPath: string        // JSONPath 표현식 (예: $.data.user.id)
}
```

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

condition node는 `LogicalTransition`으로 변수 값을 평가한다.

**구조:**
```
LogicalTransition {
  id: string
  condition: {
    conditions: SingleCondition[]     // 개별 조건 목록
    logicalOperator: "and" | "or"     // 결합 방식
  }
}

SingleCondition {
  variable: string        // 비교 대상 변수 이름
  operator: OperatorEnum  // 10종 연산자
  value?: string          // 비교 값 (EXISTS/DOES_NOT_EXIST는 불필요)
}
```

OperatorEnum 10종 상세: [node-types.md — condition 섹션](node-types.md) 참고.

- AND: 모든 조건 충족 시 해당 edge로 진행.
- OR: 하나라도 충족 시 해당 edge로 진행.

## 변수 렌더링

`{{variable_name}}` 구문으로 다음 위치에서 사용 가능:

- conversation/endCall node의 `prompt`, `staticSentence`
- conversation node의 `loopCondition`
- conversation node의 `transitions[].condition`
- api node의 `url`, `headers`, `body`
- extraction node의 `extractionPrompt`
- transferCall node의 `warmTransferPrompt`

## 변수 Naming Convention

- **snake_case** 사용: `customer_name`, `order_id`, `payment_method`
- 의미가 명확한 이름: `phone` 대신 `customer_phone_number`
- boolean은 `is_` / `has_` 접두사: `is_verified`, `has_order`
- 약어 금지: `cust_nm` 대신 `customer_name`
