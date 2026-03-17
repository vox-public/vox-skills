# Routing Model

이 repository는 free-form mesh가 아니라 top-down routing graph를 따른다.

## Canonical Rule

- 한 user request에는 하나의 primary skill만 선택한다.
- secondary activation은 explicit typed handoff가 있을 때만 허용한다.

## Edge Types

| Edge | Meaning | Activation Effect |
| ---- | ------- | ----------------- |
| `routes-to` | primary router가 canonical execution owner를 선택 | target activation 허용 |
| `requires-background` | target을 execution owner로 바꾸지 않고 background context로 요구 | background loading만 허용 |
| `pairs-with` | 함께 쓰일 가능성이 높음 | explicit handoff가 있을 때만 secondary activation 가능 |
| `related-to` | 검색 보조 관계 | activation을 직접 유발하지 않음 |

## Handoff Contract

typed handoff는 최소한 아래 정보를 가진다.

- handoff type
- source skill
- target skill
- rationale
- ownership boundary
- validation expectation

예:

```text
using-vox-best-practice
  routes-to vox-flow-agent
  rationale: user intent is flow/node conversion
  ownership boundary: router selects, flow skill executes
  validation expectation: routing eval must prefer vox-flow-agent
```
