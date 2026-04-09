import { adminRequest, extractArray } from './_request';

// Payment domain types — backend doesn't expose these in the current swagger
// schema blocks, so we define them inline until the contract is extended.
export type TransactionStatus = 'settled' | 'pending' | 'failed' | 'refunded';
export type PaymentMethod = 'cash' | 'gcash' | 'paymaya' | 'card';

export interface Transaction {
  id: string;
  ride_id: string;
  rider_name: string;
  driver_name: string;
  amount: number;
  payment_method: PaymentMethod;
  status: TransactionStatus;
  commission: number;
  created_at: string;
}

export interface DriverPayout {
  id: string;
  batch: string;
  driver_count: number;
  total_amount: number;
  period: string;
  status: 'pending' | 'approved' | 'processing' | 'done';
}

export interface PaymentSummary {
  total_revenue: number;
  total_driver_payouts: number;
  platform_commission: number;
  pending_settlements: number;
  failed_transactions: number;
}

export const paymentsApi = {
  getTransactions: () =>
    adminRequest<unknown>('GET', '/payments/transactions').then(extractArray<Transaction>),

  getPayouts: () =>
    adminRequest<unknown>('GET', '/payments/payouts').then(extractArray<DriverPayout>),

  approvePayout: (id: string) =>
    adminRequest<void>('PUT', `/payments/payouts/${id}/approve`),

  getSummary: () =>
    adminRequest<PaymentSummary>('GET', '/payments/summary'),

  getCommissionConfig: () =>
    adminRequest<unknown>('GET', '/payments/commission-config'),

  updateCommissionConfig: (data: unknown) =>
    adminRequest<unknown>('PUT', '/payments/commission-config', data),

  getGatewayConfigs: () =>
    adminRequest<unknown[]>('GET', '/payments/config').then(extractArray),
};
