import type { components } from '@/types/openapi';

type BasePaymentSummary = components['schemas']['PaymentSummary'];

export type Transaction         = components['schemas']['Transaction'];
export type DriverPayout        = components['schemas']['DriverPayout'];
export type CommissionConfig    = components['schemas']['CommissionConfig'];
export type PaymentGatewayConfig = components['schemas']['PaymentGatewayConfig'];
export type BatchApproveRequest = components['schemas']['BatchApproveRequest'];

// Widen the generated summary with mock fields used in the UI.
export type PaymentSummary = BasePaymentSummary & {
  driver_payouts?: number;
  failed_transactions?: number;
};
