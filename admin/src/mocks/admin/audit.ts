import type { AuditLogEntry } from '@/types/super-admin';

export const auditLogs: AuditLogEntry[] = [
  { id: 'AUD-001', timestamp: '2026-04-02T09:15:00Z', actor_id: 'a1b2c3d4', actor_name: 'Eduardo Reyes', ip_address: '192.168.7.101', action: 'update', resource_type: 'fare_config', resource_id: 'fare-moto-001', before_state: { base_fare: 45 }, after_state: { base_fare: 50 }, reason: 'Adjusted for fuel cost increase' },
  { id: 'AUD-002', timestamp: '2026-04-02T08:45:00Z', actor_id: 'b2c3d4e5', actor_name: 'Maria Santos', ip_address: '192.168.7.102', action: 'approve', resource_type: 'kyc', resource_id: 'KYC-099', before_state: { status: 'pending' }, after_state: { status: 'approved' }, reason: null },
  { id: 'AUD-003', timestamp: '2026-04-01T16:30:00Z', actor_id: 'a1b2c3d4', actor_name: 'Eduardo Reyes', ip_address: '192.168.7.101', action: 'create', resource_type: 'admin_user', resource_id: 'e5f6a7b8', before_state: null, after_state: { name: 'Ramon Villanueva', role: 'operations' }, reason: null },
  { id: 'AUD-004', timestamp: '2026-04-01T14:00:00Z', actor_id: 'c3d4e5f6', actor_name: 'Jose Dela Cruz', ip_address: '192.168.7.103', action: 'update', resource_type: 'commission', resource_id: 'comm-001', before_state: { rate: 14 }, after_state: { rate: 15 }, reason: 'Q2 commission adjustment' },
  { id: 'AUD-005', timestamp: '2026-04-01T11:00:00Z', actor_id: 'a1b2c3d4', actor_name: 'Eduardo Reyes', ip_address: '192.168.7.101', action: 'update', resource_type: 'feature_flag', resource_id: 'surge_pricing', before_state: { enabled: false }, after_state: { enabled: true }, reason: 'Re-enabling surge after testing' },
  { id: 'AUD-006', timestamp: '2026-04-01T09:00:00Z', actor_id: 'b2c3d4e5', actor_name: 'Maria Santos', ip_address: '192.168.7.102', action: 'reject', resource_type: 'kyc', resource_id: 'KYC-098', before_state: { status: 'pending' }, after_state: { status: 'rejected' }, reason: 'Blurry documents — unable to verify' },
  { id: 'AUD-007', timestamp: '2026-03-31T17:00:00Z', actor_id: 'a1b2c3d4', actor_name: 'Eduardo Reyes', ip_address: '192.168.7.101', action: 'update', resource_type: 'admin_user', resource_id: 'e5f6a7b8', before_state: { status: 'active' }, after_state: { status: 'suspended' }, reason: 'Policy violation' },
  { id: 'AUD-008', timestamp: '2026-03-30T08:30:00Z', actor_id: 'a1b2c3d4', actor_name: 'Eduardo Reyes', ip_address: '192.168.7.101', action: 'login', resource_type: 'session', resource_id: 'sess-001', before_state: null, after_state: null, reason: null },
];

export function generateCsv(): string {
  const headers = 'ID,Timestamp,Admin,Action,Resource Type,Resource ID,Reason';
  const rows = auditLogs.map(e =>
    `${e.id},${e.timestamp},${e.actor_name},${e.action},${e.resource_type},${e.resource_id},"${e.reason ?? ''}"`
  );
  return [headers, ...rows].join('\n');
}
