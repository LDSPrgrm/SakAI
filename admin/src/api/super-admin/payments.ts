import { adminRequest, adminRequestVoid, extractArray } from './_request';
import type { components } from '@/types/openapi';

export type Transaction              = components['schemas']['Transaction'];
export type DriverPayout             = components['schemas']['DriverPayout'];
export type PaymentSummary           = components['schemas']['PaymentSummary'];
export type CommissionConfig         = components['schemas']['CommissionConfig'];
export type BatchApproveRequest      = components['schemas']['BatchApproveRequest'];
export type UpdatePaymentConfigRequest = components['schemas']['UpdatePaymentConfigRequest'];
export type PaymentGatewayConfig     = components['schemas']['PaymentGatewayConfig'];

// String-literal aliases derived from the spec Transaction schema.
export type PaymentMethod      = NonNullable<Transaction['payment_method']>;
export type TransactionStatus  = NonNullable<Transaction['status']>;

export const paymentsApi = {
  getTransactions: () =>
    adminRequest<unknown>('GET', '/payments/transactions').then(extractArray<Transaction>),

  getPayouts: () =>
    adminRequest<unknown>('GET', '/payments/payouts').then(extractArray<DriverPayout>),

  approvePayout: (id: string) =>
    adminRequestVoid('PUT', `/payments/payouts/${id}/approve`),

  /** POST /admin/payments/payouts/approve — batch approve payouts (H9). */
  batchApprovePayouts: (ids: string[]) =>
    adminRequest<{ approved: number }>('POST', '/payments/payouts/approve', { ids } satisfies BatchApproveRequest),

  getSummary: () =>
    adminRequest<PaymentSummary>('GET', '/payments/summary'),

  getCommissionConfig: () =>
    adminRequest<CommissionConfig>('GET', '/payments/commission-config'),

  updateCommissionConfig: (data: CommissionConfig) =>
    adminRequestVoid('PUT', '/payments/commission-config', data),

  getGatewayConfigs: () =>
    adminRequest<unknown[]>('GET', '/payments/config').then(extractArray<PaymentGatewayConfig>),

  /** PUT /admin/payments/config/{provider} — update gateway config (L2). */
  updateConfig: (provider: string, payload: UpdatePaymentConfigRequest) =>
    adminRequestVoid('PUT', `/payments/config/${provider}`, payload),
};
