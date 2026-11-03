#!/bin/bash
# /usr/local/bin/crabbox-lease-init — the DIRECT-mode lease entrypoint.
#
# Direct mode applies the /crabbox inputs, then ends in `exec sshd -D`.
#
# Systemd mode is the pod-crabbox-systemd variant: systemd is PID 1, and
# sshd.service + crabbox-bootstrap.service own the same lifecycle, so this
# entrypoint is not used there. The guard makes that explicit rather than
# starting a second sshd if the image is ever run under `--systemd=always`.
set -euo pipefail

if [ "$(ps -p 1 -o comm=)" = systemd ]; then
    exit 0
fi

/usr/local/libexec/crabbox/bootstrap.sh

# sshd needs its privilege-separation directory. /run is a runtime tmpfs, so it
# cannot be created at image build time.
install -d -m 0755 /run/sshd

exec /usr/sbin/sshd -D -e
