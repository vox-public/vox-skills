# Evaluation Model

quality는 세 축으로 정의한다.

## Execution

질문:

- skill이 켜졌을 때 실제 작업을 제대로 수행하는가

주 책임:

- domain skill

## Routing

질문:

- 올바른 skill이 선택되었는가

주 책임:

- `using-vox-best-practice`

## Freshness

질문:

- 사실 정보가 최신 source-of-truth와 맞는가

주 책임:

- `vox-tool`
- `vox-phone-number`
- `vox-workspace`
- `vox-pricing`

delegated freshness owners:

- `vox-single-prompt-agent` -> `vox-tool`, `vox-workspace`, `vox-pricing`
- `vox-call` -> `vox-tool`, `vox-phone-number`, `vox-workspace`

## Harness Model

quality harness는 hybrid 구조를 따른다.

- skill-local semantics
- repo-level runner

각 installable skill은 skill-local harness contract artifact를 가진다. `_harness/`는 이를 발견하고 실행/집계하며 generated state를 갱신한다.

## Security Boundary

harness artifact에는 secret, token, API key, verification payload, credential-bearing evidence를 포함할 수 없다.
