---
name: vox-onboarding
description: "Getting started with vox.ai — create a voice AI agent, make an outbound call, and set up inbound reception. Guides the full onboarding flow: agent creation → outbound test call → inbound phone number setup. Especially useful for first-time users and general vox.ai questions. Trigger on '에이전트 만들어줘', '전화 걸어줘', 'vox 시작', '음성 에이전트', '아웃바운드', '인바운드', or any getting-started request."
---

# vox — 음성 AI 에이전트 시작하기

vox.ai MCP 도구를 사용해 음성 AI 에이전트를 만들고 실제 전화를 걸거나 받는 것을 도와주는 스킬.

## 온보딩

처음 사용하는 사용자를 자연스러운 대화로 안내한다. 사용자가 한 번에 정보를 주면 추가 질문 없이 바로 진행. 정보가 부족할 때만 가볍게 물어본다.

### Step 1: MCP 연결 확인

`list_agents` MCP 도구를 호출하여 vox.ai 서버 연결을 확인한다.

성공하면 Step 2로 넘어간다.

실패하면:
- "vox.ai MCP 서버에 연결되지 않았습니다. 어떤 AI 도구를 사용하고 계신가요?" (Claude Code / Codex / Cursor / VS Code 등)
- 사용자가 알려주면 references/mcp-vox-integration.md에서 해당 클라이언트 섹션을 읽고 연결 방법을 안내
- OAuth가 기본. "claude mcp add" 명령어 실행 후 브라우저에서 로그인 팝업이 뜸
- API 토큰을 원하면: vox.ai 대시보드(https://www.tryvox.co) 에서 발급 가능
- 안내 후: "설정이 완료되면 '준비됐어요'라고 말씀해주세요" → 다시 list_agents 호출하여 확인

### Step 2: 에이전트 생성

사용자가 이미 충분한 정보를 줬으면 (예: "치과 예약 에이전트 만들어줘") 바로 생성. 정보가 부족할 때만 질문한다.

**필요한 정보:**
- 업종 (어떤 분야?)
- 사용 사례 (에이전트가 할 일?)
- 웹사이트/참고 자료 (선택)

**프롬프트 생성 시 반드시 vox-agents 스킬의 템플릿을 참조한다:**
- `vox-agents/references/voice-ai-prompt-template.md`를 읽어서 프롬프트 구조를 따른다
- `vox-agents/references/voice-ai-playbook.md`의 규칙을 적용한다
- 핵심: 역할 정의, 인사말, 업무 범위, 톤, 금지사항, 마무리 멘트를 포함
- 한국어 자연스러운 음성 대화체 사용

수집한 정보로:
1. 에이전트 이름 자동 생성 (업종 + 사용 사례 기반)
2. 위 템플릿 기반으로 프롬프트 생성
3. 사용자에게 이름과 프롬프트 요약을 보여주고 확인: "이렇게 만들까요?"
4. 확인 받으면 `create_agent` MCP 도구로 생성
   - name: 이름
   - prompt: 생성된 프롬프트
   - agent_type: "single_prompt" (고정)

생성 성공 시에만 다음 단계로 진행.
실패 시: 에러 내용을 보여주고 수정 후 재시도.

### Step 3: 아웃바운드 콜 (전화 걸기)

"직접 들어보시겠어요? 전화번호를 알려주시면 에이전트가 전화합니다."
(넘어가려면 "나중에 해볼게요"도 OK)

사용자가 번호를 알려주면:
1. `list_telephone_numbers` MCP 도구로 보유 번호 확인
2. 보유 번호가 있으면: 해당 번호를 call_from으로 사용
3. 보유 번호가 없으면:
   - "아직 발신 번호가 없습니다. 전화를 걸려면 번호가 필요해요."
   - `list_available_telephone_numbers` MCP 도구로 구매 가능 번호 조회
   - 사용자가 구매 원하면: `create_telephone_number`로 번호 구매 (비용: 월 7,000원부터)
   - 아니면: "나중에 번호를 구매하신 후 전화를 걸 수 있어요" → Step 4로
4. 번호가 있으면 `create_call` MCP 도구 실행
   - agent_id: Step 2에서 생성한 에이전트 ID
   - call_from: 보유 번호
   - call_to: 사용자가 알려준 번호
5. 전화는 보통 10~30초 내에 걸려온다. 통화 후 결과를 확인하려면 `get_call` 도구를 사용할 수 있다.

### Step 4: 인바운드 안내 (전화 받기)

"전화를 받는 에이전트도 설정할 수 있어요."
(넘어가려면 "나중에 할게요"도 OK)

1. `list_telephone_numbers` MCP 도구로 보유 번호 확인 (Step 3에서 이미 조회했으면 재사용)
2. 번호가 있으면:
   - "이 번호에 에이전트를 연결할까요?"
   - `update_telephone_number` MCP 도구로 inbound_agent_id 설정
     - record_id: list_telephone_numbers 응답에서 추출한 UUID (number 문자열이 아님)
     - inbound_agent_id: Step 2에서 생성한 에이전트 ID
   - "이제 이 번호로 전화하면 에이전트가 받습니다"
3. 번호가 없으면:
   - "인바운드 설정에는 전화번호가 필요합니다"
   - 번호 구매를 원하면 안내 (비용: 월 7,000원부터, vox-docs MCP에서 pricing 페이지 검색)
   - `create_telephone_number` 시 inbound_agent_id를 함께 설정하면 한 번에 완료

### Step 5: 완료

**완료 요약:**
- 생성된 에이전트: {name} (ID: {agent_id})
- 아웃바운드 테스트: {완료/스킵}
- 인바운드 설정: {완료/스킵}
- 대시보드: https://www.tryvox.co/agent/{agent_id}

**다음 단계:**
- 프롬프트 다듬기 → 그냥 "프롬프트 수정해줘"라고 말하면 됨 (vox-agents 스킬이 처리)
- 대량 발신 → "대량발신 설정해줘" (vox-dash-guide 스킬이 처리)
- 도구 추가 → "도구 연결해줘" (vox-tools 스킬이 처리)
- 요금 확인 → "요금이 얼마예요?" (vox-docs MCP에서 pricing 검색)

이 스킬들은 vox-ai 플러그인에 포함되어 있으며, 플러그인 설치 시 함께 사용 가능하다.

## 이 스킬이 하지 않는 것

- 프롬프트 작성의 세부 규칙 → vox-agents
- 플로우 노드 설계 → vox-flow
- 빌트인/커스텀 도구 관리 → vox-tools
- 가격 정책 상세 → vox-docs MCP에서 pricing 검색

## Related Resources

### MCP Tools (vox)
- `list_agents`, `create_agent` — 에이전트 조회/생성
- `create_call` — 아웃바운드 콜 실행
- `list_telephone_numbers`, `create_telephone_number`, `update_telephone_number` — 전화번호 관리

### Docs (vox-docs)
- `docs/quickstart` — 빠른 시작 가이드
- `docs/pricing` — 요금 안내

### App URLs
- `https://www.tryvox.co` — 대시보드 홈
- `https://www.tryvox.co/agent/{agentId}` — 에이전트 상세
