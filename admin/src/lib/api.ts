// ---------------------------------------------------------------------------
// SakAI API Client — typed wrapper for all endpoints in swagger.yaml v1.1.0
// Base URL: http://localhost:8080/api  (override via VITE_API_URL)
// ---------------------------------------------------------------------------

const BASE_URL = (import.meta.env.VITE_API_URL as string) || 'https://sakai-backend-production.up.railway.app/api';

// ── Token storage ────────────────────────────────────────────────────────────

const ACCESS_TOKEN_KEY = 'sakai_access_token';
const REFRESH_TOKEN_KEY = 'sakai_refresh_token';

export const tokenStore = {
  getAccess: () => localStorage.getItem(ACCESS_TOKEN_KEY),
  getRefresh: () => localStorage.getItem(REFRESH_TOKEN_KEY),
  set: (access: string, refresh: string) => {
    localStorage.setItem(ACCESS_TOKEN_KEY, access);
    localStorage.setItem(REFRESH_TOKEN_KEY, refresh);
  },
  clear: () => {
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
  },
};

// ── Schemas (mirrors swagger.yaml) ───────────────────────────────────────────

export interface LatLng {
  lat: number;
  lng: number;
}

export interface VehicleInfo {
  make: string;
  model: string;
  color: string;
  plate: string;
}

export interface UserProfile {
  id: string;
  name: string;
  email: string;
  role: 'passenger' | 'driver';
  vehicle?: VehicleInfo | null;
  created_at: string;
}

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  access_token_expires_at: string;
  user: UserProfile;
}

export type RideStatus =
  | 'requested'
  | 'accepted'
  | 'arrived'
  | 'in_progress'
  | 'completed'
  | 'cancelled';

export interface DriverSummary {
  id: string;
  name: string;
  vehicle: VehicleInfo;
  current_location?: LatLng;
}

export interface RideResponse {
  id: string;
  status: RideStatus;
  passenger: UserProfile;
  driver?: DriverSummary | null;
  origin: LatLng;
  destination: LatLng;
  origin_address?: string | null;
  destination_address?: string | null;
  notes?: string | null;
  cancelled_by?: 'passenger' | 'driver' | null;
  created_at: string;
  updated_at: string;
}

export interface HealthResponse {
  status: 'ok' | 'degraded' | 'down';
  version?: string;
  dependencies?: {
    database?: 'ok' | 'down';
    redis?: 'ok' | 'down';
  };
}

export interface ErrorResponse {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

export interface DriverStatusResponse {
  driver_id: string;
  status: 'online' | 'offline';
  updated_at: string;
}

// ── Core fetch helper ─────────────────────────────────────────────────────────

export class ApiError extends Error {
  constructor(
    public status: number,
    public code: string,
    message: string,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

async function request<T>(
  method: string,
  path: string,
  body?: unknown,
  extraHeaders?: Record<string, string>,
): Promise<T> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...extraHeaders,
  };

  const token = tokenStore.getAccess();
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });

  if (res.status === 204) return undefined as T;

  const data = await res.json().catch(() => ({}));

  if (!res.ok) {
    const err = data as ErrorResponse;
    throw new ApiError(res.status, err.code ?? 'UNKNOWN', err.message ?? res.statusText);
  }

  return data as T;
}

// ── System ────────────────────────────────────────────────────────────────────

export const api = {
  health: {
    check: () => request<HealthResponse>('GET', '/health'),
  },

  // ── Auth ───────────────────────────────────────────────────────────────────

  auth: {
    register: (body: {
      name: string;
      email: string;
      password: string;
      role: 'passenger' | 'driver';
    }) => request<AuthResponse>('POST', '/auth/register', body),

    login: (body: { email: string; password: string }) =>
      request<AuthResponse>('POST', '/auth/login', body),

    refresh: (refresh_token: string) =>
      request<AuthResponse>('POST', '/auth/refresh', { refresh_token }),

    logout: (refresh_token: string) =>
      request<void>('POST', '/auth/logout', { refresh_token }),
  },

  // ── Users ──────────────────────────────────────────────────────────────────

  users: {
    me: () => request<UserProfile>('GET', '/users/me'),
  },

  // ── Driver ─────────────────────────────────────────────────────────────────

  driver: {
    setStatus: (status: 'online' | 'offline') =>
      request<DriverStatusResponse>(
        'PUT',
        '/driver/status',
        { status },
      ),

    updateLocation: (location: LatLng, heading?: number) =>
      request<void>('PUT', '/driver/location', { location, heading }),

    getIncomingRide: () => request<RideResponse>('GET', '/driver/rides/incoming'),
  },

  // ── Rides ──────────────────────────────────────────────────────────────────

  rides: {
    getActive: () => request<RideResponse>('GET', '/rides/active'),

    request: (
      body: {
        origin: LatLng;
        destination: LatLng;
        origin_address?: string;
        destination_address?: string;
        notes?: string;
      },
      idempotencyKey: string,
    ) =>
      request<RideResponse>('POST', '/rides', body, {
        'Idempotency-Key': idempotencyKey,
      }),

    get: (rideId: string) => request<RideResponse>('GET', `/rides/${rideId}`),

    accept: (rideId: string) => request<RideResponse>('POST', `/rides/${rideId}/accept`),

    decline: (rideId: string) => request<RideResponse>('POST', `/rides/${rideId}/decline`),

    arrive: (rideId: string) => request<RideResponse>('POST', `/rides/${rideId}/arrive`),

    start: (rideId: string) => request<RideResponse>('POST', `/rides/${rideId}/start`),

    complete: (rideId: string) => request<RideResponse>('POST', `/rides/${rideId}/complete`),

    cancel: (rideId: string, reason?: string) =>
      request<RideResponse>('POST', `/rides/${rideId}/cancel`, reason ? { reason } : undefined),
  },
};

// ── WebSocket Event Schemas (mirrors swagger.yaml) ─────────────────────────

export interface WsEnvelope<T = unknown> {
  event: string;
  payload: T;
}

export interface WsEventRideRequested {
  ride_id: string;
  passenger: UserProfile;
  origin: LatLng;
  destination: LatLng;
  origin_address?: string | null;
  destination_address?: string | null;
  notes?: string | null;
  expires_at: string;
}

export interface WsEventRideOfferExpired {
  ride_id: string;
}

export interface WsEventRideAccepted {
  ride_id: string;
  driver: DriverSummary;
}

export interface WsEventRideDeclined {
  ride_id: string;
  message?: string;
}

export interface WsEventDriverLocationUpdated {
  ride_id: string;
  location: LatLng;
  heading?: number | null;
}

export interface WsEventRideStatusChanged {
  ride_id: string;
  status: RideStatus;
  updated_at: string;
}

export interface WsEventRideCancelled {
  ride_id: string;
  cancelled_by: 'passenger' | 'driver';
  reason?: string | null;
}

export interface WsEventNoDriversAvailable {
  ride_id: string;
  message?: string;
}

