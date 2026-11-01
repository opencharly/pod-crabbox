# AGENTS.md — pod-crabbox

The CachyOS **lease base image** for the Crabbox `containerd` provider: the
`pod-crabbox` image (`charly.yml`) and the `/crabbox` guest contract it installs
(`candy/crabbox-guest/`). The variants are their own repos and import this image
at a pinned tag.

Canonical files:

- `charly.yml` — the `pod-crabbox` image: `base: cachyos.cachyos`, `user: crabbox`,
  the lease entrypoint, and the `crabbox-guest` candy.
- `candy/crabbox-guest/charly.yml` — the contract candy: package list, port 2222,
  the plan steps that install the scripts/unit/config, and the deterministic
  `check:` steps.
- `candy/crabbox-guest/{bootstrap.sh,lease-init.sh,ready.sh,crabbox-bootstrap.service,sshd_config.conf}`
  — the contract's own files, copied into the image by the candy.
- `README.md` — user overview only; never agent guidance.

## Load these skills first (R0)

- `/charly-image:image` — the `candy:` image entry (base, user, entrypoint, candy).
- `/charly-image:layer` — the candy body: `distro:` packages, `port:`, plan step
  verbs, and the `check:` surface.
- `/charly-distros:cachyos` — the CachyOS base, its import namespace and its
  Arch-derived package/build semantics.
- `/charly-check:check` — the check verbs, the ADE requirement, and the R10 gate.
- `/charly-internals:git-workflow` — before any git/PR action.

## What is unique here

- **Two init modes, one input path.** Direct mode: the image entrypoint
  (`/usr/local/bin/crabbox-lease-init`) applies the inputs and ends in
  `exec sshd -D`. Systemd mode: the `pod-crabbox-systemd` variant enables
  `sshd.service` + `crabbox-bootstrap.service`. Both read the read-only
  `/crabbox` directory — never `/run`, which systemd covers with a tmpfs.
- **This candy ships the systemd unit but never enables it.** Enabling a unit
  would select systemd for the base image, which runs without it in direct mode.
  Enabling is the systemd variant's decision.
- **Inputs are written temp + `mv`, and read once.** A krun guest's virtiofs can
  serve an in-place rewrite torn for up to 5 s; the bootstrap copies each input to
  a local file and never rewrites an input in place.
- **Readiness is usability, not SSH reachability.** The consumer runs
  `/usr/local/libexec/crabbox/ready` over SSH after the port answers and polls it
  until exit 0, reporting the elapsed time. It asserts the user, passwordless sudo,
  the 2222 listener, and that supplied inputs were consumed.
- **The port is 2222, in the candy.** The image declares no `port:` — boxes inherit
  the candy's port through the base chain.
- **Never `seccomp=unconfined` and never `--no-sandbox`.** The variant that needs a
  sandbox ships the narrow seccomp profile; this base does not weaken the boundary.

## Build / validate / test

- `charly box validate` at the repo root — the structural check.
- `charly box generate pod-crabbox` — inspect the emitted Containerfile and the
  baked `ai.opencharly.description` plan, which is what the validator reads.
- `charly check box pod-crabbox` — the build-scope checks (the binaries, the uid-1000
  user, the SSH drop-in, `sshd -t`, the bootstrap unit).
- The live witness for a lease is a Crabbox bed that runs the image under
  `containerd` and drives SSH + the readiness hook; a host without that venue skips
  it visibly.

## Landing

- PR-only. Every change lands through a pull request; the org-required
  `charly/pr-validator` validates the diff and body and arms native auto-merge on
  PASS. Direct pushes to `main` are blocked.
- History lives in `CHANGELOG/` (written by `tag-on-merge` at merge time); the PR
  body IS the changelog.
- The authoritative rulebook is the umbrella `AGENTS.md` in
  `opencharly/opencharly`. Do not restate its rules here.
