// Admin user types — re-exported from the generated OpenAPI contract.
// Source: src/types/openapi.d.ts (run `npm run generate:types` to refresh)

import type { components } from '@/types/openapi';

export type AdminUser   = components['schemas']['AdminUser'];
export type AdminStatus = 'active' | 'suspended' | 'deactivated';
export type AdminRole   = 'super_admin' | 'operations' | 'finance' | 'support';

export type { AdminUser as default };
