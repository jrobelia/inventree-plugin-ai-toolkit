---
name: new-inventree-plugin
description: Use when scaffolding a new InvenTree plugin from scratch. Starts with planning (wayfinder), runs plugin-creator with no CI, applies the toolkit test scaffold, and verifies.
---

# New InvenTree Plugin Skill

**Purpose:** Agent-driven scaffolding for new InvenTree plugins

---

## Overview

This skill guides an AI agent through creating a new InvenTree plugin from scratch. The agent first reaches a clear plan, then runs `plugin-creator`, explicitly opts out of CI, applies the toolkit's `plugin-templates/` test scaffold, and verifies the result.

---

## Prerequisites

Complete the initial setup in [SETUP.md](../../SETUP.md) before using this skill. This includes:
- Docker Desktop installed and running
- VS Code with Dev Containers extension (or the CLI docker compose path)
- Devcontainer open and running
- `reference/plugin-creator` submodule initialized

For automated command execution (Docker exec), see [SESSION-ONBOARDING.md](../reference/SESSION-ONBOARDING.md#automated-command-execution).

---

## Workflow

### 1. Plan the Plugin

Do **not** run `plugin-creator` until the plugin's purpose and shape are clear. If the user has not already produced a plan doc, invoke `/wayfinder` (or an equivalent planning mode) to produce one.

The plan doc must include enough information to answer every `plugin-creator` prompt:

- Plugin name (kebab-case)
- Human-readable name and description
- Author / license
- Required InvenTree mixins (e.g., EventMixin, NavigationMixin, UserInterfaceMixin, SettingsMixin)
- Frontend needs: panels, dashboard items, buttons, spotlight actions, etc.
- Whether the plugin is **headless** (no React frontend) or **UI/hybrid** (has a `frontend/` package)
- API endpoints and DRF serializers (if any)
- Database models and plugin settings (if any)
- Test fixtures or part IDs the E2E tests will need

Only proceed once the user confirms the plan is complete enough to scaffold.

### 2. Determine the Module Name

From the plan, determine the Python module name. This is usually the `package_name` produced by `plugin-creator` (the directory inside the plugin root that will contain `__init__.py` and `core.py`).

Use `<MODULE_NAME>` in all commands below.

### 3. Run plugin-creator

```bash
cd /workspace/reference/plugin-creator
python plugin_creator/main.py
```

Answer the interactive prompts **from the plan doc**, not by asking the user again.

When you reach the DevOps / CI prompt, explicitly select **None**. The upstream default is **GitHub Actions**, so move the selection to **None** and confirm. This should prevent `.github/workflows/` from being generated.

If `plugin-creator` generates CI files anyway (for example, because `cookiecutter.json` defaults `ci_support` to `github`), remove them before continuing:

```bash
rm -rf /workspace/plugins/<plugin-name>/.github/workflows
rmdir /workspace/plugins/<plugin-name>/.github 2>/dev/null || true
```

### 4. Apply the Toolkit Test-Scaffold Template

`plugin-creator` does not generate a `tests/` folder. Apply the toolkit's test scaffold on top of the generated plugin:

```bash
PLUGIN_DIR="/workspace/plugins/<plugin-name>"
MOD="<MODULE_NAME>"

# Unified deterministic test runner
cp /workspace/plugin-templates/test-all.sh "$PLUGIN_DIR/test-all.sh"
sed -i "s/{{PLUGIN_NAME}}/<plugin-name>/g; s/{{MODULE_NAME}}/$MOD/g" "$PLUGIN_DIR/test-all.sh"
chmod +x "$PLUGIN_DIR/test-all.sh"

# Backend tests and fixtures (always)
cp -r /workspace/plugin-templates/backend/* "$PLUGIN_DIR/$MOD/"

# Frontend scaffold (only for UI or hybrid plugins)
# Skip this block if the plan has no UserInterfaceMixin and no frontend.
if grep -q "UserInterfaceMixin" "$PLUGIN_DIR/$MOD/core.py" 2>/dev/null || [ -d "$PLUGIN_DIR/frontend" ]; then
  cp -r /workspace/plugin-templates/frontend/e2e "$PLUGIN_DIR/frontend/"
  cp /workspace/plugin-templates/frontend/playwright.config.cjs "$PLUGIN_DIR/frontend/playwright.config.cjs"
  mkdir -p "$PLUGIN_DIR/frontend/src/utils"
  cp /workspace/plugin-templates/frontend/src/utils/example.test.ts "$PLUGIN_DIR/frontend/src/utils/example.test.ts"
fi

# Agent rules
cp /workspace/plugin-templates/AGENTS.md.template "$PLUGIN_DIR/AGENTS.md"
sed -i "s/{{PLUGIN_NAME}}/<plugin-name>/g; s/{{MODULE_NAME}}/$MOD/g" "$PLUGIN_DIR/AGENTS.md"
```

> If `plugin-creator` generated files with the same names, do not overwrite them; ask the user which version to keep.

### 5. Install Dependencies and Run Initial Checks

```bash
cd "$PLUGIN_DIR"

# Python backend
python -m pip install -e .

# Frontend (only for UI or hybrid plugins)
if [ -d "frontend" ]; then
  cd frontend
  npm install
  cd ..
fi

# Static checks
ruff check "$MOD"
ruff format --check "$MOD"
if [ -d "frontend" ]; then
  npm run lint --prefix frontend
fi

# Fast unit tests (no InvenTree server required)
python -m pytest "$MOD/tests/unit" -v
if [ -d "frontend" ]; then
  npm run test --prefix frontend
fi

# Note: Playwright browsers are installed by .devcontainer/postCreateCommand.sh.
# Only install them on the host if you are running E2E tests interactively outside the container.
```

Integration and E2E tests require the InvenTree dev server and a populated dataset. Once those are ready, run the full deterministic chain:

```bash
cd "$PLUGIN_DIR"
./test-all.sh
```

### 6. Document the Plugin

- Update `README.md` with purpose, features, installation, and usage.
- Create `CONTEXT.md` with the plugin's domain glossary.
- Create `docs/adr/` when you make non-obvious decisions.
- Add the plugin to the toolkit's `CONTEXT-MAP.md` if it belongs to a shared domain.

---

## Common Patterns

### Adding a Custom Panel

1. Create the panel component in `frontend/src/`.
2. Register it in the plugin's `core.py` or `setup.py`.
3. Add a navigation entry if using `NavigationMixin`.

### Adding an API Endpoint

1. Create endpoint code in `api.py` or `views.py`.
2. Add URL routing in `api/urls.py` or `urls.py`.
3. Create a serializer if needed.
4. Write a unit test in `<MODULE_NAME>/tests/unit/`.

### Adding Database Models

1. Create the model in `models.py`.
2. Create and run a migration.
3. Register with InvenTree admin if needed.
4. Write an integration test in `<MODULE_NAME>/tests/integration/`.

---

## Verification Checklist

- [ ] Plan doc exists and is approved by the user.
- [ ] `plugin-creator` ran successfully with DevOps set to **None**.
- [ ] No `.github/workflows/` were generated (or they were removed).
- [ ] Plugin directory created in `/workspace/plugins/`.
- [ ] `test-all.sh` copied from `plugin-templates/` and placeholders replaced.
- [ ] Backend `tests/` copied from `plugin-templates/`.
- [ ] For UI/hybrid plugins: frontend `e2e/` and `playwright.config.cjs` copied from `plugin-templates/`.
- [ ] For headless plugins: no `frontend/` directory and `test-all.sh` skips frontend steps.
- [ ] `ruff check` and `ruff format --check` pass.
- [ ] For UI/hybrid plugins: `npm run lint` passes.
- [ ] Unit tests pass (`pytest <MODULE_NAME>/tests/unit`, and `npm run test` for UI plugins).
- [ ] Plugin loads in InvenTree (test in devcontainer).
- [ ] `README.md` and `CONTEXT.md` updated.

---

## Troubleshooting

**Plugin not appearing in InvenTree:**
- Check the plugin is in `/workspace/plugins/` and linked under `$INVENTREE_PLUGIN_DIR`.
- Verify the plugin is enabled in InvenTree settings.
- Check InvenTree server logs for import errors.

**Frontend not loading:**
- Verify the plugin dev server is running (`npm run dev` in `frontend/`).
- Check browser console for CORS or JavaScript errors.

**Tests failing:**
- Ensure `INVENTREE_HOME` and `INVENTREE_PLUGIN_DIR` are set inside the devcontainer.
- Check `test-all.sh` preflight output for the exact missing piece (server, dataset, plugin link).
- Verify test fixtures match the actual data in the devcontainer.
