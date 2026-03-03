#!/usr/bin/env bash
set -euo pipefail

DUMP_PATH="${1:-}"

if [[ -z "${DUMP_PATH}" ]]; then
  echo "Usage: bash ingest/load_sql_dump.sh path/to/dump.sql"
  exit 1
fi

if [[ ! -f "${DUMP_PATH}" ]]; then
  echo "File not found: ${DUMP_PATH}"
  exit 1
fi

echo "Loading SQL dump into Postgres..."
cat "${DUMP_PATH}" | docker compose exec -T postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"

echo "✅ SQL dump load complete."