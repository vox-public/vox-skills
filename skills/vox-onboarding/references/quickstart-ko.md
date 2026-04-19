# vox.ai MCP 수동 연결 가이드

이 문서는 **Plugin을 사용하지 않고** vox.ai MCP 서버에 직접 연결하려는 사용자를 위한 reference다. 대부분의 사용자는 [AI 앱 연동 개요](https://docs.tryvox.co/docs/ai/overview)를 따라 Plugin을 설치하면 되고, Plugin이 `.mcp.json`으로 MCP 연결을 자동 구성한다.

## MCP 서버 연결

vox.ai MCP 서버 URL: `https://mcp.tryvox.co/mcp`

### Claude Code

OAuth (기본):
```bash
claude mcp add --transport http vox https://mcp.tryvox.co/mcp
```

API 토큰:
```bash
export VOX_API_KEY="sk_..."
claude mcp add --transport http vox https://mcp.tryvox.co/mcp \
  --header "Authorization: Bearer ${VOX_API_KEY}"
```

### OpenAI Codex

Plugin (권장):
```bash
git clone https://github.com/vox-public/vox-skills.git
cd vox-skills
codex
```

Codex 안에서 `/plugins`를 실행하고 `vox.ai Plugins` marketplace에서 `vox-ai`를 설치하세요.

MCP 직접 등록 - OAuth:
```bash
codex mcp add vox --url https://mcp.tryvox.co/mcp
codex mcp login vox
```

API 토큰 — `~/.codex/config.toml`:
```toml
[mcp_servers.vox]
url = "https://mcp.tryvox.co/mcp"
bearer_token_env_var = "VOX_API_KEY"
```

### Cursor

설정 → MCP → 추가:
```json
{
  "url": "https://mcp.tryvox.co/mcp",
  "headers": { "Authorization": "Bearer ${env:VOX_API_KEY}" }
}
```

### VS Code Copilot

`.vscode/mcp.json`:
```json
{
  "servers": {
    "vox": {
      "url": "https://mcp.tryvox.co/mcp",
      "headers": { "Authorization": "Bearer ${input:vox_api_key}" }
    }
  }
}
```

## 사용

연결 후 AI 앱에서 vox.ai MCP 도구가 보이면 연결 완료다. 확인: "vox.ai 에이전트 목록을 보여줘"라고 요청해 `list_agents`가 실행되면 정상이다.

Plugin을 설치한 경우에는 `/vox-ai:vox-onboarding`(Claude Code/Codex/Cowork) 또는 "에이전트 만들어줘" 같은 자연어 요청으로 온보딩이 시작된다.

## 공개 MCP 도구 (Phase 1)

아래는 공개 surface(`PUBLIC_TOOL_NAMES`)에 노출되는 도구다.

| 도구 | 설명 |
|------|------|
| `list_organizations` | 소속 조직 목록과 current/default 조직 확인 |
| `set_organization` | 현재 세션의 활성 조직 전환 |
| `list_agents` | 에이전트 목록 |
| `get_agent` | 에이전트 상세 |
| `create_agent` | 에이전트 생성 |
| `update_agent` | 에이전트 수정 |
| `list_calls` | 통화 기록 |
| `get_call` | 통화 상세 |
| `create_call` | 아웃바운드 콜 |
| `list_built_in_tools` | 빌트인 도구 목록 |
| `list_custom_tools` | 커스텀 도구 목록 |
| `create_custom_tool` | 커스텀 도구 생성 |
| `list_telephone_numbers` | 보유 번호 조회 (read-only) |

번호 구매, 번호-에이전트 연결, 대량 발신 캠페인은 이 phase에서 공개 MCP 도구가 없다. 웹 앱(`https://www.tryvox.co/dashboard/{organizationId}/numbers`)에서 수행한다.
