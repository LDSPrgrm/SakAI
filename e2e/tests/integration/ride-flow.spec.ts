import { test, expect } from "@playwright/test";
import { createMockApiState, installMockApi } from "../support/mockApi";

test.describe("End-to-End Ride Flow", () => {
  test("should complete a ride from request to dropoff", async ({
    browser,
  }) => {
    const apiState = createMockApiState();

    // 1. Setup two separate contexts
    const passengerContext = await browser.newContext({
      permissions: ["geolocation"],
      geolocation: { latitude: 14.5995, longitude: 120.9842 },
    });
    const driverContext = await browser.newContext({
      permissions: ["geolocation"],
      geolocation: { latitude: 14.5995, longitude: 120.9842 },
    });

    const passengerPage = await passengerContext.newPage();
    const driverPage = await driverContext.newPage();
    await installMockApi(passengerPage, apiState);
    await installMockApi(driverPage, apiState);

    // 2. Driver logs in and goes online
    await driverPage.goto("http://localhost:3001/?enable-semantics=true&sakai-e2e=true");
    await driverPage.waitForSelector("flt-semantics", {
      state: "attached",
      timeout: 30000,
    });

    // Handle onboarding for driver
    const driverSkip = driverPage.locator("text=Skip").first();
    const driverSignIn = driverPage.locator("text=Sign in").first();
    await Promise.race([
      driverSkip.waitFor({ state: "visible", timeout: 20000 }).catch(() => {}),
      driverSignIn
        .waitFor({ state: "visible", timeout: 20000 })
        .catch(() => {}),
    ]);
    if (await driverSkip.isVisible()) {
      await driverSkip.click({ force: true });
    }

    // Wait for login screen to be ready
    await expect(driverPage.locator("text=Sign in").first()).toBeAttached({
      timeout: 20000,
    });

    await driverPage.getByRole("textbox").first().click();
    await driverPage.getByRole("textbox").first().fill("driver@example.com");
    await driverPage.getByRole("textbox").last().click();
    await driverPage.getByRole("textbox").last().fill("password123");
    await driverPage.locator("text=Sign in").first().click({ force: true });

    const onlineToggle = driverPage.locator("text=Start shift").first();
    await expect(onlineToggle).toBeAttached({ timeout: 15000 });
    await onlineToggle.click({ force: true });

    // 3. Passenger logs in and requests a ride
    await passengerPage.goto("http://localhost:3000/?enable-semantics=true&sakai-e2e=true");
    await passengerPage.waitForSelector("flt-semantics", {
      state: "attached",
      timeout: 30000,
    });

    // Handle onboarding for passenger
    const passengerSkip = passengerPage.locator("text=Skip").first();
    const passengerSignIn = passengerPage.locator("text=Sign in").first();
    await Promise.race([
      passengerSkip
        .waitFor({ state: "visible", timeout: 20000 })
        .catch(() => {}),
      passengerSignIn
        .waitFor({ state: "visible", timeout: 20000 })
        .catch(() => {}),
    ]);
    if (await passengerSkip.isVisible()) {
      await passengerSkip.click({ force: true });
    }

    // Wait for login screen to be ready
    await expect(passengerPage.locator("text=Sign in").first()).toBeAttached({
      timeout: 20000,
    });

    await passengerPage.getByRole("textbox").first().click();
    await passengerPage
      .getByRole("textbox")
      .first()
      .fill("passenger@example.com");
    await passengerPage.getByRole("textbox").last().click();
    await passengerPage.getByRole("textbox").last().fill("password123");
    await passengerPage.locator("text=Sign in").first().click({ force: true });

    const saanKayoText = passengerPage.locator("text=Where to?").first();
    await expect(saanKayoText).toBeAttached({ timeout: 15000 });

    const passengerPickup = passengerPage.locator("text=Tap to set pickup").first();
    if (await passengerPickup.isVisible().catch(() => false)) {
      await passengerPickup.click({ force: true });
      const pickupInput = passengerPage.getByRole("textbox").last();
      await expect(pickupInput).toBeAttached({ timeout: 10000 });
      await pickupInput.fill("Manila");
      const pickupConfirm = passengerPage.locator('text=Confirm "Manila"').first();
      const pickupSuggestion = passengerPage
        .locator("flt-semantics-container")
        .filter({ hasText: "Manila" })
        .first();
      await Promise.race([
        pickupSuggestion.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
        pickupConfirm.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
      ]);
      if (await pickupConfirm.isVisible()) {
        await pickupConfirm.click({ force: true });
      } else {
        await pickupSuggestion.click({ force: true });
      }
      await expect(passengerPage.locator("text=Where to?").first()).toBeAttached({
        timeout: 10000,
      });
    }

    await saanKayoText.click({ force: true });

    await passengerPage.waitForTimeout(1000);
    const whereToInput = passengerPage.getByRole("textbox").last();
    await expect(whereToInput).toBeAttached({ timeout: 10000 });
    await whereToInput.fill("Airport");
    const confirmButton = passengerPage.locator('text=Confirm "Airport"').first();
    const firstSuggestion = passengerPage
      .locator("flt-semantics-container")
      .filter({ hasText: "Airport" })
      .first();
    await Promise.race([
      firstSuggestion.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
      confirmButton.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
    ]);
    if (await confirmButton.isVisible()) {
      await confirmButton.click({ force: true });
    } else {
      await firstSuggestion.click({ force: true });
    }

    const requestRideButton = passengerPage.locator("text=Request").first();
    await expect(requestRideButton).toBeAttached({ timeout: 15000 });
    await requestRideButton.click({ force: true });

    // 4. Driver receives and accepts the ride
    // Wait for the incoming ride modal/notification on the driver app
    const acceptButton = driverPage.locator("text=Accept").first();
    await expect(acceptButton).toBeAttached({ timeout: 20000 }); // give backend time to match
    await acceptButton.click({ force: true });

    // 5. Verify Passenger sees driver is en route
    await expect(
      passengerPage
        .locator("text=Driver is on the way")
        .or(passengerPage.locator("text=Arriving in"))
        .first(),
    ).toBeAttached({ timeout: 15000 });

    // 6. Complete the ride lifecycle
    // Driver taps 'Arrived'
    const arrivedButton = driverPage.locator("text=Arrived").first();
    await expect(arrivedButton).toBeAttached({ timeout: 10000 });
    await arrivedButton.click({ force: true });
    const forceArrive = driverPage.locator("text=Force Anyway").first();
    if (await forceArrive.isVisible({ timeout: 1000 }).catch(() => false)) {
      await forceArrive.click({ force: true });
    }

    // Driver taps 'Start Ride'
    const startRideButton = driverPage
      .locator("text=Start Ride")
      .or(driverPage.locator("text=Resume Active Ride"))
      .first();
    await expect(startRideButton).toBeAttached({ timeout: 10000 });
    await startRideButton.click({ force: true });

    // Driver taps 'Complete Ride' or 'Dropoff'
    const completeRideButton = driverPage
      .locator("text=Complete Ride")
      .or(driverPage.locator("text=Dropoff"))
      .first();
    await expect(completeRideButton).toBeAttached({ timeout: 10000 });
    await completeRideButton.click({ force: true });
    const forceComplete = driverPage.locator("text=Force Anyway").first();
    if (await forceComplete.isVisible({ timeout: 1000 }).catch(() => false)) {
      await forceComplete.click({ force: true });
    }

    // 7. Verify Passenger reaches completion/rating screen
    await expect(
      passengerPage
        .locator("text=Ride completed")
        .or(passengerPage.locator("text=Rate your driver"))
        .first(),
    ).toBeAttached({ timeout: 15000 });

    // Cleanup
    await passengerContext.close();
    await driverContext.close();
  });
});
