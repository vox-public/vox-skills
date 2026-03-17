---
name: using-vox-best-practice
description: "Use when starting any conversation about vox.ai voice agent development — prompt authoring, flow conversion, tool integration, phone number setup, workspace configuration, pricing inquiry, call operation, or any vox.ai platform question. This skill selects the right domain skill and never executes domain logic itself."
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
| `vox-best-practice` | voice agent prompt 작성/리팩터링/진단/MCP 통합 | prompt authoring, MCP integration | pricing, workspace, flow |
| `flow-node-creator` | 콜센터/OB/CS 스크립트 → flow node 변환 | flow node conversion | prompt authoring, pricing |
| `vox-pricing` | 가격/요금/플랜/빌링/cost 질문 | pricing and plan facts | prompt authoring, workspace |

### Not Installed

| Skill | Status |
|-------|--------|
| `vox-single-prompt-agent` | `[not installed]` |
| `vox-flow-agent` | `[not installed]` |
| `vox-call` | `[not installed]` |
| `vox-tool` | `[not installed]` |
| `vox-phone-number` | `[not installed]` |
| `vox-workspace` | `[not installed]` |

미설치 스킬 영역에 대한 요청은 `vox-best-practice`로 fallback한다.

## Routing Rules

1. **1% rule** — 요청이 1%라도 특정 domain skill에 해당되면 반드시 해당 skill을 invoke한다.
2. **One primary skill per request** — 한 요청에는 하나의 primary skill만 선택한다.
3. **Process skills before implementation skills** — 작업 방법론 skill을 실행 skill보다 먼저 적용한다.

## Edge Types

| Edge | Meaning | Activation Effect |
|------|---------|-------------------|
| `routes-to` | router가 canonical execution owner를 선택 | target activation 허용 |
| `requires-background` | execution owner를 바꾸지 않고 background context로 요구 | background loading만 허용 |
| `pairs-with` | 함께 쓰일 가능성이 높음 | explicit handoff가 있을 때만 secondary activation 가능 |
| `related-to` | 검색 보조 관계 | activation을 직접 유발하지 않음 |

## What This Skill Does NOT Do

- 가격표, 요율, 빌링 정책을 직접 포함하지 않는다 → `vox-pricing`
- prompt 템플릿, 진단 규칙, MCP 설정을 직접 포함하지 않는다 → `vox-best-practice`
- flow node 변환 로직을 직접 포함하지 않는다 → `flow-node-creator`
- domain skill의 내용을 복제하거나 요약하지 않는다
