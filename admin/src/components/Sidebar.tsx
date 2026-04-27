import React from 'react';
import { cn } from '@/lib/utils';
import { Link, useLocation } from 'react-router-dom';
import {
  AlertTriangle,
  LayoutDashboard, Users, Car, CreditCard, ShieldAlert, BarChart3
} from 'lucide-react';
import { PhpIcon } from '@/components/ui/PhpIcon';
import { useAuth } from '@/contexts/AuthContext';
import { usePermissions, type PermissionKey } from '@/hooks/usePermissions';
import { SidebarSection } from '@/components/layout/SidebarSection';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

interface NavItem {
  path: string;
  label: string;
  icon: React.ElementType;
  perm: PermissionKey;
}

interface NavSection {
  label: string;
  items: NavItem[];
}

const navSections: NavSection[] = [
  {
    label: 'Overview',
    items: [
      { path: '/admin/dashboard', label: 'Dashboard', icon: LayoutDashboard, perm: 'dashboard' },
    ],
  },
  {
    label: 'Operations',
    items: [
      { path: '/admin/users', label: 'User Management', icon: Users, perm: 'user_management' },
      { path: '/admin/rides', label: 'Ride Management', icon: Car,   perm: 'user_management' },
    ],
  },
  {
    label: 'Finance',
    items: [
      { path: '/admin/payments', label: 'Payments & Earnings', icon: CreditCard, perm: 'payments' },
      { path: '/admin/fare',     label: 'Fare & Surge',        icon: PhpIcon,    perm: 'fare_config' },
    ],
  },
  {
    label: 'Safety',
    items: [
      { path: '/admin/safety',  label: 'Safety & Compliance', icon: ShieldAlert, perm: 'safety_incidents' },
      { path: '/admin/reports', label: 'Reports & Analytics', icon: BarChart3,   perm: 'reports' },
    ],
  },
];

const allItems = navSections.flatMap((s) => s.items);

export function Sidebar({ isOpen, onClose }: SidebarProps) {
  const { user } = useAuth();
  const { can, error } = usePermissions();
  const location = useLocation();

  const visibleItems = allItems.filter((item) => can(item.perm, 'read'));

  // Permissions fetch failed for a non-superadmin: surface the error and keep
  // Dashboard visible so the user isn't stranded on a blank sidebar.
  const showFallback =
    !!error && user?.role !== 'superadmin' && visibleItems.length === 0;
  const fallbackItems = showFallback
    ? allItems.filter((i) => i.perm === 'dashboard')
    : null;

  const renderNavLink = (item: NavItem) => {
    const Icon = item.icon;
    const isActive = location.pathname.startsWith(item.path);
    return (
      <Link
        key={item.path}
        to={item.path}
        onClick={() => { if (window.innerWidth < 768) onClose(); }}
        className={cn(
          'w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors',
          isActive
            ? 'bg-primary/10 text-primary'
            : 'text-text-muted hover:bg-surface-hover hover:text-text-main'
        )}
      >
        <Icon className="w-5 h-5" />
        {item.label}
      </Link>
    );
  };

  return (
    <aside
      className={cn(
        'fixed inset-y-0 left-0 z-40 w-64 h-screen bg-surface border-r border-border flex flex-col flex-shrink-0 transition-transform duration-300',
        'md:relative md:translate-x-0',
        isOpen ? 'translate-x-0' : '-translate-x-full'
      )}
    >
      <div className="h-16 flex items-center pl-7 pr-6 border-b border-border">
        <div className="flex items-center gap-2 text-primary font-bold text-xl tracking-tight">
          <Car className="w-6 h-6" />
          <span>SakAI</span>
        </div>
      </div>

      <div className="flex-1 py-4 px-3 space-y-1 overflow-y-auto">
        {showFallback && (
          <div
            role="alert"
            className="mb-3 flex items-start gap-2 rounded-lg border border-danger/40 bg-danger/10 px-3 py-2 text-xs text-danger"
          >
            <AlertTriangle className="w-4 h-4 mt-0.5 flex-shrink-0" />
            <span>
              Failed to load permissions. Please retry or contact a superadmin.
            </span>
          </div>
        )}
        {fallbackItems
          ? fallbackItems.map(renderNavLink)
          : navSections.map((section) => {
              const items = section.items.filter((item) => can(item.perm, 'read'));
              return (
                <SidebarSection key={section.label} label={section.label} isEmpty={items.length === 0}>
                  {items.map(renderNavLink)}
                </SidebarSection>
              );
            })}
      </div>

      <div className="p-4 border-t border-border">
        <div className="bg-background rounded-lg p-3 flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold flex-shrink-0">
            {user?.name?.[0]?.toUpperCase() ?? 'A'}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-text-main truncate">{user?.name ?? 'Admin User'}</p>
            <p className="text-xs text-text-muted truncate">{user?.role ?? 'operations'}</p>
          </div>
        </div>
      </div>
    </aside>
  );
}
