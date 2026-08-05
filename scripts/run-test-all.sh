#!/bin/bash
# Run a plugin's deterministic test-all.sh inside the devcontainer.
# Usage: scripts/run-test-all.sh [path/to/plugin]
# Defaults to /workspace/plugins/inventree-flat-bom-generator
# If an InvenTree server is already healthy on port 8001, it is reused.

set -e

PLUGIN_DIR="${1:-/workspace/plugins/inventree-flat-bom-generator}"
SERVER_LOG=/tmp/inventree-server.log
HEALTH_URL="http://localhost:8001/api/system/health/"
SERVER_PID=""

# Activate the named-volume venv, not the old bind-mounted dev/venv.
source /inventree-data/venv/bin/activate

is_server_healthy() {
  curl -s "$HEALTH_URL" > /dev/null
}

if is_server_healthy; then
  echo "Reusing existing InvenTree server at $HEALTH_URL"
else
  echo "No healthy InvenTree server found; starting one..."

  cd /workspace/reference/inventree-source
  invoke dev.server -a 0.0.0.0:8001 > "$SERVER_LOG" 2>&1 &
  SERVER_PID=$!
  cd - >/dev/null

  trap 'if [ -n "$SERVER_PID" ]; then kill "$SERVER_PID" 2>/dev/null || true; fi' EXIT

  for i in $(seq 1 60); do
    if is_server_healthy; then
      break
    fi
    sleep 2
  done

  if ! is_server_healthy; then
    echo "ERROR: InvenTree server did not become healthy" >&2
    tail -30 "$SERVER_LOG" >&2
    exit 1
  fi
fi

cd "$PLUGIN_DIR"
./test-all.sh
