# vox.ai Skills

vox.ai 개발자를 위한 Codex/Claude plugin + Agent Skills 레포입니다.

## 설치

### OpenAI Codex Plugin (권장)

이 repo는 Codex workspace install 구조를 이미 포함합니다. repo root에서 Codex를 열고 plugin을 설치하세요.

```bash
git clone https://github.com/vox-public/vox-skills.git
cd vox-skills
codex
```

Codex 안에서:

1. `/plugins` 실행
2. marketplace에서 `vox.ai Plugins` 선택
3. `vox-ai` 설치
4. 필요하면 OAuth 로그인 완료

Plugin 설치 후 MCP 서버와 스킬이 함께 활성화됩니다.

repo를 clone한 뒤 Codex가 이미 열려 있었다면 재시작하세요.

### Claude Code Plugin

```bash
# 1. marketplace 등록
/plugin marketplace add vox-public/vox-skills

# 2. plugin 설치
/plugin install vox-ai@vox-ai
```

한 번의 설치로 MCP 서버 + Skills가 모두 제공됩니다.

### MCP 직접 등록 (대안)

```bash
# Codex MCP
codex mcp add vox --url https://mcp.tryvox.co/
codex mcp login vox

# Claude Code MCP
claude mcp add --transport http vox https://mcp.tryvox.co/

# Skills
npx skills add https://github.com/vox-public/vox-skills --skill using-vox-skills
```

설치 전에 레포에 포함된 스킬 목록을 확인하려면:

```bash
npx skills add https://github.com/vox-public/vox-skills --list
```

## Available Skills

### using-vox-skills (router)

vox.ai 관련 요청의 routing entrypoint. 요청 내용에 따라 아래 domain skill을 자동 선택합니다.

- `skills/using-vox-skills/SKILL.md`

### vox-onboarding

첫 사용자 온보딩. 에이전트 생성 → 아웃바운드 테스트 → 인바운드 설정까지 안내합니다.

- MCP 서버 연결 설정 (Claude/Cursor/ChatGPT/VS Code/Codex/OpenCode)
- `skills/vox-onboarding/SKILL.md`

### vox-agents

프롬프트 에이전트(single prompt) 설계와 공통 음성 UX 규칙을 담당합니다.

- 신규 프롬프트 작성 워크플로우 + 한국어 템플릿
- 실패 사례 원인 진단 → 리팩터링
- agent.data 스키마 (MCP create_agent/update_agent)
- Agent Type 판단 (prompt vs flow) + flow handoff
- `skills/vox-agents/SKILL.md`

### vox-flow

플로우 에이전트 설계를 담당합니다. vox-agents의 확장 스킬입니다.

- 10종 node type 설계/설정
- 스크립트 → Mermaid flowchart → flow node 변환
- 변수 시스템 (extraction → condition 체인)
- 설계물 체크리스트 기반 리뷰
- `skills/vox-flow/SKILL.md`

### vox-tools

vox.ai 에이전트의 빌트인/커스텀 도구 관리를 담당합니다.

- 빌트인 도구: end_call, transfer_call, transfer_agent, send_sms, send_dtmf
- 커스텀 도구 (API/MCP type) 생성/연결/해제
- `skills/vox-tools/SKILL.md`

### vox-web-app

vox.ai 웹 앱(`tryvox.co/dashboard`) 사용 가이드. 다른 스킬에서 UI 안내가 필요할 때도 참조됩니다.

- 구축(build): agents, voice, tools, knowledge
- 배포(deploy): numbers, single/batch outbound
- 모니터링(monitor): analytics, history, alerts
- 설정(settings): workspace, billing, member, api-key, webhook, sms, profile
- 딥링크 치트시트 (`?new=1`, `?clone=true`, `?create=api` 등)
- Chrome MCP extension으로 화면 보며 안내 지원
- `skills/vox-web-app/SKILL.md`

## MCP Servers

이 플러그인은 두 개의 MCP 서버를 연결합니다:

| Name | URL | 역할 |
|------|-----|------|
| `vox` | `https://mcp.tryvox.co/` | 플랫폼 도구 (에이전트, 통화, 조직 등) |
| `vox-docs` | `https://docs.tryvox.co/mcp` | 공식 문서 검색 (search + get_page) |
