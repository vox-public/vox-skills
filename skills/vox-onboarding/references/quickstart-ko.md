# vox.ai 빠른 시작 가이드

## 설치

```
npx skills add https://github.com/vox-public/vox-skills --skill vox
```

## MCP 서버 연결

vox.ai MCP 서버 URL: `https://mcp.tryvox.co/`

### Claude Code

OAuth (기본):
```bash
claude mcp add --transport http vox https://mcp.tryvox.co/
```

API 토큰:
```bash
export VOX_API_KEY="sk_..."
claude mcp add --transport http vox https://mcp.tryvox.co/ \
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
codex mcp add vox --url https://mcp.tryvox.co/
codex mcp login vox
```

API 토큰 — `~/.codex/config.toml`:
```toml
[mcp_servers.vox]
url = "https://mcp.tryvox.co/"
bearer_token_env_var = "VOX_API_KEY"
```

### Cursor

설정 → MCP → 추가:
```json
{
  "url": "https://mcp.tryvox.co/",
  "headers": { "Authorization": "Bearer ${env:VOX_API_KEY}" }
}
```

### VS Code Copilot

`.vscode/mcp.json`:
```json
{
  "servers": {
    "vox": {
      "url": "https://mcp.tryvox.co/",
      "headers": { "Authorization": "Bearer ${input:vox_api_key}" }
    }
  }
}
```

## 사용

설치 + 연결 후:

1. `/vox` 입력 → 가이드 시작
2. 또는 직접: "에이전트 만들어줘" → "전화 걸어줘"

## 사용 가능한 MCP 도구

| 도구 | 설명 |
|------|------|
| `list_agents` | 에이전트 목록 |
| `create_agent` | 에이전트 생성 |
| `update_agent` | 에이전트 수정 |
| `get_agent` | 에이전트 상세 |
| `create_call` | 아웃바운드 콜 |
| `list_calls` | 통화 기록 |
| `get_call` | 통화 상세 |
| `list_available_telephone_numbers` | 구매 가능 번호 |
| `create_telephone_number` | 번호 구매 |
| `list_telephone_numbers` | 보유 번호 |
| `update_telephone_number` | 번호 설정 (에이전트 연결) |
| `create_campaign` | 대량 발신 캠페인 |
| `list_campaigns` | 캠페인 목록 |
