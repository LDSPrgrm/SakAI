import React from 'react';
import { Bell, Search, LogOut, Menu } from 'lucide-react';
import { Input } from './ui/Input';
import { Button } from './ui/Button';
import { useAuth } from '@/contexts/AuthContext';

interface HeaderProps {
  onMenuToggle: () => void;
}

export function Header({ onMenuToggle }: HeaderProps) {
  const { logout } = useAuth();

  return (
    <header className="h-16 bg-surface border-b border-border flex items-center justify-between px-4 md:px-6 sticky top-0 z-10 gap-3">
      <div className="flex items-center gap-3 flex-1 min-w-0">
        <button
          aria-label="Open menu"
          onClick={onMenuToggle}
          className="md:hidden p-2 text-text-muted hover:text-text-main transition-colors rounded-lg hover:bg-surface-hover flex-shrink-0"
        >
          <Menu className="w-5 h-5" />
        </button>

        <div className="flex-1 max-w-sm hidden sm:block">
          <Input
            placeholder="Search rides, users..."
            icon={<Search className="w-4 h-4" />}
            className="bg-background border-border"
          />
        </div>
      </div>

      <div className="flex items-center gap-2 md:gap-4 flex-shrink-0">
        <button aria-label="Notifications" className="relative p-2 text-text-muted hover:text-text-main transition-colors rounded-full hover:bg-surface-hover">
          <Bell className="w-5 h-5" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-danger rounded-full border-2 border-surface"></span>
        </button>

        <div className="h-8 w-px bg-border mx-1 hidden sm:block"></div>

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
