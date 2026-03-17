# Naming And Boundaries

## Naming

- `using-*`: router/process skill
- `vox-*`: installable domain skill

## Packaging Boundary

- installable skill의 physical packaging boundary는 `skills/` 디렉터리다.
- installable skill의 logical namespace는 flat하다.

즉:

- `skills/using-vox-best-practice`
- `skills/vox-call`
- `skills/vox-workspace`

처럼 배치하되, architecture 상으로는 flat installable namespace로 다룬다.

## Broad Domain Skill

`vox-workspace`처럼 하나의 installable trigger boundary 아래에 여러 내부 concern을 둘 수 있다.

예:

- `apikey`
- `verification`

이 concern들은 새 installable skill이 아니라 internal concern으로 유지한다.
