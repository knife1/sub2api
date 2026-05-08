#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend"

export http_proxy=
export https_proxy=
export all_proxy=
unset http_proxy https_proxy all_proxy

command -v pnpm >/dev/null 2>&1 || {
  echo "pnpm not found. Install pnpm first."
  exit 1
}

cd "$FRONTEND_DIR"

if [ ! -d node_modules ]; then
  echo "Installing frontend dependencies..."
  pnpm install --registry=https://registry.npmjs.org
fi

echo "Starting Sub2API frontend at http://127.0.0.1:3000"
exec pnpm run dev -- --host 127.0.0.1 --port 3000
