# Security

skills repo의 harness와 generated docs는 민감 정보를 저장소에 남기지 않는다.

금지:

- API key
- token
- verification payload
- credential-bearing logs

허용:

- redacted fixture
- non-secret synthetic example
- environment-isolated verification
