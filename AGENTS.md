# SakAI — instructions for agents and automation

Use this file as the **first stop** when an AI assistant or bot works in this repository. It points to canonical sources and non-negotiable workflows.

## Authoritative docs (read in order)

1. [`docs/agent_playbook.md`](docs/agent_playbook.md) — structured playbook (workflows, paths, symbols).
2. [`docs/agent_context.json`](docs/agent_context.json) — machine-readable repo facts (JSON).
3. [`openapi/swagger.yaml`](openapi/swagger.yaml) — REST contract; branch errors on `ErrorCode`, not `message`.
4. [`CONTRIBUTING.md`](CONTRIBUTING.md) — setup, tests, client generation.
5. [`overview.md`](overview.md) — phase status, audit IDs, architecture diagram.
6. [`docs/codebase_architecture.md`](docs/codebase_architecture.md) — layered architecture narrative.

## Hard rules

- **Contract-first:** change [`openapi/swagger.yaml`](openapi/swagger.yaml) before implementing new or altered REST behavior; then Go, then regenerate the Dart client ([`scripts/generate-client.sh`](scripts/generate-client.sh)).
- **Backend dependency direction:** `internal/delivery` → `internal/usecase` → `internal/domain` ← `internal/repository`. Never import `delivery` from `usecase` or `domain`.
- **Mobile:** keep API calls and mapping in `data/`; UI only in `presentation/`. Prefer `package:sakai_shared/sakai_shared.dart` for theme, `SakaiApiSupport`, and generated `SakaiApiClient`.
- **Regulated domain:** do not invent legal or compliance claims; flag assumptions in PRs or docs.
- **Edits to generated code:** do not hand-edit [`mobile/shared/lib/api_client/`](mobile/shared/lib/api_client/) except via codegen + [`scripts/patch-generated-api-client.sh`](scripts/patch-generated-api-client.sh) pipeline (see playbook).

## One-line tasks

| Task | Command / path |
|------|----------------|
| Regenerate Dart API client | `./scripts/generate-client.sh` then `cd mobile/shared && flutter pub get` |
| Backend tests | `cd backend && go test -race ./...` |
| Flutter analyze | `cd mobile/shared && flutter analyze` (and `passenger` / `driver` as needed) |
| Local API explorer | Run backend; open `http://localhost:8080/swagger/index.html` |

When in doubt, open [`docs/agent_playbook.md`](docs/agent_playbook.md).
