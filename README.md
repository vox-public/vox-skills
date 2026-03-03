# vox.ai Skills

vox.ai 개발자를 위한 Agent Skills 모음 레포입니다.

## 설치

### Claude Code Plugin (권장)

```bash
# 1. marketplace 등록
/plugin marketplace add fleek-fitness/vox-skills

# 2. plugin 설치
/plugin install vox-ai@vox-ai
```

한 번의 설치로 MCP 서버 + Skills가 모두 제공됩니다.

### 수동 설치 (개별)

```bash
# MCP
claude mcp add --transport http vox https://mcp.tryvox.co/

# Skills
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
- (MCP 연결 시) call_id로 통화 로그/에이전트 프롬프트를 가져와 진단 → 리팩터링 → update_agent(prompt={...}) 반영까지 (설정/스키마는 `skills/vox-best-practice/references/agent-data-reference.md` 참고)
- `skills/vox-best-practice/SKILL.md`

### flow-node-creator

vox.ai flow 에이전트의 노드를 생성하는 스킬입니다.

- `skills/flow-node-creator/SKILL.md`
