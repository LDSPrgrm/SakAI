import React from 'react';
import { cn } from '@/lib/utils';
import { Link, useLocation } from 'react-router-dom';
import {
  LayoutDashboard, ShieldCheck, UserCog, PhilippinePeso, Banknote,
  FileText, Wrench, Activity, ScrollText, Shield, Car, Building2,
} from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { usePermissions, PermissionKey } from '@/hooks/usePermissions';
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

const saNavSections: NavSection[] = [
  {
    label: 'Overview',
    items: [
      { path: '/super-admin/dashboard', label: 'SA Dashboard', icon: LayoutDashboard, perm: 'dashboard' },
    ],
  },
  {
    label: 'Access',
    items: [
      { path: '/super-admin/admins', label: 'Admin Management', icon: UserCog, perm: 'admin_management' },
      { path: '/super-admin/roles',  label: 'Role Management',  icon: Shield,  perm: 'role_management' },
    ],
  },
  {
    label: 'Operations',
    items: [
      { path: '/super-admin/fares',    label: 'Fare Config',        icon: PhilippinePeso, perm: 'fare_config' },
      { path: '/super-admin/payments', label: 'Financial Controls', icon: Banknote,       perm: 'payments' },
      { path: '/super-admin/safety',   label: 'Safety & Compliance', icon: ShieldCheck,   perm: 'safety_incidents' },
      { path: '/super-admin/lgu',      label: 'LGU & Coverage',     icon: Building2,      perm: 'system_config' },
    ],
  },
  {
    label: 'Insights',
    items: [
      { path: '/super-admin/reports', label: 'Reports',   icon: FileText,   perm: 'reports' },
      { path: '/super-admin/audit',   label: 'Audit Log', icon: ScrollText, perm: 'audit_log' },
    ],
  },
  {
    label: 'System',
    items: [
      { path: '/super-admin/system', label: 'System Config', icon: Wrench,   perm: 'system_config' },
      { path: '/super-admin/health', label: 'System Health', icon: Activity, perm: 'system_health' },
    ],
  },
];

export function Sidebar({ isOpen, onClose }: SidebarProps) {
  const { user } = useAuth();
  const { can } = usePermissions();
  const location = useLocation();

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
            ? 'bg-warning/10 text-warning'
            : 'text-text-muted hover:bg-surface-hover hover:text-text-main',
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
        isOpen ? 'translate-x-0' : '-translate-x-full',
      )}
    >
      <div className="h-16 flex items-center pl-7 pr-6 border-b border-border">
        <div className="flex items-center gap-2 text-warning font-bold text-xl tracking-tight">
          <Car className="w-6 h-6" />
          <span>SakAI Super</span>
        </div>
      </div>

      <div className="flex-1 py-4 px-3 space-y-1 overflow-y-auto">
        {saNavSections.map((section) => {
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
          <div className="w-8 h-8 rounded-full bg-warning/20 flex items-center justify-center text-warning font-bold flex-shrink-0">
            {user?.name?.[0]?.toUpperCase() ?? 'S'}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-text-main truncate">{user?.name ?? 'Super Admin'}</p>
            <p className="text-xs text-text-muted truncate">{user?.role ?? 'superadmin'}</p>
          </div>
        </div>
      </div>
    </aside>
  );
}
