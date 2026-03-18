# vox-fde

vox.ai FDE(Forward Deployed Engineer)가 고객 POC 온보딩을 독립 수행할 수 있게 돕는 Claude Cowork 플러그인.

**버전: 0.6.1**

## 기능

### 커맨드

| 커맨드                                     | 설명                                                |
| ------------------------------------------ | --------------------------------------------------- |
| `/vox-fde:new-poc [고객사명 또는 이슈URL]` | Linear에 POC 구조 자동 생성 (프로젝트 or 이슈 기반) |
| `/vox-fde:poc-status [고객사명]`           | Linear에서 POC 진행 상황 조회 및 다음 할 일 안내    |
| `/vox-fde:create-prompt [고객사명]`        | 에이전트 프롬프트 작성 워크플로우 시작              |
| `/vox-fde:dash-guide [url]`                | 대시보드 온보딩 가이드 (url은 옵셔널)               |

### 스킬

| 스킬             | 설명                                                                   |
| ---------------- | ---------------------------------------------------------------------- |
| `poc-onboarding` | POC 단계별 가이드, 체크리스트, Linear 구조 생성 템플릿                 |
| `dashboard-guide` | 고객 온보딩 가이드 (에이전트 설정, 테스트, 대량발신, 통화 데이터 조회) |

> **참고:** `vox-best-practice`와 `flow-node-creator`는 독립 스킬로 제공됩니다. 이 플러그인의 커맨드에서 자동으로 참조하므로 별도 설정 없이 사용 가능합니다.

### MCP 서버

| 서버   | URL                          | 용도                               |
| ------ | ---------------------------- | ---------------------------------- |
| vox    | `https://mcp.tryvox.co/`     | 에이전트 생성/수정/조회, 도구 관리 |
| linear | `https://mcp.linear.app/sse` | 프로젝트/마일스톤/이슈 관리        |

## 설치

### Cowork에 업로드

1. zip 파일 생성:

```bash
cd plugins
zip -r vox-fde.zip vox-fde/
```

2. Cowork 프로젝트 설정에서 **Plugins → Upload** 로 `vox-fde.zip` 업로드

### Claude Code CLI

```bash
git clone https://github.com/tryvox/vox-skills.git
claude plugin install /path/to/vox-skills/plugins/vox-fde
```

## POC 생성 — 세 가지 모드

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

### 모드 C: 파싱 기반 (파일/메일/URL에서 시작)

```
/vox-fde:new-poc  (+ 파일 첨부, 메일 본문 붙여넣기, 또는 노션/구글독스 URL)
→ 문서에서 고객사명, 담당자, 도입 범위 등 자동 추출
→ 추출 결과 확인 후 모드 A로 프로젝트 생성
→ 추출 정보를 1.1 이슈 description에 기록
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
