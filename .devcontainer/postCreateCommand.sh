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

# Load a known-good demo dataset so integration and E2E tests have data.
# The demo-dataset branch must match the InvenTree release line. When
# reference/inventree-source is bumped to a new major/minor version, update
# the derivation below or pin to a known commit for that release.
echo "Deriving demo-dataset branch from InvenTree version..."
inventree_version=$(grep -E "^INVENTREE_SW_VERSION[[:space:]]*=[[:space:]]*'[^']+'" "$INVENTREE_HOME/src/backend/InvenTree/InvenTree/version.py" | sed -E "s/.*'([^']+)'.*/\1/") || inventree_version="1.4.2"
inventree_major=$(echo "$inventree_version" | cut -d. -f1)
inventree_minor=$(echo "$inventree_version" | cut -d. -f2)
demo_branch="${inventree_major}.${inventree_minor}.x"
echo "Loading demo dataset for InvenTree $inventree_version (branch: $demo_branch)..."
invoke dev.setup-test -i -b "$demo_branch" -p /inventree-data/demo-dataset

# The demo-dataset admin user may have an unknown password. Set it to the
# documented dev credentials so tests can log in without extra configuration.
echo "Setting dev admin credentials..."
python - <<'PY'
import os, sys
sys.path.insert(0, os.path.join(os.environ['INVENTREE_HOME'], 'src', 'backend', 'InvenTree'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'InvenTree.settings')
import django
django.setup()
from django.contrib.auth.models import User
u, _ = User.objects.get_or_create(
    username='admin',
    defaults={'email': 'admin@demo.inventree.org', 'is_superuser': True, 'is_staff': True}
)
u.set_password('admin')
u.save()
PY

# Install required frontend packages.
invoke int.frontend-install

# Install frontend dependencies for every plugin that has a frontend package.
# Each plugin's frontend/node_modules is a named Docker volume mounted over the
# workspace bind mount, so packages live on a real Linux filesystem and stay
# owned by the vscode user.
echo "Installing plugin frontend dependencies..."
for package_json in /workspace/plugins/*/frontend/package.json; do
    [ -f "$package_json" ] || continue
    frontend_dir=$(dirname "$package_json")
    plugin_name=$(basename "$(dirname "$frontend_dir")")
    echo "Installing frontend dependencies for $plugin_name..."
    cd "$frontend_dir"
    # The named volume for this node_modules is mounted over the workspace bind
    # mount and may initially be owned by root. Ensure it is owned by the
    # container user before npm writes into it.
    mkdir -p node_modules
    sudo chown -R "$(id -u):$(id -g)" node_modules
    # Vite build output lands in a sibling package's static/ directory, which is
    # on the workspace bind mount and may also be root-owned. Make it writable.
    find "$(dirname "$frontend_dir")" -maxdepth 2 -type d -name static -not -path "$frontend_dir/*" -exec sudo chown -R "$(id -u):$(id -g)" {} +
    if [ -f package-lock.json ]; then
        npm ci
    else
        # No lock file yet; create it once and then it can be tracked as the
        # source of truth for future `npm ci` runs.
        npm install
    fi
    # Install Playwright browsers and system dependencies for this plugin's
    # version of @playwright/test. Browsers live in the vscode user cache.
    if [ -d node_modules/@playwright/test ] || [ -d node_modules/playwright ]; then
        npx playwright install chromium webkit
        sudo npx playwright install-deps chromium webkit
    fi
    cd - >/dev/null
done

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
