# Execution node markdown

이 문서는 conversation 외 노드의 **설계 markdown** 작성법을 다룬다. MCP/API `flow_data` JSON field 는 항상 `get_schema(namespace="flow-schema", schema_type="flow-data")` 결과를 따른다.

## Shared rules

- 실패, else, fallback path 가 필요하면 markdown 에 의도를 쓰고 JSON 변환 시 `edges` 로 명시한다.
- 과거 field 이름(`agentId`, `promptType`, `staticSentence`, node 내부 `transitions[]`)을 JSON field 로 복사하지 않는다.
- 각 노드는 `## name / ## content / ## transition conditions` 구조를 유지한다.
- **응답 비기대형 노드 (extraction / condition / api / sendSms / tool / transferCall / transferAgent) 의 outgoing edge 는 모두 `skip_user_response=true` 로 보낸다.** 누락 시 통화가 `flow_error` 데드락 ([`hidden-contracts.md` §1](hidden-contracts.md#1-응답-비기대형-노드의-outgoing-transition-skip_user_responsetrue)).
- markdown 단계에서는 표준 양식만 쓰고, JSON 변환 시 위 contract 를 적용한다.

## extraction

대화 컨텍스트에서 값을 추출한다. 고객에게 새 질문을 하지 않는다.

```md
## name
[노드 이름]

## content
### 목적
1. [추출 소스]에서 [추출 대상]을 추출한다.

### 추출 변수
- [variable_name] ([type]): [추출 소스] + [추출 대상 설명] + [포맷 규칙 + 예시]
  ex) [기대 출력 예시]

## transition conditions
(조건 없이 다음 노드로 진행. JSON 변환 시 outgoing edge 에 skip_user_response=true 명시.)
```

작성 규칙:
- 추출 소스를 명시한다: 직전 대화, DTMF 입력, API 응답 설명 등.
- 전화번호, 주문번호처럼 형식이 있는 값은 **description 에 포맷 규칙 + 예시를 명확히** 기록한다 (변수 정규화는 빌트인 미지원, [`hidden-contracts.md` §11](hidden-contracts.md#11-extraction-변수-정규화는-description--후속-prompt-로-보정)).
- 변수명은 snake_case + flow 전체에서 유일하게 ([`hidden-contracts.md` §8](hidden-contracts.md#8-변수명은-flow-전체에서-유일하게)).
- 여러 값을 추출해야 하면 각 변수의 기대 출력 예시를 둔다.
- **분기 / 후속 발화 / api 호출에 사용 안 하는 단순 기록 변수는 extraction 노드가 아닌 `agent.data.postCall.actions` 로** 보낸다 — 자세한 판단 기준은 `flow-guide.md` 의 "extraction 변수 vs postCall 변수" 표.

JSON 변환 시:
- outgoing edge 마다 `skip_user_response=true` 명시 (누락 시 `flow_error` 데드락).
- `extraction_configuration.variables[]` 의 `variable_name` / `variable_type` (`string` / `number` / `boolean`) / `variable_description` 만 schema 에 노출됨. format / regex / parser 옵션은 현재 없음 (백엔드 추가 예정).

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
(변수 기반 분기. JSON 변환 시 edge condition union 과 operator enum 을 schema endpoint 로 확인.)
```

작성 규칙:
- 앞선 extraction / api 에서 만든 변수만 소비한다.
- else/default 분기를 둔다 (`condition.type="fallback"` edge 1 개).
- 실제 JSON operator 이름은 schema endpoint 결과를 따른다.
- **`value` 는 무조건 string** 으로 보낸다. number / boolean 직접 보내면 web editor 크래시 + boolean 비교 매치 실패 가능 ([`hidden-contracts.md` §2](hidden-contracts.md#2-logiccondition-value-는-string--boolean-비교-우회)).
- boolean 변수 분기는 가능하면 피한다 — extraction 시 `string` 으로 추출 (`"yes"` / `"no"`) 하거나, conversation 노드 out-edge 의 ai condition 으로 우회.

JSON 변환 시:
- outgoing edge 마다 `skip_user_response=true` 명시.
- 분기 조건은 모두 `edges[].condition` 으로. 노드 `data` 에는 분기 조건 넣지 않음 (`name`, `global` 만).

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

### 응답 형식 (필요 시)
- response 가 plain text 인 경우: json_path="$" + 후속 conversation prompt 정제 지시

## transition conditions
- 성공: API 응답 정상 수신 시 다음 노드로 진행. (보통 condition / 다음 conversation 으로)
- 실패: API 호출 실패 시 fallback edge 로 진행. 보통 transferCall 또는 안내 endCall.
```

JSON 변환 시 (필수 가이드):

1. **`api_configuration` default 필드 8 개 모두 명시** — 누락 시 web editor 크래시 ([`hidden-contracts.md` §3](hidden-contracts.md#3-api-노드-api_configuration-default-필드-모두-명시)).

   ```json
   {
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
   ```

2. **success / failure 분리 패턴**:
   - 성공 path: `condition.type="ai"` (예: "API 호출 성공 + 변수 채워진 경우") 또는 `condition.type="logic"` 으로 변수 채움 검증
   - 실패 path: `condition.type="fallback"` → 보통 transferCall 또는 안내 endCall
   - web editor UI 의 "요청 실패 시" 기본 옵션은 fallback edge 와 매핑됨

3. **plain text 응답 처리** ([`hidden-contracts.md` §12](hidden-contracts.md#12-api-plain-text-응답은-jsonpath--후속-prompt-정제)):
   - `response_variables[].json_path="$"` 로 body 전체 수신
   - trailing newline / 공백이 변수에 포함될 수 있음
   - 변수 사용 conversation prompt 에 "값에서 숫자만 읽고 자연스럽게 안내" 같은 정제 지시
   - 가능하면 JSON 응답 API 우선 시도

4. **outgoing edge 양쪽 모두 `skip_user_response=true`** 명시.

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
- transfer target: [전화번호 또는 SIP URI. 미정이면 placeholder + 사용자 후속 작업 안내]
- displayed caller id: [agent/user]

### warm transfer 설정
- transfer message mode: [static/generated]
- 멘트/프롬프트: "[상담원에게 전달할 브리핑]"

## transition conditions
- 성공: 전환 성공 시 에이전트 퇴장.
- 실패: 전환 실패 시 fallback edge 로 진행. (JSON 변환 시 edge 명시)
```

작성 규칙:
- **번호가 미정이면** placeholder (`010-0000-0000` 등) 로 채우고 markdown 의 "전환 설정" 섹션에 "사용자가 web editor 또는 별도 update 로 실제 번호 입력 필요" 명시.
- 빈 값으로 두지 않는다 — schema 가 거절하거나 web editor 가 깨질 수 있음.
- outgoing edge `skip_user_response=true` 명시.

## transferAgent

같은 조직 내 다른 vox.ai 에이전트로 대화를 넘긴다.

```md
## name
[노드 이름]

## content
### 목적
1. [전환 이유]

### 전환 설정
- target agent: [전환 대상 에이전트. agentId 는 int 내부 ID — list_agents 응답의 string UUID 가 아님]
- preserve chat context: [true/false]

## transition conditions
- 성공: 에이전트 전환 성공 시 현재 에이전트 퇴장.
- 실패: 전환 실패 시 fallback edge로 진행. (JSON 변환 시 edge 명시)
```

작성 규칙:
- **`agentId` 는 int** ([`hidden-contracts.md` §7](hidden-contracts.md#7-transferagentagentid-는-int-내부-id)). `list_agents()` 응답의 string UUID 와 다름.
- MCP / API 만으로 채우기 어렵다면 `agentId: 0` 같은 placeholder 후 사용자에게 web editor 의 agent 드롭다운으로 선택해달라고 안내한다.
- outgoing edge `skip_user_response=true` 명시.

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
- (LMS/MMS인 경우) 제목: "[제목 — static 시 필수]"

### 발신 설정
- sender: [기본값 사용 또는 발신 가능 번호. JSON shape 는 schema endpoint 확인]

## transition conditions
- 성공: SMS 발송 성공 시 다음 노드로 진행.
- 실패: SMS 발송 실패 시 fallback edge로 진행. (JSON 변환 시 edge 명시)
```

작성 규칙:
- **현재 sendSms 노드는 schema 검증이 약함** ([`hidden-contracts.md` §10](hidden-contracts.md#10-sendsms-노드는-schema-검증이-약하므로-필수-필드-모두-명시)). 다음 필드를 모두 직접 명시:
  - `prompt_type`: `"static"` 또는 `"dynamic"`
  - `prompt`: dynamic 일 때 생성 프롬프트
  - `static_sentence`: static 일 때 본문
  - `static_title`: static 일 때 제목 (LMS/MMS)
  - outgoing edge 의 `skip_user_response=true`
- LMS/MMS (제목 + 본문) 는 static 모드 + `static_title` + `static_sentence` 조합으로.

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
