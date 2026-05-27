// Admin create/edit form schema. Kept separate from AdminForm.tsx so the
// component file only exports components (React Fast Refresh requirement —
// react-doctor `only-export-components`).
import { z } from 'zod';

export const adminSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').max(255, 'Name is too long'),
  email: z.string().email('Must be a valid email address').max(255, 'Email is too long'),
  role: z.string().min(1, 'Role is required').max(100, 'Role is too long'),
  status: z.enum(['active', 'suspended', 'deactivated']),
  password: z
    .string()
    .min(8, 'Must be at least 8 characters')
    .max(128, 'Password is too long')
    .optional()
    .or(z.literal('')),
});

export type AdminFormValues = z.infer<typeof adminSchema>;
