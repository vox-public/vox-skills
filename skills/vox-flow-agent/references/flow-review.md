# Flow Review: 설계물 검증

flow agent 설계물(flowchart + 노드 상세 설계)을 체크리스트 기반으로 리뷰하고, CRITICAL/WARN/INFO로 분류한 리포트를 출력한다.

검증 기준은 같은 디렉토리의 레퍼런스를 따른다:
- [flow-sketch.md](flow-sketch.md) — Mermaid 모양 규칙, 패턴
- [node-creation.md](node-creation.md) — 노드 작성 포맷, 전환조건/멘트 규칙
- [node-types.md](node-types.md) — 노드 타입 필드 상세
- [variable-system.md](variable-system.md) — 변수 시스템

## 입력

사용자가 다음을 제공한다:
- **Flowchart**: Mermaid flowchart + 노드 요약 테이블
- **노드 상세 설계**: 각 노드의 `## name / ## content / ## transition conditions`
- **원본 스크립트** (있으면): 설계의 원본이 된 콜센터/OB/CS 스크립트

셋 중 일부만 있으면 있는 것만 리뷰한다.

## 심각도 분류

| 심각도 | 의미 | 기준 |
|--------|------|------|
| **CRITICAL** | flow가 오작동하거나 실행 불가 | 노드 타입 오류, 필수 전환 누락, 구조 불일치 |
| **WARN** | 품질 저하 또는 예외 처리 미흡 | 분기 누락, 전환조건 부정확, 턴 운영 위반 |
| **INFO** | 개선 권장 (동작에 영향 없음) | 네이밍, 레이아웃, static/dynamic 선택 |

## 체크리스트

### A. Flowchart

| ID | 심각도 | 항목 | 판단 기준 |
|----|--------|------|----------|
| A1 | CRITICAL | 노드 모양 정확성 | conversation=`[]`, condition=`{}`, extraction=`[//]`, api=`[()]`, begin/endCall=`([])`, transfer=`>]` |
| A2 | CRITICAL | conversation vs condition 혼동 | 고객 발화 기반 분기 → conversation. 변수 값 비교 → condition. "동의/거절" 판단은 conversation |
| A3 | CRITICAL | condition 앞에 extraction/api 없음 | condition은 이미 추출된 변수를 비교. 변수 생성 노드 없이 condition 사용하면 오류 |
| A4 | WARN | 필수 예외 분기 누락 | 오대상(본인아님/관리사무소아님), 통화거절 등 OB콜 기본 예외 |
| A5 | WARN | 불필요한 분기 추가 | 원본 스크립트에 없는 분기를 임의 추가 |
| A6 | INFO | 레이아웃 | happy path 위→아래 일직선, 거절/예외 오른쪽 배치 |
| A7 | INFO | 엣지 라벨 | 2~5단어 이내 키워드 |

### B. 노드 상세 설계

| ID | 심각도 | 항목 | 판단 기준 |
|----|--------|------|----------|
| B1 | CRITICAL | 포맷 | `## name` / `## content` / `## transition conditions` 3섹션 고정. 다른 섹션 없어야 함 |
| B2 | CRITICAL | 전환조건에 "다음 단계 이름" 포함 | "다음은 XX로 넘어간다" 금지. exit 조건만 기술 |
| B3 | CRITICAL | begin/endCall 누락 | flow에 begin과 endCall이 각각 최소 1개 존재해야 함 |
| B4 | WARN | 목적 단일성 | 한 노드의 목적이 2개 이상이면 분리 검토 |
| B5 | WARN | 전환조건이 고객 발화 기반 아님 | "안내완료", "처리완료" 같은 에이전트 행동 기반 조건. skipUserResponse 노드 제외 |
| B6 | WARN | exit 상태 수 부족 | conversation 노드에 exit 상태가 1개뿐이면 거절/보류 분기 누락 가능 |
| B7 | WARN | 턴 운영 위반 | 한 턴 3문장 초과 (skipUserResponse 노드 제외) |
| B8 | WARN | content depth 초과 | 리스트 depth 3단 이상 중첩 |
| B9 | WARN | transition conditions 중첩 | 전환조건에 하위 불릿/번호 사용 |
| B10 | INFO | skipUserResponse 적절성 | 일방 안내 노드에 skipUserResponse 설정 여부, static/dynamic 선택 |
| B11 | INFO | 멘트 품질 | 큰따옴표 감싸기, TTS 불가 특수문자, 자연스러운 존댓말 |
| B12 | INFO | `{{변수}}` 누락 | 원본 스크립트의 런타임 변수가 빠지지 않았는지 |
| B13 | CRITICAL | extraction 포맷 | extraction 노드에 추출 변수 목록(변수명/타입/설명)이 정의되어 있는가. transition conditions가 "자동 전환"으로 표기되어 있는가 |
| B14 | CRITICAL | condition 분기 완전성 | condition 노드의 분기 조건이 모든 케이스를 커버하는가. else/default 분기가 존재하는가 |
| B15 | WARN | condition 변수 소비 | condition 노드에서 참조하는 변수가 앞선 extraction/api 노드에서 실제로 생성되는가 |
| B16 | WARN | api 응답 변수 정의 | api 노드에 responseVariables(변수명 + JSONPath)가 정의되어 있는가 |
| B17 | WARN | Global Node 설정 여부 | 스크립트에 "언제든" 예외가 있으면 해당 endCall/conversation에 Global Node 설정이 있는가 |

### C. Flowchart ↔ 노드 설계 정합성

| ID | 심각도 | 항목 | 판단 기준 |
|----|--------|------|----------|
| C1 | CRITICAL | 노드 수 불일치 | flowchart 노드 수 ≠ 노드 설계 수 |
| C2 | CRITICAL | 노드 이름 불일치 | flowchart 라벨과 노드 설계의 `## name`이 다른 경우 |
| C3 | WARN | 전환조건 라벨 불일치 | flowchart edge 라벨과 노드 설계 transition conditions의 exit 상태명이 불일치 |
| C4 | WARN | 분기 구조 불일치 | flowchart의 분기 수와 노드 설계의 exit 상태 수가 다른 경우 |

## 출력 포맷

```
## Flow Review Report

### CRITICAL (N건)
- **[ID] 항목**: 문제 설명 → 수정: 구체적 수정 방법

### WARN (N건)
- **[ID] 항목**: 문제 설명 → 수정: 구체적 수정 방법

### INFO (N건)
- **[ID] 항목**: 문제 설명 → 권장: 개선 방법

### 판정: 통과 / 수정 필요
- CRITICAL 0건 + WARN 2건 이하 → **통과**
- CRITICAL 1건 이상 또는 WARN 3건 이상 → **수정 필요**
```

CRITICAL이 없고 WARN이 경미하면 "통과"로 판정. 각 항목은 1~2문장으로 간결하게 작성한다.

### 수정 가이드

"수정 필요" 판정 시 아래 기준으로 수정 범위를 안내한다:

| 지적 유형 | 수정 범위 | 재리뷰 범위 |
|----------|----------|------------|
| CRITICAL A1~A5 (flowchart 구조 문제) | 1단계(flow-sketch) 수정 후 2단계 재작업 | 전체 재리뷰 |
| CRITICAL B1~B3, C1~C2 (노드 설계/정합성 문제) | 해당 노드만 2단계 재작업 | 해당 항목 + 정합성(C) 재리뷰 |
| WARN | 해당 항목만 수정 | 수정 항목에 대해서만 재확인 |

- 재리뷰 시 이전 리뷰에서 OK였던 항목은 재검사하지 않는다.
- 수정 후 재리뷰 결과를 기존 리포트에 이어서 출력한다.

## 운영 규칙

1. 체크리스트 항목을 전수 검사한다. OK인 항목은 출력하지 않는다 — 문제 있는 항목만 출력
2. 원본 스크립트가 있으면 스크립트 충실도도 검증한다 (핵심 멘트/논리 누락 여부)
3. 수정 제안은 구체적으로 — "수정 필요" 대신 "B[오프닝안내] -->|관리사무소아님| Z 추가" 수준
4. 판단이 애매한 항목은 낮은 심각도로 분류한다
