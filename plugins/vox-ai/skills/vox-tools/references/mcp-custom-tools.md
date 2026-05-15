# 커스텀 도구 레퍼런스

조직 단위 커스텀 도구(api, mcp)의 조회, 생성, 에이전트 연결/해제입니다.

## 조회: list_custom_tools(organization_id)

```
list_custom_tools(organization_id="org-uuid")
```

| 파라미터 | 필수 | 설명 |
|---------|------|------|
| `organization_id` | 선택 | 미지정 시 기본 조직 사용 |

응답 예시:

```json
{
  "organization_id": "org-uuid",
  "tools": [
    {"uid": "tool-uuid", "name": "check_order_status", "tool_type": "api", "description": "주문 상태 조회"}
  ],
  "count": 1
}
```

## 생성: create_custom_tool(...)

```
create_custom_tool(name="check_reservation", tool_type="api", data={...}, description="예약 상태 조회")
```

| 파라미터 | 필수 | 설명 |
|---------|------|------|
| `organization_id` | 선택 | 미지정 시 기본 조직 사용 |
| `name` | 필수 | 도구 이름 (영문/숫자/`_`/`-`, 1-64자) |
| `tool_type` | 필수 | `"api"` 또는 `"mcp"` |
| `data` | 선택 | 도구 설정 (타입별 구조 다름, api 타입은 apiConfiguration 필수) |
| `description` | 선택 | 도구 설명 |

### api 도구 data

HTTP 엔드포인트를 호출하는 도구. `apiConfiguration` 내 `url`, `method` 필수:

```json
{
  "apiConfiguration": {
    "url": "https://api.example.com/reservations",
    "method": "GET",
    "timeoutSeconds": 5,
    "headers": {"Authorization": "Bearer {{api_token}}"},
    "headersEnabled": true
  },
  "parameters": {
    "type": "object",
    "properties": {"reservation_id": {"type": "string", "description": "예약 번호"}},
    "required": ["reservation_id"]
  }
}
```

### mcp 도구 data

외부 MCP 서버에 연결하는 도구. `data`는 빈 객체 `{}` 가능, `apiConfiguration` 선택:

```json
{
  "apiConfiguration": {
    "url": "https://mcp.example.com/",
    "timeoutSeconds": 5,
    "headers": {"Authorization": "Bearer {{mcp_token}}"},
    "headersEnabled": true
  }
}
```

## 에이전트 연결: update_agent(toolIds=[...])

```
update_agent(agent_id="agent-uuid", toolIds=["tool-uuid"])
```

`list_custom_tools()` 또는 `create_custom_tool()` 응답의 `uid`를 `toolIds` 배열에 넣어 전달합니다.

## 에이전트 해제: update_agent(toolIds=[...])

```
update_agent(agent_id="agent-uuid", toolIds=[])
```

`toolIds`는 교체(replace) 방식입니다. 일부만 변경할 때는 `get_agent()`로 현재 `data.toolIds`를 조회한 뒤 원하는 항목을 추가/제거한 전체 배열을 다시 저장하세요.

## 참고

- 커스텀 도구 삭제: `delete_custom_tool(tool_id="uuid")`
- `timeoutSeconds` 기본값: api=10초, mcp=5초 (1-60 범위)
