---
name: vox-pricing
description: "Use when the user asks about vox.ai pricing, plans, rates, billing, costs, credits, subscriptions, compares plan features, asks about telecom fees, phone number costs, SMS rates, transfer call pricing, or enterprise pricing inquiries."
---

# vox-pricing

vox.ai 요금 체계의 사실 기반 응답을 제공하는 domain skill.

## 구독 플랜

| 플랜 | 월 구독료 | AI 통화 (10초당) | 전환 통화 (10초당) | 일일 한도 | 시간당 한도 | 동시 통화 |
|------|---------|----------------|-----------------|---------|----------|---------|
| Start | 무료 | 30원 | 13원 | 100건 | 100건 | 5 |
| Build | 250,000원 | 25원 | 12원 | 1,000건 | 500건 | 25 |
| Scale | 500,000원 | 22원 | 11원 | 2,500건 | 1,000건 | 50 |
| Enterprise | 별도 문의 | 별도 문의 | 별도 문의 | 별도 문의 | 별도 문의 | 별도 문의 |

## 추가 요금

| 항목 | 요금 | 비고 |
|------|------|------|
| 발신 통신료 (휴대전화) | 10초 12원 (variable) | 010 등 |
| 발신 통신료 (유선전화) | 1분 15원 (variable) | 02, 031, 070 등 |
| 발신 통신료 (대표번호) | 10초 12원 (variable) | 1588 등 |
| 발신 기본료 | 건당 20원 | 아웃바운드 |
| 음성사서함 / 통화 실패 | 건당 20원 | |
| 문자 발신 (텍스트) | 25원/건 | SMS/LMS 균일 |
| 문자 발신 (첨부파일) | 60원/건 | MMS |
| 문자 수신 | 25원/건 | |
| 채팅 API | 20원/건 | |
| 070 번호 월정액 | 7,000원/월 (variable) | 일할 계산 |
| 문자 수신 기능 | 10,000원/월 | |

## 빌링 모델

- **전면 후불제**: 전월 사용량을 익월 5일 인보이스 발행, 10일까지 결제
- **과금 단위**: AI 통화(`agent_rate`) 10초, 전환 통화(`transfer_rate`) 10초, 발신 통신료(`telephony_rate`) 착신 대역별
- **크레딧**: 잔액이 있으면 즉시 차감, 남은 금액은 후불로 누적

## References

상세 스펙은 아래 문서 참조:

- Rate 정의, Transfer Matrix, Timeline Diagram, 과금 항목, 정책: See [references/rate-definitions.md](references/rate-definitions.md)
- 건별 과금 예시 7건, 월간 비용 시뮬레이션: See [references/billing-examples.md](references/billing-examples.md)

## Operating Rules

1. **이 문서에 없는 가격은 추측하지 않는다.** 미확인 요금 → "vox.ai/pricing 또는 영업팀에 확인해주세요"
2. `(variable)` 표시 항목은 운영 정책에 따라 변동 가능함을 안내한다.
3. **VAT 별도**임을 안내한다.
4. Enterprise 플랜은 별도 문의임을 안내한다.
5. 작업 전 필요한 reference 문서를 먼저 열고 그 데이터를 적용한다.

## Freshness

- 마지막 검증: 2026-04
- 소스: `__docs__/specs/features/telecom-billing/pricing.md`, `__docs__/reference/pricing-table/vox-pricing-table-2604.pdf`
