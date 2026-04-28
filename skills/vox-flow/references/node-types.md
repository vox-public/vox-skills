# Node Types: schema endpoint playbook

이 파일은 node type 을 고르는 기준과 흔한 실수를 정리한다. 실제 `flow_data` 의 node type, field, enum, required 여부는 이 파일에 박아두지 않는다. 작업 직전에 MCP schema endpoint 를 호출해 현재 API 계약을 확인한다.

## Authoritative schema

MCP 로 flow JSON 을 만들거나 수정하기 전에 항상 호출한다.

```text
get_schema(namespace="flow-schema", schema_type="flow-data")
```

agent `data` 도 같이 작성해야 하면 별도로 호출한다.

```text
get_schema(namespace="agent-schema", schema_type="agent-data-create")
get_schema(namespace="agent-schema", schema_type="agent-data-update")
```

schema 결과를 받은 뒤에만 `create_agent(type="flow", data=..., flow_data=...)` 또는 `update_agent(flow_data=...)` 를 호출한다. 전송 후 `get_agent` 로 다시 읽어, 보낸 field 가 silently drop 되지 않았는지 확인한다.

## Node selection guide

아래는 설계 판단용 요약이다. 정확한 JSON shape 는 schema endpoint 결과를 따른다.

| Node | 선택 기준 |
|---|---|
| `begin` | flow 시작점. 보통 첫 실행 node 로 연결한다. |
| `conversation` | 고객 발화를 듣고 LLM 이 응답하거나 exit 조건을 판단해야 하는 대화 단계. |
| `condition` | 이미 추출된 변수나 API 응답 값을 deterministic logic 으로 분기할 때. 고객 발화를 직접 해석하는 용도가 아니다. |
| `extraction` | 이전 대화 컨텍스트에서 이름, 주문번호, 의사 여부 같은 변수를 추출할 때. |
| `api` | 외부 HTTP API 호출과 응답 변수 추출이 필요할 때. |
| `tool` | vox.ai 에 등록된 custom tool 을 실행할 때. built-in tool 설정은 agent `data` schema 를 별도로 확인한다. |
| `transferCall` | 외부 전화번호나 SIP 대상으로 통화를 전환할 때. |
| `transferAgent` | 같은 조직 내 다른 vox.ai agent 로 대화를 넘길 때. |
| `sendSms` | 통화 중 SMS/LMS/MMS 를 발송할 때. |
| `endCall` | 종료 발화 후 통화를 끝내거나 즉시 종료할 때. |
| `note` | editor 설명용 메모. runtime 실행 흐름에는 넣지 않는다. |

## Edge and transition rules

- 노드 내부에 구 v2 `transitions[]`, `logicalTransitions[]` 같은 legacy field 를 임의로 넣지 않는다. schema endpoint 가 노출하는 형태만 따른다.
- 분기는 `edges[].condition` 으로 표현한다. condition 의 정확한 union shape 는 schema endpoint 를 확인한다.
- fallback 은 자동으로 생긴다고 가정하지 않는다. JSON 을 보낼 때 필요한 fallback path 는 `edges` 안에 명시한다.
- `position`, `viewport`, `targetHandle`, animated edge 등 layout/editor field 는 API payload 기준이 아니다. 필요 여부는 schema endpoint 와 round-trip 결과로만 판단한다.
- **edge 가 web editor 에 안 그려지는 가장 흔한 원인은 `edge.sourceHandle` 이 source 노드의 transition.id 와 매칭이 안 될 때다.** schema endpoint 가 transition 을 노출하면 매칭을 정확히 유지한다 ([`hidden-contracts.md` §4](hidden-contracts.md#4-edge--transition-매칭은-sourcehandle--transitionid)).

## High-risk nodes

아래 node 는 schema 표면만 보고는 알 수 없는 contract 가 있어 작성 전 schema endpoint + [`hidden-contracts.md`](hidden-contracts.md) 를 같이 본다.

- `begin`: outgoing edge 에 transitions 를 넣지 않는다. `condition.type=ai` 또는 `skip_user_response=true` 를 보내도 server 가 silently `fallback` + `false` 로 강제 ([`hidden-contracts.md` §1](hidden-contracts.md#1-응답-비기대형-노드의-outgoing-transition-skip_user_responsetrue), §5).
- `conversation`: outgoing edge 에 `condition.type="fallback"` 사용 금지. 거절/예외도 ai condition 자연어로 ([`hidden-contracts.md` §5](hidden-contracts.md#5-fallback-은-응답-비기대형-분기-노드에서만)). first_message 와 변수 값의 어휘 중복 회피는 `conversation-markdown.md` 참조.
- `extraction`: outgoing edge 의 `skip_user_response=true` 명시 누락 시 통화 데드락 (`flow_error`). 변수 정규화는 빌트인 미지원 — description 에 형식 + 예시 필수 ([`hidden-contracts.md` §1, §11](hidden-contracts.md#1-응답-비기대형-노드의-outgoing-transition-skip_user_responsetrue)).
- `condition`: node `data` 안에 분기 조건을 넣지 않는다. 분기 조건은 edge condition. **`LogicCondition.value` 는 항상 string** — boolean 변수 비교는 ai condition 으로 우회 ([`hidden-contracts.md` §2](hidden-contracts.md#2-logiccondition-value-는-string--boolean-비교-우회)).
- `api`: 지원 HTTP method, auth, body, response variable shape 를 schema 결과에서 확인한다. 임의로 `PATCH` 등을 추가하지 않는다. **`api_configuration` default 8 필드 모두 명시** 하지 않으면 web editor 크래시. plain text 응답은 `json_path="$"` + 후속 prompt 정제 ([`hidden-contracts.md` §3, §12](hidden-contracts.md#3-api-노드-api_configuration-default-필드-모두-명시)).
- `transferCall`: 번호 미정 시 placeholder + 사용자 후속 작업 안내. 빈 값 금지.
- `transferAgent`: **`agentId` 는 int 내부 ID** — `list_agents()` UUID 가 아님. placeholder `agentId: 0` 후 사용자가 web editor 에서 선택 ([`hidden-contracts.md` §7](hidden-contracts.md#7-transferagentagentid-는-int-내부-id)).
- `sendSms`: schema 검증 약함. `prompt_type` / `prompt` 또는 `static_sentence` + `static_title` / outgoing edge `skip_user_response=true` 모두 직접 명시 ([`hidden-contracts.md` §10](hidden-contracts.md#10-sendsms-노드는-schema-검증이-약하므로-필수-필드-모두-명시)).
- `tool`: built-in tool 과 custom tool 을 섞지 않는다. custom tool 실행 node 와 agent `data.builtInTools` 설정은 별도 schema surface 다.

flow_data 의 변수명은 flow 전체에서 유일하게 ([`hidden-contracts.md` §8](hidden-contracts.md#8-변수명은-flow-전체에서-유일하게)). 노드/transition id 는 nanoid 또는 UUID 권장 ([`hidden-contracts.md` §9](hidden-contracts.md#9-노드transition-id-는-nanoid-또는-uuid)).

## Review checklist

1. `get_schema(namespace="flow-schema", schema_type="flow-data")` 를 호출했는가?
2. schema 결과에 없는 field 를 과거 문서나 UI 기억만으로 넣지 않았는가?
3. fallback, failure, else path 를 필요한 `edges` 로 명시했는가?
4. `create_agent` / `update_agent` 후 `get_agent` 로 round-trip 확인했는가?
5. 응답에서 사라진 field 가 있다면, 해당 field 를 제거하거나 schema 결과 기준으로 다시 작성했는가?
