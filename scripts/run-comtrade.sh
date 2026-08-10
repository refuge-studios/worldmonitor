#!/bin/sh
# Isolated runner for seed-comtrade-bilateral-hs4.mjs — excluded from
# run-seeders.sh's main loop (see the exclusion comment there) because it
# routinely runs to the full 1800s timeout against UN Comtrade's slow
# bilateral-trade API, which would starve every seeder after it in that
# sequential loop. Given its own schedule instead (see crontab: daily,
# guarded by flock + an outer timeout independent of this one).
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$PROJECT_DIR/.env"
  set +a
fi

if [ -n "${REDIS_TOKEN:-}" ]; then
  UPSTASH_REDIS_REST_TOKEN="$REDIS_TOKEN"
fi
UPSTASH_REDIS_REST_URL="${UPSTASH_REDIS_REST_URL:-http://localhost:8079}"
if [ -z "${UPSTASH_REDIS_REST_TOKEN:-}" ]; then
  echo "ERROR: REDIS_TOKEN (or UPSTASH_REDIS_REST_TOKEN) is required." >&2
  exit 1
fi
export UPSTASH_REDIS_REST_URL UPSTASH_REDIS_REST_TOKEN

exec node "$SCRIPT_DIR/seed-comtrade-bilateral-hs4.mjs"
