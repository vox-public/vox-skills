# vox MCP Integration (Streamable HTTP)

## Canonical Facts

- Server URL: `https://mcp.tryvox.co/`
- Transport: Streamable HTTP
- Auth: OAuth (user-scope) OR API token (org-scope)

## Policy (짧게)

- 기본 제안: OAuth
- 사용자가 API token을 원하면 해당 방식 안내
- API token은 `Authorization: Bearer ${VOX_API_KEY}` 헤더 사용
- 클라이언트가 헤더를 못 붙이면 프록시(mcp-remote 등)로 헤더 주입

## Quick Navigation

- [Claude Desktop / Claude Web](#claude-desktop--claude-web)
- [Claude Code (CLI)](#claude-code-cli)
- [ChatGPT (Developer mode)](#chatgpt-developer-mode)
- [OpenAI Codex](#openai-codex)
- [OpenCode](#opencode)
- [Cursor](#cursor)

## 공통 준비

- `VOX_API_KEY`는 vox.ai dashboard에서 발급 (org-scope)
- 환경변수로 주입 권장

## Claude Desktop / Claude Web

### OAuth (기본)

1. Settings → Connectors → Add custom connector
2. URL: `https://mcp.tryvox.co/`
3. Connect/Authenticate 완료

### API token (요청 시)

- Claude는 authless 또는 OAuth remote MCP만 지원한다.
- API token은 직접 헤더 주입이 불가하므로, 프록시를 원격에 띄워 헤더를 주입한 뒤 그 URL을 No Auth로 추가한다.

## Claude Code (CLI)

### OAuth (기본)

```bash
claude mcp add --transport http vox https://mcp.tryvox.co/
> /mcp
```

### API token (요청 시)

```bash
export VOX_API_KEY="sk_...redacted..."
claude mcp add vox-token -- npx -y mcp-remote https://mcp.tryvox.co/ --header "Authorization: Bearer ${VOX_API_KEY}"
```

## ChatGPT (Developer mode)

### OAuth (기본)

1. Settings → Apps → Advanced settings → Developer mode
2. Create app → MCP server URL: `https://mcp.tryvox.co/`
3. OAuth 로그인

### API token (요청 시)

- Developer mode는 OAuth 또는 No Auth만 지원한다.
- API token은 프록시를 원격에 띄워 헤더를 주입한 뒤 그 URL을 No Auth로 추가한다.

## OpenAI Codex

### OAuth (기본)

```bash
codex mcp add vox --url https://mcp.tryvox.co/
codex mcp login vox
```

### API token (요청 시)

`~/.codex/config.toml`:

```toml
[mcp_servers.vox]
url = "https://mcp.tryvox.co/"
bearer_token_env_var = "VOX_API_KEY"
```

## OpenCode

### OAuth (기본)

`opencode.jsonc`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "vox": { "type": "remote", "url": "https://mcp.tryvox.co/" }
  }
}
```

필요 시:

```bash
opencode mcp auth vox
```

### API token (요청 시)

`opencode.jsonc`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "vox": {
      "type": "remote",
      "url": "https://mcp.tryvox.co/",
      "oauth": false,
      "headers": { "Authorization": "Bearer {env:VOX_API_KEY}" }
    }
  }
}
```

## Cursor

### OAuth (기본)

`~/.cursor/mcp.json` 또는 `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "vox": { "url": "https://mcp.tryvox.co/" }
  }
}
```

### API token (요청 시)

```json
{
  "mcpServers": {
    "vox": {
      "url": "https://mcp.tryvox.co/",
      "headers": { "Authorization": "Bearer ${env:VOX_API_KEY}" }
    }
  }
}
```
