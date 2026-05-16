import { Page, expect } from "@playwright/test";

export async function setPickup(
  page: Page,
  query: string = "Manila",
): Promise<void> {
  const pickupButton = page.locator("text=Tap to set pickup").first();
  if (!(await pickupButton.isVisible().catch(() => false))) return;
  await pickupButton.click({ force: true });
  const input = page.getByRole("textbox").last();
  await input.waitFor({ state: "visible", timeout: 10000 });
  const confirm = page.locator(`text=Confirm "${query}"`).first();
  const suggestion = page
    .getByRole("button", { name: new RegExp(query, "i") })
    .first();
  let winner: "suggestion" | "confirm" | null = null;
  for (let attempt = 0; attempt < 2 && !winner; attempt++) {
    await input.fill("");
    await input.fill(query);
    winner = await Promise.race([
      suggestion
        .waitFor({ state: "attached", timeout: 10000 })
        .then(() => "suggestion" as const)
        .catch(() => null),
      confirm
        .waitFor({ state: "attached", timeout: 10000 })
        .then(() => "confirm" as const)
        .catch(() => null),
    ]);
  }
  if (!winner) {
    throw new Error(`No autocomplete option appeared for pickup "${query}"`);
  }
  if (await confirm.isVisible().catch(() => false)) {
    await confirm.click({ force: true });
  } else {
    await suggestion.click({ force: true });
  }
  await expect(page.locator("text=Where to?").first()).toBeAttached({
    timeout: 10000,
  });
}

export async function setDestination(
  page: Page,
  query: string = "Airport",
): Promise<void> {
  const whereToBtn = page.getByRole("button", { name: "Where to?" });
  await whereToBtn.waitFor({ state: "visible", timeout: 10000 });
  await whereToBtn.click({ force: true });
  const input = page.getByRole("textbox").last();
  await input.waitFor({ state: "visible", timeout: 15000 });
  const confirm = page.locator(`text=Confirm "${query}"`).first();
  const suggestion = page
    .getByRole("button", { name: new RegExp(query, "i") })
    .first();
  let winner: "suggestion" | "confirm" | null = null;
  for (let attempt = 0; attempt < 2 && !winner; attempt++) {
    await input.fill("");
    await input.fill(query);
    winner = await Promise.race([
      suggestion
        .waitFor({ state: "attached", timeout: 10000 })
        .then(() => "suggestion" as const)
        .catch(() => null),
      confirm
        .waitFor({ state: "attached", timeout: 10000 })
        .then(() => "confirm" as const)
        .catch(() => null),
    ]);
  }
  if (!winner) {
    throw new Error(`No autocomplete option appeared for destination "${query}"`);
  }
  if (await confirm.isVisible().catch(() => false)) {
    await confirm.click({ force: true });
  } else {
    await suggestion.click({ force: true });
  }
}

export async function requestRide(
  page: Page,
  opts: { pickup?: string; destination?: string } = {},
): Promise<void> {
  await setPickup(page, opts.pickup ?? "Manila");
  await setDestination(page, opts.destination ?? "Airport");
  const button = page.getByRole("button", { name: /^Request/ }).first();
  await expect(button).toBeAttached({ timeout: 15000 });
  await expect(button).toBeEnabled({ timeout: 10000 });
  await button.click({ force: true });
}

export async function expectOnWaiting(page: Page): Promise<void> {
  await expect(page.locator("text=Finding your driver").first()).toBeAttached({
    timeout: 15000,
  });
}

export async function cancelWaiting(page: Page): Promise<void> {
  const cancel = page.locator("text=Cancel Ride").first();
  await expect(cancel).toBeAttached({ timeout: 10000 });
  await cancel.click({ force: true });
}

export async function expectOnCancelled(page: Page): Promise<void> {
  // The cancelled screen is reached via go_router at /ride/cancelled/:rideId.
  // URL change is the most reliable signal — the screen's content depends on
  // an async loadCancellation() call that may show a spinner first.
  await page.waitForURL(/\/ride\/cancelled\//, { timeout: 15000 });
  // Also confirm the WaitingScreen is gone.
  await expect(
    page.locator("text=Finding your driver").first(),
  ).not.toBeAttached();
}

export async function expectOnRideComplete(page: Page): Promise<void> {
  await expect(
    page
      .locator("text=Ride completed")
      .or(page.locator("text=Rate your driver"))
      .first(),
  ).toBeAttached({ timeout: 15000 });
}

export async function retryRequest(page: Page): Promise<void> {
  const retry = page
    .locator("text=Try Again")
    .or(page.locator("text=Retry"))
    .or(page.locator("text=Request New Ride"))
    .first();
  await expect(retry).toBeAttached({ timeout: 10000 });
  await retry.click({ force: true });
}
