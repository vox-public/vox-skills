# vox MCP Integration (Streamable HTTP)

## Canonical Facts

- Server URL: `https://mcp.tryvox.co/`
- Transport: Streamable HTTP
- Auth: OAuth (user-scope) OR API token (org-scope)

## Auth Modes (중요)

vox MCP는 크게 2가지 인증 방식을 지원한다.

### 1) OAuth (권장: 일반 사용자/대화형)

- **권한 범위**: 로그인한 사용자가 속한 **모든 org** 대상으로 동작한다.
- **연결 방식**: 클라이언트에서 `https://mcp.tryvox.co/` 를 remote MCP로 추가 → 브라우저에서 로그인/승인(OAuth) → 클라이언트로 복귀.

### 2) API token (권장: 조직 고정/CI/헤드리스)

- **권한 범위**: 해당 **org scope**로만 동작한다.
- **발급 위치**: vox dashboard의 API Key 메뉴에서 발급한다.
- **연결 방식**: 모든 요청에 아래 헤더를 붙인다.
  - `Authorization: Bearer ${VOX_API_KEY}`
- **팁**: 클라이언트가 remote MCP에 custom header를 못 붙이면, `mcp-remote`(local proxy)를 사용해서 “local MCP server” 형태로 붙인다(아래 OpenCode 예시 참고).
- **보안**: API key는 시크릿이다. 레포/설정 파일에 실제 값을 커밋하지 말고 환경변수/시크릿 매니저로 주입한다.

## Quick Navigation

- [OpenCode](#opencode)
- [Cursor](#cursor)
- [Claude Code (CLI)](#claude-code-cli)
- [Claude Desktop / Claude Web](#claude-desktop--claude-web)
- [ChatGPT](#chatgpt)
- [OpenAI Codex](#openai-codex)
- [VS Code Copilot Agent](#vs-code-copilot-agent)
- [Troubleshooting](#troubleshooting)

## 공통 워크플로우

0. OAuth(유저 전체 org) / API token(특정 org) 중 어떤 인증을 쓸지 결정한다.
1. 서버 추가
   - OAuth: `https://mcp.tryvox.co/` 를 **remote MCP 서버**로 추가 → 브라우저 로그인/승인 → 클라이언트로 복귀.
   - API token: `VOX_API_KEY` 준비 → `Authorization: Bearer ${VOX_API_KEY}` 헤더를 붙여 호출.
     - 클라이언트가 헤더를 못 붙이면 `mcp-remote`를 local MCP server로 사용한다.
2. 연결 확인: 서버가 Connected이고, 도구 목록이 보이는지 확인한다.
3. 실패하면 아래 Troubleshooting에서 증상별로 분기한다.

## OpenCode

### 설정 파일 위치

- Global 설정: `~/.config/opencode/opencode.json`
- Project 설정: 프로젝트 루트의 `opencode.json`

### Option A) OAuth (remote)

이미 `mcpServers` 설정이 있으면 **덮어쓰지 말고 병합**한다.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcpServers": {
    "vox": {
      "type": "remote",
      "url": "https://mcp.tryvox.co/",
      "enabled": true
    }
  }
}
```

### OAuth 로그인/인증

원격 MCP 서버가 OAuth를 요구하면, OpenCode에서 인증 플로우를 시작한다.

```bash
opencode mcp auth vox
```

### Option B) API token (local via mcp-remote)

OpenCode에서 org-scoped API token을 쓰려면, `mcp-remote`를 “local MCP server”로 붙이고 Authorization 헤더를 주입한다.

1) vox dashboard에서 API key를 발급하고, 실행 환경에 환경변수로 넣는다:

```bash
export VOX_API_KEY="sk_...redacted..."
```

2) `opencode.jsonc`에 아래처럼 서버를 추가한다(예: `vox-mcp`).

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcpServers": {
    "vox-mcp": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "mcp-remote",
        "https://mcp.tryvox.co/",
        "--header",
        "Authorization: Bearer ${VOX_API_KEY}"
      ],
      "enabled": true
    }
  }
}
```

주의: `environment` 필드로 키를 직접 넣을 수도 있지만(= 파일에 시크릿이 들어감), 레포에 커밋되기 쉬우므로 권장하지 않는다.

### 연결 확인

```bash
opencode mcp list
```

도구가 안 보이거나 인증이 안 된 상태면, `auth`를 다시 시도하거나 앱을 재시작한다.

### 참고(공식 문서)

- OpenCode Config: https://opencode.ai/docs/config
- MCP servers: https://opencode.ai/docs/mcp-servers

## Cursor

### 설정 파일 위치

Cursor는 MCP 서버를 `mcp.json`으로 설정할 수 있다.

- Global 설정: `~/.cursor/mcp.json`
- Project 설정: 프로젝트 루트의 `.cursor/mcp.json`

### vox 서버 추가 (Streamable HTTP / OAuth)

`mcp.json`이 이미 있으면 **`mcpServers` 아래에 병합**한다.

```json
{
  "mcpServers": {
    "vox": {
      "url": "https://mcp.tryvox.co/"
    }
  }
}
```

### OAuth 로그인/인증

vox는 OAuth를 사용한다. Cursor는 OAuth가 필요한 MCP 서버에 대해 인증 UI를 띄우고 브라우저로 로그인/승인을 진행한다.

### 연결 확인(추천)

Cursor Agent CLI가 설치되어 있으면 아래로 확인한다.

```bash
cursor-agent mcp list
cursor-agent mcp list-tools vox
```

UI에서 확인할 때는 Cursor 설정의 MCP 섹션에서 서버 상태/도구 목록을 확인한다.

### 참고(공식 문서)

- Cursor MCP: https://docs.cursor.com/context/mcp
- Cursor Agent CLI MCP: https://docs.cursor.com/en/cli/mcp

## Claude Code (CLI)

Claude Code는 MCP 서버를 CLI 명령으로 추가/관리한다.

### vox 서버 추가 (Streamable HTTP / OAuth)

User(전역) 범위로 추가:

```bash
claude mcp add --transport http --scope user vox https://mcp.tryvox.co/
```

프로젝트 범위로 추가(팀 공유가 필요하면 추천). 실행 위치에 `.mcp.json`이 생성/수정될 수 있다:

```bash
claude mcp add --transport http --scope project vox https://mcp.tryvox.co/
```

### OAuth 로그인/인증

Claude Code에서 `/mcp`를 열고 `vox` 서버에 대해 **Authenticate/Connect**를 진행한다.
(브라우저가 열리면 OAuth 로그인/승인 후 Claude로 돌아온다.)

### 연결 확인

CLI로 서버 목록 확인:

```bash
claude mcp list
claude mcp get vox
```

또는 Claude Code 세션에서 `/mcp` 화면에서 연결 상태/도구 목록을 확인한다.

### 참고(공식 문서)

- Claude Code MCP: https://docs.anthropic.com/en/docs/claude-code/mcp

## Claude Desktop / Claude Web

### 중요한 제한(원격 서버)

Claude Desktop은 **원격(remote) MCP 서버를 `claude_desktop_config.json`에 직접 넣어서는 연결되지 않는다.**
원격 MCP 서버는 **Settings → Connectors**에서 추가해야 한다.

### 사전 조건

- Claude Desktop 또는 claude.ai(웹)에서 “Remote MCP servers” 기능이 활성화된 플랜/계정이어야 한다.

### vox 서버 추가 (Streamable HTTP / OAuth)

1. Claude(Desktop 또는 Web)에서 **Settings → Connectors**로 이동
2. “Add connector / Add MCP server(원격)” 같은 메뉴에서 서버 URL에 아래를 입력
   - `https://mcp.tryvox.co/`
3. Connect/Authenticate를 진행하면 브라우저 OAuth 로그인/승인 화면이 뜬다 → 완료 후 Claude로 복귀

### 연결 확인

- Connectors 목록에서 `vox`가 Connected 상태인지 확인
- 채팅에서 해당 MCP 툴이 노출되는지 확인(도구 버튼/툴 목록 UI)

### 참고(공식 문서)

- Anthropic Help: Getting started with custom connectors using remote MCP: https://support.claude.com/en/articles/11175166-getting-started-with-custom-connectors-using-remote-mcp
- Anthropic Help: Using remote MCP servers: https://support.claude.com/en/articles/11501805549339-using-remote-mcp-servers

## ChatGPT

ChatGPT는 **Developer mode(베타)**를 통해 원격 MCP 서버(Streaming/Streamable HTTP 포함)를 앱으로 추가할 수 있다.

### 사전 조건

- ChatGPT에서 Developer mode를 지원하는 플랜/계정이어야 한다(지원 여부는 ChatGPT 설정에서 확인).

### 1) Developer mode 켜기

1. ChatGPT 웹에서 프로필/아바타 메뉴 → **Settings**
2. **Apps**(또는 Connectors/Apps 섹션)에서 **Developer mode** 토글을 켠다

### 2) vox MCP 서버를 App으로 추가

1. 채팅 입력창에서 도구 선택(Developer mode tool)로 이동
2. “Add an app / Create app”에서 **MCP server**를 선택
3. 서버 URL에 입력:
   - `https://mcp.tryvox.co/`
4. Connect/Authenticate → 브라우저에서 OAuth 로그인/승인 → ChatGPT로 복귀

### 3) 연결 확인

- Developer mode 도구에서 `vox` 앱을 선택했을 때 도구 목록이 보이는지 확인
- 실제 대화에서 “vox를 사용해서 … 해줘” 같은 요청을 했을 때 툴 호출이 되는지 확인

### 참고(공식 문서)

- ChatGPT Developer mode: https://platform.openai.com/docs/guides/developer-mode
- OpenAI MCP 가이드: https://platform.openai.com/docs/docs-mcp

## OpenAI Codex

### CLI로 추가(추천)

```bash
codex mcp add vox --url https://mcp.tryvox.co/
codex mcp login vox
```

`codex mcp login`은 브라우저 OAuth 로그인/승인을 진행하고, 완료되면 토큰을 저장한다.

### 연결 확인

```bash
codex mcp list
```

### config.toml로 설정(대안)

전역 설정 파일: `~/.codex/config.toml`

```toml
[mcp_servers.vox]
url = "https://mcp.tryvox.co/"
```

### 참고(공식 문서)

- Codex MCP: https://developers.openai.com/codex/mcp/
- OpenAI MCP 가이드(클라이언트별 설정 예시): https://platform.openai.com/docs/docs-mcp

## VS Code Copilot Agent

VS Code에서 GitHub Copilot **Agent mode**가 MCP 서버 구성을 지원하는 경우, 프로젝트에 MCP 설정 파일을 추가해 연결할 수 있다.

### 1) 프로젝트에 `.vscode/mcp.json` 추가

프로젝트 루트에 `.vscode/mcp.json` 파일을 만들고 `vox` 서버를 추가한다.

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

### 2) 연결 확인

- VS Code에서 Copilot Agent가 MCP 서버를 인식/로드하는지 확인
- OAuth가 필요한 경우 로그인/승인 플로우가 뜨면 완료 후 다시 시도

### 참고(공식 문서)

- OpenAI MCP 가이드(VS Code 포함 클라이언트별 설정 예시): https://platform.openai.com/docs/docs-mcp

## Troubleshooting

### 증상: 서버/도구가 아예 안 보임

- 설정 파일이 **올바른 위치**에 있는지 확인한다.
  - Cursor: `~/.cursor/mcp.json` 또는 `.cursor/mcp.json`
  - OpenCode: `~/.config/opencode/opencode.json` 또는 `opencode.json`
  - VS Code: `.vscode/mcp.json`
- JSON/TOML 문법 오류가 없는지 확인한다(쉼표, 따옴표, 중괄호).
- 앱/에이전트를 재시작(또는 설정 reload)한다.

### 증상: OAuth 로그인/승인 화면이 안 뜸

- 브라우저 팝업 차단/기본 브라우저 설정을 확인한다.
- CLI라면 `auth/login` 명령이 있는지 확인하고 다시 실행한다.
  - OpenCode: `opencode mcp auth vox`
  - Codex: `codex mcp login vox`
- Claude Desktop은 원격 MCP 서버를 **Settings → Connectors**에서 추가해야 한다(설정 파일로는 안 됨).

### 증상: 401/403 (인증 실패)

- OAuth 토큰이 만료/폐기됐을 수 있다 → 다시 로그인한다.
  - OpenCode: `opencode mcp logout vox` 후 `opencode mcp auth vox`
  - Codex: `codex mcp login vox`
  - Claude Code: `/mcp`에서 해당 서버 Authenticate 재시도
- API token 방식이면 아래를 확인한다.
  - `VOX_API_KEY`가 설정돼 있는지(비어 있으면 `${VOX_API_KEY}`가 그대로 들어가서 실패)
  - 헤더 형식이 정확한지: `Authorization: Bearer <token>`
  - API key는 **org-scoped**이므로, 기대한 org에서 발급한 키가 맞는지

### 증상: 연결은 되는데 호출이 실패(타임아웃/네트워크)

- 네트워크/방화벽/프록시 환경에서 `https://mcp.tryvox.co/` 접근이 가능한지 확인한다.
- Codex 같은 샌드박스 환경이라면 외부 네트워크 접근이 막혀 있을 수 있다(클라이언트 설정에서 network access 허용 필요).

### 빠른 체크리스트

- URL이 정확한가: `https://mcp.tryvox.co/`
- 클라이언트가 Streamable HTTP를 지원하는가(최신 버전 권장)
- OAuth 로그인 완료 후 앱으로 정상 복귀했는가
