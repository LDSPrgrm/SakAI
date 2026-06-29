import { test, expect } from "@playwright/test";

import { openApp } from "../../helpers/setup";
import { expectOnHome, expectOnLogin, loginAs } from "../../helpers/auth";
import {
  cancelWaiting,
  expectOnCancelled,
  expectOnWaiting,
  requestRide,
} from "../../helpers/passenger";

test.describe("Passenger cancels during waiting", () => {
  test.use({
    permissions: ["geolocation"],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test("cancel from waiting screen lands on cancelled-ride screen", async ({
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
    await requestRide(page, { pickup: "Manila", destination: "Airport" });
    await expectOnWaiting(page);

    await cancelWaiting(page);

    await expectOnCancelled(page);
    expect(state.rideCancelled).toBe(true);
  });
});
