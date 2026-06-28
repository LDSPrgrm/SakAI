import React from 'react';
import { Search, LogOut, Menu } from 'lucide-react';
import { Input } from './ui/Input';
import { Button } from './ui/Button';
import { NotificationBell } from './layout/NotificationBell';
import { useAuth } from '@/contexts/AuthContext';
import { usePermissions } from '@/hooks/usePermissions';

interface HeaderProps {
  onMenuToggle: () => void;
}

export function Header({ onMenuToggle }: HeaderProps) {
  const { logout } = useAuth();
  const { can } = usePermissions();
  const canSeeNotifications = can('audit_log', 'read');

  return (
    <header className="h-16 bg-surface border-b border-border flex items-center justify-between px-4 md:px-6 sticky top-0 z-10 gap-3">
      <div className="flex items-center gap-3 flex-1 min-w-0">
        <button
          type="button"
          aria-label="Open menu"
          onClick={onMenuToggle}
          className="md:hidden p-2 text-text-muted hover:text-text-main transition-colors rounded-lg hover:bg-surface-hover flex-shrink-0"
        >
          <Menu className="w-5 h-5" />
        </button>

        <div className="flex-1 max-w-md hidden sm:block">
          <Input
            placeholder="Search records (rides, users)..."
            icon={<Search className="w-4 h-4" />}
            className="bg-background border-border shadow-sm focus:border-primary transition-all duration-200"
          />
        </div>
      </div>

      <div className="flex items-center gap-2 md:gap-4 flex-shrink-0">
        {canSeeNotifications && <NotificationBell />}
        <Button
          variant="ghost"
          size="sm"
          className="gap-2 text-text-muted hover:text-danger"
          onClick={logout}
        >
          <LogOut className="w-4 h-4" />
          <span className="hidden sm:inline">Logout</span>
        </Button>
      </div>
    </header>
  );
}
