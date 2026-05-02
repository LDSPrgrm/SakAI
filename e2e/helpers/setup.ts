import { Page } from "@playwright/test";
import {
  createMockApiState,
  installMockApi,
  MockApiState,
} from "../tests/support/mockApi";

export {
  createMockApiState,
  installMockApi,
  type MockApiState,
} from "../tests/support/mockApi";

export type Role = "passenger" | "driver";

const PORTS: Record<Role, number> = { passenger: 3000, driver: 3001 };

export type OpenAppOpts = {
  state?: MockApiState;
  skipOnboarding?: boolean;
  query?: string;
};

export async function openApp(
  page: Page,
  role: Role,
  opts: OpenAppOpts = {},
): Promise<MockApiState> {
  const state = opts.state ?? createMockApiState();
  await installMockApi(page, state);
  const port = PORTS[role];
  const extra = opts.query ?? "";
  await page.goto(
    `http://localhost:${port}/?enable-semantics=true&sakai-e2e=true${extra}`,
  );
  await page.waitForSelector("flt-semantics", { timeout: 30000 });
  if (opts.skipOnboarding ?? true) {
    await skipOnboardingIfPresent(page);
  }
  return state;
}

async function skipOnboardingIfPresent(page: Page): Promise<void> {
  const skip = page.getByRole("button", { name: /^Skip$/i }).first();
  const signIn = page.getByRole("button", { name: /^Sign in$/i }).first();
  await Promise.race([
    skip.waitFor({ state: "visible", timeout: 20000 }).catch(() => {}),
    signIn.waitFor({ state: "visible", timeout: 20000 }).catch(() => {}),
  ]);
  if (await skip.isVisible().catch(() => false)) {
    await skip.click({ force: true });
  }
}
