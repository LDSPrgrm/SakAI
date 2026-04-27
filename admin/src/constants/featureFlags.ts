// Known feature flag keys — kept in sync with the backend seed data.
// Components should use these constants instead of raw strings.

export const FLAG_KEYS = {
  SURGE_PRICING:     'surge_pricing',
  MAINTENANCE_MODE:  'maintenance_mode',
  KYC_AUTO_APPROVE:  'kyc_auto_approve',
  CASHLESS_PAYMENTS: 'cashless_payments',
} as const;

export type FlagKey = (typeof FLAG_KEYS)[keyof typeof FLAG_KEYS];
