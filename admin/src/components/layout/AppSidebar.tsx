import React from 'react';
import { cn } from '@/lib/utils';
import { Link, useLocation } from 'react-router-dom';
import { AlertTriangle, Car } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { usePermissions } from '@/hooks/usePermissions';
import { useRoleAccent } from '@/hooks/useRoleAccent';
import { SidebarSection } from '@/components/layout/SidebarSection';
import type { NavSection, NavItem } from '@/nav/admin';

interface AppSidebarProps {
  isOpen: boolean;
  onClose: () => void;
  sections: NavSection[];
  brandLabel: string;
  fallbackOnPermsError?: boolean;
  fallbackPerm?: NavItem['perm'];
  defaultUserInitial?: string;
  defaultUserName?: string;
  defaultUserRole?: string;
}

export function AppSidebar({
  isOpen,
  onClose,
  sections,
  brandLabel,
  fallbackOnPermsError = false,
  fallbackPerm = 'dashboard',
  defaultUserInitial = 'A',
  defaultUserName = 'Admin User',
  defaultUserRole = 'operations',
}: AppSidebarProps) {
  const { user } = useAuth();
  const { can, error } = usePermissions();
  const location = useLocation();
  const accent = useRoleAccent();

  const allItems = sections.flatMap((s) => s.items);
  const visibleItems = allItems.filter((item) => can(item.perm, 'read'));

  const showFallback =
    fallbackOnPermsError && !!error && user?.role !== 'superadmin' && visibleItems.length === 0;
  const fallbackItems = showFallback ? allItems.filter((i) => i.perm === fallbackPerm) : null;

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
            ? accent.classes.navActive
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
        <div className={cn('flex items-center gap-2 font-bold text-xl tracking-tight', accent.classes.textBrand)}>
          <Car className="w-6 h-6" />
          <span>{brandLabel}</span>
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
          : sections.map((section) => {
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
          <div className={cn('w-8 h-8 rounded-full flex items-center justify-center font-bold flex-shrink-0', accent.classes.initialBlock)}>
            {user?.name?.[0]?.toUpperCase() ?? defaultUserInitial}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-text-main truncate">{user?.name ?? defaultUserName}</p>
            <p className="text-xs text-text-muted truncate">{user?.role ?? defaultUserRole}</p>
          </div>
        </div>
      </div>
    </aside>
  );
}
