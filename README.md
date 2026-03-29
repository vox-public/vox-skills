# vox.ai Skills

vox.ai 개발자를 위한 Codex/Claude plugin + Agent Skills 레포입니다.

## 설치

### OpenAI Codex Plugin (권장)

이 repo는 Codex workspace install 구조를 이미 포함합니다. repo root에서 Codex를 열고 plugin을 설치하세요.

```bash
git clone https://github.com/fleek-fitness/vox-skills.git
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
/plugin marketplace add fleek-fitness/vox-skills

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
npx skills add https://github.com/fleek-fitness/vox-skills --skill vox-best-practice
```

설치 전에 레포에 포함된 스킬 목록을 확인하려면:

```bash
npx skills add https://github.com/fleek-fitness/vox-skills --list
```

## Available Skills

### using-vox-best-practice (router)

vox.ai 관련 요청의 routing entrypoint. 요청 내용에 따라 아래 domain skill을 자동 선택합니다.

- `skills/using-vox-best-practice/SKILL.md`

### vox-single-agent

한국어 음성(single prompt) 에이전트의 system prompt 설계/작성/리팩터링/진단을 담당합니다.

- 신규 프롬프트 작성 워크플로우 + 한국어 템플릿
- 실패 사례 원인 진단 → 리팩터링
- agent.data 스키마 (MCP create_agent/update_agent)
- `skills/vox-single-agent/SKILL.md`

### vox-flow-agent

여러 node를 연결해 대화 흐름을 제어하는 flow agent 설계를 담당합니다.

- Flow vs Single Prompt 판단 기준
- 10종 node type 설계/설정
- 스크립트 → flow node 변환
- 변수 시스템 (extraction → condition 체인)
- `skills/vox-flow-agent/SKILL.md`

### vox-tool

vox.ai 에이전트의 빌트인/커스텀 도구 관리를 담당합니다.

- 빌트인 도구: end_call, transfer_call, transfer_agent, send_sms, send_dtmf
- 커스텀 도구 (API/MCP type) 생성/연결/해제
- `skills/vox-tool/SKILL.md`

### vox-general

vox.ai 플랫폼 요금 체계와 MCP 서버 연결 설정을 담당합니다.

- 구독 플랜/요금/빌링 안내
- vox MCP 서버를 Claude/Cursor/ChatGPT/VS Code/Codex/OpenCode에 연결
- `skills/vox-general/SKILL.md`
