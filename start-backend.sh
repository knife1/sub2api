#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"

export http_proxy=
export https_proxy=
export all_proxy=
unset http_proxy https_proxy all_proxy

command -v brew >/dev/null 2>&1 || {
  echo "Homebrew not found. Install Homebrew first."
  exit 1
}

command -v go >/dev/null 2>&1 || {
  echo "Go not found. Install it with: brew install go"
  exit 1
}

command -v psql >/dev/null 2>&1 || {
  echo "PostgreSQL client not found. Install it with: brew install postgresql@16"
  exit 1
}

command -v redis-server >/dev/null 2>&1 || {
  echo "Redis not found. Install it with: brew install redis"
  exit 1
}

echo "Starting PostgreSQL and Redis..."
brew services start postgresql@16 >/dev/null
brew services start redis >/dev/null

echo "Ensuring local PostgreSQL database exists..."
createuser -h 127.0.0.1 -U "$(whoami)" sub2api 2>/dev/null || true
createdb -h 127.0.0.1 -U "$(whoami)" -O sub2api sub2api 2>/dev/null || true

cd "$BACKEND_DIR"

if [ ! -f config.yaml ] || [ ! -f .installed ]; then
  export AUTO_SETUP=true
  export DATABASE_HOST=127.0.0.1
  export DATABASE_PORT=5432
  export DATABASE_USER=sub2api
  export DATABASE_PASSWORD=
  export DATABASE_DBNAME=sub2api
  export REDIS_HOST=127.0.0.1
  export REDIS_PORT=6379
  export REDIS_PASSWORD=
  export SERVER_HOST=127.0.0.1
  export SERVER_PORT=8080
  export ADMIN_EMAIL=admin@sub2api.local
  export ADMIN_PASSWORD=admin123
  export JWT_SECRET=local-dev-secret-local-dev-secret-local-dev-secret-local-dev-secret
  export TOTP_ENCRYPTION_KEY=local-dev-totp-local-dev-totp-local-dev-totp-local-dev-totp
fi

echo "Starting Sub2API backend at http://127.0.0.1:8080"
exec go run ./cmd/server
