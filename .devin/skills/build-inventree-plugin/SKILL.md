---
name: build-inventree-plugin
description: Build a packaged InvenTree plugin when the user or another skill wants a wheel, a frontend bundle, or pre-deploy packaging.
---

# Build an InvenTree plugin

**Purpose:** Produce a distributable Python wheel and compiled frontend bundle for any plugin in `plugins/`.

---

## One-liner

From the toolkit root, with the devcontainer running:

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "cd /workspace && bash scripts/build-plugin.sh /workspace/plugins/<PluginFolderName>"
```

If you are already inside the devcontainer:

```bash
bash scripts/build-plugin.sh /workspace/plugins/<PluginFolderName>
```

---

## Workflow

### 1. Resolve the plugin

Ask the user for the plugin folder name if it is not already in context. The folder is the name under `plugins/`, not the Python module name (e.g., `inventree-flat-bom-generator`, not `flat_bom_generator`).

**Completion criterion:** a valid `plugins/<PluginFolderName>` directory exists.

### 2. Discover the runtime environment

Run these checks from the toolkit root:

```powershell
# Is the devcontainer running?
docker ps --filter "name=toolkit" --format "{{.Names}}"

# Is the plugin directory present?
Test-Path "plugins\<PluginFolderName>"
```

**Completion criterion:** the devcontainer is running and the plugin directory exists.

### 3. Run the build

Use the one-liner from the top of this skill, appending options after the plugin path as needed. The part after the `bash -c` string is:

```bash
bash scripts/build-plugin.sh /workspace/plugins/<PluginFolderName> [options]
```

Options:

| Option | Effect |
|--------|--------|
| `--no-version-bump` | Do not auto-increment `PLUGIN_VERSION` and `package.json` version |
| `--no-pre-commit` | Skip `pre-commit run --all-files` |
| `--clean` | Remove `dist/`, `build/`, and `*.egg-info/` before building |
| `--skip-frontend` | Build only the Python package |

Example with `--clean` and `--no-version-bump`:

```bash
bash scripts/build-plugin.sh /workspace/plugins/<PluginFolderName> --clean --no-version-bump
```

### 4. Verify the output

`build-plugin.sh` checks that `dist/*.whl` exists and, for UI plugins, that a `Panel.js` bundle exists under the package's `static/` directory.

**Completion criterion:** the build command exits 0 and reports the built wheel filename.

### 5. Report the result

Summarize:

- Built wheel filename and version.
- Whether the frontend bundle was produced.
- Any warnings (e.g., pre-commit issues, missing static bundle).
- The next step (usually deploy to staging via the `deploy-inventree-plugin` skill).

---

## Build vs. test

Build does **not** run the test suite. It is a packaging step. Before building for release, run the deterministic tests via the `test-inventree-plugin` skill.

---

## Common pitfalls

- **Devcontainer must be running.** `build-plugin.sh` depends on the container's Node environment and the named-volume `node_modules`.
- **Version bump creates uncommitted changes.** Unless `--no-version-bump` is used, the script edits the plugin's `__init__.py` and `frontend/package.json`. Commit these after a successful build.
- **pre-commit may reformat files.** If `pre-commit` modifies sources, the build continues with the formatted sources. Check `git status` afterwards.
- **Wrong plugin name.** Pass the folder name (e.g., `inventree-flat-bom-generator`), not the Python module name.
- **Stale `dist/` contents.** Use `--clean` when switching versions or when the wheel seems to include old static files.
