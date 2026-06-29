// Maps audit-log resource_type values to the prefix used by EntityId so the
// resource_id column shows e.g. INC-XXXX or USR-XXXX rather than a raw UUID.
// Keep keys aligned with backend usecase ResourceType strings.
export const RESOURCE_TYPE_PREFIX: Record<string, string> = {
  incident: 'INC',
  ride: 'RIDE',
  user: 'USR',
  admin_user: 'USR',
  fare_config: 'FARE',
  surge_config: 'SURGE',
  alert_rule: 'ALERT',
  payment: 'TXN',
  ride_payment: 'TXN',
};

export function prefixFor(resourceType: string | null | undefined): string {
  if (!resourceType) return 'REF';
  return RESOURCE_TYPE_PREFIX[resourceType] ?? 'REF';
}
