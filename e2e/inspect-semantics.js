const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  // Step 1: Load the app first to discover what localStorage keys Flutter uses
  console.log('Step 1: Initial load to discover keys...');
  await page.goto('http://localhost:3000/?enable-semantics=true');
  await page.waitForSelector('flt-semantics', { timeout: 30000 });
  await page.waitForTimeout(8000); // Wait for app to initialize SharedPreferences
  
  const keys = await page.evaluate(() => {
    const items = {};
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      items[key] = localStorage.getItem(key);
    }
    return items;
  });
  
  console.log('\n=== LocalStorage keys after init ===');
  console.log(JSON.stringify(keys, null, 2));
  
  // Step 2: Delete the hasSeenWelcome key and reload  
  const welcomeKey = Object.keys(keys).find(k => k.includes('hasSeenWelcome'));
  console.log('\nhasSeenWelcome key:', welcomeKey);
  
  if (welcomeKey) {
    await page.evaluate((k) => localStorage.removeItem(k), welcomeKey);
  } else {
    // Try to set it explicitly to false
    await page.evaluate(() => {
      // Flutter web SharedPreferences uses 'flutter.' prefix
      localStorage.removeItem('flutter.hasSeenWelcome');
    });
  }
  
  console.log('\nStep 2: Reloading with hasSeenWelcome removed...');
  await page.reload({ waitUntil: 'domcontentloaded' });
  await page.waitForSelector('flt-semantics', { timeout: 30000 });
  
  // Wait for splash to resolve
  console.log('Waiting 10s for app to route past splash...');
  await page.waitForTimeout(10000);
  
  const elements = await page.evaluate(() => {
    const all = document.querySelectorAll('flt-semantics');
    return Array.from(all).slice(0, 200).map(el => ({
      label: el.getAttribute('aria-label'),
      role: el.getAttribute('role'),
      text: el.textContent ? el.textContent.trim().substring(0, 80) : null,
    }));
  });
  
  console.log('\n=== FLT-SEMANTICS ELEMENTS (after removing hasSeenWelcome) ===');
  elements.filter(e => e.label || e.role || (e.text && e.text.length > 1)).forEach((e, i) => {
    console.log(`[${i}] role="${e.role}" label="${e.label}" text="${e.text}"`);
  });
  
  const buttons = await page.getByRole('button').all();
  console.log(`\n=== BUTTONS (${buttons.length}) ===`);
  for (const btn of buttons.slice(0, 20)) {
    const label = await btn.getAttribute('aria-label').catch(() => null);
    const text = await btn.textContent().catch(() => null);
    console.log(`  label="${label}" text="${text ? text.trim() : ''}"`);
  }
  
  const finalKeys = await page.evaluate(() => {
    const items = {};
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      items[key] = localStorage.getItem(key);
    }
    return items;
  });
  console.log('\n=== Final LocalStorage ===');
  console.log(JSON.stringify(finalKeys, null, 2));
  
  await browser.close();
})();
