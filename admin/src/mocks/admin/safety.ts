import type { Incident, KycEntry } from '@/types/super-admin';

export const incidents: Incident[] = [
  { id: 'INC-001', ride_id: 'RD-99421', triggered_by: 'rider', rider_name: 'Maria Santos', driver_name: 'Juan Dela Cruz', type: 'sos_triggered', severity: 'high', status: 'investigating', assigned_to: 'Maria Santos (Ops)', resolution_notes: null, created_at: '2026-04-02T09:15:00Z', resolved_at: null },
  { id: 'INC-002', ride_id: 'RD-99388', triggered_by: 'rider', rider_name: 'Jose Rizal', driver_name: 'Pedro Penduko', type: 'reported_incident', severity: 'medium', status: 'open', assigned_to: null, resolution_notes: null, created_at: '2026-04-01T18:30:00Z', resolved_at: null },
  { id: 'INC-003', ride_id: 'RD-99210', triggered_by: 'driver', rider_name: 'Ana Reyes', driver_name: 'Carlo Bautista', type: 'safety_complaint', severity: 'low', status: 'resolved', assigned_to: 'Ana Gonzales (Support)', resolution_notes: 'Resolved after investigation. No further action needed.', created_at: '2026-03-30T14:00:00Z', resolved_at: '2026-03-31T10:00:00Z' },
  { id: 'INC-004', ride_id: 'RD-99105', triggered_by: 'rider', rider_name: 'Luisa Fernandez', driver_name: 'Ramon Cruz', type: 'sos_triggered', severity: 'high', status: 'escalated', assigned_to: 'Eduardo Reyes (Super Admin)', resolution_notes: 'Escalated to law enforcement.', created_at: '2026-03-28T22:00:00Z', resolved_at: null },
];

const LICENSE_IMG = 'https://picsum.photos/seed/license/800/500';
const REGISTRATION_IMG = 'https://picsum.photos/seed/registration/800/500';
const INSURANCE_IMG = 'https://picsum.photos/seed/insurance/800/500';
const PROFILE_IMG = 'https://picsum.photos/seed/profile/600/600';
const NBI_IMG = 'https://picsum.photos/seed/nbi/800/500';

export const kycQueue: KycEntry[] = [
  {
    id: 'KYC-101', driver_id: 'D-3001', driver_name: 'Carlo Reyes',
    submitted_at: '2026-04-01T08:00:00Z', status: 'pending',
    docs: [
      { type: 'drivers_license', label: "Driver's License", url: LICENSE_IMG },
      { type: 'vehicle_registration', label: 'Vehicle Registration', url: REGISTRATION_IMG },
      { type: 'insurance', label: 'Insurance Policy', url: INSURANCE_IMG },
      { type: 'profile_photo', label: 'Profile Photo', url: PROFILE_IMG },
      { type: 'nbi_clearance', label: 'NBI Clearance', url: NBI_IMG },
    ],
  },
  {
    id: 'KYC-102', driver_id: 'D-3002', driver_name: 'Liza Marcos',
    submitted_at: '2026-04-01T11:30:00Z', status: 'pending',
    docs: [
      { type: 'drivers_license', label: "Driver's License", url: LICENSE_IMG },
      { type: 'vehicle_registration', label: 'Vehicle Registration', url: REGISTRATION_IMG },
      { type: 'profile_photo', label: 'Profile Photo', url: PROFILE_IMG },
    ],
  },
  {
    id: 'KYC-103', driver_id: 'D-3003', driver_name: 'Ben Aquino',
    submitted_at: '2026-04-02T07:00:00Z', status: 'pending',
    docs: [
      { type: 'drivers_license', label: "Driver's License", url: LICENSE_IMG },
      { type: 'vehicle_registration', label: 'Vehicle Registration', url: REGISTRATION_IMG },
      { type: 'insurance', label: 'Insurance Policy', url: INSURANCE_IMG },
      { type: 'nbi_clearance', label: 'NBI Clearance', url: NBI_IMG },
    ],
  },
];

export const ltfrbCompliance = {
  accreditation_status: 'Active',
  accreditation_expiry: '2027-06-30',
  driver_compliance_rate: 91.4,
  insurance_compliance_rate: 88.2,
  inspection_compliance_rate: 79.6,
  violations_open: 3,
  violations_resolved: 47,
  last_report_submitted: '2026-03-01',
  next_report_due: '2026-06-01',
};
