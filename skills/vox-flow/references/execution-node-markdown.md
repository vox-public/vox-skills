# Execution node markdown

이 문서는 conversation 외 노드의 **설계 markdown** 작성법을 다룬다. MCP/API `flow_data` JSON field 는 항상 `get_schema(namespace="flow-schema", schema_type="flow-data")` 결과를 따른다.

## Shared rules

- 실패, else, fallback path 가 필요하면 markdown 에 의도를 쓰고 JSON 변환 시 `edges` 로 명시한다.
- 과거 field 이름(`agentId`, `promptType`, `staticSentence`, node 내부 `transitions[]`)을 JSON field 로 복사하지 않는다.
- 각 노드는 `## name / ## content / ## transition conditions` 구조를 유지한다.

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
- 성공: API 응답 정상 수신 시 다음 노드로 진행.
- 실패: API 호출 실패 시 fallback edge로 진행. (JSON 변환 시 edge 명시)
```

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

## Global node

통화 종료 요청, 상담원 연결 요청처럼 어디서든 발생할 수 있는 예외는 global node 후보가 될 수 있다.

작성 규칙:
- 보통 conversation 또는 endCall 에 설계한다. 정확한 허용 shape 는 schema endpoint 결과를 따른다.
- global enter condition 은 고객 발화 기반으로 쓴다.
- 2-3개 이내로 제한한다. 너무 많으면 전환 충돌 위험이 커진다.
