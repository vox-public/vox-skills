# vox.ai Skills Architecture

이 repository는 `constitutional docs -> installable skills -> harness infrastructure`의 세 층으로 설계된다.

## Layers

1. `AGENTS.md`, `ARCHITECTURE.md`, `docs/design-docs/*`
   - 허용되는 구조와 경계를 정의한다.
2. `skills/*`
   - installable skill packages가 위치한다.
3. `_harness/`
   - routing, execution, freshness quality를 검증하는 repo-level infra다.

## Skill Classes

### Router Skill

- `using-vox-best-practice`
- relevant skill selection을 담당한다.
- 직접 domain execution을 다시 소유하지 않는다.

### Domain Skill

- `vox-single-prompt-agent`
- `vox-flow-agent`
- `vox-call`
- `vox-tool`
- `vox-phone-number`
- `vox-workspace`
- `vox-pricing`

이 skill들은 실제 user task를 수행하는 canonical domain owners다.

## Topology Rules

- installable skill의 logical namespace는 flat하다.
- installable skill의 physical packaging boundary는 `skills/`를 유지한다.
- 새 skill은 새로운 retrieval unit일 때만 만든다.
- broad domain skill 내부 concern은 별도 installable skill로 분리하지 않는다.

## Routing Rules

- 한 user request에는 하나의 primary skill만 선택한다.
- 추가 activation은 explicit typed handoff가 있을 때만 허용한다.
- canonical edge type은 `routes-to`, `requires-background`, `pairs-with`, `related-to`다.

## Quality Rules

- `execution`: skill이 올바르게 수행되는가
- `routing`: 올바른 skill이 선택되는가
- `freshness`: fact-heavy skill의 정보가 최신인가

skill-local semantics는 각 skill 패키지가 소유하고, `_harness/`는 이를 발견하고 검증한다.
