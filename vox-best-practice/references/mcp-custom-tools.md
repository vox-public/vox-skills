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
| `data` | 선택 | 도구 설정 (타입별 구조 다름) |
| `description` | 선택 | 도구 설명 |

### api 도구 data

HTTP 엔드포인트를 호출하는 도구:

```json
{
  "url": "https://api.example.com/reservations",
  "method": "GET",
  "headers": {"Authorization": "Bearer {{api_token}}"},
  "timeoutInSeconds": 5,
  "parameters": {
    "type": "object",
    "properties": {"reservation_id": {"type": "string", "description": "예약 번호"}},
    "required": ["reservation_id"]
  }
}
```

### mcp 도구 data

외부 MCP 서버에 연결하는 도구:

```json
{
  "serverUrl": "https://mcp.example.com/",
  "toolName": "search_products",
  "headers": {"Authorization": "Bearer {{mcp_token}}"}
}
```

## 에이전트 연결: update_agent(add_tool_id="uuid")

```
update_agent(agent_id="agent-uuid", add_tool_id="tool-uuid")
```

`list_custom_tools()` 또는 `create_custom_tool()` 응답의 `uid`를 전달합니다. 이미 연결된 도구는 중복 추가되지 않습니다.

## 에이전트 해제: update_agent(remove_tool_id="uuid")

```
update_agent(agent_id="agent-uuid", remove_tool_id="tool-uuid")
```

## 참고

- 커스텀 도구 삭제 API는 현재 MCP 미제공. vox.ai 대시보드에서 수행.
