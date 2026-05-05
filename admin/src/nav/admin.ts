import {
  LayoutDashboard, Users, Car, CreditCard, ShieldAlert, BarChart3,
} from 'lucide-react';
import { PhpIcon } from '@/components/ui/PhpIcon';
import type { PermissionKey } from '@/hooks/usePermissions';

export interface NavItem {
  path: string;
  label: string;
  icon: React.ElementType;
  perm: PermissionKey;
}

export interface NavSection {
  label: string;
  items: NavItem[];
}

export const adminNavSections: NavSection[] = [
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
