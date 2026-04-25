import type { FeatureFlag, SystemService } from '@/types/super-admin';

export const integrations = [
  { service: 'google_maps', label: 'Google Maps', api_key: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX1234', status: 'ok', last_used: '2026-04-02T09:10:00Z' },
  { service: 'twilio', label: 'Twilio SMS', api_key: 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx5678', status: 'ok', last_used: '2026-04-02T09:05:00Z' },
  { service: 'firebase', label: 'Firebase FCM', api_key: 'AAAAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx9012', status: 'ok', last_used: '2026-04-02T09:01:00Z' },
  { service: 'background_check', label: 'Background Check', api_key: 'BCxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx3456', status: 'degraded', last_used: '2026-04-01T22:00:00Z' },
  { service: 'cloud_storage', label: 'Cloud Storage (S3)', api_key: 'AKIAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx7890', status: 'ok', last_used: '2026-04-02T08:55:00Z' },
];

export const notificationTemplates = [
  { event: 'ride_accepted', channel: 'Push + SMS', body: 'Your driver {driver_name} is on the way! ETA: {eta}. Vehicle: {vehicle_type}.' },
  { event: 'driver_eta_update', channel: 'Push', body: '{driver_name} will arrive in {eta}.' },
  { event: 'ride_started', channel: 'Push', body: 'Your ride has started. Pickup: {pickup_address}. Driver: {driver_name}.' },
  { event: 'ride_completed', channel: 'Push + SMS', body: 'Ride completed! Fare: {fare} via {payment_method}. Thanks for riding with SakAI.' },
  { event: 'payment_failed', channel: 'Push + SMS', body: 'Payment of {amount} via {payment_method} failed. Please retry: {retry_url}' },
  { event: 'sos_alert', channel: 'SMS', body: 'ALERT: {rider_name} triggered SOS. Location: {location_url}. Ride: {ride_id}.' },
  { event: 'kyc_approved', channel: 'Push + SMS', body: 'Congratulations {driver_name}! Your KYC has been approved. You can now start accepting rides.' },
  { event: 'kyc_rejected', channel: 'Push + SMS', body: 'Hi {driver_name}, your KYC was rejected. Reason: {rejection_reason}. Please resubmit.' },
];

export const featureFlags: FeatureFlag[] = [
  { key: 'surge_pricing',    label: 'Surge Pricing',    description: 'Enable dynamic surge pricing based on demand/supply ratio.', enabled: true },
  { key: 'motorcycle_rides', label: 'Motorcycle Rides', description: 'Allow motorcycle ride bookings.', enabled: true },
  { key: 'tricycle_rides',   label: 'Tricycle Rides',   description: 'Allow tricycle ride bookings.', enabled: true },
  { key: 'car_rides',        label: 'Car Rides',        description: 'Allow 4-seater car ride bookings.', enabled: true },
  { key: 'gcash_payments',   label: 'GCash Payments',   description: 'Accept GCash as a payment method.', enabled: true },
  { key: 'paymaya_payments', label: 'PayMaya Payments', description: 'Accept PayMaya as a payment method.', enabled: true },
  { key: 'card_payments',    label: 'Card Payments',    description: 'Accept credit/debit card payments.', enabled: true },
  { key: 'cash_payments',    label: 'Cash Payments',    description: 'Accept cash payments.', enabled: true },
  { key: 'maintenance_mode', label: 'Maintenance Mode', description: 'Disable ride booking and show a maintenance message to users.', enabled: false },
];

export const services: SystemService[] = [
  { name: 'API Gateway', status: 'ok', latency_ms: 112, uptime_pct: 99.98, last_checked: new Date().toISOString() },
  { name: 'Dispatch Service', status: 'ok', latency_ms: 340, uptime_pct: 99.95, last_checked: new Date().toISOString() },
  { name: 'Payment Service', status: 'degraded', latency_ms: 820, uptime_pct: 99.12, last_checked: new Date().toISOString() },
  { name: 'WebSocket (Tracking)', status: 'ok', latency_ms: 45, uptime_pct: 99.99, last_checked: new Date().toISOString() },
  { name: 'PostgreSQL', status: 'ok', latency_ms: 18, uptime_pct: 100, last_checked: new Date().toISOString() },
  { name: 'Redis', status: 'ok', latency_ms: 3, uptime_pct: 100, last_checked: new Date().toISOString() },
  { name: 'NATS JetStream', status: 'ok', latency_ms: 9, uptime_pct: 99.97, last_checked: new Date().toISOString() },
];
