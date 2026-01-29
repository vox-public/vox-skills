---
name: vox-best-practices
description: This skill should be used when building vox.ai agents, designing conversation flows, configuring voice settings, or integrating APIs. Contains guidelines for Flow Agent design, Prompt Agent optimization, and AICC best practices.
metadata:
  author: vox
  version: "1.0.0"
---

# vox.ai Best Practices

Comprehensive guidelines for building effective vox.ai AICC (AI-powered Call Center) agents. Contains rules across multiple categories covering Flow Agent design, Prompt Agent optimization, voice configuration, and API integration.

## When to Apply

Reference these guidelines when:
- Creating a new vox.ai agent
- Designing conversation flows (Flow Agent)
- Writing prompts (Prompt Agent)
- Configuring TTS/STT voice settings
- Integrating external APIs
- Troubleshooting agent behavior
- Reviewing agent configuration for issues

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Flow Agent Design | CRITICAL | `flow-` |
| 2 | Prompt Agent | HIGH | `prompt-` |
| 3 | Voice Configuration | HIGH | `voice-` |
| 4 | API Integration | MEDIUM | `api-` |
| 5 | Error Handling | MEDIUM | `error-` |

## Quick Reference

### 1. Flow Agent Design (CRITICAL)

- `flow-structure` - Design clear conversation flow structure
- `flow-branching` - Implement proper branching logic
- `flow-fallback` - Always include fallback handlers
- `flow-context` - Manage conversation context properly

### 2. Prompt Agent (HIGH)

- `prompt-system` - Write effective system prompts
- `prompt-context` - Provide sufficient context
- `prompt-constraints` - Define clear constraints and boundaries

### 3. Voice Configuration (HIGH)

- `voice-provider` - Choose appropriate TTS/STT provider
- `voice-latency` - Optimize for low latency
- `voice-natural` - Configure natural-sounding speech

### 4. API Integration (MEDIUM)

- `api-webhook` - Configure webhooks correctly
- `api-timeout` - Set appropriate timeouts
- `api-retry` - Implement retry logic

### 5. Error Handling (MEDIUM)

- `error-graceful` - Handle errors gracefully
- `error-logging` - Implement proper logging
- `error-recovery` - Design recovery strategies

## How to Use

Read individual rule files for detailed explanations and examples:

```
references/rules/flow-structure.md
references/rules/prompt-system.md
references/rules/_sections.md
```

Each rule file contains:
- Brief explanation of why it matters
- Incorrect example with explanation
- Correct example with explanation
- When NOT to use the pattern
- Reference links to official documentation

## Documentation

For detailed vox.ai documentation: https://docs.tryvox.co
