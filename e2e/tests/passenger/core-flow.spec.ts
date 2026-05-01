import { test, expect } from "@playwright/test";
import { createMockApiState, installMockApi } from "../support/mockApi";

test.describe("Passenger Core Flow", () => {
  test.use({
    permissions: ["geolocation"],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test.beforeEach(async ({ page }) => {
    await installMockApi(page, createMockApiState());

    // Navigate to the passenger app with semantics enabled
    await page.goto("http://localhost:3000/?enable-semantics=true&sakai-e2e=true");

    // Wait for the Flutter semantics tree to be attached
    // This is more reliable than waiting for specific tags in some Flutter versions
    await page.waitForSelector("flt-semantics", { timeout: 30000 });

    // Wait for either onboarding or login screen after splash resolves.
    // The splash screen now lets GoRouter handle navigation based on auth state,
    // so we wait for the final destination (welcome/login) instead of intermediate elements.
    const skipButton = page.locator("text=Skip").first();
    const signInButton = page.locator("text=Sign in").first();

    // Wait for one of them to be visible
    await Promise.race([
      skipButton.waitFor({ state: "visible", timeout: 20000 }).catch(() => {}),
      signInButton
        .waitFor({ state: "visible", timeout: 20000 })
        .catch(() => {}),
    ]);

    if (await skipButton.isVisible()) {
      await skipButton.click({ force: true });
    }

    // Wait for login screen to be visible
    await expect(page.locator("text=Sign in").first()).toBeAttached({
      timeout: 20000,
    });
  });

  test("should display login screen", async ({ page }) => {
    // Check if the sign in button is visible
    await expect(page.locator("text=Sign in").first()).toBeAttached();
  });

  test("should allow a user to sign in and request a ride", async ({
    page,
  }) => {
    // 1. Log In
    const emailInput = page.getByRole("textbox").first();
    const passwordInput = page.getByRole("textbox").last();
    const signInButton = page.locator("text=Sign in").first();

    // Fill in the login form
    await emailInput.click();
    await emailInput.fill("passenger@example.com");
    await passwordInput.click();
    await passwordInput.fill("password123");

    await signInButton.click({ force: true });

    // 2. Wait for home screen — the home/map tab has NO AppBar, so "SakAI · Home"
    //    is never in the DOM. Confirm we're on home by the "Where to?" button.
    const whereToButton = page.locator("text=Where to?").first();
    await expect(whereToButton).toBeAttached({ timeout: 15000 });

    const pickupButton = page.locator("text=Tap to set pickup").first();
    if (await pickupButton.isVisible().catch(() => false)) {
      await pickupButton.click({ force: true });
      const pickupTextbox = page.getByRole("textbox").last();
      await expect(pickupTextbox).toBeAttached({ timeout: 10000 });
      await pickupTextbox.fill("Manila");
      const pickupSuggestion = page
        .getByRole("button", { name: /Manila/i })
        .first();
      const pickupConfirm = page.locator('text=Confirm "Manila"').first();
      await Promise.race([
        pickupSuggestion.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
        pickupConfirm.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
      ]);
      if (await pickupConfirm.isVisible().catch(() => false)) {
        await pickupConfirm.click({ force: true });
      } else {
        await pickupSuggestion.click({ force: true });
      }
      await expect(page.locator("text=Where to?").first()).toBeAttached({
        timeout: 10000,
      });
    }

    // 3. Open destination search by tapping "Where to?"
    const whereToButtonRole = page.getByRole("button", { name: "Where to?" });
    await whereToButtonRole.waitFor({ state: "visible", timeout: 10000 });
    await whereToButtonRole.click();
    await page.waitForTimeout(800);

    // The bottom sheet expands and a search textbox appears
    const searchTextbox = page.getByRole("textbox").last();
    await expect(searchTextbox).toBeAttached({ timeout: 15000 });
    await searchTextbox.fill("Airport");

    // 4. Handle destination selection — two possible paths:
    //    a) Geocoding returns suggestions → click the first suggestion button
    //    b) No results found → a "Confirm "Airport"" button appears
    const confirmButton = page.locator('text=Confirm "Airport"').first();
    const firstSuggestion = page
      .getByRole("button", { name: /Airport/i })
      .first();

    await Promise.race([
      firstSuggestion.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
      confirmButton.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
    ]);

    if (await confirmButton.isVisible().catch(() => false)) {
      await confirmButton.click({ force: true });
    } else {
      await firstSuggestion.click({ force: true });
    }

    // 5. Wait for the ride options panel.
    //    Button label is "Request Ride" or "Request {VehicleType}" — match via substring.
    const requestRideButton = page
      .getByRole("button", { name: /^Request/ })
      .first();
    await expect(requestRideButton).toBeAttached({ timeout: 15000 });
    await expect(requestRideButton).toBeEnabled({ timeout: 10000 });
    await requestRideButton.click({ force: true });

    // 6. Confirm navigation to the waiting / driver-finding screen
    await expect(
      page.locator("text=Finding your driver").first()
    ).toBeAttached({ timeout: 15000 });
  });
});
