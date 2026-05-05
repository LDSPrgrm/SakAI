import { test, expect } from "@playwright/test";

import { openApp } from "../../helpers/setup";
import { expectOnHome, expectOnLogin } from "../../helpers/auth";

test.describe("Driver registration", () => {
  test.use({
    permissions: ["geolocation"],
    geolocation: { latitude: 14.5995, longitude: 120.9842 },
  });

  test("driver register form lands on home", async ({ page }) => {
    test.setTimeout(90_000);
    await openApp(page, "driver");
    await expectOnLogin(page);

    // Driver login screen has a "Register" text button at the bottom that
    // pushes /register.
    await page
      .getByRole("button", { name: /^Register$/i })
      .first()
      .click({ force: true });

    // Register screen has 9 textboxes:
    //   name, email, password, confirm password,
    //   vehicle make, model, plate, color, year.
    const fields = page.getByRole("textbox");
    await expect(fields.first()).toBeAttached({ timeout: 15000 });

    const values = [
      "Driver Two",
      "driver.new@example.com",
      "password123",
      "password123",
      "Toyota",
      "Vios",
      "ABC-1234",
      "Silver",
      "2022",
    ];

    for (let i = 0; i < values.length; i++) {
      const field = fields.nth(i);
      // Scroll into view then verify Flutter actually accepted the value.
      // The Make field flakes when the form is mid-scroll: fill() resolves
      // without error but the TextField state stays empty. Retry once via
      // pressSequentially if a fill silently dropped.
      await field.scrollIntoViewIfNeeded().catch(() => {});
      await field.click();
      await field.fill(values[i]);
      const got = await field.inputValue().catch(() => "");
      if (got !== values[i]) {
        await field.click();
        await field.fill("");
        await field.pressSequentially(values[i], { delay: 20 });
      }
    }

    await page
      .getByRole("button", { name: /Create Account|Sign Up|Register/i })
      .first()
      .scrollIntoViewIfNeeded()
      .catch(() => {});
    await page
      .getByRole("button", { name: /Create Account|Sign Up|Register/i })
      .first()
      .click({ force: true });

    await expectOnHome(page, "driver");
  });
});
