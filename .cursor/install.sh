#!/usr/bin/env bash
# Idempotent repository bootstrap for the Database Lab (KeyDB) environment.
#
# The repository is a study workspace: Go is the language for isolated
# experiment modules, and KeyDB (Redis-compatible) is the database under study.
# This script ensures both toolchains are available and prepares any experiment
# Go modules that already exist. It is safe to run repeatedly.
set -euo pipefail

log() { printf '[install] %s\n' "$*"; }

log "Go toolchain: $(go version)"

# --- Ensure the KeyDB server + CLI are installed --------------------------------
# KeyDB has no native Ubuntu 24.04 (noble) package; the jammy packages are the
# vendor-recommended choice and are compatible. We install "keydb-tools" (the
# binaries: keydb-server, keydb-cli, keydb-benchmark) rather than the
# "keydb-server" service package, whose postinstall assumes systemd and fails in
# a container. When booting from a prebuilt snapshot KeyDB is already present, so
# this whole block is skipped.
if command -v keydb-server >/dev/null 2>&1; then
  log "KeyDB already installed: $(keydb-server --version)"
else
  log "Installing KeyDB (jammy packages) ..."
  sudo wget -qO /etc/apt/trusted.gpg.d/keydb.gpg https://download.keydb.dev/open-source-dist/keyring.gpg
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/keydb.gpg] https://download.keydb.dev/open-source-dist jammy main" \
    | sudo tee /etc/apt/sources.list.d/keydb.list >/dev/null
  sudo apt-get update -o Acquire::Retries=3
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y keydb-tools
  log "Installed KeyDB: $(keydb-server --version)"
fi

# --- Best-effort prep of any existing experiment modules ------------------------
# Each experiment lives in its own directory with its own go.mod. None exist yet;
# when they do, warm their module caches. Failures here (e.g. offline) must not
# fail environment setup.
shopt -s nullglob
found_module=0
while IFS= read -r -d '' modfile; do
  found_module=1
  moddir="$(dirname "$modfile")"
  log "Preparing Go module: $moddir"
  ( cd "$moddir" && go mod download ) || log "warning: 'go mod download' failed in $moddir (continuing)"
done < <(find keydb/experiments -name go.mod -print0 2>/dev/null)
[ "$found_module" -eq 0 ] && log "No experiment Go modules found yet (expected for a fresh lab)."

log "Install complete."
