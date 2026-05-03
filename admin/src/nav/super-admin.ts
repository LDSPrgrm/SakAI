import {
  LayoutDashboard, ShieldCheck, UserCog, PhilippinePeso, Banknote,
  FileText, Wrench, Activity, ScrollText, Shield, Building2,
} from 'lucide-react';
import type { NavSection } from './admin';

export const superAdminNavSections: NavSection[] = [
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
