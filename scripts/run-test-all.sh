#!/bin/bash
# Run a plugin's deterministic test-all.sh inside the devcontainer.
# Usage: scripts/run-test-all.sh [path/to/plugin]
# Defaults to /workspace/plugins/inventree-flat-bom-generator

set -e

PLUGIN_DIR="${1:-/workspace/plugins/inventree-flat-bom-generator}"
SERVER_LOG=/tmp/inventree-server.log

# Activate the named-volume venv, not the old bind-mounted dev/venv.
source /inventree-data/venv/bin/activate

cd /workspace/reference/inventree-source
invoke dev.server -a 0.0.0.0:8001 > "$SERVER_LOG" 2>&1 &
SERVER_PID=$!

trap 'kill "$SERVER_PID" 2>/dev/null || true' EXIT

for i in $(seq 1 60); do
  if curl -s http://localhost:8001/api/system/health/ > /dev/null; then
    break
  fi
  sleep 2
done

if ! curl -s http://localhost:8001/api/system/health/ > /dev/null; then
  echo "ERROR: InvenTree server did not become healthy" >&2
  tail -30 "$SERVER_LOG" >&2
  exit 1
fi

cd "$PLUGIN_DIR"
./test-all.sh
