# Billing Examples

## 건별 과금 예시

### 예시 1: transfer 없는 단순 인바운드 5분 (Start 플랜)

| 항목 | 계산 | 금액 |
|------|------|------|
| `agent_rate` | 5분 = 30 x 10초, 30 x 30원/10초 | 900원 |
| `telephony_rate` | 수신 무료 | 0원 |
| **합계** | | **900원** |

### 예시 2: transfer 없는 단순 아웃바운드, 20초 ringing + 3분 통화 (Build 플랜, 무선)

| 항목 | 계산 | 금액 |
|------|------|------|
| Outbound Minimum | 1건 | 20원 |
| `agent_rate` | answered 3분 = 18 x 10초, 18 x 25원/10초 | 450원 |
| `telephony_rate` | answered 3분 = 18 x 10초, 18 x 12원/10초 | 216원 |
| `ringing` 구간 | 20초 | 0원 |
| **합계** | | **686원** |

### 예시 3: Warm 대국전환, user1-agent 4분 + ringing 20초 + agent-user2 상담 40초 + user1-user2 통화 2분 (Scale 플랜, 무선)

| 항목 | 계산 | 금액 |
|------|------|------|
| `agent_rate` | user1-agent 4분 + ringing 20초 + agent-user2 40초 = 5분 = 30 x 10초, 30 x 22원/10초 | 660원 |
| `transfer_rate` | user1-user2 2분 = 12 x 10초, 12 x 11원/10초 | 132원 |
| `telephony_rate` | agent-user2 40초 + user1-user2 2분 = 2분 40초 = 16 x 10초, 16 x 12원/10초 | 192원 |
| **합계** | | **984원** |

### 예시 4: Cold Transfer + SIP, user1-agent 2분 후 즉시 종료 (Start 플랜)

| 항목 | 계산 | 금액 |
|------|------|------|
| `agent_rate` | 2분 = 12 x 10초, 12 x 30원/10초 | 360원 |
| `transfer_rate` | cold transfer + SIP | 0원 |
| `telephony_rate` | SIP | 0원 |
| **합계** | | **360원** |

### 예시 5: Cold Transfer + 대국전환, user1-agent 2분 + ringing 30초 + user1-user2 통화 1분 (Build 플랜, 무선)

| 항목 | 계산 | 금액 |
|------|------|------|
| `agent_rate` | 2분 = 12 x 10초, 12 x 25원/10초 | 300원 |
| `ringing` 구간 | 30초 | 0원 |
| `transfer_rate` | cold transfer | 0원 |
| `telephony_rate` (user1-user2 1분) | 1분 = 6 x 10초, 6 x 12원/10초 | 72원 |
| **합계** | | **372원** |

### 예시 6: 아웃바운드 → 음성사서함 (Start 플랜)

| 항목 | 계산 | 금액 |
|------|------|------|
| Voicemail | 1건 (기본요금만) | 20원 |
| **합계** | | **20원** |

### 예시 7: 아웃바운드 → 통화 실패 (Start 플랜)

| 항목 | 계산 | 금액 |
|------|------|------|
| Failed Call | 1건 | 20원 |
| **합계** | | **20원** |

## 월간 비용 시뮬레이션

| 규모 | 일 건수 | 평균 통화 | 추천 플랜 | 구독료 | 월 예상 비용 |
|------|--------|----------|---------|-------|------------|
| 소규모 | 30건 | 3분 | Start | 무료 | ~44만원 |
| 중규모 | 200건 | 3분 | Build | 25만원 | ~280만원 |
| 대규모 | 1,000건 | 3분 | Scale | 50만원 | ~1,180만원 |

## 요금 구조 요약

```text
월 청구서
├── 구독료 (플랜 월정액, 일할 계산)
├── 전화번호 월정액 (7,000원 x 보유 수, 일할 계산)
├── usage
│   ├── agent_rate
│   │   ├── inbound / outbound agent-user 통화
│   │   └── warm transfer 중 agent-user2 상담
│   ├── transfer_rate
│   │   └── warm transfer 완료 후 user1-user2 통화
│   ├── telephony_rate
│   │   └── answered_at 이후 외부 발신 leg
│   ├── Outbound Minimum (건당 20원)
│   ├── Voicemail (건당 20원)
│   └── Failed Call (건당 20원)
├── 문자료
│   ├── 발신 텍스트 (25원)
│   ├── 발신 첨부파일 (60원)
│   └── 수신 (25원)
└── 채팅료
    └── 발신 (20원/건)
```

> 모든 billable item은 동일한 billing policy를 따른다.
> 크레딧 잔액이 있으면 가능한 만큼 즉시 차감하고, 남은 금액은 후불 결제 금액으로 누적한다.
