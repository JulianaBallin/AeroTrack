#!/usr/bin/env bash
# Reproduces the AeroTrack project end to end: database, Hop project
# registration, workflow execution and dashboard export.
#
# Requirements: Docker + Docker Compose, Java 21, Apache Hop 2.18+ on PATH
# (or set HOP_HOME below), Python 3.
#
# Usage: scripts/replicate.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

info()  { printf '\n[replicate] %s\n' "$1"; }
fail()  { printf '\n[replicate] ERROR: %s\n' "$1" >&2; exit 1; }

command -v docker >/dev/null 2>&1 || fail "docker is not installed or not on PATH"
command -v python3 >/dev/null 2>&1 || fail "python3 is not installed or not on PATH"

HOP_RUN="${HOP_RUN:-hop-run.sh}"
HOP_CONF="${HOP_CONF:-hop-conf.sh}"
command -v "$HOP_RUN" >/dev/null 2>&1 || fail "hop-run.sh not found. Set HOP_RUN to its full path or add Apache Hop's hop/ folder to PATH."
command -v "$HOP_CONF" >/dev/null 2>&1 || fail "hop-conf.sh not found. Set HOP_CONF to its full path or add Apache Hop's hop/ folder to PATH."

info "1/4 Starting the database (docker compose)"
(cd "$REPO_DIR/database" && docker compose up -d)

info "Waiting for PostgreSQL to become healthy"
for _ in $(seq 1 30); do
  if docker exec aerotrack-hop-postgres pg_isready -U aerotrack -d aerotrack >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
docker exec aerotrack-hop-postgres pg_isready -U aerotrack -d aerotrack >/dev/null 2>&1 \
  || fail "PostgreSQL did not become ready in time"

info "2/4 Registering the aerotrack project in Apache Hop (safe to repeat)"
if "$HOP_CONF" -pl 2>/dev/null | grep -q "^  aerotrack "; then
  echo "  project 'aerotrack' is already registered, skipping"
else
  "$HOP_CONF" -pc -p aerotrack -ph "$REPO_DIR/hop" -pf project-config.json -pkf \
    -ps "AeroTrack - Module 6 Apache Hop final project" >/dev/null
fi

info "3/4 Running the workflow (ingestion, treatment and consolidation)"
"$HOP_RUN" -j aerotrack -f "$REPO_DIR/hop/workflows/wf_air_quality_orchestration.hwf" -r local -l Basic

info "4/4 Exporting dashboard indicators"
"$REPO_DIR/scripts/export_dashboard.sh"

info "Done. Serve the dashboard with:"
echo "  cd \"$REPO_DIR/dashboard\" && python3 -m http.server 8000"
echo "  then open http://localhost:8000"
