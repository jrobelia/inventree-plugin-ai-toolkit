# Plugin Templates

This directory contains template files for InvenTree plugins. Since plugins are stored in their own repositories, these templates live in the toolkit repo and can be copied into new or existing plugin repos.

## Using Templates

Copy the contents of the relevant `frontend/` or `backend/` directories into your plugin repo, then replace placeholders like `{{PLUGIN_NAME}}` and `{{MODULE_NAME}}`.

### Agent Rules (`AGENTS.md`)

To add Devin/Cascade agent rules to a new plugin:

```bash
cp /workspace/plugin-templates/AGENTS.md.template /workspace/plugins/your-plugin-name/AGENTS.md
```

Then create the matching `docs/agents/` files:

```bash
mkdir -p /workspace/plugins/your-plugin-name/docs/agents
# Copy/adapt from an existing plugin or from the toolkit root docs/agents/
```

Replace `{{PLUGIN_NAME}}` and `{{MODULE_NAME}}` in `AGENTS.md`, and fill in the plugin-specific context.

### Backend Tests (pytest)

To add Python backend tests to a plugin:

```bash
cp -r /workspace/plugin-templates/backend/* /workspace/plugins/your-plugin-name/my_plugin/tests/
```

Update `tests/conftest.py` if your InvenTree source tree lives elsewhere.

Run tests:

```bash
cd /workspace/plugins/your-plugin-name
python -m pytest my_plugin/tests/unit -v
python -m pytest my_plugin/tests/integration -v
```

### Frontend Unit Tests (Vitest)

To add frontend unit tests to a plugin:

```bash
cp -r /workspace/plugin-templates/frontend/src /workspace/plugins/your-plugin-name/frontend/
```

Ensure your plugin's `frontend/package.json` has the `test` script:

```json
{
  "scripts": {
    "test": "vitest run"
  }
}
```

Run tests:

```bash
cd /workspace/plugins/your-plugin-name/frontend
npm install
npm run test
```

### Playwright E2E Tests

To add Playwright E2E tests to a plugin:

```bash
cp -r /workspace/plugin-templates/frontend/* /workspace/plugins/your-plugin-name/frontend/
```

Then add the following to your plugin's `frontend/package.json` `scripts` section:

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug"
  }
}
```

And ensure these dev dependencies are present:

```json
{
  "devDependencies": {
    "@playwright/test": "^1.48.0",
    "@types/node": "^20.0.0"
  }
}
```

### Running All Tests

Copy the unified test runner template and adjust the placeholders:

```bash
cp /workspace/plugin-templates/test-all.sh /workspace/plugins/your-plugin-name/test-all.sh
```

Update `{{PLUGIN_NAME}}` and `{{MODULE_NAME}}` in the file, then make it executable:

```bash
chmod +x /workspace/plugins/your-plugin-name/test-all.sh
```

## Configuration

E2E tests read dev server credentials and URL from `config/servers.json` (relative to toolkit root). See `config/servers.json.example` for the expected format.

E2E tests run inside the devcontainer as part of `test-all.sh` (or directly via `CI=1 npm run test:e2e` in the container). The HTML report and video artifacts are written to `frontend/playwright-report/` and `frontend/test-results/` and are accessible on the host through the devcontainer volume mount.

For interactive frontend debugging on the host (where the browser and display live):

```bash
cd /workspace/plugins/your-plugin-name/frontend
npm install
npx playwright install
npm run test:e2e       # opens the HTML report automatically if a test fails
npm run test:e2e:ui    # opens the Playwright UI for live debugging
```

To force the HTML report to open after every run, set `PLAYWRIGHT_HTML_OPEN=always`:

```bash
PLAYWRIGHT_HTML_OPEN=always npm run test:e2e
```

See `docs/reference/SESSION-ONBOARDING.md` for full setup instructions.
