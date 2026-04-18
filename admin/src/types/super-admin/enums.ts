import type { components } from '@/types/openapi';

export type RideStatus      = components['schemas']['RideStatus'];
export type ErrorCode       = components['schemas']['ErrorCode'];
export type TransactionStatus = 'settled' | 'pending' | 'failed' | 'refunded';
export type PaymentMethod     = 'cash' | 'gcash' | 'paymaya' | 'card';
export type IncidentStatus    = 'open' | 'investigating' | 'resolved' | 'escalated';
export type IncidentSeverity  = 'low' | 'medium' | 'high';
export type IncidentType      = 'sos_triggered' | 'reported_incident' | 'safety_complaint';
