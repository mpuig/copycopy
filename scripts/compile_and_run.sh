#!/usr/bin/env bash
# Kill running instances, build, launch, verify.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="${ROOT_DIR}/dist/CopyCopy.app"
APP_PROCESS_PATTERN="CopyCopy.app/Contents/MacOS/CopyCopy"

log()  { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

kill_all_copycopy() {
  for _ in {1..10}; do
    pkill -f "${APP_PROCESS_PATTERN}" 2>/dev/null || true
    pkill -x "CopyCopy" 2>/dev/null || true
    if ! pgrep -f "${APP_PROCESS_PATTERN}" >/dev/null 2>&1 && ! pgrep -x "CopyCopy" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.3
  done
}

log "==> Killing existing CopyCopy instances"
kill_all_copycopy

log "==> Building"
"${ROOT_DIR}/build.sh"

log "==> Launching"
open -n "${APP_BUNDLE}"

log "==> Verifying process stays alive"
sleep 1
if pgrep -f "${APP_PROCESS_PATTERN}" >/dev/null 2>&1; then
  log "OK: CopyCopy is running."
else
  fail "App exited immediately. Check crash logs in Console.app (User Reports)."
fi

