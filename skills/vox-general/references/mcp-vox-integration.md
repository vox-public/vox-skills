# vox MCP Integration (Streamable HTTP)

## Canonical Facts

- Server URL: `https://mcp.tryvox.co/`
- Transport: Streamable HTTP
- Auth: OAuth (user-scope) OR API token (org-scope)

## Policy (짧게)

- 기본 제안: OAuth
- 사용자가 API token을 원하면 해당 방식 안내
- API token은 `Authorization: Bearer ${VOX_API_KEY}` 헤더 사용
- 클라이언트가 헤더를 지원하지 않으면 OAuth만 안내

## 클라이언트 호환성

| 클라이언트 | OAuth | API token | 비고 |
|---|---|---|---|
| Claude Desktop/Web | O | -- | Connectors UI는 OAuth 전용 |
| Claude Code | O | O | `--header` 플래그 |
| ChatGPT | O | -- | Developer mode OAuth 전용 |
| OpenAI Codex | O | O | Plugin 또는 MCP 설정 |
| OpenCode | O | O | `headers` 객체 |
| Cursor | O | O | `headers` 객체 |
| VS Code Copilot | O | O | `${input:}` 변수 |

## Quick Navigation

- [Claude Desktop / Claude Web](#claude-desktop--claude-web)
- [Claude Code (CLI)](#claude-code-cli)
- [ChatGPT (Developer mode)](#chatgpt-developer-mode)
- [OpenAI Codex](#openai-codex)
- [OpenCode](#opencode)
- [Cursor](#cursor)
- [VS Code Copilot](#vs-code-copilot)

## 공통 준비

- `VOX_API_KEY`는 vox.ai dashboard에서 발급 (org-scope)
- 환경변수로 주입 권장

## Claude Desktop / Claude Web

### OAuth (기본)

1. Settings → Connectors → Add custom connector
2. URL: `https://mcp.tryvox.co/`
3. Connect/Authenticate 완료

### API token (요청 시)

- Connectors UI는 OAuth 전용이므로 API token 헤더 주입이 불가하다.
- API token이 필요하면 Claude Code 사용을 권장한다.

## Claude Code (CLI)

### OAuth (기본)

```bash
claude mcp add --transport http vox https://mcp.tryvox.co/
```

추가 후 채팅에서 `/mcp` 명령으로 연결 상태를 확인한다.

### API token (요청 시)

```bash
export VOX_API_KEY="sk_...redacted..."
claude mcp add --transport http vox-token https://mcp.tryvox.co/ \
  --header "Authorization: Bearer ${VOX_API_KEY}"
```

## ChatGPT (Developer mode)

### OAuth (기본)

1. Settings → Apps → Advanced settings → Developer mode
2. Create app → MCP server URL: `https://mcp.tryvox.co/`
3. OAuth 로그인

### API token (요청 시)

- Developer mode는 OAuth 또는 No Auth만 지원한다.
- API token이 필요하면 다른 클라이언트(Claude Code, Cursor 등) 사용을 권장한다.

## OpenAI Codex

### Plugin 설치 (권장)

```bash
git clone https://github.com/vox-public/vox-skills.git
cd vox-skills
codex
```

Codex 안에서 `/plugins`를 실행하고 `vox.ai Plugins` marketplace에서 `vox-ai`를 설치한다.

- 이 방식은 vox.ai MCP 서버와 best-practice skills를 함께 제공한다.
- repo를 clone한 뒤 Codex가 이미 열려 있었다면 재시작한다.

### MCP 직접 등록 - OAuth (대안)

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

## VS Code Copilot

### OAuth (기본)

`.vscode/mcp.json`:

```json
{
  "servers": {
    "vox": {
      "type": "http",
      "url": "https://mcp.tryvox.co/"
    }
  }
}
```

### API token (요청 시)

`.vscode/mcp.json`:

```json
{
  "servers": {
    "vox": {
      "type": "http",
      "url": "https://mcp.tryvox.co/",
      "headers": {
        "Authorization": "Bearer ${input:vox-api-key}"
      }
    }
  },
  "inputs": [
    {
      "id": "vox-api-key",
      "type": "promptString",
      "description": "vox API Key (sk_...)",
      "password": true
    }
  ]
}
```
