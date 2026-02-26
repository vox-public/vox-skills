# agent.data Reference

`agent.data`의 canonical 구조와 MCP 동작(정규화/병합/검증)을 정리한 레퍼런스입니다.

대상:
- `domains/voxai/mcp/schemas/agent_schema_v1_resolved.json`
- MCP `create_agent` / `update_agent`

## Source of Truth

- 스키마 스냅샷: `domains/voxai/mcp/schemas/agent_schema_v1_resolved.json`
- 루트 URI: `voxai://agent-schema/agent-data/v1`
- Root `additionalProperties`: `false` (정의되지 않은 루트 키 불가)
- Root required:
  - `prompt`
  - `stt`
  - `llm`
  - `voice`
  - `postCall`
  - `toolIds`

## Root 구조

| 필드 | 필수 | 타입 | 핵심 규칙 |
|------|------|------|-----------|
| `prompt` | 필수 | object | `prompt`, `firstLineType` 필수 |
| `stt` | 필수 | object | `provider` 필수 |
| `llm` | 필수 | object | `model` 필수 |
| `voice` | 필수 | object | `provider`, `id` 필수 |
| `postCall` | 필수 | object | `actions` 배열 |
| `toolIds` | 필수 | array | item은 UUID string |
| `builtInTools` | 선택 | array | toolType별 oneOf 스키마 |
| `speech` | 선택 | object | 응답성/turn 관련 |
| `callSettings` | 선택 | object | 통화 설정 |
| `security` | 선택 | object | 민감정보 저장 opts |
| `knowledge` | 선택 | object | RAG/knowledge 설정 |
| `webhookSettings` | 선택 | object | webhook URL 설정 |
| `presetDynamicVariables` | 선택 | object | value는 string |

## 주요 서브스키마

### prompt

- required: `prompt`, `firstLineType`
- `firstLineType` enum:
  - `userFirst`
  - `aiFirstDynamic`
  - `aiFirstStatic`
- `pauseBeforeSpeakingSeconds`: `0.0 ~ 5.0`

### llm

- required: `model`
- optional: `temperature`, `thinkingBudget`, `reasoningEffort`
- `reasoningEffort` enum:
  - `none`, `minimal`, `low`, `medium`, `high`, `null`

### stt

- required: `provider`
- optional: `language`

### voice

- required: `provider`, `id`
- optional: `model`, `speed`, `volume`, `temperature`

### postCall

- `actions[]` item required: `type`, `name`
- `type` enum:
  - `string`
  - `enum`
  - `boolean`
  - `number`
- 운영 규칙(비즈니스 검증): `type="enum"`이면 `enumOptions` 필수

### callSettings

- `backgroundMusic` enum: `none`, `cafe`, `office`, `call_center`, `library`, `dial_tone`
- `noiseCancellation` enum: `none`, `nc`, `bvc`
- `dtmfTerminationKey` enum: `0-9`, `#`, `*`

## builtInTools(oneOf)

`builtInTools[]`는 아래 toolType 스키마 중 하나를 따라야 합니다.

| toolType | 필수 필드 |
|----------|-----------|
| `end_call` | `toolType`, `name` |
| `transfer_call` | `toolType`, `name`, `transferConfiguration` |
| `transfer_agent` | `toolType`, `name`, `transferAgentId` |
| `send_sms` | `toolType`, `name` |
| `skill` | `toolType`, `name`, `skillPayload` |

## MCP 동작 규칙 (중요)

### create_agent

- MCP는 schema-aligned 기본값으로 `agent.data`를 생성
- `prompt` 파라미터 전달 시 `data.prompt.prompt`만 업데이트

### update_agent

지원 입력:
- `prompt`
- `data`
- `llm`
- `stt`
- `voice`
- `postCall`
- `callSettings`
- `knowledge`
- `webhookSettings`
- `security`
- `speech`
- `presetDynamicVariables`
- `builtInTools`
- `toolIds`

동작:
1. 기존 `agent.data`를 읽음
2. 입력 파라미터를 병합
3. 정규화(normalize)
4. 스키마 밖 필드 정리(strip)
5. JSON Schema 검증 + 비즈니스 검증
6. 저장

## 정규화 규칙

MCP는 업데이트 전 아래 legacy key를 canonical로 변환합니다.

- `llm.id -> llm.model`
- `voice.speedV2 -> voice.speed`
- `llm.provider` 제거

## 실전 예시

### 최소 유효 payload

```json
{
  "prompt": {"prompt": "안녕하세요", "firstLineType": "aiFirstDynamic"},
  "stt": {"provider": "rtzr"},
  "llm": {"model": "gpt-4o-mini"},
  "voice": {"provider": "elevenlabs", "id": "voice-id"},
  "postCall": {"actions": []},
  "toolIds": []
}
```

### update_agent 예시

```text
update_agent(
  agent_id="agent-uuid",
  llm={"model": "gpt-4o-mini", "temperature": 0.2},
  stt={"provider": "rtzr", "language": "ko"},
  postCall={"actions": []},
  builtInTools=[{"toolType": "end_call", "name": "end_call"}],
  toolIds=["tool-uuid"]
)
```

주의:
- `postCall`만 사용
- unknown key는 정리되거나 검증 에러가 발생할 수 있음
- 반영 후 `get_agent(agent_id=...)`로 최종 `agent.data` 확인 권장
