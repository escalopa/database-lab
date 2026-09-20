#!/usr/bin/env bash
# Shared helpers for the Database Lab (KeyDB) environment scripts.

# Absolute path to the compose file, resolved relative to this library.
CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$CURSOR_DIR/keydb.compose.yml"

# Ensure the Docker daemon is running. Cloud Agent VMs have no systemd, so we
# start dockerd ourselves (idempotently) with the fuse-overlayfs storage driver
# required for the nested-container environment.
ensure_dockerd() {
  if sudo docker info >/dev/null 2>&1; then
    return 0
  fi
  sudo mkdir -p /etc/docker
  if [ ! -f /etc/docker/daemon.json ]; then
    echo '{ "storage-driver": "fuse-overlayfs" }' | sudo tee /etc/docker/daemon.json >/dev/null
  fi
  echo "[docker] starting dockerd ..."
  sudo bash -c 'nohup dockerd >/var/log/dockerd.log 2>&1 &'
  for _ in $(seq 1 60); do
    if sudo docker info >/dev/null 2>&1; then
      echo "[docker] dockerd is ready."
      return 0
    fi
    sleep 1
  done
  echo "[docker] ERROR: dockerd did not become ready. Recent log:" >&2
  sudo tail -30 /var/log/dockerd.log >&2 || true
  return 1
}
