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

## Core operating rules (must)

- 이 문서는 링크 모음입니다. 작업을 시작하기 전에 필요한 reference 문서를 먼저 열고(최소 1개) 그 규칙을 적용합니다. 문서를 열 수 없으면 유저에게 해당 섹션을 붙여달라고 요청합니다.
- vox 플랫폼/도구/모델과 관련된 사실(지원 모델/버전/도구명/필드/엔드포인트)은 **확인된 목록**이 없으면 만들어내지 않습니다.
  - 목록이 없으면: (1) 확인 질문 1개, 또는 (2) `[[...]]` placeholder로 남깁니다.
  - 예: vox에 없는 “GLM-*” 버전/이름을 임의로 생성 금지.
- 트레이드오프 우선순위:
  1) 사실성/정확성(추측 금지, 도구/근거 우선)
  2) 음성 UX(짧게, 턴테이킹)
  3) 친절함/설명량
- “기본 1–2문장” 같은 장문 방지 규칙은 **음성 에이전트의 런타임 발화**에 적용됩니다. 개발 산출물(시스템 프롬프트, 진단 YAML, 패치 노트)은 필요한 만큼 길어도 됩니다.
- 리팩터링은 “최소 변경”이 원칙입니다: 기존 프롬프트의 필수 섹션/도구 계약/변수/에러처리를 삭제하지 않습니다(중복 제거는 의미 보존이 전제).
- 진단 → 리팩터링 연결(핸드오프):
  - diagnosis 단계 산출물에는 `failure_modes`와 각 항목의 `change_requests`가 반드시 포함되어야 합니다.
  - revision 단계는 `change_requests`를 근거로만 변경합니다(근거 없는 재설계 금지).
- MCP로 실제 업데이트는 유저가 “적용/업데이트”를 명시했을 때만 실행합니다.
