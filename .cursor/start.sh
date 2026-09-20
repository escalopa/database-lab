#!/usr/bin/env bash
# Start the KeyDB service for the Database Lab environment.
#
# Runs on every boot. Ensures the Docker daemon is up, then brings up the KeyDB
# container defined in keydb.compose.yml. Idempotent: `compose up -d` reconciles
# an already-running container. Experiments connect over RESP at 127.0.0.1:6379.
set -euo pipefail

CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$CURSOR_DIR/lib.sh"

log() { printf '[start] %s\n' "$*"; }

ensure_dockerd

log "Bringing up KeyDB container ..."
sudo docker compose -f "$COMPOSE_FILE" up -d

# Wait until KeyDB answers on the published port.
for _ in $(seq 1 60); do
  if sudo docker exec keydb keydb-cli ping 2>/dev/null | grep -q PONG; then
    log "KeyDB is ready: $(sudo docker exec keydb keydb-cli ping)"
    log "Version: $(sudo docker exec keydb keydb-server --version)"
    log "Reachable on 127.0.0.1:6379 (try: docker exec -it keydb keydb-cli)"
    exit 0
  fi
  sleep 0.5
done

echo "[start] ERROR: KeyDB did not become ready. Container logs:" >&2
sudo docker compose -f "$COMPOSE_FILE" logs --tail 30 keydb >&2 || true
exit 1
