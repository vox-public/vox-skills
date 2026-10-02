> **Deprecated: 이 저장소는 더 이상 관리하지 않는다.**
> vox.ai plugin([vox-public/plugin](https://github.com/vox-public/plugin))으로 옮겼다. 새 설치와 업데이트는 모두 plugin 저장소를 쓴다. 아래 skill 내용은 이전 설치 호환을 위해 남겨 둔 것이며 갱신되지 않는다.

# vox.ai Skills (deprecated)

## 새 plugin 설치

하나의 GitHub 저장소(`https://github.com/vox-public/plugin.git`)로 세 호스트에 모두 설치한다.

Claude Code:

```text
/plugin marketplace add https://github.com/vox-public/plugin.git
/plugin install vox-ai@vox-ai
/reload-plugins
```

Codex CLI:

```sh
codex plugin marketplace add https://github.com/vox-public/plugin.git
codex plugin add vox-ai@vox-ai
codex mcp login vox-ai
```

Grok Build:

```sh
grok plugin install https://github.com/vox-public/plugin.git
```

## 이전 `vox-skills` 설치에서 옮기기

이 저장소의 marketplace와 plugin 이름도 `vox-ai`라서 새 plugin과 충돌한다. 옛 것을 uninstall, marketplace remove 한 뒤 새 marketplace를 add 하고 install 한다. 이름이 같아 버전이 1.0.1에서 0.2.x로 낮아져도 정상이다.

```text
# Claude Code
/plugin uninstall vox-ai@vox-ai
/plugin marketplace remove vox-ai
/plugin marketplace add https://github.com/vox-public/plugin.git
/plugin install vox-ai@vox-ai
/reload-plugins
```

```sh
# Codex CLI
codex plugin marketplace remove vox-ai
codex plugin marketplace add https://github.com/vox-public/plugin.git
codex plugin add vox-ai@vox-ai
codex mcp login vox-ai

# Grok Build
grok plugin uninstall vox-ai
grok plugin marketplace remove vox-ai
grok plugin install https://github.com/vox-public/plugin.git
```

MCP 직접 등록과 CLI 안내는 [docs.tryvox.co/docs/ai/overview](https://docs.tryvox.co/docs/ai/overview)를 따른다.

## Available Skills

### using-vox-skills (router)

vox.ai 관련 요청의 routing entrypoint. 요청 내용에 따라 아래 domain skill을 자동 선택합니다.

- `skills/using-vox-skills/SKILL.md`

### vox-onboarding

첫 사용자 온보딩. 에이전트 생성 → 아웃바운드 테스트 → 인바운드 설정까지 안내합니다.

- MCP 서버 연결 설정 (Claude/Cursor/ChatGPT/VS Code/Codex/OpenCode)
- `skills/vox-onboarding/SKILL.md`

### vox-agents

프롬프트 에이전트(single prompt) 설계와 Agent의 선택적 기능인 Manual, 공통 음성 UX 규칙을 담당합니다.

- 신규 프롬프트 작성 워크플로우 + 한국어 템플릿
- Manual 분리 판단, Trigger/content/linked 체인, Manual 소유 Tool 설계
- 직접·linked Manual 재귀 품질 검사
- 쓰기 Tool·PostCall·내용 확인을 구분하는 Side-effect 완료 근거 계약
- 인바운드·아웃바운드 정상 종료 확인 질문과 `end_call.speakDuringExecution` 종료 멘트 계약
- 실패 사례 원인 진단 → 리팩터링
- agent.data 스키마 (MCP create_agent/update_agent)
- Agent Type 판단 (prompt-based vs flow) + single_prompt 내부 Manual 사용 판단 + flow handoff
- `skills/vox-agents/SKILL.md`

### vox-flow

플로우 에이전트 설계를 담당합니다. vox-agents의 확장 스킬입니다.

- 11종 node type 설계/설정
- 스크립트 → Mermaid flowchart → flow node 변환
- 변수 시스템 (extraction → condition 체인)
- 설계물 체크리스트 기반 리뷰
- `skills/vox-flow/SKILL.md`

### vox-tools

vox.ai 에이전트의 빌트인/커스텀 도구 관리를 담당합니다.

- 빌트인 도구: end_call, transfer_call, transfer_agent, send_sms, send_dtmf, search_address
- 커스텀 도구 (API/MCP type) 생성/연결/해제
- `skills/vox-tools/SKILL.md`

### vox-web-app

vox.ai 웹 앱(`tryvox.co/dashboard`) 사용 가이드. 다른 스킬에서 UI 안내가 필요할 때도 참조됩니다.

- 구축(build): agents, voice, tools, knowledge
- 배포(deploy): numbers, single/batch outbound
- 모니터링(monitor): history, alerts (통화 차트는 대시보드 홈)
- 설정(settings): workspace, billing, member, api-key, webhook, sms, profile
- 딥링크 치트시트 (`?new=1`, `?clone=true`, `?create=api` 등)
- `skills/vox-web-app/SKILL.md`

## 검사

```bash
bash scripts/check-bundle-sync.sh            # Codex 번들·매니페스트 버전 동기화
bash scripts/check-skill-mcp-conformance.sh  # MCP 도구명·인자 형태 회귀
node --test 'tests/**/*.test.mjs'            # 스킬 계약 테스트
```

trigger eval 세트는 `evals/<skill>/trigger_eval.json`에 있고, 실행 방법은 `evals/README.md`를 참고합니다. 라이선스는 [MIT](LICENSE)입니다.

## MCP Servers

이 플러그인은 두 개의 MCP 서버를 연결합니다:

| Name | URL | 역할 |
|------|-----|------|
| `vox` | `https://mcp.tryvox.co/mcp` | 플랫폼 도구 (에이전트, 통화, 조직 등) |
| `vox-docs` | `https://fleek.mintlify.app/mcp` | 공식 문서 검색 (search_vox_ai_docs + query_docs_filesystem) |
