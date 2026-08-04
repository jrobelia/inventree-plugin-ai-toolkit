#!/bin/bash
set -e

echo "Running postCreateCommand.sh for InvenTree Plugin AI Toolkit..."

# Ensure expected paths are available, defaulting to the container layout.
INVENTREE_HOME="${INVENTREE_HOME:-/workspace/reference/inventree-source}"
INVENTREE_BACKEND_DIR="${INVENTREE_BACKEND_DIR:-$INVENTREE_HOME/src/backend}"
INVENTREE_DATA_DIR="${INVENTREE_DATA_DIR:-/inventree-data}"
INVENTREE_PY_ENV="${INVENTREE_PY_ENV:-$INVENTREE_DATA_DIR/venv}"
INVENTREE_CONFIG_FILE="${INVENTREE_CONFIG_FILE:-$INVENTREE_DATA_DIR/config.yaml}"
INVENTREE_SECRET_KEY_FILE="${INVENTREE_SECRET_KEY_FILE:-$INVENTREE_DATA_DIR/secret_key.txt}"
INVENTREE_OIDC_PRIVATE_KEY_FILE="${INVENTREE_OIDC_PRIVATE_KEY_FILE:-$INVENTREE_DATA_DIR/oidc.pem}"
INVENTREE_STATIC_ROOT="${INVENTREE_STATIC_ROOT:-$INVENTREE_DATA_DIR/static}"
INVENTREE_MEDIA_ROOT="${INVENTREE_MEDIA_ROOT:-$INVENTREE_DATA_DIR/media}"
INVENTREE_BACKUP_DIR="${INVENTREE_BACKUP_DIR:-$INVENTREE_DATA_DIR/backup}"

# Avoiding Dubious Ownership in Dev Containers for setup commands that use git
git config --global --add safe.directory /workspace
git config --global --add safe.directory /workspace/reference/inventree-source

# Remove existing gitconfig created by "Avoiding Dubious Ownership" step
# so that it gets copied from host to the container to have your global
# git config in container
rm -f /home/vscode/.gitconfig

# Create required directory structure under the data volume (not the bind mount).
mkdir -p "$INVENTREE_DATA_DIR" "$INVENTREE_STATIC_ROOT" "$INVENTREE_MEDIA_ROOT" "$INVENTREE_BACKUP_DIR"

# Seed the config file if this is a fresh data volume.
if [ ! -f "$INVENTREE_CONFIG_FILE" ]; then
    echo "Copying config file from $INVENTREE_BACKEND_DIR/InvenTree/config_template.yaml to $INVENTREE_CONFIG_FILE"
    cp "$INVENTREE_BACKEND_DIR/InvenTree/config_template.yaml" "$INVENTREE_CONFIG_FILE"
fi

# Create a Python virtual environment on the named volume. Do NOT use
# --system-site-packages; an isolated venv plus the requirements file below
# gives a repeatable environment. Do NOT use --upgrade-deps; install the
# core tools explicitly so their versions are controlled.
python3 -m venv "$INVENTREE_PY_ENV"

# Activate the new venv
. "$INVENTREE_PY_ENV/bin/activate"

# Upgrade the venv's core packaging tools explicitly before installing anything else.
python -m pip install --upgrade pip setuptools wheel

# Ensure the correct invoke is available for the InvenTree task runner.
python -m pip install invoke Pillow

# Install lint/test tooling needed by the plugin test-all.sh scripts.
python -m pip install ruff

# Install base level packages from InvenTree reference.
cd "$INVENTREE_HOME"
python -m pip install -Ur contrib/container/requirements.txt --require-hashes

# Run initial InvenTree server setup (migrations, static files, etc.).
invoke update -s

# Configure dev environment (ignore git hook errors).
set +e
invoke dev.setup-dev
set -e

# Install required frontend packages.
invoke int.frontend-install

# Set up plugin development configuration for FlatBOMGenerator.
echo "Setting up plugin development configuration..."
cd /workspace/plugins/inventree-flat-bom-generator/frontend
npm install

# Install Playwright browsers and system dependencies for E2E tests.
# Browsers live in the vscode user cache and are shared across plugin frontends.
echo "Installing Playwright browsers and system dependencies..."
npx playwright install chromium webkit
sudo npx playwright install-deps chromium webkit

echo ""
echo "=========================================="
echo "Devcontainer setup complete!"
echo "=========================================="
echo "InvenTree server: http://localhost:8001"
echo ""
echo "To start FlatBOMGenerator plugin dev server:"
echo "  cd /workspace/plugins/inventree-flat-bom-generator/frontend"
echo "  npm run dev"
echo ""
echo "Plugin dev server will run on http://localhost:5174"
echo "=========================================="
