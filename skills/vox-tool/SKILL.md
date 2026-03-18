---
name: vox-tool
description: "Use whenever the user asks about vox.ai tool management — adding or removing built-in tools (end_call, transfer_call, transfer_agent, send_sms, send_dtmf), creating custom API or MCP tools, tool attachment/detachment workflow, or any question about managing tools on a vox agent. Trigger on 'end_call 추가해줘', 'custom tool 만들어줘', '도구 연결 어떻게 해', '빌트인 도구 목록', or any vox tool question."
---

# vox-tool

vox.ai 에이전트의 도구 관리를 다루는 domain skill. 빌트인 도구와 커스텀 도구의 조회/생성/장착/해제를 안내한다.

## References

- 도구 관리 전체 워크플로우를 파악할 때: See [references/mcp-tool-management.md](references/mcp-tool-management.md)
- 빌트인 도구 파라미터 상세가 필요할 때 (end_call, transfer_call, transfer_agent, send_dtmf): See [references/mcp-built-in-tools.md](references/mcp-built-in-tools.md)
- 커스텀 도구 생성/연결/삭제가 필요할 때: See [references/mcp-custom-tools.md](references/mcp-custom-tools.md)

MCP 서버 연결 설정(Claude, Cursor, ChatGPT 등)은 `vox-general` 스킬이 담당한다.

## Core Operating Rules

- 작업 유형에 맞는 reference를 먼저 열고 그 규칙을 적용한다.
- vox 플랫폼의 도구명/필드/엔드포인트는 **확인된 목록**이 없으면 만들어내지 않는다 — 존재하지 않는 도구를 안내하면 고객이 디버깅에 시간을 낭비한다.
- MCP로 실제 업데이트는 유저가 "적용/업데이트"를 명시했을 때만 실행한다 — `builtInTools`와 `toolIds`는 전체 교체(replace) 방식이라 실수로 실행하면 기존 도구가 전부 지워진다.
- 도구 이름 규칙: 영문/숫자/`_`/`-`만 허용, 1-64자, 에이전트 내 중복 금지.

## Ownership Boundary

| Owns | Does Not Own |
|------|--------------|
| built-in tools (end_call, transfer_call, transfer_agent, send_sms, send_dtmf) | prompt authoring |
| custom tools (api, mcp type) | pricing |
| tool management workflow | flow design |
| tool naming rules | MCP server connection setup (→ vox-general) |
