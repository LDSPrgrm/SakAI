/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from '@/contexts/AuthContext';
import { usePermissions } from '@/hooks/usePermissions';
import { Loader2 } from 'lucide-react';

// Layouts
import { AdminShell } from '@/components/layout/AdminShell';
import { SuperAdminShell } from '@/components/super-admin/layout/SuperAdminShell';

import { Login } from '@/pages/Login';

// Regular admin pages
import { Dashboard } from '@/pages/Dashboard';
import { UserManagement } from '@/pages/UserManagement';
import { RideManagement } from '@/pages/RideManagement';
import { Payments } from '@/pages/Payments';
import { FareSurge } from '@/pages/FareSurge';
import { SafetyCompliance } from '@/pages/SafetyCompliance';
import { Reports } from '@/pages/Reports';
import { Settings } from '@/pages/Settings';

// Super Admin pages
const SADashboard = lazy(() => import('@/pages/super-admin/SADashboard').then(m => ({ default: m.SADashboard })));
const SAAdminManagement = lazy(() => import('@/pages/super-admin/SAAdminManagement').then(m => ({ default: m.SAAdminManagement })));
const SAFareConfig = lazy(() => import('@/pages/super-admin/SAFareConfig').then(m => ({ default: m.SAFareConfig })));
const SAPayments = lazy(() => import('@/pages/super-admin/SAPayments').then(m => ({ default: m.SAPayments })));
const SASafetyCompliance = lazy(() => import('@/pages/super-admin/SASafetyCompliance').then(m => ({ default: m.SASafetyCompliance })));
const SAReports = lazy(() => import('@/pages/super-admin/SAReports').then(m => ({ default: m.SAReports })));
const SASystemConfig = lazy(() => import('@/pages/super-admin/SASystemConfig').then(m => ({ default: m.SASystemConfig })));
const SASystemHealth = lazy(() => import('@/pages/super-admin/SASystemHealth').then(m => ({ default: m.SASystemHealth })));
const SAAuditLog = lazy(() => import('@/pages/super-admin/SAAuditLog').then(m => ({ default: m.SAAuditLog })));
const SARoleManagement = lazy(() => import('@/pages/super-admin/SARoleManagement').then(m => ({ default: m.SARoleManagement })));

function PageLoader() {
  return (
    <div className="flex-1 flex items-center justify-center min-h-screen">
      <Loader2 className="w-8 h-8 animate-spin text-primary" />
    </div>
  );
}

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) return <PageLoader />;
  if (!isAuthenticated) return <Navigate to="/login" replace />;

  return <>{children}</>;
}

function RootRedirect() {
  const { user, isLoading } = useAuth();
  const { can, loading: permsLoading } = usePermissions();

  if (isLoading || permsLoading) return <PageLoader />;
  if (!user) return <Navigate to="/login" replace />;

  // super_admin always goes to the super-admin portal regardless of permissions load state
  if (user.role === 'super_admin' || can('dashboard', 'read')) {
    return <Navigate to="/super-admin/dashboard" replace />;
  }
  return <Navigate to="/admin/dashboard" replace />;
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />

          <Route path="/admin" element={
            <ProtectedRoute>
              <AdminShell />
            </ProtectedRoute>
          }>
            <Route index element={<Navigate to="dashboard" replace />} />
            <Route path="dashboard" element={<Dashboard />} />
            <Route path="users" element={<UserManagement />} />
            <Route path="rides" element={<RideManagement />} />
            <Route path="payments" element={<Payments />} />
            <Route path="fare" element={<FareSurge />} />
            <Route path="safety" element={<SafetyCompliance />} />
            <Route path="reports" element={<Reports />} />
            <Route path="settings" element={<Settings />} />
          </Route>

          <Route path="/super-admin" element={
            <ProtectedRoute>
              <SuperAdminShell />
            </ProtectedRoute>
          }>
            <Route index element={<Navigate to="dashboard" replace />} />
            <Route path="dashboard" element={
              <Suspense fallback={<PageLoader />}><SADashboard /></Suspense>
            } />
            <Route path="admins" element={
              <Suspense fallback={<PageLoader />}><SAAdminManagement /></Suspense>
            } />
            <Route path="roles" element={
              <Suspense fallback={<PageLoader />}><SARoleManagement /></Suspense>
            } />
            <Route path="fares" element={
              <Suspense fallback={<PageLoader />}><SAFareConfig /></Suspense>
            } />
            <Route path="payments" element={
              <Suspense fallback={<PageLoader />}><SAPayments /></Suspense>
            } />
            <Route path="safety" element={
              <Suspense fallback={<PageLoader />}><SASafetyCompliance /></Suspense>
            } />
            <Route path="reports" element={
              <Suspense fallback={<PageLoader />}><SAReports /></Suspense>
            } />
            <Route path="system" element={
              <Suspense fallback={<PageLoader />}><SASystemConfig /></Suspense>
            } />
            <Route path="health" element={
              <Suspense fallback={<PageLoader />}><SASystemHealth /></Suspense>
            } />
            <Route path="audit" element={
              <Suspense fallback={<PageLoader />}><SAAuditLog /></Suspense>
            } />
          </Route>

          <Route path="/" element={<RootRedirect />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
