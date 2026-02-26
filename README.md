# vox.ai Skills

vox.ai 개발자를 위한 Agent Skills 모음 레포입니다.

## Install

이 레포의 스킬을 설치하려면:

```bash
npx skills add https://github.com/fleek-fitness/vox-skills --skill vox-best-practice
```

설치 전에 레포에 포함된 스킬 목록을 확인하려면:

```bash
npx skills add https://github.com/fleek-fitness/vox-skills --list
```

## Available skills

### vox-best-practice

vox.ai 개발자를 위한 올인원 스킬입니다:

- 한국어 음성(single prompt) 에이전트 system prompt 설계/작성/리팩터링
- vox MCP 서버(https://mcp.tryvox.co/, OAuth/API token)를 ChatGPT/Claude/Cursor/OpenCode/Codex/VS Code 등 MCP 클라이언트에 연결
- (MCP 연결 시) call_id로 통화 로그/에이전트 프롬프트를 가져와 진단 → 리팩터링 → update_agent(prompt=...) 반영까지 (설정/스키마는 `vox-best-practice/references/agent-data-reference.md` 참고)
- `vox-best-practice/SKILL.md`
