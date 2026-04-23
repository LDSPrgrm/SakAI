import React, { useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Car, Mail, Lock, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { useAuth } from '@/contexts/AuthContext';
import { ApiError } from '@/lib/api';

const loginSchema = z.object({
  email: z.string().email('Enter a valid email address').max(255),
  password: z.string().min(1, 'Password is required').max(128),
});

type LoginValues = z.infer<typeof loginSchema>;

export function Login() {
  const { login, isAuthenticated } = useAuth();
  const [apiError, setApiError] = useState('');
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginValues>({ resolver: zodResolver(loginSchema) });

  if (isAuthenticated) {
    return <Navigate to="/" replace />;
  }

  const onSubmit = async (values: LoginValues) => {
    setApiError('');
    try {
      await login(values.email, values.password);
    } catch (err) {
      if (err instanceof ApiError) {
        setApiError(err.message);
      } else {
        setApiError('Unable to reach the server. Check your connection.');
      }
    }
  };

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <div className="w-full max-w-sm">
        <div className="flex items-center justify-center gap-2 text-primary font-bold text-2xl mb-8">
          <Car className="w-7 h-7" />
          <span>SakAI Admin</span>
        </div>

        <div className="bg-surface border border-border rounded-xl p-6 space-y-5">
          <div>
            <h1 className="text-lg font-semibold text-text-main">Sign in</h1>
            <p className="text-sm text-text-muted mt-1">Enter your admin credentials to continue.</p>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4" noValidate>
            <div className="space-y-1">
              <label className="text-sm font-medium text-text-muted">Email</label>
              <Input
                {...register('email')}
                type="email"
                placeholder="admin@sakai.ph"
                icon={<Mail className="w-4 h-4" />}
                autoComplete="email"
                className={errors.email ? 'border-danger' : ''}
              />
              {errors.email && (
                <p className="text-xs text-danger">{errors.email.message}</p>
              )}
            </div>

            <div className="space-y-1">
              <label className="text-sm font-medium text-text-muted">Password</label>
              <Input
                {...register('password')}
                type="password"
                placeholder="••••••••"
                icon={<Lock className="w-4 h-4" />}
                autoComplete="current-password"
                className={errors.password ? 'border-danger' : ''}
              />
              {errors.password && (
                <p className="text-xs text-danger">{errors.password.message}</p>
              )}
            </div>

            {apiError && (
              <div className="flex items-center gap-2 text-sm text-danger bg-danger/10 border border-danger/20 rounded-lg px-3 py-2">
                <AlertCircle className="w-4 h-4 flex-shrink-0" />
                <span>{apiError}</span>
              </div>
            )}

            <Button type="submit" className="w-full" disabled={isSubmitting}>
              {isSubmitting ? 'Signing in…' : 'Sign in'}
            </Button>
          </form>
        </div>

        <p className="text-center text-xs text-text-muted mt-6">
          SakAI Admin Panel · v1.1.0
        </p>
      </div>
    </div>
  );
}
