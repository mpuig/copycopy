#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="${ROOT_DIR}/dist/CopyCopy.app"
BIN="${APP}/Contents/MacOS/CopyCopy"

log()  { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ -d "$APP" ]] || fail "Missing app bundle: $APP (run ./build.sh first)"
[[ -x "$BIN" ]] || fail "Missing executable: $BIN"

log "==> Checking architectures"
lipo -info "$BIN" || fail "lipo failed"

log "==> Checking SwiftPM resource bundles"
if ! ls "$APP/Contents/Resources/"*.bundle >/dev/null 2>&1; then
  fail "No .bundle files found in $APP/Contents/Resources (KeyboardShortcuts requires this)"
fi
if [[ ! -d "$APP/Contents/Resources/KeyboardShortcuts_KeyboardShortcuts.bundle" ]]; then
  fail "Missing KeyboardShortcuts resource bundle"
fi

log "==> Checking embedded frameworks (optional)"
if [[ -d "$APP/Contents/Frameworks/Sparkle.framework" ]]; then
  log "Sparkle.framework present"
else
  log "Sparkle.framework not present (OK if updates disabled)"
fi

log "==> Verifying code signature (best-effort)"
codesign --verify --deep --strict "$APP" || true
codesign -dv --verbose=2 "$APP" 2>&1 | sed -n '1,40p' || true

log "OK: bundle looks consistent."

