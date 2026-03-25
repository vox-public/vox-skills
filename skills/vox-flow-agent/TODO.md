# vox-flow-agent 워크플로우 리뷰 TODO

2026-03-24 워크플로우 리뷰 결과 정리. 2026-03-25 1차 수정 반영.

---

## 완료 (2026-03-25)

### ~~1. 1→2단계 핸드오프 공백~~ ✓

flow-sketch.md 출력에 "핸드오프 메모 (2단계용)" 섹션 추가. 작업 절차 5단계로 삽입, 기존 5단계→6단계로 이동.

### ~~2. conversation 외 노드 작성법 미정의~~ ✓

node-creation.md에 "노드 타입별 작성법" 섹션 추가: extraction, condition, api, endCall 각각 포맷 + 적용 예시.

### ~~3. 리뷰 후 수정 프로세스 미정의~~ ✓

flow-review.md 출력 포맷 하단에 "수정 가이드" 섹션 추가. CRITICAL/WARN별 수정 범위 + 재리뷰 범위 테이블.

### ~~4. Global Node 설계 가이드 없음~~ ✓

node-creation.md에 "Global Node 설계 가이드" 섹션 추가. 후보 판별, 설계 규칙, 일반적인 구성 테이블.

### ~~5. extraction/condition/api 전용 리뷰 체크 없음~~ ✓

flow-review.md B섹션에 B13~B17 추가: extraction 포맷, condition 분기 완전성, condition 변수 소비, api 응답 변수, Global Node 설정.

### ~~6. "확정된 flowchart에서 2단계만 시작" 케이스 미정의~~ ✓

SKILL.md 워크플로우 섹션에 "확정된 flowchart가 이미 있으면 2단계부터 시작한다. 리뷰 지적사항 반영 시 해당 단계만 재수행한다." 추가.

### ~~7. SKILL.md 워크플로우 섹션 중복~~ ✓

"Node 생성" 섹션(구 라인 109-115) 삭제. 상단 워크플로우 섹션으로 통합.

---

## 미완료

### 8. 최종 산출물 성격 미명시

**파일**: `SKILL.md`

**문제**: 파이프라인 최종 산출물이 "사람이 vox.ai UI에 수동 입력하는 markdown"인지, "프로그래밍적으로 JSON 생성 가능한 스펙"인지 명시되어 있지 않음. SKILL.md에 Supabase `ReactFlowJsonObject` 저장 구조가 설명되어 있어 JSON 변환 기대를 줄 수 있음.

**수정 제안**: 현재 산출물의 성격을 명시. 향후 JSON 생성 단계 추가 여지를 열어두는 것도 고려.

---

### 9. flow-sketch.md extraction 노드 skipUserResponse 미언급

**파일**: `references/flow-sketch.md`

**문제**: node-types.md에 따르면 extraction 노드는 항상 `isSkipUserResponse: true`. 이 특성이 flow-sketch.md의 노드 타입 판단 기준 테이블에 명시되지 않아, 시각화 시 extraction을 대화형 노드처럼 취급할 수 있음.

**수정 제안**: flow-sketch.md 노드 타입 판단 기준 테이블에 extraction의 자동 전환 특성 명시. (노드 요약 테이블 출력에서 extraction은 "자동 전환"으로 표기하도록 이미 반영됨 — 판단 기준 테이블 업데이트만 잔존)

---

### 추가: SKILL.md description 리뷰 반영

**2026-03-25 반영**: 3인칭 변경 ("This skill should be used when..."), catch-all 제거, 중복 트리거 정리.
