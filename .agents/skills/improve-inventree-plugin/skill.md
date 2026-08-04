---
name: improve-inventree-plugin
description: Use when modifying, extending, or fixing an existing InvenTree plugin. Guides the change verification loop from analysis through commit.
---

# Improve InvenTree Plugin Skill

**Purpose:** Change verification loop for existing InvenTree plugins

---

## Overview

This skill guides an AI agent through making a change to an existing InvenTree plugin. The default verification path is the plugin's `./test-all.sh` inside the devcontainer. Use individual lint/test commands only when `./test-all.sh` cannot be run yet.

---

## Prerequisites

Complete the initial setup in [SETUP.md](../../SETUP.md) before using this skill. This includes:
- Docker Desktop installed and running
- VS Code with Dev Containers extension (or the CLI docker compose path)
- Devcontainer open and running
- Plugin exists in `/workspace/plugins/<plugin-name>`

For automated command execution (Docker exec), see [SESSION-ONBOARDING.md](../reference/SESSION-ONBOARDING.md#automated-command-execution).

---

## Workflow

### 1. Understand Change Request

Ask the user to describe:
- What functionality needs to be changed/added
- Which files/components are affected
- Expected behavior after change
- Any breaking changes

### 2. Determine the Module Name

Find the plugin's Python module name. This is the directory under the plugin root that contains `__init__.py` and `core.py`. Use `<MODULE_NAME>` in the commands below.

```bash
cd /workspace/plugins/<plugin-name>
# Find the module package
dirname $(ls */__init__.py | head -1)
```

### 3. Analyze Current Implementation

Review relevant files:
- Backend: `<MODULE_NAME>/core.py`, `<MODULE_NAME>/api.py`, `<MODULE_NAME>/views.py`, `<MODULE_NAME>/models.py`
- Frontend: `frontend/src/Panel.tsx`, components
- Tests: `<MODULE_NAME>/tests/unit/`, `<MODULE_NAME>/tests/integration/`, `frontend/e2e/`

### 4. Make Changes

**Backend changes:**
- Edit Python files.
- Add/update API endpoints.
- Add/update database models.
- Create migrations if needed.

**Frontend changes:**
- Edit React/TypeScript components.
- Update API calls.
- Test with hot reload (no server restart needed).

### 5. Verify with the Deterministic Test Command

The canonical verification is `./test-all.sh` in the plugin directory:

```bash
cd /workspace/plugins/<plugin-name>
./test-all.sh
```

This runs, in order:
1. Preflight checks (`INVENTREE_HOME`, `INVENTREE_PLUGIN_DIR`, plugin link, server health, dataset presence)
2. Code quality (`ruff check <MODULE_NAME>`, `ruff format --check <MODULE_NAME>`, and `npm run lint` if a frontend exists)
3. Python unit tests (`pytest <MODULE_NAME>/tests/unit`)
4. Frontend unit tests (`npm run test`) if a frontend exists
5. Python integration tests (`pytest <MODULE_NAME>/tests/integration`)
6. Frontend build and E2E tests (`npm run build` and `CI=1 npm run test:e2e`) if `UserInterfaceMixin` is in `core.py`

`test-all.sh` skips frontend steps automatically for headless plugins and supports these optional env flags:
- `FAST=1` - lint + unit tests only (no build, integration, or E2E)
- `SKIP_E2E=1` - skip Playwright E2E (frontend build still runs to catch TS errors)
- `SKIP_INTEGRATION=1` - skip Python integration tests
- `SKIP_FRONTEND=1` - skip all frontend steps
- `SKIP_LINT=1` or `SKIP_UNIT=1` - skip those layers

If `./test-all.sh` is missing, copy it from `plugin-templates/` and replace the placeholders:

```bash
cp /workspace/plugin-templates/test-all.sh /workspace/plugins/<plugin-name>/test-all.sh
sed -i 's/{{PLUGIN_NAME}}/<plugin-name>/g; s/{{MODULE_NAME}}/<MODULE_NAME>/g' /workspace/plugins/<plugin-name>/test-all.sh
chmod +x /workspace/plugins/<plugin-name>/test-all.sh
```

If the InvenTree server or dataset is not ready, run the fast subset that does not need them:

```bash
cd /workspace/plugins/<plugin-name>
ruff check <MODULE_NAME>
ruff format --check <MODULE_NAME>
python -m pytest <MODULE_NAME>/tests/unit -v
if [ -d frontend ]; then
  cd frontend && npm run lint && npm run test
  cd ..
fi
```

For interactive E2E debugging on the host (where the browser and display live), use:

```bash
cd /workspace/plugins/<plugin-name>/frontend
npm run test:e2e          # opens the HTML report if a test fails
npm run test:e2e:ui       # opens the Playwright UI for live debugging
PLAYWRIGHT_HTML_OPEN=always npm run test:e2e  # opens the report every time
```

### 6. Manual Verification (when needed)

**Backend changes:**
- Restart InvenTree server: `cd /workspace/reference/inventree-source && invoke dev.server -a 0.0.0.0:8001`
- Log in to http://localhost:8001
- Navigate to the changed functionality
- Check InvenTree logs for errors

**Frontend changes:**
- Plugin dev server should auto-reload
- Test UI changes in the browser
- Check browser console for errors

### 7. Build Plugin

```bash
cd /workspace/plugins/<plugin-name>
python -m build
```

Verify a `.whl` file is created in `dist/`.

### 8. Document Changes

Update relevant documentation:
- `README.md` - new features, breaking changes
- `CHANGELOG.md` - if it exists
- `docs/adr/` - non-obvious decisions
- Code comments for complex logic

### 9. Commit Changes

```bash
cd /workspace/plugins/<plugin-name>
git add .
git commit -m "feat: description of change"
```

---

## Change Verification Loop

For each change, follow this loop:

1. **Make change** - Edit code
2. **Run `./test-all.sh`** - Deterministic verification
3. **Fix failures** - Re-run from step 2 until green
4. **Build** - Ensure the package builds (`python -m build`)
5. **Document** - Update docs for the change
6. **Commit** - Save work with a clear message

**If `./test-all.sh` cannot run yet (server/data not ready):**
- Run the fast subset above (`ruff`, `npm run lint`, `npm run test`, `pytest unit`)
- Do not treat the fast subset as final verification; run `./test-all.sh` as soon as the devcontainer environment is ready.

---

## Common Patterns

### Adding a New API Field

1. Add field to the serializer
2. Update the API endpoint
3. Write a unit test for the new field
4. Run `./test-all.sh`
5. Test in browser with the API client
6. Update documentation

### Changing a Frontend Component

1. Edit the React/TypeScript component
2. Verify hot reload works
3. Run `npm run lint` and `npm run test`
4. Test in browser
5. Run `./test-all.sh`
6. Update documentation

### Database Schema Change

1. Create/update the model
2. Create a migration
3. Update the serializer and views
4. Write a migration test
5. Run the migration in dev
6. Run `./test-all.sh`
7. Document breaking changes

---

## Troubleshooting

**Tests failing after change:**
- Check if the change broke existing functionality.
- Update test fixtures if the schema changed.
- Verify test data is still valid.
- Check for race conditions in integration tests.

**Frontend not updating:**
- Check the plugin dev server is running.
- Clear browser cache.
- Check for JavaScript errors in the console.
- Verify Vite hot reload is working.

**Build failing:**
- Check for syntax errors.
- Verify all dependencies are in `pyproject.toml`.
- Check for missing files in `MANIFEST.in`.
- Verify the version number is valid.

---

## Best Practices

1. **Test frequently** - Run `./test-all.sh` after each significant change.
2. **Small commits** - Commit often with clear messages.
3. **Branch for features** - Use feature branches for larger changes.
4. **Review changes** - Before committing, review the diff.
5. **Update docs** - Keep documentation in sync with code.
6. **Check logs** - Monitor InvenTree logs during development.
7. **Use hot reload** - Take advantage of frontend hot reload.
8. **Test manually when needed** - Automated tests do not catch UI feel.

---

## Verification Checklist

- [ ] Change request is understood and scoped
- [ ] Relevant existing code has been reviewed
- [ ] `./test-all.sh` passes (or the fast subset if server/data is not ready)
- [ ] Code quality checks pass (`ruff`, `npm run lint`)
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Frontend unit tests pass
- [ ] Plugin builds successfully (`python -m build`)
- [ ] Documentation updated
- [ ] Changes committed with a clear message
- [ ] No breaking changes (or documented)
