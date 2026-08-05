#!/bin/bash
# Build an InvenTree plugin inside the devcontainer.
# Usage: scripts/build-plugin.sh <plugin-folder-name> [options]
# Example: scripts/build-plugin.sh inventree-flat-bom-generator

set -e

NO_VERSION_BUMP=""
NO_PRE_COMMIT=""
CLEAN=""
SKIP_FRONTEND=""

print_usage() {
    cat <<EOF
Usage: $(basename "$0") <plugin-folder-name> [options]

Options:
  --no-version-bump   Do not auto-increment PLUGIN_VERSION/package.json version
  --no-pre-commit     Skip pre-commit hooks
  --clean             Remove dist/, build/, and *.egg-info/ before building
  --skip-frontend     Build only the Python package
  -h, --help          Show this help

Examples:
  $(basename "$0") inventree-flat-bom-generator
  $(basename "$0") inventree-flat-bom-generator --clean --no-version-bump
EOF
}

# Parse args
PLUGIN_NAME=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-version-bump) NO_VERSION_BUMP=1; shift ;;
        --no-pre-commit) NO_PRE_COMMIT=1; shift ;;
        --clean) CLEAN=1; shift ;;
        --skip-frontend) SKIP_FRONTEND=1; shift ;;
        -h|--help) print_usage; exit 0 ;;
        -*)
            echo "Unknown option: $1" >&2
            print_usage >&2
            exit 1
            ;;
        *)
            if [[ -n "$PLUGIN_NAME" ]]; then
                echo "Error: only one plugin name allowed" >&2
                print_usage >&2
                exit 1
            fi
            PLUGIN_NAME="$1"
            shift
            ;;
    esac
done

if [[ -z "$PLUGIN_NAME" ]]; then
    echo "Error: plugin folder name is required" >&2
    print_usage >&2
    exit 1
fi

# Resolve plugin path
if [[ -d "$PLUGIN_NAME" ]]; then
    PLUGIN_DIR="$(cd "$PLUGIN_NAME" && pwd)"
else
    PLUGIN_DIR="/workspace/plugins/$PLUGIN_NAME"
fi

if [[ ! -d "$PLUGIN_DIR" ]]; then
    echo "Error: plugin not found: $PLUGIN_DIR" >&2
    exit 1
fi

echo "=========================================="
echo "Building plugin: $PLUGIN_NAME"
echo "Plugin directory: $PLUGIN_DIR"
echo "=========================================="

# Activate the devcontainer venv
if [[ -f /inventree-data/venv/bin/activate ]]; then
    # shellcheck source=/dev/null
    source /inventree-data/venv/bin/activate
fi

cd "$PLUGIN_DIR"

# Discover Python package module (directory with __init__.py containing PLUGIN_VERSION)
MODULE_DIR=""
while IFS= read -r -d '' init_file; do
    if grep -q 'PLUGIN_VERSION' "$init_file" 2>/dev/null; then
        MODULE_DIR="$(dirname "$init_file")"
        break
    fi
done < <(find . -maxdepth 2 -name '__init__.py' -not -path './.venv/*' -not -path './node_modules/*' -not -path './dist/*' -not -path './build/*' -not -path './tests/*' -print0)

if [[ -z "$MODULE_DIR" ]]; then
    echo "Warning: could not find a Python package with PLUGIN_VERSION" >&2
fi

# Auto-increment patch version to avoid browser cache issues
if [[ -z "$NO_VERSION_BUMP" && -n "$MODULE_DIR" ]]; then
    echo ""
    echo ">>> Auto-incrementing patch version..."

    INIT_FILE="$MODULE_DIR/__init__.py"
    if [[ -f "$INIT_FILE" ]]; then
        CURRENT_VERSION=$(python - <<PY
import re
with open('$INIT_FILE', 'r', encoding='utf-8') as f:
    content = f.read()
match = re.search(r'PLUGIN_VERSION\s*=\s*"([0-9]+)\.([0-9]+)\.([0-9]+)"', content)
if match:
    major, minor, patch = match.groups()
    print(f'{major}.{minor}.{patch}')
PY
        ) || CURRENT_VERSION=""

        if [[ -n "$CURRENT_VERSION" ]]; then
            NEW_VERSION=$(python - <<PY
major, minor, patch = '$CURRENT_VERSION'.split('.')
print(f'{major}.{minor}.{int(patch) + 1}')
PY
            )

            python - <<PY
import re
init_path = '$INIT_FILE'
old = 'PLUGIN_VERSION = "$CURRENT_VERSION"'
new = 'PLUGIN_VERSION = "$NEW_VERSION"'
with open(init_path, 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace(old, new, 1)
with open(init_path, 'w', encoding='utf-8') as f:
    f.write(content)
print(f'Python version: $CURRENT_VERSION -> $NEW_VERSION')
PY

            # Sync frontend/package.json if it exists
            if [[ -f "frontend/package.json" ]]; then
                python - <<PY
import json, re
path = 'frontend/package.json'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()
new_content = re.sub(r'"version"\s*:\s*"[^"]+"', '"version": "$NEW_VERSION"', content, count=1)
with open(path, 'w', encoding='utf-8') as f:
    f.write(new_content)
print(f'Frontend version: $CURRENT_VERSION -> $NEW_VERSION')
PY
            fi
        else
            echo "Warning: could not parse PLUGIN_VERSION in $INIT_FILE" >&2
        fi
    else
        echo "Warning: __init__.py not found in module directory" >&2
    fi
elif [[ -n "$NO_VERSION_BUMP" ]]; then
    echo "Skipping version bump (--no-version-bump)"
fi

# Clean build artifacts if requested
if [[ -n "$CLEAN" ]]; then
    echo ""
    echo ">>> Cleaning build artifacts..."
    rm -rf dist build *.egg-info
    echo "Cleaned"
fi

# Determine if this plugin has a frontend
HAS_FRONTEND=0
if [[ -d "frontend" && -f "frontend/package.json" && -z "$SKIP_FRONTEND" ]]; then
    HAS_FRONTEND=1
fi

# Build frontend if it exists
if [[ "$HAS_FRONTEND" -eq 1 ]]; then
    if [[ -z "$NO_PRE_COMMIT" ]]; then
        echo ""
        echo ">>> Running pre-commit hooks (formatters) if available..."
        if command -v pre-commit >/dev/null 2>&1; then
            if pre-commit run --all-files; then
                echo "pre-commit completed without changes."
            else
                echo "Warning: pre-commit reported issues or modified files. Build will proceed." >&2
            fi
        else
            echo "pre-commit not found; skipping. To enable, install pre-commit in the venv."
        fi
    else
        echo "Skipping pre-commit hooks (--no-pre-commit)"
    fi

    echo ""
    echo ">>> Building frontend code..."
    pushd frontend >/dev/null

    if [[ ! -d "node_modules" ]] || [[ -z "$(ls -A node_modules 2>/dev/null)" ]]; then
        echo "Installing frontend dependencies..."
        if [[ -f "package-lock.json" ]]; then
            npm ci
        else
            npm install
        fi
    fi

    if [[ -f ".linguirc" ]]; then
        echo "Compiling translations..."
        npm run translate
    fi

    npm run build
    echo "[OK] Frontend built successfully"
    popd >/dev/null
elif [[ -d "frontend" && -n "$SKIP_FRONTEND" ]]; then
    echo "Skipping frontend build (--skip-frontend)"
fi

# Build Python package
echo ""
echo ">>> Building Python package..."

# Suppress setuptools warnings about test packages (expected)
export PYTHONWARNINGS='ignore::UserWarning'
python -m build
unset PYTHONWARNINGS

# Verify expected outputs
echo ""
echo "Build artifacts:"
WHEEL=$(find dist -maxdepth 1 -name '*.whl' -print -quit)
if [[ -z "$WHEEL" ]]; then
    echo "Error: Python build reported success but no .whl file was found in dist/" >&2
    exit 1
fi
echo "  [PACKAGE] $(basename "$WHEEL")"

if [[ "$HAS_FRONTEND" -eq 1 ]]; then
    PANEL_JS=$(find . -name 'Panel.js' -not -path './node_modules/*' -not -path './dist/*' -not -path './build/*' -print -quit)
    if [[ -z "$PANEL_JS" ]]; then
        echo "Warning: no Panel.js bundle found. Check the plugin's Vite output directory." >&2
    else
        echo "  [BUNDLE] $PANEL_JS"
    fi
fi

echo ""
echo "=========================================="
echo "Build complete: $(basename "$WHEEL")"
echo "=========================================="
