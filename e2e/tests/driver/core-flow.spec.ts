import { test, expect } from '@playwright/test';
import { createMockApiState, installMockApi } from '../support/mockApi';

test.describe('Driver Core Flow', () => {
  test.use({
    permissions: ['geolocation'],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test.beforeEach(async ({ page }) => {
    await installMockApi(page, createMockApiState());

    // Navigate to the driver app with semantics enabled
    await page.goto('http://localhost:3001/?enable-semantics=true&sakai-e2e=true');
    
    // Wait for the Flutter semantics tree to be attached
    await page.waitForSelector('flt-semantics', { timeout: 30000 });

    // Wait for either onboarding or login screen to appear after splash
    const skipButton = page.getByRole('button', { name: 'Skip' });
    const signInButton = page.getByRole('button', { name: /Sign in/i });
    
    // Wait for one of them to be visible
    await Promise.race([
      skipButton.waitFor({ state: 'visible', timeout: 20000 }).catch(() => {}),
      signInButton.waitFor({ state: 'visible', timeout: 20000 }).catch(() => {})
    ]);

    if (await skipButton.isVisible()) {
      await skipButton.click();
    }
    
    // Wait for login screen to be visible
    await expect(page.getByRole('button', { name: /Sign in/i })).toBeAttached({ timeout: 20000 });
  });

  test('should display login screen', async ({ page }) => {
    // Check if the sign in button is visible
    await expect(page.getByRole('button', { name: /Sign in/i })).toBeAttached();
  });

  test('should allow a driver to sign in and go online', async ({ page }) => {
    // 1. Log In
    const emailInput = page.getByRole('textbox').first();
    const passwordInput = page.getByRole('textbox').last();
    const signInButton = page.getByRole('button', { name: /Sign in/i });

    // Fill in the login form. Click first to ensure focus for Flutter Web.
    await emailInput.click();
    await emailInput.fill('driver@example.com');
    await passwordInput.click();
    await passwordInput.fill('password123');
    
    await signInButton.click();

    // 2. Go Online
    // The driver home screen usually has an 'Offline' / 'Go Online' toggle
    const onlineToggle = page.locator('text=Start shift').first();
    
    await expect(onlineToggle).toBeAttached({ timeout: 15000 });
    await onlineToggle.click({ force: true });

    // Verify status changed to online
    const endShiftToggle = page.locator('text=End shift').first();
    await expect(endShiftToggle).toBeAttached({ timeout: 15000 });
  });
});
