---
name: vox-best-practice
description: vox.ai 개발 베스트 프랙티스를 적용한다. (1) 한국어 음성 에이전트 system prompt 설계/작성/리팩터링(템플릿, {{...}} 변수 주입, 필러 옵션, Character normalization, 도구/무음 액션, 테스트/운영), (2) vox MCP 서버(https://mcp.tryvox.co/, Streamable HTTP, OAuth 또는 API token)를 ChatGPT/Claude Desktop/Claude Code/Cursor/OpenCode/Codex/VS Code Copilot 등에 연결할 때 사용한다.
---

# vox.ai Skills

한국어 음성(single prompt) 에이전트의 system prompt를 빠르고 안정적으로 만들기 위한 **올인원** 스킬입니다.

- 작성/리팩터링 워크플로우 + 규칙 + 체크리스트: See [references/voice-ai-playbook.md](references/voice-ai-playbook.md)
- 바로 복사해 쓰는 한국어 템플릿: See [references/voice-ai-prompt-template.md](references/voice-ai-prompt-template.md)
- 실패 사례 기반 원인 진단: See [references/voice-ai-prompt-diagnosis.md](references/voice-ai-prompt-diagnosis.md)
- 진단 기반 리팩터링(개선된 prompt 출력): See [references/voice-ai-prompt-revision.md](references/voice-ai-prompt-revision.md)
- vox MCP integration (Streamable HTTP, OAuth/API token, 클라이언트별 설정): See [references/mcp-vox-integration.md](references/mcp-vox-integration.md)
