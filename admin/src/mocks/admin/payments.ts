import { Transaction, DriverPayout } from '@/lib/admin-api';

export const summary = {
  total_revenue: 4520000,
  driver_payouts: 3616000,
  commission: 904000,
  pending_settlements: 125000,
  failed_transactions: 12,
};

export const transactions: Transaction[] = [
  { id: 'TXN-8821', ride_id: 'RD-99281', rider_name: 'Maria Santos', driver_name: 'Juan Dela Cruz', amount: 150, payment_method: 'gcash', status: 'settled', commission: 22.5, created_at: '2026-04-01T14:35:00Z' },
  { id: 'TXN-8822', ride_id: 'RD-99282', rider_name: 'Jose Rizal', driver_name: 'Pedro Penduko', amount: 50, payment_method: 'cash', status: 'settled', commission: 7.5, created_at: '2026-04-01T15:20:00Z' },
  { id: 'TXN-8823', ride_id: 'RD-99283', rider_name: 'Andres Bonifacio', driver_name: 'Cardo Dalisay', amount: 220, payment_method: 'paymaya', status: 'failed', commission: 0, created_at: '2026-04-01T16:05:00Z' },
  { id: 'TXN-8824', ride_id: 'RD-99284', rider_name: 'Emilio Aguinaldo', driver_name: 'Antonio Luna', amount: 180, payment_method: 'card', status: 'pending', commission: 27, created_at: '2026-04-01T16:50:00Z' },
  { id: 'TXN-8825', ride_id: '-', rider_name: '-', driver_name: 'Juan Dela Cruz', amount: -2500, payment_method: 'gcash', status: 'settled', commission: 0, created_at: '2026-04-01T10:00:00Z' },
];

export const payouts: DriverPayout[] = [
  { id: 'PAY-492', batch: '#492', driver_count: 142, total_amount: 450000, period: '2026-03-25 to 2026-03-31', status: 'pending' },
  { id: 'PAY-491', batch: '#491', driver_count: 89, total_amount: 210000, period: '2026-03-18 to 2026-03-24', status: 'pending' },
  { id: 'PAY-490', batch: '#490', driver_count: 203, total_amount: 680000, period: '2026-03-11 to 2026-03-17', status: 'done' },
];
