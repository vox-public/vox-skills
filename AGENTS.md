# vox.ai Skills

vox.ai 개발자를 위한 가이드라인과 베스트 프랙티스.

## Structure

- `skills/vox-best-practice/` - 단일(올인원) vox.ai 스킬. `skills/vox-best-practice/SKILL.md`에서 references로 타고 들어감
  - `skills/vox-best-practice/references/`
    - `voice-ai-playbook.md` - 워크플로우/규칙/체크리스트(올인원)
    - `voice-ai-prompt-template.md` - 한국어 system prompt 템플릿
    - `voice-ai-prompt-diagnosis.md` - 실패 사례 기반 원인 진단(+ MCP 연동: call_id → get_call/get_agent로 로그/프롬프트 자동 수집)
    - `voice-ai-prompt-revision.md` - 진단 결과 기반 prompt 리팩터링(+ MCP 연동: update_agent(prompt={...})로 프롬프트 객체 실제 반영)
    - `mcp-vox-integration.md` - vox MCP(https://mcp.tryvox.co/) 클라이언트별 연결 가이드(설정 + troubleshooting)
- `skills/flow-node-creator/` - vox.ai flow 에이전트 노드 생성 스킬
- `.claude-plugin/plugin.json` - Claude Code Plugin 메타데이터
- `.mcp.json` - Plugin MCP 서버 설정 (vox MCP 자동 연결)

## See Also

- vox.ai 문서(내부): 조직의 단일 소스에 맞춰 링크/경로를 추가하세요.
