# agent.data Reference

MCP `create_agent` / `update_agent` 사용 시 `agent.data`의 동작 규칙을 정리한 레퍼런스.

**스키마 기본값** → [default-agent-data.json](default-agent-data.json)을 먼저 읽어라. 모든 필드와 기본값이 들어 있다.

## Root 필수 필드

`prompt`, `stt`, `llm`, `voice`, `postCall`, `toolIds` — 이 6개가 없으면 검증 에러.
나머지(`builtInTools`, `speech`, `callSettings`, `security`, `knowledge`, `webhookSettings`, `presetDynamicVariables`, `isMemoryEnabled`)는 선택.

## 필드별 핵심 규칙

스키마 전체는 JSON 참조. 여기는 **LLM이 실수하기 쉬운 규칙만** 정리한다.

### prompt

- `firstLineType` enum: `userFirst` | `aiFirstDynamic` | `aiFirstStatic`
- `firstLine`: `aiFirstStatic`일 때만 사용 — 매 통화 동일한 첫 인사. `aiFirstDynamic`이면 LLM이 생성하므로 빈 문자열로 두면 된다.
- `pauseBeforeSpeakingSeconds`: `0.0 ~ 5.0` — 인바운드에서 수신 후 첫 발화까지 대기 시간.
- `isFirstMessageInterruptible`: 첫 인사 중간에 사용자가 끊고 말할 수 있는지. 긴 인사말이면 `true` 권장.

### llm

- `model` 필수. 기본값 `z-ai/glm-4.7`.

### stt

- `languages` 필수. `string[]` 형태 (예: `["ko"]`, `["ko", "en"]`).
- `speed`: 단일 언어면 `"high"` | `"medium"` | `"low"`, 다국어(`languages.length >= 2`)면 `null`.

### voice

- `provider`, `id` 필수.
- `speed`: 발화 속도 (0.5~2.0). 기본 0.95.
- `temperature`: 음성 변이. 기본 0.9.

### postCall

- `actions[]` 각 항목에 `type`, `name` 필수.
- `type` enum: `string` | `enum` | `boolean` | `number`
- `type="enum"`이면 `enumOptions` 필수 — 없으면 런타임에 빈 선택지가 되어 추출 실패.

### callSettings

- `callTimeoutInSeconds`: 최대 통화 시간. 기본 900초(15분). 짧은 CS콜이면 300초 권장.
- `silenceCallTimeoutInSeconds`: 양쪽 무음 시 자동 종료. 기본 30초.
- `backgroundMusic` enum: `none` | `cafe` | `office` | `call_center` | `library` | `dial_tone`
- `noiseCancellation` enum: `none` | `nc` | `bvc` (기본 `bvc`)
- `dtmfTerminationEnabled` / `dtmfTerminationKey` / `dtmfTimeoutSeconds`: DTMF 입력 종료 설정.

### speech

- `isAllowInterruption`: 사용자가 에이전트 발화 중 끊을 수 있는지. 기본 `true`.
- `isAllowTurnDetection`: 턴 감지 활성화. 기본 `true`.
- `responsiveness`: 0.0~2.0. 높을수록 빠르게 응답 시작. 기본 1.0.
- `boostedKeywords`: `string[]` — STT가 더 잘 인식해야 할 키워드 (브랜드명, 전문용어).

### security

- `optOutSensitiveDataStorage`: `true`면 통화 데이터 저장 안함.

### builtInTools

`builtInTools[]`는 아래 toolType 중 하나를 따른다.

| toolType | 필수 필드 |
|----------|-----------|
| `end_call` | `toolType`, `name` |
| `transfer_call` | `toolType`, `name`, `transferConfiguration` |
| `transfer_agent` | `toolType`, `name`, `transferAgentId` |
| `send_sms` | `toolType`, `name` |
| `send_dtmf` | `toolType`, `name` |
| `skill` | `toolType`, `name`, `skillPayload` |

## MCP 동작 규칙

### create_agent

- `name`, `agent_type`, `prompt`, `data` 파라미터 지원.
- MCP가 [default-agent-data.json](default-agent-data.json) 기반 기본값과 병합하여 생성.
- `data` 없이 `prompt`만 전달해도 동작 — 기본값에 `data.prompt.prompt`만 덮어씀.
- `agent_type`: `"single_prompt"` | `"flow"` (기본 `"single_prompt"`)

### update_agent

지원 입력: `name`, `prompt`, `data`, `llm`, `stt`, `voice`, `postCall`, `callSettings`, `knowledge`, `webhookSettings`, `security`, `speech`, `presetDynamicVariables`, `builtInTools`, `toolIds`

동작:
1. 기존 `agent.data`를 읽음
2. 입력된 필드를 **replace** (부분 merge 아님 — 해당 섹션 전체를 교체)
3. 정규화(normalize)
4. 스키마 밖 필드 strip
5. JSON Schema 검증 + 비즈니스 검증
6. 저장

**replace semantics가 핵심이다** — `builtInTools`에 `end_call` 하나만 넣으면 기존 도구가 전부 사라진다. 반드시 `get_agent()`로 현재 값을 읽고, 수정 후 전체를 다시 보내라.

## 실전 예시

### 최소 create_agent

```text
create_agent(
  name="CS 상담 에이전트",
  prompt="당신은 CS 상담 에이전트입니다..."
)
```

`data` 없이도 기본값이 자동 병합된다.

### update_agent — 프롬프트 + LLM 변경

```text
update_agent(
  agent_id="agent-uuid",
  prompt="수정된 프롬프트...",
  llm={"model": "gpt-4o-mini", "temperature": 0.2}
)
```

### update_agent — builtInTools 추가 (replace 주의)

```text
# 1. 현재 설정 조회
get_agent(agent_id="agent-uuid")
# → data.builtInTools: [{"toolType": "end_call", "name": "end_call"}]

# 2. 기존 + 신규를 합쳐서 전체를 보냄
update_agent(
  agent_id="agent-uuid",
  builtInTools=[
    {"toolType": "end_call", "name": "end_call"},
    {"toolType": "transfer_call", "name": "transfer_to_human",
     "transferConfiguration": [{"transferType": "phone", "transferTo": "010-1234-5678"}],
     "transferType": "cold"}
  ]
)
```

### 확인

```text
get_agent(agent_id="agent-uuid")
```

반영 후 반드시 확인. unknown key가 strip되었거나 검증 에러가 발생할 수 있다.
