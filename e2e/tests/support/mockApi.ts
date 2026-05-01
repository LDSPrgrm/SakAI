import { Page, Route } from "@playwright/test";

type RideStatus =
  | "requested"
  | "accepted"
  | "arrived"
  | "in_progress"
  | "completed";

export type MockApiState = {
  rideStatus: RideStatus;
  rideRequested: boolean;
  driverOnline: boolean;
};

export function createMockApiState(): MockApiState {
  return {
    rideStatus: "requested",
    rideRequested: false,
    driverOnline: false,
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

function ride(status: RideStatus = "requested", withDriver = false) {
  return {
    id: "ride-e2e-1",
    status,
    passenger,
    driver: withDriver ? driverSummary() : null,
    origin: { lat: 14.5995, lng: 120.9842 },
    destination: { lat: 14.6091, lng: 121.0223 },
    origin_address: "SakAI E2E Pickup",
    destination_address: "Airport",
    estimated_fare: 120.0,
    actual_fare: status === "completed" ? 120.0 : null,
    ride_type: "car",
    payment_method: "cash",
    decline_count: 0,
    created_at: now(),
    updated_at: now(),
  };
}

async function json(route: Route, status: number, body: unknown) {
  await route.fulfill({
    status,
    contentType: "application/json",
    headers: {
      "access-control-allow-origin": "*",
      "access-control-allow-methods": "GET,POST,PUT,DELETE,OPTIONS",
      "access-control-allow-headers": "authorization,content-type,idempotency-key",
    },
    body: JSON.stringify(body),
  });
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
          "access-control-allow-headers": "authorization,content-type,idempotency-key",
        },
      });
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

    if (method === "POST" && path === "/auth/refresh") {
      return json(route, 200, {
        access_token: "refreshed-access-token",
        refresh_token: "refreshed-refresh-token",
        access_token_expires_at: "2026-12-31T00:00:00.000Z",
        user: passenger,
      });
    }

    if (method === "GET" && path === "/users/me") {
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
            distance_m: 300,
            location: { lat: 14.5995, lng: 120.9842 },
            heading: 90,
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
      if (!state.rideRequested || state.rideStatus !== "requested") {
        return json(route, 404, { code: "NOT_FOUND", message: "No ride" });
      }
      return json(route, 200, ride("requested"));
    }

    if (method === "POST" && path === "/rides") {
      state.rideRequested = true;
      state.rideStatus = "requested";
      return json(route, 201, ride("requested"));
    }

    if (method === "GET" && path === "/rides/active") {
      if (!state.rideRequested) {
        return json(route, 404, { code: "NOT_FOUND", message: "No ride" });
      }
      return json(
        route,
        200,
        ride(state.rideStatus, state.rideStatus !== "requested"),
      );
    }

    if (method === "GET" && path === "/rides/ride-e2e-1") {
      return json(
        route,
        200,
        ride(state.rideStatus, state.rideStatus !== "requested"),
      );
    }

    if (method === "POST" && path === "/rides/ride-e2e-1/accept") {
      state.rideStatus = "accepted";
      return json(route, 200, ride("accepted", true));
    }

    if (method === "POST" && path === "/rides/ride-e2e-1/arrive") {
      state.rideStatus = "arrived";
      return json(route, 200, ride("arrived", true));
    }

    if (method === "POST" && path === "/rides/ride-e2e-1/start") {
      state.rideStatus = "in_progress";
      return json(route, 200, ride("in_progress", true));
    }

    if (method === "POST" && path === "/rides/ride-e2e-1/complete") {
      state.rideStatus = "completed";
      return json(route, 200, ride("completed", true));
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
