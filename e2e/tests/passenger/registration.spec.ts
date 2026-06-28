import { test, expect } from "@playwright/test";

import { openApp } from "../../helpers/setup";
import { expectOnHome, expectOnLogin, gotoRegister } from "../../helpers/auth";

test.describe("Passenger registration", () => {
  test.use({
    permissions: ["geolocation"],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test("submitting register form lands on home", async ({ page }) => {
    test.setTimeout(60_000);
    await openApp(page, "passenger");
    await expectOnLogin(page);

    await gotoRegister(page);

    // Register form: name, email, password textboxes (in that DOM order).
    const fields = page.getByRole("textbox");
    await fields.nth(0).click();
    await fields.nth(0).fill("New Rider");
    await fields.nth(1).click();
    await fields.nth(1).fill("new.rider@example.com");
    await fields.nth(2).click();
    await fields.nth(2).fill("password123");

    await page
      .getByRole("button", { name: /Create Account/i })
      .first()
      .click({ force: true });

    await expectOnHome(page, "passenger");
  });
});
