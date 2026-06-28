import { test, expect } from "@playwright/test";

import { openApp } from "../../helpers/setup";
import { expectOnHome, expectOnLogin, loginAs } from "../../helpers/auth";
import { requestRide } from "../../helpers/passenger";

test.describe("No drivers available", () => {
  test.use({
    permissions: ["geolocation"],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test("POST /rides returning NO_DRIVERS_AVAILABLE surfaces error and stays on home", async ({
    page,
  }) => {
    test.setTimeout(60_000);
    const state = await openApp(page, "passenger");
    await expectOnLogin(page);
    await loginAs(page, {
      email: "passenger@example.com",
      password: "password123",
    });
    await expectOnHome(page, "passenger");

    // Force the next POST /rides to return NO_DRIVERS_AVAILABLE.
    state.failNextRideCreate = true;

    await requestRide(page, { pickup: "Manila", destination: "Airport" });

    await expect(
      page.locator("text=No drivers are available right now").first(),
    ).toBeAttached({ timeout: 15000 });

    // Stays on home: never navigated to Waiting screen.
    await expect(
      page.locator("text=Finding your driver").first(),
    ).not.toBeAttached();
    // Request button still present so the user can retry.
    await expect(
      page.getByRole("button", { name: /^Request/ }).first(),
    ).toBeAttached({ timeout: 5000 });
  });
});
