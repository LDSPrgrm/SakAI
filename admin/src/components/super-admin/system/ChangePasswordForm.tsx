import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Lock } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { authApi } from '@/api/super-admin/auth';

const schema = z
  .object({
    oldPassword: z.string().min(1, 'Current password is required').max(128),
    newPassword: z
      .string()
      .min(8, 'Password must be at least 8 characters')
      .max(128, 'Password is too long'),
    confirmPassword: z.string(),
  })
  .refine((v) => v.newPassword === v.confirmPassword, {
    path: ['confirmPassword'],
    message: 'New passwords do not match',
  });

type Values = z.infer<typeof schema>;

export function ChangePasswordForm() {
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<Values>({ resolver: zodResolver(schema) });

  const [apiError, setApiError] = useState('');
  const [success, setSuccess] = useState(false);

  async function onSubmit(values: Values) {
    setApiError('');
    setSuccess(false);
    try {
      await authApi.changePassword({
        old_password: values.oldPassword,
        new_password: values.newPassword,
      });
      setSuccess(true);
      reset();
    } catch {
      setApiError('Failed to change password. Check your current password and try again.');
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="max-w-md space-y-4" noValidate>
      <div className="flex items-center gap-2 mb-2">
        <Lock className="w-4 h-4 text-text-muted" />
        <h3 className="font-semibold text-text-main">Change Password</h3>
      </div>

      <div className="space-y-3">
        <div>
          <label className="block text-xs text-text-muted mb-1">Current Password</label>
          <Input
            {...register('oldPassword')}
            type="password"
            placeholder="Enter current password"
            className={errors.oldPassword ? 'border-danger' : ''}
          />
          {errors.oldPassword && (
            <p className="text-xs text-danger mt-1">{errors.oldPassword.message}</p>
          )}
        </div>

        <div>
          <label className="block text-xs text-text-muted mb-1">New Password</label>
          <Input
            {...register('newPassword')}
            type="password"
            placeholder="Min. 8 characters"
            className={errors.newPassword ? 'border-danger' : ''}
          />
          {errors.newPassword && (
            <p className="text-xs text-danger mt-1">{errors.newPassword.message}</p>
          )}
        </div>

        <div>
          <label className="block text-xs text-text-muted mb-1">Confirm New Password</label>
          <Input
            {...register('confirmPassword')}
            type="password"
            placeholder="Repeat new password"
            className={errors.confirmPassword ? 'border-danger' : ''}
          />
          {errors.confirmPassword && (
            <p className="text-xs text-danger mt-1">{errors.confirmPassword.message}</p>
          )}
        </div>
      </div>

      {apiError && <p className="text-sm text-danger">{apiError}</p>}
      {success && <p className="text-sm text-success">Password changed successfully.</p>}

      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Saving…' : 'Change Password'}
      </Button>
    </form>
  );
}
