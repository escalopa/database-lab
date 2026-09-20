#!/usr/bin/env bash
# Idempotent repository bootstrap for the Database Lab (KeyDB) environment.
#
# The repository is a study workspace: Go is the language for isolated
# experiment modules, and KeyDB (Redis-compatible) is the database under study.
# KeyDB runs in Docker via the official image, which keeps setup simple and
# avoids OS-package quirks. This script installs the Docker toolchain, pre-pulls
# the KeyDB image, and prepares any experiment Go modules. Safe to run repeatedly.
set -euo pipefail

CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$CURSOR_DIR/lib.sh"

log() { printf '[install] %s\n' "$*"; }

log "Go toolchain: $(go version)"

# --- Ensure the Docker toolchain is installed -----------------------------------
# When booting from a prebuilt snapshot these are already present and this block
# is skipped.
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  log "Docker already installed: $(docker --version)"
else
  log "Installing Docker (docker.io, compose v2, fuse-overlayfs) ..."
  sudo apt-get update -o Acquire::Retries=3
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    docker.io docker-compose-v2 fuse-overlayfs uidmap
  # fuse3 ships an interactive conffile prompt; keep the packaged default.
  sudo DEBIAN_FRONTEND=noninteractive dpkg --configure -a --force-confdef --force-confold || true
  log "Installed Docker: $(docker --version)"
fi

# Let the ubuntu user run docker without sudo in future interactive sessions.
sudo groupadd -f docker
sudo usermod -aG docker "${USER:-ubuntu}" || true

# Configure the daemon's storage driver for the nested-container environment.
sudo mkdir -p /etc/docker
if [ ! -f /etc/docker/daemon.json ]; then
  echo '{ "storage-driver": "fuse-overlayfs" }' | sudo tee /etc/docker/daemon.json >/dev/null
fi

# --- Pre-pull the KeyDB image so first boot is fast -----------------------------
ensure_dockerd
log "Pulling KeyDB image ..."
sudo docker compose -f "$COMPOSE_FILE" pull

# --- Best-effort prep of any existing experiment modules ------------------------
# Each experiment lives in its own directory with its own go.mod. None exist yet;
# when they do, warm their module caches. Failures here must not fail setup.
found_module=0
while IFS= read -r -d '' modfile; do
  found_module=1
  moddir="$(dirname "$modfile")"
  log "Preparing Go module: $moddir"
  ( cd "$moddir" && go mod download ) || log "warning: 'go mod download' failed in $moddir (continuing)"
done < <(find keydb/experiments -name go.mod -print0 2>/dev/null)
[ "$found_module" -eq 0 ] && log "No experiment Go modules found yet (expected for a fresh lab)."

log "Install complete."
