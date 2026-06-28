import { test, expect } from "@playwright/test";

import { openApp } from "../../helpers/setup";
import { expectOnLogin, loginAs } from "../../helpers/auth";
import { goOffline, goOnline } from "../../helpers/driver";

test.describe("Driver end shift toggle", () => {
  test.use({
    permissions: ["geolocation"],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test("Start shift then End shift toggles back to Start shift", async ({
    page,
  }) => {
    test.setTimeout(60_000);
    await openApp(page, "driver");
    await expectOnLogin(page);
    await loginAs(page, {
      email: "driver@example.com",
      password: "password123",
    });

    await goOnline(page);
    await goOffline(page);

    await expect(page.locator("text=Start shift").first()).toBeAttached({
      timeout: 15000,
    });
  });
});
