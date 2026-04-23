import { adminRequest, adminRequestVoid, extractArray } from './_request';
import type { SurgeZone } from '@/lib/maps';

// ServiceArea.boundary is stored as raw JSONB; the mobile client treats it as
// opaque and the admin UI renders it via the SurgeZoneEditor, which expects
// the same {name, multiplier, polygon} shape.
export interface ServiceArea {
  id: string;
  name: string;
  lgu_code?: string;
  boundary: SurgeZone; // reuses the polygon shape
  active: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface LGUPartnership {
  id: string;
  service_area_id?: string | null;
  lgu_name: string;
  contact_name?: string;
  contact_email?: string;
  contact_phone?: string;
  agreement_start?: string | null;
  agreement_end?: string | null;
  status: 'active' | 'pending' | 'expired' | 'terminated';
  notes?: string;
  created_at?: string;
  updated_at?: string;
}

export interface LGUPartnershipInput {
  service_area_id?: string | null;
  lgu_name: string;
  contact_name?: string;
  contact_email?: string;
  contact_phone?: string;
  agreement_start?: string | null;
  agreement_end?: string | null;
  status?: LGUPartnership['status'];
  notes?: string;
}

export interface ServiceAreaInput {
  name: string;
  lgu_code?: string;
  boundary: SurgeZone;
  active?: boolean;
}

export const serviceAreaApi = {
  list: () =>
    adminRequest<unknown>('GET', '/service-areas').then(extractArray<ServiceArea>),
  create: (data: ServiceAreaInput) =>
    adminRequest<ServiceArea>('POST', '/service-areas', data),
  update: (id: string, data: ServiceAreaInput) =>
    adminRequestVoid('PUT', `/service-areas/${id}`, data),
  remove: (id: string) => adminRequestVoid('DELETE', `/service-areas/${id}`),
};

export const lguApi = {
  list: () =>
    adminRequest<unknown>('GET', '/lgu-partnerships').then(extractArray<LGUPartnership>),
  get: (id: string) =>
    adminRequest<LGUPartnership>('GET', `/lgu-partnerships/${id}`),
  create: (data: LGUPartnershipInput) =>
    adminRequest<LGUPartnership>('POST', '/lgu-partnerships', data),
  update: (id: string, data: LGUPartnershipInput) =>
    adminRequestVoid('PUT', `/lgu-partnerships/${id}`, data),
  remove: (id: string) => adminRequestVoid('DELETE', `/lgu-partnerships/${id}`),
};
