# pod-crabbox

The CachyOS **lease base image** for the Crabbox `containerd` provider — the
image a `crabbox` lease runs from. Every `pod-crabbox-<variant>` image
(`systemd`, `desktop`, `browser`, `code`, `tailscale`, `nested`, `k3s`, …) is
its own repo and imports this one at a pinned tag
(`base: pod-crabbox.pod-crabbox`).

## The `/crabbox` SSH contract

| Property | Value |
|---|---|
| Base | CachyOS (`cachyos.cachyos`) |
| SSH | `sshd` on **2222**, public-key only, user `crabbox` |
| Sudo | `crabbox` has passwordless sudo (`/etc/sudoers.d/crabbox`) |
| Tools | `git rsync curl sudo python3 jq tmux flock iproute2 openssl` |
| Inputs | read-only `/crabbox`: `authorized_keys`, `lease.env`, `bootstrap.sh` |
| Direct mode | `/usr/local/bin/crabbox-lease-init` → `exec sshd -D` |
| Systemd mode | `sshd.service` + `crabbox-bootstrap.service` (shipped, not enabled) |
| Readiness | `/usr/local/libexec/crabbox/ready` — polled over SSH until exit 0 |

The consumer writes the inputs temp + `mv`; the bootstrap reads each once into a
local copy, applies `authorized_keys` to the lease user, sources `lease.env`, runs
the deployment's `bootstrap.sh`, then records `/var/lib/crabbox/bootstrapped`.

Readiness is not SSH readiness: after the port answers, the consumer runs the
readiness hook over SSH and polls it until it exits 0, reporting the elapsed time
rather than a pass/fail alone. The hook asserts the user, passwordless sudo, the
listener on 2222, and — when inputs were supplied — that the bootstrap consumed
them.

## How to use it

```sh
charly box build pod-crabbox
charly check box pod-crabbox
```

A variant imports it rather than copying it:

```yaml
import:
    - crabbox: '@github.com/opencharly/pod-crabbox:<tag>'
pod-crabbox-systemd:
    candy:
        base: crabbox.pod-crabbox
        # … the variant's own init and layers
```

The image tag and the git tag are the same build: `pod-crabbox:<tag>` names
`ghcr.io/opencharly/pod-crabbox:<tag>`.

## Layout

- `charly.yml` — the `pod-crabbox` image (CachyOS base + the lease contract).
- `candy/crabbox-guest/` — the `/crabbox` contract candy: the entrypoint, the
  shared bootstrap, the readiness hook, the systemd oneshot and the SSH drop-in.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `CHANGELOG/` — per-CalVer history.

## Related

- [`opencharly/pod-crabbox-coordinator`](https://github.com/opencharly/pod-crabbox-coordinator)
  — the local Crabbox coordinator (the control plane a lease is requested from).
- [`opencharly/layer-crabbox`](https://github.com/opencharly/layer-crabbox) — the
  `crabbox` CLI candy.
- [`opencharly/plugin-crabbox`](https://github.com/opencharly/plugin-crabbox) — the
  `crabbox:` check verb.
