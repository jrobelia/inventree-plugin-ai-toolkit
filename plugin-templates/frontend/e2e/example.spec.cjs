const { test, expect } = require('@playwright/test');
const path = require('path');

/**
 * Generic InvenTree plugin E2E template.
 *
 * Copy this file into `frontend/e2e/` of a plugin repo, then customize the
 * panel test below for your plugin's UI. The test reads dev server credentials
 * from the toolkit's `config/servers.json` (relative to the plugin frontend).
 *
 * Dev server default: http://localhost:8001 (via devcontainer port forward)
 */

const configPath = path.resolve(__dirname, '../../../../config/servers.json');

let username = 'admin';
let password = 'admin';
let baseURL = 'http://localhost:8001';

try {
  const config = require(configPath);
  if (config?.servers?.dev) {
    username = config.servers.dev.username || username;
    password = config.servers.dev.password || password;
    baseURL = config.servers.dev.url || baseURL;
  }
} catch (error) {
  console.log('config/servers.json not found; using default dev credentials');
}

/**
 * Log in to the InvenTree SPA.
 * Credentials come from `config/servers.json` (dev server section).
 */
async function login(page) {
  await page.goto('/web/');
  await page.waitForLoadState('networkidle');

  // The SPA redirects unauthenticated users to the login route.
  const usernameInput = page.locator('input[name="username"]').first();
  const passwordInput = page.locator('input[name="password"]').first();
  const submitButton = page.locator('button[type="submit"]').first();

  await usernameInput.waitFor({ state: 'visible', timeout: 10000 });
  await usernameInput.fill(username);
  await passwordInput.fill(password);
  await submitButton.click();

  // Wait until we are no longer on the login page.
  await page.waitForURL((url) => !url.pathname.includes('/login'), {
    timeout: 30000
  });
}

test.describe('InvenTree plugin E2E template', () => {
  test('can log in and load the parts list', async ({ page }) => {
    test.setTimeout(60000);

    await login(page);

    // Navigate to the parts list. This works once the InvenTree server has
    // data (demo dataset or your own parts).
    await page.goto('/part/');
    await page.waitForLoadState('networkidle');

    // Generic assertion: the SPA route for parts is active.
    await expect(page).toHaveURL(/\/part/);

    // A basic check that the page rendered content. The exact selector can be
    // adjusted once you know your plugin's target page.
    const heading = page.locator('h1, h2, [role="heading"]').first();
    await expect(heading).toBeVisible({ timeout: 10000 });
  });

  test.skip('can open the plugin panel (customize for your plugin)', async ({ page }) => {
    test.setTimeout(60000);

    await login(page);

    // TODO: replace with a part PK that is an assembly (or any part) for your
    // plugin, then un-skip this test.
    const partId = process.env.PLUGIN_TEST_PART_ID || '1';
    await page.goto(`/part/${partId}/`);
    await page.waitForLoadState('networkidle');

    // TODO: replace with your plugin's panel title (e.g. "Flat BOM Viewer").
    const panelTab = page.locator('text=Your Panel Title');
    await panelTab.waitFor({ state: 'visible', timeout: 10000 });
    await panelTab.click();

    // TODO: add assertions that your plugin-specific UI is visible.
    const pluginContent = page.locator('text=Your plugin-specific content');
    await expect(pluginContent).toBeVisible();
  });
});
