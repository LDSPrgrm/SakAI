import { Page, expect } from "@playwright/test";

import type { Role } from "./setup";

export async function expectOnLogin(page: Page): Promise<void> {
  await expect(
    page.getByRole("button", { name: /^Sign in$/i }).first(),
  ).toBeAttached({ timeout: 20000 });
}

export async function loginAs(
  page: Page,
  creds: { email: string; password: string },
): Promise<void> {
  const email = page.getByRole("textbox").first();
  const password = page.getByRole("textbox").last();
  const signIn = page.getByRole("button", { name: /^Sign in$/i }).first();

  await email.click();
  await email.fill(creds.email);
  await password.click();
  await password.fill(creds.password);
  await signIn.click({ force: true });
}

export async function gotoRegister(page: Page): Promise<void> {
  await page.locator("text=Create account").first().click({ force: true });
  // The form swaps via AnimatedSwitcher; the submit button label is "Create Account".
  await expect(
    page.getByRole("button", { name: /Create Account/i }).first(),
  ).toBeAttached({ timeout: 10000 });
}

export async function register(
  page: Page,
  data: { name: string; email: string; password: string },
): Promise<void> {
  const fields = page.getByRole("textbox");
  await fields.nth(0).click();
  await fields.nth(0).fill(data.name);
  await fields.nth(1).click();
  await fields.nth(1).fill(data.email);
  await fields.nth(2).click();
  await fields.nth(2).fill(data.password);
  await page
    .getByRole("button", { name: /Create Account/i })
    .first()
    .click({ force: true });
}

export async function expectOnHome(page: Page, role: Role): Promise<void> {
  if (role === "passenger") {
    await expect(page.locator("text=Where to?").first()).toBeAttached({
      timeout: 30000,
    });
  } else {
    await expect(page.locator("text=Start shift").first()).toBeAttached({
      timeout: 30000,
    });
  }
}
