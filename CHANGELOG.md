# Changelog

이 파일은 `domains/voxai/skills`의 maintainer-facing 변경 이력을 남긴다.

## Changelog Philosophy

- high-signal만 남긴다.
- skill catalog 변경, routing 규칙, MCP 연결 설정, plugin install 절차, 공개 문구(README/references) 변화 위주로 기록한다.
- 단순 formatting, noisy refactor, generated diff는 원칙적으로 적지 않는다.
- reader는 미래의 maintainer라고 가정한다.

## Format

- reverse chronological order를 유지한다.
- 먼저 `Unreleased`를 두고, release 시 날짜/버전 section으로 잘라낸다.
- category는 아래만 쓴다:
  - `Added`
  - `Changed`
  - `Fixed`
  - `Removed`
  - `Docs`

## Entry Rules

- 한 줄 요약이 아니라, 무엇이 바뀌었고 왜 중요한지 짧게 적는다.
- skill trigger/routing/ownership boundary가 바뀌면 반드시 남긴다.
- plugin install 절차, MCP 서버 URL, `.mcp.json` 스키마가 바뀌면 반드시 남긴다.
- README/references 같은 공개 문서 contract가 바뀌면 `Docs`에 남긴다.

## Template

```md
## Unreleased

### Added
- ...

### Changed
- ...

### Fixed
- ...

### Removed
- ...

### Docs
- ...
```

## Unreleased

### Changed
- `vox-onboarding` Step 4(인바운드 안내)를 공개 MCP surface와 정합화했다. `update_telephone_number`가 Phase 1 public이 아니므로 번호-에이전트 연결은 웹 앱(`/dashboard/{organizationId}/numbers`)으로 안내하도록 바꿨다.
- `vox-onboarding` Related Resources의 MCP Tools 목록을 실제 public(`list_telephone_numbers`만 read-only)으로 정리하고 `list_organizations`를 명시했다.

### Docs
- `README.md`의 Claude Code Plugin 섹션에 `/reload-plugins` 단계와 "첫 도구 호출 시 OAuth 로그인" 시점을 명시했다. 설치 직후 도구가 보이지 않는 상황을 줄이기 위함이다.
- `references/mcp-vox-integration.md`, `references/quickstart-ko.md`, `README.md`의 MCP 서버 URL을 canonical `/mcp` 경로로 통일했다. `https://mcp.tryvox.co/`(root)는 404이고 실제 endpoint는 `/mcp`다.
- `references/quickstart-ko.md`를 "Plugin 없이 MCP 수동 연결"에 집중하도록 재정리하고, 공개 MCP 도구 목록을 Phase 1 public surface(`PUBLIC_TOOL_NAMES`)와 정합화했다. campaign/telephone 번호 CRUD/eval 도구가 공개되어 있다는 오해를 제거했다.
