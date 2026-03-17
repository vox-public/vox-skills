# Rate Definitions

## Rate 정의

| Rate | 기존 표현 | 정의 | 시작 시점 | 종료 시점 | 과금 단위 |
|------|----------|------|----------|----------|----------|
| `agent_rate` | Call Time, AI 통화 요율 | `agent`가 call에 참여 중인 upper lane 구간의 요율. `user1-agent`, SIP 연결/대기, 발신(`ringing`), `agent-user2` 상담을 포함할 수 있다 | `agent`가 call에 참여하기 시작할 때 | `agent`가 call에서 완전히 빠지거나 통화가 끝날 때 | 10초 |
| `transfer_rate` | Transfer, 전환 요율 | warm transfer 완료 후 `user1-user2`가 통화하는 구간의 요율 | `user1-user2` 연결이 성립할 때 | `user1-user2` 통화가 끝날 때 | 10초 |
| `telephony_rate` | 통신료, telecom rate | 외부 전화번호로 발신한 leg가 연결된 동안의 요율 | `answered_at` | 외부 발신 leg가 종료될 때 | 착신 대역별 |

## Rate 적용 규칙

- `agent_rate`와 `transfer_rate`는 동시에 부과되지 않는다.
- `telephony_rate`는 `ringing` 동안 부과되지 않는다.
- `telephony_rate`는 SIP로 전환할 때는 부과되지 않는다.
- CDR 요율(`agent_rate`, `transfer_rate`)은 통화 발생 시점의 active 플랜 요율을 적용한다.
- warm transfer에서 `agent`가 아직 `user1`과 통화 중인 대기/발신 구간은 `agent_rate`로 본다.
- warm transfer에서 `agent-user2` 상담 구간은 `agent_rate`, `user1-user2` 연결 구간은 `transfer_rate`로 본다.
- warm transfer에서는 같은 rate lane에 속한 비연속 구간을 따로 계산하지 않고 합산한 뒤 10초 단위로 계산한다.

## 과금 항목

| 항목 | 적용 rate | 설명 | 과금 기준 |
|------|----------|------|----------|
| **Agent Active Time** | `agent_rate` | `agent`가 call에 참여 중인 upper lane 구간. warm transfer의 SIP 연결/대기, 발신(`ringing`), `agent-user2` 상담 포함 | 10초당 플랜 요율 |
| **Warm Transfer (SIP)** | `transfer_rate` | warm transfer 완료 후 `user1-user2` 통화 구간 | 10초당 전환 요율 |
| **Warm Transfer (대국전환)** | `transfer_rate` + `telephony_rate` | warm transfer 완료 후 `user1-user2` 통화 구간 + 외부 발신 leg | 10초당 전환 요율 + 착신 대역별 발신 요율 |
| **Cold Transfer (SIP)** | 없음 | `agent`가 통화를 넘기고 종료하면 vox.ai 과금도 종료 | 추가 과금 없음 |
| **Cold Transfer (대국전환)** | `telephony_rate` | `agent`는 빠지지만 외부 발신 leg가 유지됨 | 연결된 구간의 착신 대역별 발신 요율 |
| **Outbound Minimum** | 없음 | 아웃바운드 기본 요금 | 건당 20원 |
| **Voicemail** | 없음 | 음성사서함 도달 시 | 건당 20원 (기본요금만) |
| **Failed Call** | 없음 | 통화 실패 (`call.status` 기반) | 건당 20원 |

## Transfer 2x2 Rate Matrix

|  | SIP (고객 PBX) | 대국전환 (전화번호) |
|--|---------------|-----------------|
| **Cold** | 전환 후 즉시 종료. 추가 rate 없음 | 전환 후 `telephony_rate`만 유지 |
| **Warm** | `user1-agent`, SIP 연결/대기, `agent-user2` 상담은 `agent_rate`, `user1-user2` 통화는 `transfer_rate` | `user1-agent`, 발신(`ringing`)은 `agent_rate`, `agent-user2` 상담은 `agent_rate + telephony_rate`, `user1-user2` 통화는 `transfer_rate + telephony_rate` |

## Transfer Timeline Diagrams

Legend:

- Upper lane = `agent_rate` / `transfer_rate`
- Lower lane = `telephony_rate`
- `[A]` = `agent_rate`
- `[T]` = `transfer_rate`
- `[P]` = `telephony_rate`
- `[ ]` = 부과 없음

### 1. Cold Transfer + SIP

```text
시간축 ------------------------------------------------------------>

user1-agent 통화                  전환 요청               통화 종료
[A][A][A][A][A][A][A][A]-------->|[ ]|

결과:
- agent가 빠지면 vox.ai 과금도 종료
- transfer_rate, telephony_rate 모두 없음
```

### 2. Cold Transfer + 대국전환

```text
시간축 ------------------------------------------------------------------------>

user1-agent 통화                  발신(ringing)             user1-user2 통화
[A][A][A][A][A][A][A][A]-------->|[ ][ ][ ]|-------------->[P][P][P][P][P][P]

결과:
- ringing 동안 telephony_rate 없음
- 연결 후에는 telephony_rate만 유지
- cold transfer이므로 transfer_rate는 붙지 않음
```

### 3. Warm Transfer + SIP

```text
시간축 ------------------------------------------------------------------------------------>

구간                  | user1-agent 통화 | SIP 연결/대기 | agent-user2 상담 | user1-user2 통화 |
rate lane (upper)     | [A][A][A][A][A] | [A][A]        | [A][A][A][A]     | [T][T][T][T][T] |
telephony lane(lower) | [ ][ ][ ][ ][ ] | [ ][ ]        | [ ][ ][ ][ ]     | [ ][ ][ ][ ][ ] |

결과:
- upper lane에서 agent_rate는 user1-agent + SIP 연결/대기 + agent-user2 상담을 하나로 합산해 계산
- user1-user2 연결 이후 upper lane은 transfer_rate
- SIP이므로 telephony_rate는 없음
```

### 4. Warm Transfer + 대국전환

```text
시간축 ------------------------------------------------------------------------------------------------------>

구간                  | user1-agent 통화 | 발신(ringing) | agent-user2 상담 | user1-user2 통화 |
rate lane (upper)     | [A][A][A][A][A] | [A][A][A]     | [A][A][A][A]     | [T][T][T][T][T] |
telephony lane(lower) | [ ][ ][ ][ ][ ] | [ ][ ][ ]     | [P][P][P][P]     | [P][P][P][P][P] |

결과:
- upper lane에서 agent_rate는 user1-agent + 발신(ringing) + agent-user2 상담을 하나로 합산해 계산
- ringing 동안 telephony_rate는 붙지 않음
- agent-user2 상담 구간부터 lower lane에 telephony_rate가 시작
- user1-user2 연결 이후에는 upper lane이 transfer_rate, lower lane은 계속 telephony_rate
- agent_rate와 transfer_rate는 동시에 붙지 않음
```

## 결과별 기본 정책

- `answered`: 통화 연결 구간 과금 + `Outbound Minimum`
- `no_answer`: `Outbound Minimum`
- `busy`: `Outbound Minimum`
- `voicemail`: `Voicemail`
- `failed`: `Failed Call`
- `canceled`: 0원

## 플랜 변경 정책

- **즉시 적용** + **일할 계산**
- 예: 1일~10일 무료 → 11일~20일 Start → 21일~30일 Build → 각 구간 일할 계산하여 후불 청구

## 구독 취소 정책

- 취소 요청 시점과 무관하게 해당 월 전액 과금 (일할계산 미적용)
- 구독 효력은 해당 월 말일에 종료
- 환불 없음
- 다음 달부터 과금 중단
