import { Page, expect } from "@playwright/test";

export async function goOnline(page: Page): Promise<void> {
  const toggle = page.locator("text=Start shift").first();
  await expect(toggle).toBeAttached({ timeout: 30000 });
  await toggle.click({ force: true });
  await expect(page.locator("text=End shift").first()).toBeAttached({
    timeout: 15000,
  });
}

export async function goOffline(page: Page): Promise<void> {
  const toggle = page.locator("text=End shift").first();
  await expect(toggle).toBeAttached({ timeout: 10000 });
  await toggle.click({ force: true });
}

export async function expectIncomingOffer(page: Page): Promise<void> {
  await expect(page.locator("text=Accept").first()).toBeAttached({
    timeout: 25000,
  });
}

export async function acceptIncoming(page: Page): Promise<void> {
  await expectIncomingOffer(page);
  await page.locator("text=Accept").first().click({ force: true });
}

export async function declineIncoming(page: Page): Promise<void> {
  await expect(page.locator("text=Decline").first()).toBeAttached({
    timeout: 25000,
  });
  await page.locator("text=Decline").first().click({ force: true });
}

export async function arrive(page: Page): Promise<void> {
  const arrived = page.locator("text=Arrived").first();
  await expect(arrived).toBeAttached({ timeout: 15000 });
  await arrived.click({ force: true });
  const force = page.locator("text=Force Anyway").first();
  if (await force.isVisible({ timeout: 1000 }).catch(() => false)) {
    await force.click({ force: true });
  }
}

export async function startRide(page: Page): Promise<void> {
  const start = page
    .locator("text=Start Ride")
    .or(page.locator("text=Resume Active Ride"))
    .first();
  await expect(start).toBeAttached({ timeout: 10000 });
  await start.click({ force: true });
}

export async function completeRide(page: Page): Promise<void> {
  const complete = page
    .locator("text=Complete Ride")
    .or(page.locator("text=Dropoff"))
    .first();
  await expect(complete).toBeAttached({ timeout: 10000 });
  await complete.click({ force: true });
  const force = page.locator("text=Force Anyway").first();
  if (await force.isVisible({ timeout: 1000 }).catch(() => false)) {
    await force.click({ force: true });
  }
}
