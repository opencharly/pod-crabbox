# AGENTS.md — pod-crabbox

Standalone candy repo for the `crabbox-coordinator` candy — the local Crabbox
Node.js/PostgreSQL coordinator, supervised on `8080` with `/v1/health` +
`/v1/ready` and backed by the opencharly `postgresql` candy. The candy lives in
`charly.yml` at the repo root: the `crabbox-coordinator:` entity with its `var`,
`require`, `env`, port, `service:`, `plan:` (the pinned-tag build and the inline
start wrapper), plus its `skill:` entity.

Canonical files:

- `charly.yml` — the `crabbox-coordinator` candy entity and its `skill:` entity.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `CHANGELOG/` — per-CalVer history.
- `README.md` — user overview only; never agent guidance.

## Load these skills first (R0)

- `/charly-crabbox:crabbox-coordinator` — the owning skill: service properties,
  the deploy env table, and the local deployment recipe. Load before editing,
  building, deploying, or troubleshooting this candy.
- `/charly-tools:crabbox` — the CLI candy (layer-crabbox) that pairs with this
  coordinator.
- `/charly-check:crabbox` — the `crabbox:` check verb (plugin-crabbox) used by the
  e2e bed.
- `/charly-infrastructure:postgresql` — the backing database candy.
- `/charly-image:layer` — the candy authoring reference (`charly.yml` schema,
  `var:` substitution, `plan:` step verbs, service declarations).
- `/charly-internals:git-workflow` — before any git/PR action.

## Build / validate / test

- `charly box validate` at the repo root — the structural check: the manifest
  must parse and validate at the installed charly.
- The merge gate is the **org-wide** `charly/pr-validator` (required check
  `validate / validate`, defined in `opencharly/.github`); this repo has **no**
  per-repo candy gate. Its only workflow file is
  `.github/workflows/tag-on-merge.yml`.
- The live R10 witness is the e2e bed: it logs the CLI into the broker and drives
  broker-backed `crabbox:` verb methods (leases / usage / events / logs) against
  it. The candy's own `check:` steps assert the built runtime, the wrapper, the
  supervised service, and live `/v1/health` + `/v1/ready` `200`s.

## Modify this repo

- Edit the `crabbox-coordinator:` candy entity in `charly.yml`; the `skill:`
  entity in the same file is the owning skill's source — a candy change and its
  skill change land together.
- The `CRABBOX_COORDINATOR_TAG` var pins the upstream build; a bump must keep the
  coordinator and CLI tags paired (v0.51.0+ pairs with the v0.51.0 CLI). The tag
  is annotated, so the plan dereferences it to its peeled commit.
- Keep the start wrapper's `DATABASE_URL` assembly and `pg_isready` wait in step
  with the postgresql candy's env contract (the wrapper is the inline `write:`
  step in the plan).
- The `skill:` entity is the source for `/charly-crabbox:crabbox-coordinator`;
  never edit the generated `SKILL.md` — regenerate it.

## Landing

- PR-only. Every change lands through a pull request; the org-required
  `charly/pr-validator` validates the diff and body and arms native auto-merge
  on PASS. Direct pushes to `main` are blocked.
- History lives in `CHANGELOG/` (written by `tag-on-merge` at merge time); the
  PR body IS the changelog.
- The authoritative rulebook is the umbrella `AGENTS.md` in
  `opencharly/opencharly` and `charly/AGENTS.md` in the charly repo. Do not
  restate its rules here.
