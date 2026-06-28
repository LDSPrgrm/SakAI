import { Page, Route } from "@playwright/test";

type RideStatus =
  | "requested"
  | "accepted"
  | "arrived"
  | "in_progress"
  | "completed"
  | "cancelled";

type CancelledByValue = "passenger" | "driver" | "system";

export type MockApiState = {
  rideStatus: RideStatus;
  rideRequested: boolean;
  driverOnline: boolean;
  rideCancelled: boolean;
  cancelledBy?: CancelledByValue;
  driverDeclined: boolean;
  forceUnauthorizedOnce: boolean;
  failNextRideCreate: boolean;
  registerShouldFail: boolean;
};

export function createMockApiState(): MockApiState {
  return {
    rideStatus: "requested",
    rideRequested: false,
    driverOnline: false,
    rideCancelled: false,
    driverDeclined: false,
    forceUnauthorizedOnce: false,
    failNextRideCreate: false,
    registerShouldFail: false,
  };
}

const now = () => new Date().toISOString();

const passenger = {
  id: "passenger-1",
  name: "Passenger One",
  email: "passenger@example.com",
  role: "passenger",
  created_at: "2026-01-01T00:00:00.000Z",
};

const driver = {
  id: "driver-1",
  name: "Driver One",
  email: "driver@example.com",
  role: "driver",
  created_at: "2026-01-01T00:00:00.000Z",
};

function driverSummary() {
  return {
    id: driver.id,
    name: driver.name,
    vehicle: {
      make: "Toyota",
      model: "Vios",
      plate: "SAK-123",
      color: "Silver",
      type: "car",
    },
    current_location: { lat: 14.5995, lng: 120.9842 },
  };
}

function ride(
  status: RideStatus = "requested",
  withDriver = false,
  state?: MockApiState,
) {
  const isCancelled = status === "cancelled" || (state?.rideCancelled ?? false);
  return {
    id: "ride-e2e-1",
    status: isCancelled ? "cancelled" : status,
    passenger,
    driver: withDriver ? driverSummary() : null,
    origin: { lat: 14.5995, lng: 120.9842 },
    destination: { lat: 14.6091, lng: 121.0223 },
    origin_address: "SakAI E2E Pickup",
    destination_address: "Airport",
    estimated_fare: 120.5,
    actual_fare: status === "completed" ? 120.5 : null,
    fare: isCancelled ? 0 : null,
    ride_type: "car",
    payment_method: "cash",
    decline_count: 0,
    created_at: now(),
    updated_at: now(),
    cancelled_by: isCancelled ? state?.cancelledBy ?? "passenger" : null,
    cancellation_reason: isCancelled ? "changed_plans" : null,
    cancellation_reason_text: null,
  };
}

async function json(route: Route, status: number, body: unknown) {
  await route.fulfill({
    status,
    contentType: "application/json",
    headers: {
      "access-control-allow-origin": "*",
      "access-control-allow-methods": "GET,POST,PUT,DELETE,OPTIONS",
      "access-control-allow-headers":
        "authorization,content-type,idempotency-key",
    },
    body: JSON.stringify(body),
  });
}

function geocodeFor(query: string): {
  lat: number;
  lng: number;
  address: string;
} {
  const q = query.toLowerCase();
  if (q.includes("airport")) {
    return {
      lat: 14.5086,
      lng: 121.0194,
      address:
        "Ninoy Aquino International Airport, Pasay, Metro Manila, Philippines",
    };
  }
  return {
    lat: 14.5995,
    lng: 120.9842,
    address: "Manila, Metro Manila, Philippines",
  };
}

export async function installMockApi(page: Page, state: MockApiState) {
  await page.route("**/*", async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace(/^\/api/, "");
    const method = request.method();
    if (method === "OPTIONS" && isApiPath(path)) {
      return route.fulfill({
        status: 204,
        headers: {
          "access-control-allow-origin": "*",
          "access-control-allow-methods": "GET,POST,PUT,DELETE,OPTIONS",
          "access-control-allow-headers":
            "authorization,content-type,idempotency-key",
        },
      });
    }

    // ---- Third-party geocoding: Google Maps + Nominatim ---------------
    if (url.host === "maps.googleapis.com") {
      if (url.pathname.endsWith("/place/autocomplete/json")) {
        const input = url.searchParams.get("input") ?? "";
        const loc = geocodeFor(input);
        return json(route, 200, {
          status: "OK",
          predictions: [
            {
              description: loc.address,
              place_id: `mock-${input.replace(/\W+/g, "-").toLowerCase()}`,
              structured_formatting: {
                main_text: input,
                secondary_text: loc.address,
              },
            },
          ],
        });
      }
      if (url.pathname.endsWith("/geocode/json")) {
        const address = url.searchParams.get("address") ?? "";
        const loc = geocodeFor(address);
        return json(route, 200, {
          status: "OK",
          results: [
            {
              formatted_address: loc.address,
              geometry: { location: { lat: loc.lat, lng: loc.lng } },
              place_id: `mock-${address.replace(/\W+/g, "-").toLowerCase()}`,
            },
          ],
        });
      }
    }

    if (url.host === "nominatim.openstreetmap.org") {
      if (url.pathname === "/search") {
        const q = url.searchParams.get("q") ?? "";
        const loc = geocodeFor(q);
        return json(route, 200, [
          {
            place_id: 1,
            lat: String(loc.lat),
            lon: String(loc.lng),
            display_name: loc.address,
            address: { city: "Manila", country: "Philippines" },
          },
        ]);
      }
      if (url.pathname === "/reverse") {
        const lat = parseFloat(url.searchParams.get("lat") ?? "14.5995");
        const lng = parseFloat(url.searchParams.get("lon") ?? "120.9842");
        return json(route, 200, {
          place_id: 1,
          lat: String(lat),
          lon: String(lng),
          display_name: "Manila, Metro Manila, Philippines",
          address: { city: "Manila", country: "Philippines" },
        });
      }
    }

    if (method === "POST" && path === "/auth/login") {
      const body = request.postDataJSON() as { email?: string };
      const role = body.email?.includes("driver") ? "driver" : "passenger";
      return json(route, 200, {
        access_token: `${role}-access-token`,
        refresh_token: `${role}-refresh-token`,
        access_token_expires_at: "2026-12-31T00:00:00.000Z",
        user: role === "driver" ? driver : passenger,
      });
    }

    if (method === "POST" && path === "/auth/register") {
      if (state.registerShouldFail) {
        return json(route, 409, {
          code: "USER_ALREADY_EXISTS",
          message: "Email already registered.",
        });
      }
      const body = request.postDataJSON() as { email?: string };
      const role = body.email?.includes("driver") ? "driver" : "passenger";
      return json(route, 201, {
        access_token: `${role}-access-token`,
        refresh_token: `${role}-refresh-token`,
        access_token_expires_at: "2026-12-31T00:00:00.000Z",
        user: role === "driver" ? driver : passenger,
      });
    }

    if (method === "POST" && path === "/auth/refresh") {
      return json(route, 200, {
        access_token: "refreshed-access-token",
        refresh_token: "refreshed-refresh-token",
        access_token_expires_at: "2026-12-31T00:00:00.000Z",
        user: passenger,
      });
    }

    if (method === "GET" && path === "/users/me") {
      if (state.forceUnauthorizedOnce) {
        state.forceUnauthorizedOnce = false;
        return json(route, 401, {
          code: "TOKEN_INVALID",
          message: "Invalid token.",
        });
      }
      const token = request.headers()["authorization"] ?? "";
      return json(route, 200, token.includes("driver") ? driver : passenger);
    }

    if (method === "GET" && path === "/service-area") {
      return json(route, 200, {
        areas: [
          {
            id: "global-e2e",
            name: "E2E Service Area",
            boundary: {
              name: "E2E Service Area",
              multiplier: 1.0,
              polygon: [
                [-90, -180],
                [-90, 180],
                [90, 180],
                [90, -180],
              ],
            },
            active: true,
            created_at: "2026-01-01T00:00:00.000Z",
            updated_at: "2026-01-01T00:00:00.000Z",
          },
        ],
      });
    }

    if (method === "GET" && path === "/drivers/nearby/all") {
      return json(route, 200, {
        car: [
          {
            id: "driver-1",
            name: "Driver One",
            vehicle_make: "Toyota",
            vehicle_model: "Vios",
            vehicle_plate: "SAK-123",
            vehicle_type: "car",
            rating: 4.9,
            distance_m: 300.5,
            location: { lat: 14.5995, lng: 120.9842 },
            heading: 90.5,
          },
        ],
        motorcycle: [],
        tricycle: [],
      });
    }

    if (method === "PUT" && path === "/driver/status") {
      state.driverOnline = true;
      return json(route, 200, { status: "online" });
    }

    if (method === "POST" && path === "/driver/location") {
      return json(route, 200, { ok: true });
    }

    if (method === "GET" && path === "/driver/rides/incoming") {
      if (state.driverDeclined) {
        return json(route, 404, { code: "NOT_FOUND", message: "No ride" });
      }
      if (
        !state.rideRequested ||
        state.rideStatus !== "requested" ||
        state.rideCancelled
      ) {
        return json(route, 404, { code: "NOT_FOUND", message: "No ride" });
      }
      return json(route, 200, ride("requested"));
    }

    if (method === "POST" && path === "/rides") {
      if (state.failNextRideCreate) {
        state.failNextRideCreate = false;
        return json(route, 503, {
          code: "NO_DRIVERS_AVAILABLE",
          message: "No drivers available.",
        });
      }
      state.rideRequested = true;
      state.rideStatus = "requested";
      state.rideCancelled = false;
      state.cancelledBy = undefined;
      return json(route, 201, ride("requested"));
    }

    if (method === "GET" && path === "/rides/active") {
      if (!state.rideRequested) {
        return json(route, 404, { code: "NOT_FOUND", message: "No ride" });
      }
      if (state.rideCancelled) {
        return json(route, 404, { code: "NOT_FOUND", message: "No ride" });
      }
      return json(
        route,
        200,
        ride(state.rideStatus, state.rideStatus !== "requested", state),
      );
    }

    if (method === "GET" && path === "/rides/ride-e2e-1") {
      return json(
        route,
        200,
        ride(state.rideStatus, state.rideStatus !== "requested", state),
      );
    }

    if (method === "POST" && path === "/rides/ride-e2e-1/accept") {
      state.rideStatus = "accepted";
      return json(route, 200, ride("accepted", true, state));
    }

    if (method === "POST" && path === "/rides/ride-e2e-1/decline") {
      state.driverDeclined = true;
      return json(route, 200, { status: "declined", decline_count: 1 });
    }

    if (method === "POST" && path === "/rides/ride-e2e-1/arrive") {
      state.rideStatus = "arrived";
      return json(route, 200, ride("arrived", true, state));
    }

    if (method === "POST" && path === "/rides/ride-e2e-1/start") {
      state.rideStatus = "in_progress";
      return json(route, 200, ride("in_progress", true, state));
    }

    if (method === "POST" && path === "/rides/ride-e2e-1/complete") {
      state.rideStatus = "completed";
      return json(route, 200, ride("completed", true, state));
    }

    if (method === "POST" && path === "/rides/ride-e2e-1/cancel") {
      state.rideCancelled = true;
      state.rideStatus = "cancelled";
      state.cancelledBy = "passenger";
      return json(route, 200, ride("cancelled", false, state));
    }

    return route.continue();
  });
}

function isApiPath(path: string) {
  return (
    path.startsWith("/auth/") ||
    path.startsWith("/users/") ||
    path.startsWith("/service-area") ||
    path.startsWith("/drivers/") ||
    path.startsWith("/driver/") ||
    path.startsWith("/rides")
  );
}
