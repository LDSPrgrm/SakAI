const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto('http://localhost:3001/?enable-semantics=true');
  
  await page.waitForSelector('flt-semantics', { timeout: 30000 });
  const skipButton = page.locator('text=Skip').first();
  if (await skipButton.isVisible()) {
    await skipButton.click({ force: true });
  }
  
  await page.waitForTimeout(2000);
  
  // Login
  const emailInput = page.getByRole('textbox').first();
  const passwordInput = page.getByRole('textbox').last();
  const signInButton = page.locator('text=Sign in').first();
  
  await emailInput.click({ force: true });
  await emailInput.fill('driver@example.com');
  await passwordInput.click({ force: true });
  await passwordInput.fill('password123');
  
  await signInButton.click({ force: true });
  
  // Wait for home screen
  await page.waitForTimeout(5000);
  
  const html = await page.content();
  console.log(html);
  await browser.close();
})();
