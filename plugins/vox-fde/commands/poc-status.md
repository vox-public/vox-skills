---
description: 고객 POC 프로젝트 진행 상황을 조회한다
argument-hint: [고객사명 또는 Linear 이슈/프로젝트 URL]
allowed-tools:
  - mcp__fd511148-6c71-4585-9c03-48ee818ab132__list_projects
  - mcp__fd511148-6c71-4585-9c03-48ee818ab132__get_project
  - mcp__fd511148-6c71-4585-9c03-48ee818ab132__list_issues
  - mcp__fd511148-6c71-4585-9c03-48ee818ab132__get_issue
  - mcp__fd511148-6c71-4585-9c03-48ee818ab132__save_issue
  - mcp__fd511148-6c71-4585-9c03-48ee818ab132__save_comment
  - Read
---

고객 POC의 현재 진행 상황을 Linear에서 조회하여 요약한다.

## 절차

1. `$ARGUMENTS`로 입력을 받는다.
   - 고객사명 → `list_projects(query="$ARGUMENTS")`로 프로젝트 검색
   - Linear 프로젝트 URL/ID → 해당 프로젝트 직접 조회
   - Linear 이슈 URL/ID → 해당 이슈의 sub-issue 조회
   - 비어있으면 질문한다.

2. **모드 판별**:
   - 프로젝트에서 이슈를 찾으면 → 모드 A (프로젝트 기반)
   - 이슈의 sub-issue를 조회하면 → 모드 B (이슈 기반)

3. 단계 이슈와 세부 작업(sub-issue)을 조회한다:
   - 모드 A: `list_issues(project=프로젝트ID)` → parent 기준 그룹핑
   - 모드 B: `list_issues(parentId=이슈ID)` → 단계별 sub-issue 조회

4. 아래 형식으로 요약한다:

   ```
   ## [고객사명] POC 현황

   ### 1. 초기 온보딩 — ✅ 완료 (2/2)
   - ✅ 1.1 배경 및 요구사항 정리
   - ✅ 1.2 전화번호 연동

   ### 2. 에이전트 설계 및 제작 — 🔄 진행중 (1/2)
   - ✅ 2.1 데이터 정리 & 시나리오 구성
   - 🔄 2.2 프롬프트 작성 & 에이전트 테스트

   ### 3. 1차 데모 전달 — ⬜ 대기
   ### 4. 피드백 & 수정 — ⬜ 대기 (0/2)
   ### 5. 고객 온보딩 — ⬜ 대기
   ### 6. PoC 모니터링 — ⬜ 대기
   ### 7. PoC 종료 — ⬜ 대기
   ```

5. 현재 진행중인 단계의 체크리스트에서 "다음에 할 일"을 안내한다.
   - poc-onboarding 스킬의 `references/poc-checklist.md`에서 해당 단계 가이드를 참조한다.

6. **5~7단계 자동 제안**: 4단계(피드백 & 수정)의 모든 sub-issue가 Done이고, 5단계 이슈가 아직 없으면:
   - 사용자에게 "4단계가 완료되었습니다. 5~7단계(고객 온보딩, 모니터링, 종료) 이슈를 생성할까요?"라고 질문한다.
   - 승인 시 poc-milestones.md의 "후속 단계" 섹션에 따라 5, 6, 7단계 이슈를 **순서대로** 생성한다.
