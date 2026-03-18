---
description: 새 고객 POC Linear 프로젝트를 자동 생성한다
argument-hint: [고객사명 또는 Linear 이슈 URL/ID]
---

새 고객 POC 작업 구조를 Linear에 생성한다.

## 절차

1. **입력 확인**: `$ARGUMENTS`를 분석한다.
   - 고객사명이 주어지면 → **모드 A (프로젝트 기반)**
   - Linear 이슈 URL 또는 이슈 ID가 주어지면 → **모드 B (이슈 기반)**
   - 비어있거나 불분명하면 질문한다: "고객사명을 알려주세요. 기존 Linear 이슈가 있으면 URL이나 ID를 주세요."

2. **첫 PoC 데모 전달일(DueDate)** 확인: 1차 데모를 전달할 목표 날짜를 질문한다.
   - 예: "2026-03-25"
   - 이 날짜를 기준으로 후속 일정이 자동 산정된다.

3. **고객 org_id** 확인: 고객의 vox.ai organization ID를 질문한다.
   - 에이전트 생성/수정 시 필요하므로 미리 확보한다.
   - 아직 모르면 1단계 진행 중에 확보해도 된다.

4. poc-onboarding 스킬의 `references/poc-milestones.md`를 읽고 그 구조를 따른다.

5. **영업일 계산**: DueDate를 기준으로 후속 이슈의 dueDate를 산정한다.
   - "3. 1차 데모 전달" → 입력받은 DueDate
   - "4.1 피드백 수집" → DueDate + 2영업일
   - "4.2 피드백 반영 수정" → DueDate + 4영업일
   - 주말(토/일)은 건너뛴다.

---

## 모드 A: 프로젝트 기반 생성

고객사명이 주어진 경우, 새 프로젝트를 만들고 이슈 + sub-issue로 구성한다.

1. `save_project` — 프로젝트 생성
   - 이름: `[$ARGUMENTS] AI 전화 에이전트 PoC`
   - 팀: `Customer`, 우선순위: 2 (High), 리드: "me", 시작일: 오늘

2. `save_issue` × 7 — **단계 이슈** 생성 (프로젝트에 연결)
   - "1. 초기 온보딩", "2. 에이전트 설계 및 제작", "3. 1차 데모 전달", "4. 피드백 & 수정", "5. 고객 온보딩", "6. PoC 모니터링", "7. PoC 종료"
   - poc-milestones.md의 설명을 그대로 사용
   - 담당자: "me"
   - **3단계 dueDate = DueDate**

3. `save_issue` × 6 — 1, 2, 4단계에 **sub-issue** 생성
   - `parentId`로 해당 단계 이슈에 연결
   - 담당자: "me"
   - **4.1 dueDate = DueDate+2영업일, 4.2 dueDate = DueDate+4영업일**

---

## 모드 B: 이슈 기반 생성

기존 Linear 이슈 URL/ID가 주어진 경우, 해당 이슈를 parent로 사용한다.

1. `get_issue` — 기존 이슈 정보 확인 (ID, 팀 등)

2. `save_issue` × 7 — **단계 sub-issue** 생성 (parentId = 기존 이슈 ID)
   - 팀: 기존 이슈와 동일한 팀
   - 담당자: "me"
   - **3단계 dueDate = DueDate**

3. `save_issue` × 6 — 1, 2, 4단계의 sub-issue에 **세부 작업 sub-issue** 생성
   - `parentId`로 해당 단계 sub-issue에 연결
   - 담당자: "me"
   - **4.1 dueDate = DueDate+2영업일, 4.2 dueDate = DueDate+4영업일**

---

## 완료

생성 완료 후:
- 모드 A: 프로젝트 URL을 공유
- 모드 B: parent 이슈 URL을 공유
- 1단계 체크리스트를 간략히 안내한다.
