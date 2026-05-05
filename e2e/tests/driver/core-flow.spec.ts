import { test, expect } from "@playwright/test";

import { openApp } from "../../helpers/setup";
import { expectOnLogin, loginAs } from "../../helpers/auth";
import { goOnline } from "../../helpers/driver";

test.describe("Driver Core Flow", () => {
  test.use({
    permissions: ["geolocation"],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test.beforeEach(async ({ page }) => {
    await openApp(page, "driver");
    await expectOnLogin(page);
  });

  test("should display login screen", async ({ page }) => {
    await expect(
      page.getByRole("button", { name: /^Sign in$/i }).first(),
    ).toBeAttached();
  });

  test("should allow a driver to sign in and go online", async ({ page }) => {
    await loginAs(page, {
      email: "driver@example.com",
      password: "password123",
    });
    await goOnline(page);
    await expect(page.locator("text=End shift").first()).toBeAttached({
      timeout: 15000,
    });
  });
});
