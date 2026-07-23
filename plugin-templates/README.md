# Plugin Templates

This directory contains template files for InvenTree plugins. Since plugins are stored in their own repositories, these templates live in the toolkit repo and can be copied into new or existing plugin repos.

## Using Templates

Copy the contents of the relevant `frontend/` or backend directories into your plugin repo.

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

## Configuration

Tests read dev server credentials and URL from `config/servers.json` (relative to toolkit root). See `config/servers.json.example` for the expected format.

Run tests from your host machine, not the devcontainer:

```bash
cd /workspace/plugins/your-plugin-name/frontend
npm install
npx playwright install
npm run test:e2e
```

See `docs/reference/SESSION-ONBOARDING.md` for full setup instructions.
