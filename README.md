# pod-crabbox

The `pod-crabbox` candy of the [opencharly/charly](https://github.com/opencharly/charly)
candy library, as a standalone repo (kind-prefixed naming). The candy manifest lives at
the repo root; the charly resolver fetches this repo at the pinned tag.

Installs and supervises the [Crabbox](https://github.com/openclaw/crabbox)
**coordinator** (Node.js/PostgreSQL runtime) — the broker for the fully-local
Crabbox control plane: lease state, run history, spend caps, and cleanup — built
from the pinned upstream tag, backed by the opencharly `postgresql` candy, on
port 8080 with `/v1/health` + `/v1/ready` probes.

```sh
charly box build <box-composing-crabbox-coordinator> && charly start <box>
curl -s http://127.0.0.1:8080/v1/health
```