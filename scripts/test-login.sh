#!/bin/bash
# Playwright login test for the InvenTree dev server.
# Usage: scripts/test-login.sh [SERVER_URL]
# Defaults to http://localhost:8001 and reads credentials from
# /workspace/config/servers.json (admin/admin fallback).

set -e

SERVER_URL="${1:-${SERVER_URL:-http://localhost:8001}}"
HEALTH_URL="${SERVER_URL}/api/system/health/"
SERVER_PID=""

INVENTREE_HOME="${INVENTREE_HOME:-/workspace/reference/inventree-source}"
INVENTREE_FRONTEND_DIR="$INVENTREE_HOME/src/frontend"

# Activate the devcontainer venv so invoke and python scripts find the right tools.
if [[ -f /inventree-data/venv/bin/activate ]]; then
  # shellcheck source=/dev/null
  source /inventree-data/venv/bin/activate
fi

# Let the Node script resolve Playwright from the InvenTree frontend install.
export NODE_PATH="$INVENTREE_FRONTEND_DIR/node_modules${NODE_PATH:+:$NODE_PATH}"

is_server_healthy() {
  curl -s "$HEALTH_URL" > /dev/null
}

start_server() {
  echo "No healthy InvenTree server found; starting one on $SERVER_URL..."
  cd "$INVENTREE_HOME"
  invoke dev.server -a 0.0.0.0:8001 > /tmp/inventree-server.log 2>&1 &
  SERVER_PID=$!
  cd - >/dev/null

  trap 'if [ -n "$SERVER_PID" ]; then kill "$SERVER_PID" 2>/dev/null || true; fi' EXIT

  for i in $(seq 1 60); do
    if is_server_healthy; then
      echo "InvenTree server is healthy ($HEALTH_URL)"
      return 0
    fi
    sleep 2
  done

  echo "ERROR: InvenTree server did not become healthy" >&2
  tail -30 /tmp/inventree-server.log >&2
  return 1
}

# Ensure Playwright browsers and system dependencies are present.
# The InvenTree frontend already provides the Playwright package; we only need
# to download the chromium binary if it is missing.
if [[ -d "$INVENTREE_FRONTEND_DIR/node_modules/playwright" ]]; then
  echo "Installing Playwright chromium (if missing)..."
  cd "$INVENTREE_FRONTEND_DIR"
  npx playwright install chromium
  sudo npx playwright install-deps chromium
  cd - >/dev/null
else
  echo "ERROR: Playwright not found in $INVENTREE_FRONTEND_DIR/node_modules" >&2
  exit 1
fi

if ! is_server_healthy; then
  start_server
fi

echo "Running Playwright login test against $SERVER_URL..."
node /workspace/scripts/test-login.js
