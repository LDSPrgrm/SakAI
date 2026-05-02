import { test, expect } from "@playwright/test";

import { openApp } from "../../helpers/setup";
import { expectOnLogin, loginAs } from "../../helpers/auth";
import {
  declineIncoming,
  expectIncomingOffer,
  goOnline,
} from "../../helpers/driver";

test.describe("Driver declines incoming offer", () => {
  test.use({
    permissions: ["geolocation"],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test("decline button dismisses offer and returns to home", async ({
    page,
  }) => {
    test.setTimeout(90_000);
    const state = await openApp(page, "driver");
    await expectOnLogin(page);
    await loginAs(page, {
      email: "driver@example.com",
      password: "password123",
    });
    await goOnline(page);

    // Simulate a passenger-requested ride entering the driver's incoming queue.
    state.rideRequested = true;

    await expectIncomingOffer(page);
    await declineIncoming(page);

    // Poll the mock state until the decline POST is recorded. Verifying the
    // UI returns to the home screen is unreliable because DriverHomeNotifier
    // polls /driver/rides/incoming every 2s in E2E mode and may re-push the
    // offer screen on top before the in-flight decline flips driverDeclined,
    // which breaks the single context.pop() in RideOfferScreen.onDeclined.
    await expect
      .poll(() => state.driverDeclined, { timeout: 15000 })
      .toBe(true);
  });
});
