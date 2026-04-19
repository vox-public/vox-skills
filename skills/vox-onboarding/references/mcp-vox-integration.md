# vox MCP Integration (Streamable HTTP)

## Canonical Facts

- Server URL: `https://mcp.tryvox.co/mcp`
- Transport: Streamable HTTP
- Auth: **OAuth only (user-scope)**. vox MCP는 API token / `Authorization: Bearer` 헤더 방식을 지원하지 않는다.

## Policy (짧게)

- 모든 클라이언트에서 OAuth로 연결한다.
- 클라이언트가 OAuth를 지원하지 않으면 vox MCP에 연결할 수 없다. OAuth 지원 클라이언트 사용을 안내한다.
- 첫 vox MCP 도구 호출 시 브라우저에서 로그인 창이 열린다.

## 클라이언트 호환성

| 클라이언트 | OAuth 지원 | 비고 |
|---|---|---|
| Claude Desktop/Web | O | Connectors UI로 추가 |
| Claude Code | O | `claude mcp add --transport http` |
| ChatGPT | O | Developer mode |
| OpenAI Codex | O | Plugin(권장) 또는 `codex mcp add` |
| OpenCode | O | `opencode.jsonc` remote MCP |
| Cursor | O | `.cursor/mcp.json` |
| VS Code Copilot | O | `.vscode/mcp.json` |

## Quick Navigation

- [Claude Desktop / Claude Web](#claude-desktop--claude-web)
- [Claude Code (CLI)](#claude-code-cli)
- [ChatGPT (Developer mode)](#chatgpt-developer-mode)
- [OpenAI Codex](#openai-codex)
- [OpenCode](#opencode)
- [Cursor](#cursor)
- [VS Code Copilot](#vs-code-copilot)

## Claude Desktop / Claude Web

1. Settings → Connectors → Add custom connector
2. URL: `https://mcp.tryvox.co/mcp`
3. Connect/Authenticate 완료

## Claude Code (CLI)

```bash
claude mcp add --transport http vox https://mcp.tryvox.co/mcp
```

추가 후 채팅에서 `/mcp` 명령으로 연결 상태를 확인한다. 첫 vox 도구 호출 시 OAuth 로그인 창이 뜬다.

## ChatGPT (Developer mode)

1. Settings → Apps → Advanced settings → Developer mode
2. Create app → MCP server URL: `https://mcp.tryvox.co/mcp`
3. OAuth 로그인

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

### MCP 직접 등록 (대안)

```bash
codex mcp add vox --url https://mcp.tryvox.co/mcp
codex mcp login vox
```

## OpenCode

`opencode.jsonc`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "vox": { "type": "remote", "url": "https://mcp.tryvox.co/mcp" }
  }
}
```

필요 시:

```bash
opencode mcp auth vox
```

## Cursor

`~/.cursor/mcp.json` 또는 `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "vox": { "url": "https://mcp.tryvox.co/mcp" }
  }
}
```

## VS Code Copilot

`.vscode/mcp.json`:

```json
{
  "servers": {
    "vox": {
      "type": "http",
      "url": "https://mcp.tryvox.co/mcp"
    }
  }
}
```
