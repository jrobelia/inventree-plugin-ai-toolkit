const { chromium } = require('playwright');
const fs = require('fs');

const baseUrl = process.env.SERVER_URL || 'http://localhost:8001';
const serverConfigPath = process.env.SERVER_CONFIG || '/workspace/config/servers.json';

let username = 'admin';
let password = 'admin';

try {
  const cfg = JSON.parse(fs.readFileSync(serverConfigPath, 'utf8'));
  const dev = cfg.servers?.dev || {};
  if (dev.username) username = dev.username;
  if (dev.password) password = dev.password;
} catch (e) {
  // fall back to admin/admin
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    await page.goto(`${baseUrl}/web/login`, { waitUntil: 'networkidle' });
    await page.waitForURL('**/web/login');

    await page.getByLabel('login-username').fill(username);
    await page.getByLabel('login-password').fill(password);
    await page.getByRole('button', { name: 'Log In' }).click();

    await page.getByRole('link', { name: 'Dashboard' }).waitFor();
    await page.getByRole('button', { name: 'navigation-menu' }).waitFor();

    const url = page.url();
    if (!/\/web(\/home)?$/.test(url)) {
      throw new Error(`Unexpected post-login URL: ${url}`);
    }

    console.log(`Login successful for ${username}: ${url}`);
    await context.close();
    await browser.close();
    process.exit(0);
  } catch (error) {
    console.error('Login test failed:', error.message);
    try { await page.screenshot({ path: '/tmp/test-login-failure.png' }); } catch (e) { /* ignore */ }
    await context.close().catch(() => {});
    await browser.close().catch(() => {});
    process.exit(1);
  }
})();
