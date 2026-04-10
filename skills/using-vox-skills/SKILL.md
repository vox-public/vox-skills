---
name: using-vox-skills
description: "Use when starting any conversation about vox.ai — agent authoring, flow design, tool management, MCP setup, dashboard usage, or any vox.ai platform question. This skill selects the right domain skill. Trigger on '프롬프트 작성해줘', '요금이 얼마예요', 'MCP 연결', 'flow 설계', '도구 추가', '대시보드 안내', or any vox.ai-related question."
---

# using-vox-skills

vox.ai 관련 요청의 routing entrypoint. domain 로직을 직접 실행하지 않고, 요청에 맞는 domain skill을 선택한다.

## Priority Hierarchy

1. **User instructions** — 사용자가 명시한 지시가 최우선
2. **Domain skill rules** — 선택된 domain skill의 operating rules
3. **System defaults** — 위 둘에 해당하지 않을 때의 기본 동작

## Skill Catalog

### Installed

| Skill | Trigger | Owns | Does Not Own |
|-------|---------|------|--------------|
| `vox-onboarding` | 시작/온보딩, 에이전트 만들기, 전화 걸기/받기, MCP 연결 설정, 일반 안내 | onboarding, quickstart, 에이전트 생성 가이드, 전화 실행, MCP 서버 연결 설정, 일반 사용 안내 | prompt 세부 작성, flow 설계, 도구 관리 |
| `vox-agents` | voice agent prompt 작성/리팩터링/진단, flow 설계/노드 변환/리뷰, agent.data | prompt authoring, diagnosis, revision, flow design, node conversion, variable system, agent.data | tool management, dashboard UI |
| `vox-tools` | 빌트인/커스텀 도구 관리 | built-in tools, custom tools, tool workflow | prompt authoring, flow design |
| `vox-dash-guide` | 대시보드 사용법, 에이전트 설정 UI, 웹 테스트, 대량발신, 통화 기록, 화면 가이드 | dashboard usage, agent settings UI, web testing, bulk calling, call data review, screen-guided mode | prompt authoring, flow design, tool management |

### Docs MCP 활용

요금/빌링/플랜 관련 질문은 `vox-docs` MCP 서버(`https://docs.tryvox.co/mcp`)에서 pricing 페이지를 검색하여 답변한다. 별도 스킬이 필요하지 않다.

### Not Installed

| Skill | Status |
|-------|--------|
| `vox-phone-number` | `[not installed]` |
| `vox-workspace` | `[not installed]` |

미설치 스킬 영역 fallback:

| Not Installed | Fallback To | 이유 |
|---------------|-------------|------|
| `vox-phone-number` | `vox-tools` | 번호 설정은 도구/MCP 설정 맥락 |
| `vox-workspace` | `vox-onboarding` | workspace 설정은 초기 구성과 연관 |

## Routing Rules

1. **1% rule** — 요청이 1%라도 특정 domain skill에 해당되면 반드시 해당 skill을 invoke한다.
2. **One primary skill per request** — 한 요청에는 하나의 primary skill만 선택한다.
3. **UI 보충 참조** — 다른 스킬 실행 중 대시보드 UI 가이드가 필요하면 `vox-dash-guide`를 secondary로 참조한다.

## Handoff

한 요청에는 하나의 primary skill만 선택한다. 추가 skill이 필요하면 explicit handoff로 넘긴다.

## 이 스킬이 하지 않는 것

domain skill의 내용을 복제하거나 요약하지 않는다. 각 domain skill이 소유하는 영역은 위 Skill Catalog 참조.
