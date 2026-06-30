import { test, expect } from "@playwright/test";

import { openApp } from "../../helpers/setup";
import { expectOnHome, expectOnLogin, loginAs } from "../../helpers/auth";
import { expectOnWaiting, requestRide } from "../../helpers/passenger";

test.describe("Ride request retry after failure", () => {
  test.use({
    permissions: ["geolocation"],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test("first POST fails, retry succeeds and navigates to Waiting", async ({
    page,
  }) => {
    test.setTimeout(75_000);
    const state = await openApp(page, "passenger");
    await expectOnLogin(page);
    await loginAs(page, {
      email: "passenger@example.com",
      password: "password123",
    });
    await expectOnHome(page, "passenger");

    state.failNextRideCreate = true;
    await requestRide(page, { pickup: "Manila", destination: "Airport" });
    await expect(
      page.locator("text=No drivers are available right now").first(),
    ).toBeAttached({ timeout: 15000 });

    // Retry — failNextRideCreate consumed itself on first call; second click succeeds.
    await page
      .getByRole("button", { name: /^Request/ })
      .first()
      .click({ force: true });

    await expectOnWaiting(page);
  });
});
