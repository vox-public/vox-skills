# vox-fde

vox.ai FDE(Forward Deployed Engineer)가 고객 POC 온보딩을 독립 수행할 수 있게 돕는 Claude Cowork 플러그인.

**버전: 0.5.0**

## 기능

### 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/vox-fde:new-poc [고객사명 또는 이슈URL]` | Linear에 POC 구조 자동 생성 (프로젝트 or 이슈 기반) |
| `/vox-fde:poc-status [고객사명]` | Linear에서 POC 진행 상황 조회 및 다음 할 일 안내 |
| `/vox-fde:create-prompt [고객사명]` | 에이전트 프롬프트 작성 워크플로우 시작 |

### 스킬

| 스킬 | 설명 |
|------|------|
| `poc-onboarding` | POC 단계별 가이드, 체크리스트, Linear 구조 생성 템플릿 |

> **참고:** `vox-best-practice`와 `flow-node-creator`는 독립 스킬로 제공됩니다. 이 플러그인의 커맨드에서 자동으로 참조하므로 별도 설정 없이 사용 가능합니다.

### MCP 서버

| 서버 | URL | 용도 |
|------|-----|------|
| vox | `https://mcp.tryvox.co/` | 에이전트 생성/수정/조회, 도구 관리 |
| linear | `https://mcp.linear.app/sse` | 프로젝트/마일스톤/이슈 관리 |

## 설치

### GitHub에서 clone 후 설치

```bash
git clone https://github.com/tryvox/vox-skills.git
claude plugin install /path/to/vox-skills/plugins/vox-fde
```

### 이미 clone한 경우

```bash
claude plugin install /path/to/vox-fde
```

`.claude-plugin/plugin.json`이 있는 디렉터리 경로를 지정하면 된다.

## POC 생성 — 두 가지 모드

### 모드 A: 프로젝트 기반 (고객사명으로 시작)

```
/vox-fde:new-poc 디자인무디
→ Linear 프로젝트 생성 + 1~4단계 이슈 + sub-issue (순서대로)
```

```
프로젝트: [디자인무디] AI 전화 에이전트 PoC
├── 1. 초기 온보딩 (sub: 1.1, 1.2)
├── 2. 에이전트 설계 및 제작 (sub: 2.1, 2.2)
├── 3. 1차 데모 전달
└── 4. 피드백 & 수정 (sub: 4.1, 4.2)

(5~7단계는 4단계 완료 후 생성)
```

### 모드 B: 이슈 기반 (기존 이슈에 붙이기)

```
/vox-fde:new-poc https://linear.app/tryvox/issue/CUS-123
→ 기존 이슈를 parent로, 동일한 1~4단계 구조 생성
```

## POC 워크플로우

```
[초기 생성]
1단계: 초기 온보딩
    ↓ 배경/요구사항 정리, 전화번호 연동(필요시)
2단계: 에이전트 설계 및 제작
    ↓ vox-best-practice + flow-node-creator 활용
3단계: 1차 데모 전달 (DueDate)
    ↓ 에이전트 전달 + 링크 공유 + 테스트 요청
4단계: 피드백 & 수정
    ↓ 고객 피드백 1회 반영

[4단계 완료 후 생성]
5단계: 고객 온보딩
6단계: PoC 모니터링
7단계: PoC 종료
```

## 변경 이력

### 0.5.0
- poc-onboarding 스킬 구조 개편: 3개 파일 간 중복 제거
  - SKILL.md → 라우터 전용 (레퍼런스 역할 분담표)
  - poc-milestones.md → Linear 생성 스펙 전용 (Linear 업데이트 규칙 제거)
  - poc-checklist.md → 실행 가이드 전용 (공통 규칙 통합)
- 3단계 데모 전달물 템플릿 추가 (자유 형식: Mermaid/PDF/Markdown)
- 전달 메시지 예시 추가

### 0.4.0
- `vox-best-practice`, `flow-node-creator` 스킬을 플러그인에서 제거하고 독립 스킬로 분리
- 커맨드에서 독립 스킬을 자동 참조하도록 변경

### 0.3.1
- POC 초기 생성 범위를 1~4단계로 축소 (5~7단계는 4단계 완료 후 생성)
- Linear 이슈 생성 순서를 작업 순서대로 보장 (리스트 정렬 개선)
