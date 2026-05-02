import { test, expect } from "@playwright/test";

import { createMockApiState, openApp } from "../../helpers/setup";
import { expectOnHome, expectOnLogin, loginAs } from "../../helpers/auth";
import {
  acceptIncoming,
  arrive,
  completeRide,
  goOnline,
  startRide,
} from "../../helpers/driver";
import {
  expectOnRideComplete,
  requestRide,
} from "../../helpers/passenger";

test.describe("End-to-End Ride Flow", () => {
  test("should complete a ride from request to dropoff", async ({
    browser,
  }) => {
    test.setTimeout(120_000);
    const apiState = createMockApiState();

    const passengerContext = await browser.newContext({
      permissions: ["geolocation"],
      geolocation: { latitude: 14.5995, longitude: 120.9842 },
    });
    const driverContext = await browser.newContext({
      permissions: ["geolocation"],
      geolocation: { latitude: 14.5995, longitude: 120.9842 },
    });

    const passengerPage = await passengerContext.newPage();
    const driverPage = await driverContext.newPage();

    await openApp(driverPage, "driver", { state: apiState });
    await expectOnLogin(driverPage);
    await loginAs(driverPage, {
      email: "driver@example.com",
      password: "password123",
    });
    await goOnline(driverPage);

    await openApp(passengerPage, "passenger", { state: apiState });
    await expectOnLogin(passengerPage);
    await loginAs(passengerPage, {
      email: "passenger@example.com",
      password: "password123",
    });
    await expectOnHome(passengerPage, "passenger");
    await requestRide(passengerPage, {
      pickup: "Manila",
      destination: "Airport",
    });

    await acceptIncoming(driverPage);

    await expect(
      passengerPage
        .locator("text=Driver is on the way")
        .or(passengerPage.locator("text=Arriving in"))
        .first(),
    ).toBeAttached({ timeout: 15000 });

    await arrive(driverPage);
    await startRide(driverPage);
    await completeRide(driverPage);

    await expectOnRideComplete(passengerPage);

    await passengerContext.close();
    await driverContext.close();
  });
});
