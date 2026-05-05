import { test, expect } from "@playwright/test";

import { openApp } from "../../helpers/setup";
import { expectOnHome, expectOnLogin, loginAs } from "../../helpers/auth";
import {
  expectOnWaiting,
  requestRide,
} from "../../helpers/passenger";

test.describe("Passenger Core Flow", () => {
  test.use({
    permissions: ["geolocation"],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test.beforeEach(async ({ page }) => {
    await openApp(page, "passenger");
    await expectOnLogin(page);
  });

  test("should display login screen", async ({ page }) => {
    await expect(
      page.getByRole("button", { name: /^Sign in$/i }).first(),
    ).toBeAttached();
  });

  test("should allow a user to sign in and request a ride", async ({
    page,
  }) => {
    await loginAs(page, {
      email: "passenger@example.com",
      password: "password123",
    });
    await expectOnHome(page, "passenger");
    await requestRide(page, { pickup: "Manila", destination: "Airport" });
    await expectOnWaiting(page);
  });
});
