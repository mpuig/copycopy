#!/usr/bin/env bash
# Package the app bundle into dist/CopyCopy.app.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

exec "$ROOT_DIR/build.sh"

