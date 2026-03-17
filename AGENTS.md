# vox.ai Skills

`domains/voxai/skills`는 vox.ai skills repository의 canonical home이다. 이 저장소는 installable skill 패키지 모음이면서, 동시에 그 구조와 품질 기준을 지배하는 constitutional docs를 함께 가진다.

## Read Order

수정 전에 아래 순서로 읽는다.

1. `AGENTS.md`
2. `ARCHITECTURE.md`
3. `docs/design-docs/core-beliefs.md`
4. 필요한 경우 `docs/design-docs/skill-topology.md`, `docs/design-docs/routing-model.md`, `docs/design-docs/evaluation-model.md`

## Core Rules

- `AGENTS.md`는 entrypoint index이지 백과사전이 아니다.
- installable skill의 physical packaging boundary는 `skills/` 디렉터리다.
- installable skill의 logical namespace는 flat하다.
- `using-vox-best-practice`는 thin router skill이다.
- `vox-*`는 domain skill이다.
- quality는 `execution`, `routing`, `freshness` 3축으로 정의한다.
- skill-local semantics와 repo-level harness는 분리한다.

## Repository Shape

- `ARCHITECTURE.md`: stable architecture contract
- `docs/design-docs/`: constitutional design docs
- `docs/QUALITY_SCORE.md`, `docs/RELIABILITY.md`, `docs/SECURITY.md`: operating constitution
- `skills/`: installable skill packages
- `_harness/`: repo-level quality infrastructure

## Editing Discipline

- 구조를 바꾸기 전에 문서를 먼저 바꾼다.
- `README.md`는 architecture를 요약하지만 source of truth는 아니다.
- generated state는 나중에 `docs/generated/`에서 관리한다. current state 설명을 README에 누적하지 않는다.
