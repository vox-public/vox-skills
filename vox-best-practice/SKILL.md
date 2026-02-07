---
name: vox-best-practice
description: "vox.ai development best practices. (1) Voice agent system prompt design, authoring, and refactoring (template, {{...}} variable injection, filler options, character normalization, tools/silence actions, testing/production). (2) vox MCP server integration for ChatGPT, Claude Desktop, Claude Code, Cursor, OpenCode, Codex, VS Code Copilot."
---

# vox.ai Skills

한국어 음성(single prompt) 에이전트의 system prompt를 빠르고 안정적으로 만들기 위한 **올인원** 스킬입니다.

- 작성/리팩터링 워크플로우 + 규칙 + 체크리스트: See [references/voice-ai-playbook.md](references/voice-ai-playbook.md)
- 바로 복사해 쓰는 한국어 템플릿: See [references/voice-ai-prompt-template.md](references/voice-ai-prompt-template.md)
- 실패 사례 기반 원인 진단: See [references/voice-ai-prompt-diagnosis.md](references/voice-ai-prompt-diagnosis.md)
- 진단 기반 리팩터링(개선된 prompt 출력): See [references/voice-ai-prompt-revision.md](references/voice-ai-prompt-revision.md)
- vox MCP integration (Streamable HTTP, OAuth/API token, 클라이언트별 설정): See [references/mcp-vox-integration.md](references/mcp-vox-integration.md)
- MCP 도구 관리 (개요, 워크플로우, 주의사항): See [references/mcp-tool-management.md](references/mcp-tool-management.md)
  - 빌트인 도구 상세 (end_call, transfer_call, transfer_agent, send_sms): See [references/mcp-built-in-tools.md](references/mcp-built-in-tools.md)
  - 커스텀 도구 상세 (api/mcp 조회, 생성, 연결/해제): See [references/mcp-custom-tools.md](references/mcp-custom-tools.md)
