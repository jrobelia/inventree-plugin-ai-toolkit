# Plugin Templates

This directory contains template files for InvenTree plugins. Since plugins are stored in their own repositories, these templates live in the toolkit repo and can be copied into new or existing plugin repos.

## Using Templates

Copy the contents of the relevant `frontend/` or `backend/` directories into your plugin repo, then replace placeholders like `{{PLUGIN_NAME}}` and `{{MODULE_NAME}}`.

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

Run E2E tests from your host machine, not the devcontainer:

```bash
cd /workspace/plugins/your-plugin-name/frontend
npm install
npx playwright install
npm run test:e2e
```

See `docs/reference/SESSION-ONBOARDING.md` for full setup instructions.
