#!/usr/bin/env bash
# Start a local KeyDB server for the Database Lab environment.
#
# Runs on every boot. Idempotent: if a server is already answering on the port
# it does nothing. KeyDB is the database experiments connect to over RESP
# (127.0.0.1:6379).
set -euo pipefail

HOST=127.0.0.1
PORT=6379
BASE="$HOME/.local/keydb"
DATA_DIR="$BASE/data"
PIDFILE="$BASE/keydb.pid"
LOGFILE="$BASE/keydb.log"

log() { printf '[start] %s\n' "$*"; }

if ! command -v keydb-server >/dev/null 2>&1; then
  echo "[start] ERROR: keydb-server not found. Run .cursor/install.sh first." >&2
  exit 1
fi

# Already up? Nothing to do.
if keydb-cli -h "$HOST" -p "$PORT" ping 2>/dev/null | grep -q PONG; then
  log "KeyDB already running on $HOST:$PORT."
  exit 0
fi

# Clean up a stale pidfile whose process is gone.
if [ -f "$PIDFILE" ] && ! kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  rm -f "$PIDFILE"
fi

mkdir -p "$DATA_DIR"

log "Launching keydb-server on $HOST:$PORT ..."
keydb-server \
  --daemonize yes \
  --bind "$HOST" \
  --port "$PORT" \
  --dir "$DATA_DIR" \
  --pidfile "$PIDFILE" \
  --logfile "$LOGFILE" \
  --save ''

# Wait for readiness.
for _ in $(seq 1 40); do
  if keydb-cli -h "$HOST" -p "$PORT" ping 2>/dev/null | grep -q PONG; then
    log "KeyDB is ready: $(keydb-cli -h "$HOST" -p "$PORT" ping)"
    keydb-cli -h "$HOST" -p "$PORT" info server | grep -E 'redis_version|multithreading|server_threads' || true
    exit 0
  fi
  sleep 0.25
done

echo "[start] ERROR: KeyDB did not become ready. Recent log:" >&2
tail -20 "$LOGFILE" >&2 || true
exit 1
