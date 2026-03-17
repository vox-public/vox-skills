# Skill Topology

## Router Skill

- `using-vox-best-practice`

역할:

- relevant skill selection
- top-down routing entrypoint

제약:

- 직접 깊은 domain execution을 소유하지 않는다.
- domain skill 내용을 다시 복제하지 않는다.

## Domain Skills

- `vox-single-prompt-agent`
- `vox-flow-agent`
- `vox-call`
- `vox-tool`
- `vox-phone-number`
- `vox-workspace`
- `vox-pricing`

## Ownership Summary

| Skill | Owns | Does Not Own |
| ----- | ---- | ------------ |
| `vox-single-prompt-agent` | single prompt authoring and revision | flow conversion, pricing, workspace facts |
| `vox-flow-agent` | flow and node conversion | full single prompt authoring, pricing, workspace |
| `vox-call` | call runtime and call-operation guidance | pricing, workspace, generic tool authoring |
| `vox-tool` | tool guidance and tool integration concerns | pricing, workspace, generic phone-number policy |
| `vox-phone-number` | phone-number-specific rules and formatting | pricing, workspace, generic tool docs |
| `vox-workspace` | workspace setup, apikey, verification concerns | pricing, prompt/flow authoring |
| `vox-pricing` | pricing and plan facts | workspace, prompt/flow authoring, tool execution |

## Boundary Rule

새 installable skill은 새로운 retrieval unit일 때만 만든다. broad domain skill 내부 concern으로 충분하면 분리하지 않는다.
