# vox.ai Skills

`domains/voxai/skills`는 vox.ai skills repository의 canonical home이다. 이 저장소는 installable skill packages, architectural constitution, 그리고 quality harness를 함께 가진다.

## Architecture Summary

- constitutional docs first
- thin router skill + flat domain skill namespace
- skill-local semantics + repo-level harness
- quality model: `execution`, `routing`, `freshness`

상세는 아래 문서를 읽는다.

- [ARCHITECTURE.md](/Users/busking/Documents/dev/vox/vox-mono/domains/voxai/skills/ARCHITECTURE.md)
- [core-beliefs.md](/Users/busking/Documents/dev/vox/vox-mono/domains/voxai/skills/docs/design-docs/core-beliefs.md)
- [skill-topology.md](/Users/busking/Documents/dev/vox/vox-mono/domains/voxai/skills/docs/design-docs/skill-topology.md)
- [routing-model.md](/Users/busking/Documents/dev/vox/vox-mono/domains/voxai/skills/docs/design-docs/routing-model.md)
- [evaluation-model.md](/Users/busking/Documents/dev/vox/vox-mono/domains/voxai/skills/docs/design-docs/evaluation-model.md)

## Canonical Skill Set

Canonical installable skill packages live under `skills/`.

- `using-vox-best-practice`
- `vox-single-agent`
- `vox-flow-agent`
- `vox-tool`
- `vox-phone-number`
- `vox-workspace`
- `vox-general`

## Repository Layout

```text
domains/voxai/skills/
├── AGENTS.md
├── ARCHITECTURE.md
├── README.md
├── docs/
├── skills/
└── _harness/
```

`skills/`는 packaging boundary이고, `docs/`는 이 구조를 지배하는 constitutional docs다.
