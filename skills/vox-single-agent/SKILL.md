---
name: vox-single-agent
description: "Use whenever the user is doing vox.ai single-prompt agent work — writing a system prompt, refactoring or reviewing an existing one, diagnosing why an agent behaves incorrectly, or working with agent.data schema via MCP. Trigger on '프롬프트 작성해줘', '프롬프트 고쳐줘', '에이전트가 이상하게 답해', or any vox single-prompt agent question, even if the user doesn't name this skill."
---

# vox-single-agent

한국어 음성(single prompt) 에이전트의 system prompt를 빠르고 안정적으로 만들기 위한 domain skill.

## References

신규 작성:
- 규칙 + 워크플로우 (새 프롬프트 작성 시 먼저 읽기): See [references/voice-ai-playbook.md](references/voice-ai-playbook.md)
- 한국어 프롬프트 템플릿 (작성 시 복사해 사용): See [references/voice-ai-prompt-template.md](references/voice-ai-prompt-template.md)

디버깅/개선:
- 실패 사례 원인 진단 (에이전트가 이상하게 동작할 때): See [references/voice-ai-prompt-diagnosis.md](references/voice-ai-prompt-diagnosis.md)
- 진단 기반 리팩터링 (진단 후 개선된 프롬프트 출력): See [references/voice-ai-prompt-revision.md](references/voice-ai-prompt-revision.md)

MCP/설정:
- agent.data 스키마 (create_agent/update_agent 시): See [references/agent-data-reference.md](references/agent-data-reference.md)

## Core Operating Rules

- 작업 유형에 맞는 reference를 먼저 열고 그 규칙을 적용한다.
- vox 플랫폼/도구/모델과 관련된 사실은 **확인된 목록**이 없으면 만들어내지 않는다 — 잘못된 사실은 고객 신뢰를 손상시키고 실제 장애로 이어진다.
  - 목록이 없으면: (1) 확인 질문 1개, 또는 (2) `[[...]]` placeholder로 남긴다.
- 트레이드오프 우선순위:
  1) 사실성/정확성 — 추측은 고객 이탈보다 비싸다
  2) 음성 UX — 짧고 자연스러운 턴테이킹이 통화 완료율을 높인다
  3) 친절함/설명량
- "기본 1–2문장" 같은 장문 방지 규칙은 **음성 에이전트의 런타임 발화**에 적용된다. 개발 산출물(시스템 프롬프트, 진단 YAML, 패치 노트)은 필요한 만큼 길어도 된다.
- 리팩터링은 "최소 변경"이 원칙이다 — 기존 프롬프트의 필수 섹션/도구 계약/변수/에러처리를 삭제하면 런타임에 예측 불가능한 장애가 발생한다(중복 제거는 의미 보존이 전제).
- 진단 → 리팩터링 핸드오프:
  - diagnosis 산출물에는 `failure_modes`와 `change_requests`가 반드시 포함되어야 한다.
  - revision은 `change_requests`를 근거로만 변경한다 — 근거 없는 재설계는 기존 동작을 깨뜨린다.
- MCP로 실제 업데이트는 유저가 "적용/업데이트"를 명시했을 때만 실행한다 — builtInTools/toolIds가 전체 교체 방식이라 실수로 실행하면 기존 설정이 날아간다.

## Ownership Boundary

| Owns | Does Not Own |
|------|--------------|
| single prompt authoring | flow conversion |
| prompt refactoring/diagnosis/revision | pricing |
| agent.data schema | tool management |
| voice AI playbook rules | workspace |
| prompt template | phone number |
