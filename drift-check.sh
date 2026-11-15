#!/usr/bin/env bash

set -euo pipefail

PLAYBOOK="${1:-site.yml}"
LOG="drift-check-$(date +%Y%m%dT%H%M%S).log"

if ! ansible-playbook "$PLAYBOOK" --check --diff -K > "$LOG" 2>&1; then
    echo "ERROR: playbook failed to run" >&2
    exit 2
fi

changed="$(grep -oE 'changed=[0-9]+' "$LOG" | head -1 | cut -d= -f2)" || changed=""

if [[ -z "$changed" ]]; then
    echo "ERROR: could not parse a changed= count from $LOG" >&2
    exit 2
fi

if [[ "$changed"  -gt 0 ]]; then
    echo "DRIFT DETECTED: ${changed} tasks would change (see $LOG)"
    grep -E '^(TASK|changed:)' "$LOG" || true
    exit 1
fi

echo "NO DRIFT: host matches baseline (see $LOG)"
exit 0
