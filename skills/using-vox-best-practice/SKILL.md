---
name: using-vox-best-practice
description: "Use when starting any conversation about vox.ai — prompt authoring, flow design, tool management, pricing/billing, MCP setup, or any vox.ai platform question. This skill selects the right domain skill. Trigger on '프롬프트 작성해줘', '요금이 얼마예요', 'MCP 연결', 'flow 설계', '도구 추가', or any vox.ai-related question."
---

# using-vox-best-practice

vox.ai 관련 요청의 routing entrypoint. domain 로직을 직접 실행하지 않고, 요청에 맞는 domain skill을 선택한다.

## Priority Hierarchy

1. **User instructions** — 사용자가 명시한 지시가 최우선
2. **Domain skill rules** — 선택된 domain skill의 operating rules
3. **System defaults** — 위 둘에 해당하지 않을 때의 기본 동작

## Skill Catalog

### Installed

| Skill | Trigger | Owns | Does Not Own |
|-------|---------|------|--------------|
| `vox-onboarding` | 시작/온보딩, 에이전트 만들기, 전화 걸기/받기, 캠페인, 일반 안내 | onboarding, quickstart, 에이전트 생성 가이드, 전화 실행, 일반 사용 안내 | prompt 세부 작성, flow 설계, 도구 관리, 가격 상세 |
| `vox-single-agent` | voice agent prompt 작성/리팩터링/진단/agent.data | prompt authoring, diagnosis, revision, agent.data | flow, pricing, tool management |
| `vox-tool` | 빌트인/커스텀 도구 관리 | built-in tools, custom tools, tool workflow | prompt authoring, pricing, MCP connection setup |
| `vox-flow-agent` | flow agent 설계/node 변환/변수 흐름 | flow design, node conversion, variable system | prompt authoring, pricing |
| `vox-general` | 가격/요금/플랜/빌링, MCP 서버 연결 설정 | pricing, MCP server connection, platform setup | prompt authoring, tool management, flow |
| `vox-dash-guide` | 대시보드 사용법, 에이전트 설정, 웹 테스트, 대량발신, 통화 기록, 화면 가이드 | dashboard usage, agent settings UI, web testing, bulk calling, call data review, screen-guided mode | prompt authoring, flow design, tool management, pricing |

### Not Installed

| Skill | Status |
|-------|--------|
| `vox-phone-number` | `[not installed]` |
| `vox-workspace` | `[not installed]` |

미설치 스킬 영역 fallback:

| Not Installed | Fallback To | 이유 |
|---------------|-------------|------|
| `vox-phone-number` | `vox-tool` | 번호 설정은 도구/MCP 설정 맥락 |
| `vox-workspace` | `vox-single-agent` | workspace 설정은 agent 구성과 연관 |

## Routing Rules

1. **1% rule** — 요청이 1%라도 특정 domain skill에 해당되면 반드시 해당 skill을 invoke한다.
2. **One primary skill per request** — 한 요청에는 하나의 primary skill만 선택한다.
3. **Process skills before implementation skills** — 작업 방법론 skill을 실행 skill보다 먼저 적용한다.

## Handoff

한 요청에는 하나의 primary skill만 선택한다. 추가 skill이 필요하면 explicit handoff로 넘긴다.

## 이 스킬이 하지 않는 것

domain skill의 내용을 복제하거나 요약하지 않는다. 각 domain skill이 소유하는 영역은 위 Skill Catalog 참조.
