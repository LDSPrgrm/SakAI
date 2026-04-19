import type { components } from '@/types/openapi';

type BaseFareConfig = components['schemas']['FareConfig'];
type BaseSurgeConfig = components['schemas']['SurgeConfig'];

// FareConfig with client-side fields used by the admin UI.
export type FareConfig = BaseFareConfig & {
  id?: string;
  updated_by?: string;
  updated_at?: string;
};

export interface BlackoutHour {
  day_of_week?: number;
  start_time?: string;
  end_time?: string;
  // Mock aliases used by some pages
  day?: number;
  start?: string;
  end?: string;
}

export type SurgeConfig = Omit<BaseSurgeConfig, 'blackout_hours'> & {
  id?: string;
  blackout_hours?: BlackoutHour[];
};

export type FareSimulationRequest = components['schemas']['FareSimulationRequest'];
export type FareSimulationResponse = components['schemas']['FareSimulationResponse'];

export interface AdminFaresResponse {
  fares?: FareConfig[];
  surge?: SurgeConfig;
}
