const { defineConfig, devices } = require('@playwright/test');

/**
 * Playwright configuration for InvenTree plugin E2E tests.
 *
 * This configuration is set up to test the plugin frontend against
 * the InvenTree dev server running in the devcontainer. It is tuned
 * for stability in a resource-constrained container: serial workers and
 * one retry locally to reduce noise from SPA timing.
 *
 * Interaction modes:
 * - `test-all.sh` runs with `CI=1`, so the HTML report is written but not
 *   opened, and tests run headless. Artifacts live in `playwright-report/`
 *   and `test-results/` and are accessible on the host via the devcontainer
 *   volume mount.
 * - Interactive development on the host: `PLAYWRIGHT_HTML_OPEN=always npm run test:e2e`
 *   opens the HTML report after every run. `npm run test:e2e:ui` opens the
 *   Playwright UI for live debugging.
 * - Default (no env vars): the HTML report opens automatically only if a
 *   test fails (`on-failure`).
 */
module.exports = defineConfig({
  testDir: './e2e',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 1,
  workers: 1,
  globalSetup: './e2e/global-setup.cjs',
  reporter: [
    ['list'],
    ['html', { open: process.env.CI ? 'never' : 'on-failure' }]
  ],

  use: {
    baseURL: 'http://localhost:8001',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    // Firefox temporarily disabled due to timeout issues
    // {
    //   name: 'firefox',
    //   use: { ...devices['Desktop Firefox'] },
    // },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
});
