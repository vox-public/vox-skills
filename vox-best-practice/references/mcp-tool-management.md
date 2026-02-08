# MCP 도구 관리 가이드

vox MCP 서버를 통해 에이전트에 도구를 조회/생성/장착/해제하는 방법을 다룹니다.

## 개요

vox.ai 에이전트는 두 종류의 도구를 사용합니다.

| 구분 | 빌트인 도구 | 커스텀 도구 |
|------|------------|------------|
| 종류 | `end_call`, `transfer_call`, `transfer_agent` (active 기준) | `api`, `mcp` |
| 범위 | 플랫폼 전체 공통 | 조직(organization) 단위 |
| 생성 | 불가 (플랫폼 제공) | `create_custom_tool()` |
| 에이전트 연결 | `update_agent(add_built_in_tool={...})` | `update_agent(add_tool_id="uuid")` |

- **빌트인 도구**: 플랫폼이 제공하는 기본 도구. 에이전트에 직접 설정(파라미터)을 지정하여 장착합니다.
  - 상세: See [references/mcp-built-in-tools.md](mcp-built-in-tools.md)
- **커스텀 도구**: 조직이 직접 만드는 도구. `api` 타입(HTTP 엔드포인트 호출)과 `mcp` 타입(외부 MCP 서버 연결)이 있습니다.
  - 상세: See [references/mcp-custom-tools.md](mcp-custom-tools.md)

## End-to-end 워크플로우

에이전트에 빌트인 + 커스텀 도구를 모두 장착하는 전체 흐름입니다.

### 1. 빌트인 도구 카탈로그 확인

```
list_built_in_tools()
```

### 2. 에이전트 생성

```
create_agent(name="CS 상담 에이전트", prompt="당신은 CS 상담 에이전트입니다...")
```

### 3. 빌트인 도구 장착

```
update_agent(
  agent_id="agent-uuid",
  add_built_in_tool={"toolType": "end_call", "name": "end_call", "description": "통화를 종료합니다."}
)

update_agent(
  agent_id="agent-uuid",
  add_built_in_tool={
    "toolType": "transfer_call", "name": "transfer_to_human",
    "transferConfiguration": [{"transferType": "phone", "transferTo": "010-1234-5678"}],
    "transferType": "cold"
  }
)
```

한 번의 호출에 `add_built_in_tool` 하나만 추가 가능. 여러 도구는 여러 번 호출.

### 4. 커스텀 도구 생성 & 연결

```
create_custom_tool(
  name="check_order", tool_type="api",
  data={
    "apiConfiguration": {
      "url": "https://api.example.com/orders",
      "method": "GET",
      "timeoutSeconds": 10
    },
    "parameters": {"type": "object", "properties": {"order_id": {"type": "string"}}, "required": ["order_id"]}
  },
  description="주문 상태 조회"
)

update_agent(agent_id="agent-uuid", add_tool_id="tool-uuid")
```

### 5. 확인

```
get_agent(agent_id="agent-uuid")
```

`data.builtInTools`와 `data.toolIds`를 확인.

## 주의사항

### name 규칙

- 영문/숫자/`_`/`-`만 허용, 1-64자
- 정규식: `^[A-Za-z0-9_-]{1,64}$`
- 에이전트 내 name 중복 금지 (중복 시 에러)

### 예약어

도구 이름으로 사용 불가: `extract_variables`, `request_api`, `retrieve_knowledge`, `determine_transition`

### 도구 장착 순서

`update_agent`의 도구 파라미터(`add_built_in_tool`, `remove_built_in_tool`, `add_tool_id`, `remove_tool_id`)는 한 호출에 각각 하나씩만 전달 가능. 여러 도구는 여러 번 호출.

### 커스텀 도구 삭제

현재 MCP를 통한 커스텀 도구 삭제 API는 미제공. vox.ai 대시보드에서 수행.
