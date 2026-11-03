#!/bin/bash
# /usr/local/libexec/crabbox/ready — the Crabbox readiness hook.
#
# The consumer runs this file over SSH AFTER the SSH port answers, and polls it
# until it exits 0 or the readiness timeout expires; it reports the ELAPSED TIME
# rather than a pass/fail alone. It must therefore assert that the lease is
# USABLE, not merely SSH-reachable, and it must be idempotent and side-effect
# free. It never replaces SSH readiness — it runs after it.
set -euo pipefail

# The contract user exists and can escalate without a password.
getent passwd crabbox >/dev/null
if [ "$(id -un)" = crabbox ]; then
    sudo -n true
fi

# sshd is listening on the contract port.
ss -ltn 'sport = :2222' | grep -q LISTEN

# When the consumer supplied inputs, the shared bootstrap must have applied
# them; a lease whose inputs were written but never consumed is not ready.
if [ -e /crabbox/authorized_keys ] || [ -e /crabbox/lease.env ]; then
    [ -f /var/lib/crabbox/bootstrapped ]
fi
