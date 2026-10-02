#!/usr/bin/env bash
# DEPRECATED: vox-public/vox-skills 는 더 이상 관리하지 않는다.
# vox.ai plugin(https://github.com/vox-public/plugin)으로 옮겼다.
# 이 스크립트는 아무것도 설치하지 않고 안내만 출력한 뒤 종료 코드 1로 끝난다.

cat >&2 <<'MSG'
[deprecated] vox-public/vox-skills 는 더 이상 관리하지 않습니다.
vox.ai plugin(https://github.com/vox-public/plugin)으로 옮겼습니다. 이 스크립트는 아무것도 설치하지 않습니다.

새로 설치하기
  Claude Code:
    /plugin marketplace add https://github.com/vox-public/plugin.git
    /plugin install vox-ai@vox-ai
    /reload-plugins
  Codex CLI:
    codex plugin marketplace add https://github.com/vox-public/plugin.git
    codex plugin add vox-ai@vox-ai
    codex mcp login vox-ai
  Grok Build:
    grok plugin install https://github.com/vox-public/plugin.git

이전 vox-skills 설치가 있다면 (marketplace 이름이 같아 먼저 제거해야 합니다)
  1. 옛 plugin uninstall      2. 옛 marketplace remove
  3. 새 marketplace add       4. 새 plugin install
  Claude Code: /plugin uninstall vox-ai@vox-ai  ->  /plugin marketplace remove vox-ai  ->  위 명령
  Codex CLI:   codex plugin marketplace remove vox-ai  ->  위 명령
  Grok Build:  grok plugin uninstall vox-ai && grok plugin marketplace remove vox-ai  ->  위 명령
  버전이 1.0.1에서 0.2.x 로 낮아져도 정상입니다.

문서: https://docs.tryvox.co/docs/ai/overview
MSG
exit 1
