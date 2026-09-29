# pod-crabbox

The `pod-crabbox` candy of the OpenCharly candy library, as a standalone repo
(kind-prefixed naming). It installs and supervises the
[Crabbox](https://github.com/openclaw/crabbox) **coordinator** — the broker for
the fully-local Crabbox control plane: lease state, run history, spend caps, and
cleanup.

## What it provides

A Node.js/PostgreSQL runtime built from the pinned upstream tag and run under
supervisord on port `8080`, with `/v1/health` and `/v1/ready` probes, backed by
the opencharly `postgresql` candy.

| Property | Value |
|---|---|
| Service | `crabbox-coordinator` (priority 20, `restart: always`) |
| Port | `8080` (HTTP API + web portal) |
| Endpoints | `GET /v1/health`, `GET /v1/ready` |
| Requires | `layer-nodejs`, `layer-supervisord`, `pod-postgresql`, `layer-gh` |
| Runtime | Node.js ≥22.12, built from pinned `v0.51.0` |
| Build | fetch pinned tag (annotated → peeled commit) → `npm ci --include=dev` → `build:node` → `npm prune --omit=dev` |
| Auth | deploy-time: shared-token (`CRABBOX_SHARED_TOKEN` + `_OWNER`) or GitHub OAuth — none shipped by default |

The runtime start wrapper assembles `DATABASE_URL` from deploy-provided
`POSTGRES_*` env (supervisord cannot expand variables) and creates the
`crabbox` / `crabbox_jobs` schemas on startup. This is the **local,
single-replica** deployment; Cloudflare Workers remains the production
alternative.

## How to use it

```sh
charly box build <box-composing-crabbox-coordinator> && charly start <box>
curl -s http://127.0.0.1:8080/v1/health
```

Then log the CLI into the broker (from the `layer-crabbox` CLI candy in the same
box):

```sh
crabbox login --url http://127.0.0.1:8080 --token-stdin
crabbox doctor
```

## Layout

- `charly.yml` — the `crabbox-coordinator` candy entity plus its `skill:` entity.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `CHANGELOG/` — per-CalVer history.
- `README.md` — this user overview.

## Related

- Owning skill: `/charly-crabbox:crabbox-coordinator` — the service properties,
  the deploy env, and the local deployment recipe.
- `/charly-tools:crabbox` — the CLI candy (layer-crabbox).
- `/charly-check:crabbox` — the `crabbox:` check verb (plugin-crabbox).
- `/charly-infrastructure:postgresql` — the backing database candy.
- [`opencharly/charly`](https://github.com/opencharly/charly) — the charly CLI and image builder
- [`opencharly/opencharly`](https://github.com/opencharly/opencharly) — the umbrella
