#!/bin/bash
# /usr/local/libexec/crabbox/bootstrap.sh — apply the Crabbox lease inputs.
#
# The consumer mounts the inputs READ-ONLY at /crabbox (never /run, which systemd
# covers with a tmpfs) and writes them temp + mv: `authorized_keys`, `lease.env`,
# `bootstrap.sh`. A krun guest's virtiofs can serve an in-place rewrite torn for
# up to 5 s, so every file is read ONCE, into a local copy, and an input is never
# rewritten in place. The script is idempotent: direct mode runs it from the
# entrypoint, systemd mode from crabbox-bootstrap.service.
set -euo pipefail

INPUT=/crabbox
USER_NAME=crabbox
HOME_DIR=$(getent passwd "$USER_NAME" | cut -d: -f6)

install -d -m 0755 /var/lib/crabbox

if [ -r "$INPUT/authorized_keys" ]; then
    install -d -m 0700 -o "$USER_NAME" -g "$USER_NAME" "$HOME_DIR/.ssh"
    install -m 0600 -o "$USER_NAME" -g "$USER_NAME" \
        "$INPUT/authorized_keys" "$HOME_DIR/.ssh/authorized_keys"
fi

if [ -r "$INPUT/lease.env" ]; then
    install -m 0600 "$INPUT/lease.env" /var/lib/crabbox/lease.env
    set -a
    # shellcheck disable=SC1091
    . /var/lib/crabbox/lease.env
    set +a
fi

if [ -r "$INPUT/bootstrap.sh" ]; then
    bash "$INPUT/bootstrap.sh"
fi

: > /var/lib/crabbox/bootstrapped
