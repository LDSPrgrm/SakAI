import React from 'react';
import { cn } from '@/lib/utils';
import { Link, useLocation } from 'react-router-dom';
import {
    LayoutDashboard, ShieldCheck, UserCog, PhilippinePeso, Banknote, FileText, Wrench, Activity, ScrollText, Car
} from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { PERM } from '@/lib/permissions';

interface SidebarProps {
    isOpen: boolean;
    onClose: () => void;
}

const saNavItems = [
    { path: '/super-admin/dashboard', label: 'SA Dashboard', icon: LayoutDashboard, perm: PERM.DASHBOARD_VIEW },
    { path: '/super-admin/admins', label: 'Admin Management', icon: UserCog, perm: PERM.ADMINS_MANAGE },
    { path: '/super-admin/fares', label: 'Fare Config', icon: PhilippinePeso, perm: PERM.FARES_VIEW },
    { path: '/super-admin/payments', label: 'Financial Controls', icon: Banknote, perm: PERM.PAYMENTS_VIEW },
    { path: '/super-admin/safety', label: 'Safety & KYC', icon: ShieldCheck, perm: PERM.SAFETY_READ },
    { path: '/super-admin/reports', label: 'Reports', icon: FileText, perm: PERM.REPORTS_OPERATIONAL },
    { path: '/super-admin/system', label: 'System Config', icon: Wrench, perm: PERM.SYSTEM_MANAGE },
    { path: '/super-admin/health', label: 'System Health', icon: Activity, perm: PERM.DASHBOARD_SYSTEM },
    { path: '/super-admin/audit', label: 'Audit Log', icon: ScrollText, perm: PERM.AUDIT_VIEW },
];

export function Sidebar({ isOpen, onClose }: SidebarProps) {
    const { user, hasPermission } = useAuth();
    const location = useLocation();

    const visibleSaItems = saNavItems.filter(item => hasPermission(item.perm));

    return (
        <aside
            className={cn(
                'fixed inset-y-0 left-0 z-40 w-64 h-screen bg-surface border-r border-border flex flex-col flex-shrink-0 transition-transform duration-300',
                'md:relative md:translate-x-0',
                isOpen ? 'translate-x-0' : '-translate-x-full'
            )}
        >
            <div className="h-16 flex items-center pl-7 pr-6 border-b border-border">
                <div className="flex items-center gap-2 text-warning font-bold text-xl tracking-tight">
                    <Car className="w-6 h-6" />
                    <span>SakAI Super</span>
                </div>
            </div>

            <div className="flex-1 py-4 px-3 space-y-1 overflow-y-auto">
                <div className="pt-3 pb-1 px-3">
                    <div className="flex items-center gap-2">
                        <div className="flex-1 h-px bg-border" />
                        <span className="text-[10px] font-semibold text-text-muted uppercase tracking-widest">Super Admin</span>
                        <div className="flex-1 h-px bg-border" />
                    </div>
                </div>
                {visibleSaItems.map((item) => {
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
                                    : 'text-text-muted hover:bg-surface-hover hover:text-text-main'
                            )}
                        >
                            <Icon className="w-5 h-5" />
                            {item.label}
                        </Link>
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
                        <p className="text-xs text-text-muted truncate">{user?.role ?? 'super_admin'}</p>
                    </div>
                </div>
            </div>
        </aside>
    );
}
