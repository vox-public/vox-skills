# 빌트인 도구 레퍼런스

빌트인 도구의 조회, 장착, 해제 및 타입별 파라미터 상세입니다.

## 조회: list_built_in_tools()

```
list_built_in_tools()
```

파라미터 없음. 플랫폼 제공 빌트인 도구 중 **active 상태**인 것만 반환합니다.

## 장착: update_agent(builtInTools=[...])

`builtInTools`는 배열 전체 교체(replace) 방식입니다. `toolType`에 따라 item 객체 구조가 다릅니다.

### end_call

통화를 종료합니다.

```json
{"toolType": "end_call", "name": "end_call", "description": "고객이 더 이상 질문이 없을 때 통화를 종료합니다."}
```

| 필드 | 필수 | 설명 |
|-----|------|------|
| `toolType` | 필수 | `"end_call"` |
| `name` | 필수 | 도구 이름 (고유) |
| `description` | 선택 | 호출 조건 설명 |

### transfer_call

통화를 외부 전화번호/SIP로 전환합니다.

```json
{
  "toolType": "transfer_call",
  "name": "transfer_to_agent",
  "description": "고객이 상담원 연결을 요청할 때 전환합니다.",
  "transferConfiguration": [{"transferType": "phone", "transferTo": "010-1234-5678"}],
  "transferType": "cold"
}
```

| 필드 | 필수 | 기본값 | 설명 |
|-----|------|--------|------|
| `toolType` | 필수 | | `"transfer_call"` |
| `name` | 필수 | | 도구 이름 (고유) |
| `description` | 선택 | | 호출 조건 설명 |
| `transferConfiguration` | 필수 | | 전환 대상 배열 (최소 1개) |
| `transferConfiguration[].transferType` | 선택 | `"phone"` | `"phone"` 또는 `"sip"` |
| `transferConfiguration[].transferTo` | 필수 | | 전화번호 또는 SIP URI |
| `transferConfiguration[].transferCondition` | 선택 | | 전환 조건 설명 |
| `transferType` | 선택 | `"cold"` | `"cold"` 또는 `"warm"` |
| `displayedCallerId` | 선택 | `"agent"` | `"agent"` 또는 `"user"` |
| `transferMessageType` | 선택 | `"dynamic"` | warm 시 메시지 타입: `"static"` / `"dynamic"` |
| `warmTransferPrompt` | 선택 | | warm + dynamic: AI 브리핑 프롬프트 |
| `warmTransferStaticSentence` | 선택 | | warm + static: 고정 브리핑 문장 |
| `sipHeaders` | 선택 | `[]` | SIP 헤더 배열 (최대 10개, `{name, value}`) |

**cold vs warm**:

| | cold | warm |
|---|------|------|
| 브리핑 | 없음 | AI가 다음 상담원에게 통화 요약 전달 |
| 속도 | 빠름 | 약간 느림 (브리핑 시간) |
| 용도 | 단순 전환 | 복잡한 상담, 컨텍스트 전달 필요 시 |

### transfer_agent

같은 조직 내 다른 vox 에이전트로 전환합니다.

```json
{"toolType": "transfer_agent", "name": "transfer_to_support", "transferAgentId": 123, "preserveChatContext": false}
```

| 필드 | 필수 | 기본값 | 설명 |
|-----|------|--------|------|
| `toolType` | 필수 | | `"transfer_agent"` |
| `name` | 필수 | | 도구 이름 (고유) |
| `description` | 선택 | | 호출 조건 설명 |
| `transferAgentId` | 필수 | | 전환 대상 에이전트 ID (숫자) |
| `transferAgentVersion` | 선택 | `null` | 특정 버전 (미지정 시 최신) |
| `preserveChatContext` | 선택 | `false` | 대화 컨텍스트 유지 여부 |

### send_sms (현재 비활성)

> `is_active=false` 상태로 `list_built_in_tools()`에 노출되지 않으며 에이전트에 장착 불가. 향후 활성화될 수 있음.

통화 중 SMS를 발송합니다.

```json
{"toolType": "send_sms", "name": "send_confirmation", "smsMessageType": "static", "smsMessageStaticSentence": "예약이 확정되었습니다."}
```

| 필드 | 필수 | 기본값 | 설명 |
|-----|------|--------|------|
| `toolType` | 필수 | | `"send_sms"` |
| `name` | 필수 | | 도구 이름 (고유) |
| `description` | 선택 | | 호출 조건 설명 |
| `smsMessageType` | 선택 | `"static"` | `"static"` (고정) 또는 `"dynamic"` (AI 생성) |
| `smsMessagePrompt` | 선택 | | dynamic: AI가 SMS 생성할 프롬프트 |
| `smsMessageStaticSentence` | 선택 | | static: 발송할 고정 문장 |

### send_dtmf

IVR 메뉴 탐색을 위한 DTMF 톤을 전송합니다.

- 설계 가이드: `vox-agents/references/ivr-navigation-best-practice.md` 참조

```json
{"toolType": "send_dtmf", "name": "send_dtmf", "description": "IVR 메뉴 탐색 시 DTMF 톤을 전송합니다."}
```

| 필드 | 필수 | 기본값 | 설명 |
|-----|------|--------|------|
| `toolType` | 필수 | | `"send_dtmf"` |
| `name` | 필수 | | 도구 이름 (고유) |
| `description` | 선택 | | 호출 조건 설명 |

## 공통 선택 필드

모든 빌트인 도구에 공통:

| 필드 | 기본값 | 설명 |
|-----|--------|------|
| `speakDuringExecution` | `{"enabled": false, "messages": []}` | 실행 중 발화 설정 |
| `allowInterruptionDuringExecution` | 미지정 | 실행 중 인터럽트 허용 |

`speakDuringExecution` 예시: `{"enabled": true, "messages": ["잠시만 기다려 주세요."]}`

## 해제: update_agent(builtInTools=[...])

```
update_agent(
  agent_id="agent-uuid",
  builtInTools=[
    {"toolType": "transfer_call", "name": "transfer_to_agent", "transferConfiguration": [{"transferType": "phone", "transferTo": "010-1234-5678"}]}
  ]
)
```

제거하려는 도구를 제외한 최종 배열을 전달하면 해당 도구가 해제됩니다.
