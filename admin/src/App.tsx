/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from '@/contexts/AuthContext';
import { usePermissions } from '@/hooks/usePermissions';
import { ErrorBoundary } from '@/components/ErrorBoundary';
import { RequirePermission } from '@/components/RequirePermission';
import { Loader2 } from 'lucide-react';
import type { AdminRole } from '@/lib/permissions';

// Layouts
import { AdminShell } from '@/components/layout/AdminShell';
import { SuperAdminShell } from '@/components/super-admin/layout/SuperAdminShell';

import { Login } from '@/pages/Login';

// Regular admin pages
import { Dashboard } from '@/pages/Dashboard';
import { UserManagement } from '@/pages/UserManagement';
import { RideManagement } from '@/pages/RideManagement';
import { Payments } from '@/pages/Payments';
import { SafetyCompliance } from '@/pages/SafetyCompliance';
import { Reports } from '@/pages/Reports';
// Pages that pull react-hook-form + zod — lazy-load so the libs don't bloat the
// entry chunk for admins who never hit them.
const FareSurge = lazy(() => import('@/pages/FareSurge').then(m => ({ default: m.FareSurge })));

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
const SALguPartnerships = lazy(() => import('@/pages/super-admin/SALguPartnerships').then(m => ({ default: m.SALguPartnerships })));

function PageLoader() {
  return (
    <div className="flex-1 flex items-center justify-center min-h-screen">
      <Loader2 className="w-8 h-8 animate-spin text-primary" />
    </div>
  );
}

function ProtectedRoute({
  children,
  requireRole,
}: {
  children: React.ReactNode;
  requireRole?: AdminRole;
}) {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) return <PageLoader />;
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  if (requireRole && user?.role !== requireRole) {
    return <Navigate to="/admin/dashboard" replace />;
  }

  return <>{children}</>;
}

function RootRedirect() {
  const { user, isLoading } = useAuth();
  const { can, loading: permsLoading } = usePermissions();

  if (isLoading || permsLoading) return <PageLoader />;
  if (!user) return <Navigate to="/login" replace />;

  // superadmin always goes to the super-admin portal regardless of permissions load state
  if (user.role === 'superadmin' || can('dashboard', 'read')) {
    return <Navigate to="/super-admin/dashboard" replace />;
  }
  return <Navigate to="/admin/dashboard" replace />;
}

export default function App() {
  return (
    <ErrorBoundary>
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
            <Route path="dashboard" element={
              <RequirePermission permission="dashboard"><Dashboard /></RequirePermission>
            } />
            <Route path="users" element={
              <RequirePermission permission="user_management"><UserManagement /></RequirePermission>
            } />
            <Route path="rides" element={
              <RequirePermission permission="user_management"><RideManagement /></RequirePermission>
            } />
            <Route path="payments" element={
              <RequirePermission permission="payments"><Payments /></RequirePermission>
            } />
            <Route path="fare" element={
              <RequirePermission permission="fare_config">
                <Suspense fallback={<PageLoader />}><FareSurge /></Suspense>
              </RequirePermission>
            } />
            <Route path="safety" element={
              <RequirePermission permission="safety_incidents"><SafetyCompliance /></RequirePermission>
            } />
            <Route path="reports" element={
              <RequirePermission permission="reports"><Reports /></RequirePermission>
            } />
          </Route>

          <Route path="/super-admin" element={
            <ProtectedRoute requireRole="superadmin">
              <SuperAdminShell />
            </ProtectedRoute>
          }>
            <Route index element={<Navigate to="dashboard" replace />} />
            <Route path="dashboard" element={
              <RequirePermission permission="dashboard">
                <Suspense fallback={<PageLoader />}><SADashboard /></Suspense>
              </RequirePermission>
            } />
            <Route path="admins" element={
              <RequirePermission permission="admin_management">
                <Suspense fallback={<PageLoader />}><SAAdminManagement /></Suspense>
              </RequirePermission>
            } />
            <Route path="roles" element={
              <RequirePermission permission="role_management">
                <Suspense fallback={<PageLoader />}><SARoleManagement /></Suspense>
              </RequirePermission>
            } />
            <Route path="fares" element={
              <RequirePermission permission="fare_config">
                <Suspense fallback={<PageLoader />}><SAFareConfig /></Suspense>
              </RequirePermission>
            } />
            <Route path="payments" element={
              <RequirePermission permission="payments">
                <Suspense fallback={<PageLoader />}><SAPayments /></Suspense>
              </RequirePermission>
            } />
            <Route path="safety" element={
              <RequirePermission permission="safety_incidents">
                <Suspense fallback={<PageLoader />}><SASafetyCompliance /></Suspense>
              </RequirePermission>
            } />
            <Route path="reports" element={
              <RequirePermission permission="reports">
                <Suspense fallback={<PageLoader />}><SAReports /></Suspense>
              </RequirePermission>
            } />
            <Route path="system" element={
              <RequirePermission permission="system_config">
                <Suspense fallback={<PageLoader />}><SASystemConfig /></Suspense>
              </RequirePermission>
            } />
            <Route path="health" element={
              <RequirePermission permission="system_health">
                <Suspense fallback={<PageLoader />}><SASystemHealth /></Suspense>
              </RequirePermission>
            } />
            <Route path="audit" element={
              <RequirePermission permission="audit_log">
                <Suspense fallback={<PageLoader />}><SAAuditLog /></Suspense>
              </RequirePermission>
            } />
            <Route path="lgu" element={
              <RequirePermission permission="system_config">
                <Suspense fallback={<PageLoader />}><SALguPartnerships /></Suspense>
              </RequirePermission>
            } />
          </Route>

          <Route path="/" element={<RootRedirect />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
      </AuthProvider>
    </ErrorBoundary>
  );
}
