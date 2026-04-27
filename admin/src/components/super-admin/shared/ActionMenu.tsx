import React, { useCallback, useEffect, useLayoutEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { Link } from 'react-router-dom';
import { MoreHorizontal } from 'lucide-react';
import { cn } from '@/lib/utils';

export type ActionMenuVariant = 'default' | 'warning' | 'danger';

export interface ActionMenuItem {
  key: string;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
  onClick?: () => void;
  asLink?: { to: string };
  variant?: ActionMenuVariant;
  disabled?: boolean;
  separatorBefore?: boolean;
}

export interface ActionMenuProps {
  items: ActionMenuItem[];
  align?: 'left' | 'right';
  triggerLabel?: string;
  className?: string;
}

const VARIANT_TEXT: Record<ActionMenuVariant, string> = {
  default: 'text-text-main',
  warning: 'text-warning',
  danger:  'text-danger',
};

const MENU_WIDTH = 192; // matches min-w-[12rem]
const MENU_GAP   = 4;

export function ActionMenu({ items, align = 'right', triggerLabel = 'Open actions', className }: ActionMenuProps) {
  const [open, setOpen] = useState(false);
  const [position, setPosition] = useState<{ top: number; left: number; openUp: boolean } | null>(null);
  const triggerRef = useRef<HTMLButtonElement | null>(null);
  const menuRef = useRef<HTMLDivElement | null>(null);

  const updatePosition = useCallback(() => {
    if (!triggerRef.current) return;
    const rect = triggerRef.current.getBoundingClientRect();
    const menuHeight = menuRef.current?.offsetHeight ?? 200;
    const spaceBelow = window.innerHeight - rect.bottom;
    const openUp = spaceBelow < menuHeight + 16 && rect.top > menuHeight + 16;

    const left = align === 'right'
      ? Math.max(8, rect.right - MENU_WIDTH)
      : Math.min(window.innerWidth - MENU_WIDTH - 8, rect.left);
    const top = openUp
      ? rect.top - MENU_GAP
      : rect.bottom + MENU_GAP;

    setPosition({ top, left, openUp });
  }, [align]);

  useLayoutEffect(() => {
    if (!open) return;
    updatePosition();
  }, [open, updatePosition]);

  useEffect(() => {
    if (!open) return;
    function onDocClick(event: MouseEvent) {
      const target = event.target as Node;
      if (
        triggerRef.current?.contains(target) ||
        menuRef.current?.contains(target)
      ) return;
      setOpen(false);
    }
    function onKey(event: KeyboardEvent) {
      if (event.key === 'Escape') setOpen(false);
    }
    function onReflow() {
      updatePosition();
    }
    document.addEventListener('mousedown', onDocClick);
    document.addEventListener('keydown', onKey);
    window.addEventListener('scroll', onReflow, true);
    window.addEventListener('resize', onReflow);
    return () => {
      document.removeEventListener('mousedown', onDocClick);
      document.removeEventListener('keydown', onKey);
      window.removeEventListener('scroll', onReflow, true);
      window.removeEventListener('resize', onReflow);
    };
  }, [open, updatePosition]);

  if (items.length === 0) return null;

  const menu = open && position ? (
    <div
      ref={menuRef}
      role="menu"
      style={{
        position: 'fixed',
        top: position.openUp ? undefined : position.top,
        bottom: position.openUp ? window.innerHeight - position.top : undefined,
        left: position.left,
        width: MENU_WIDTH,
      }}
      className={cn(
        'z-50 origin-top rounded-lg border border-border bg-surface py-1 shadow-2xl',
        'animate-[actionmenu-in_120ms_ease-out]',
      )}
    >
      {items.map((item, idx) => {
        const Icon = item.icon;
        const variant = item.variant ?? 'default';

        const inner = (
          <>
            <Icon className="w-4 h-4 flex-shrink-0" />
            <span className="flex-1 truncate">{item.label}</span>
          </>
        );

        const baseClass = cn(
          'flex w-full items-center gap-2 px-3 py-2 text-sm transition-colors',
          VARIANT_TEXT[variant],
          item.disabled
            ? 'opacity-40 pointer-events-none'
            : 'hover:bg-surface-hover',
        );

        return (
          <React.Fragment key={item.key}>
            {item.separatorBefore && idx > 0 && (
              <div className="my-1 border-t border-border" role="separator" />
            )}
            {item.asLink ? (
              <Link
                to={item.asLink.to}
                role="menuitem"
                className={baseClass}
                onClick={() => setOpen(false)}
              >
                {inner}
              </Link>
            ) : (
              <button
                type="button"
                role="menuitem"
                disabled={item.disabled}
                className={baseClass}
                onClick={() => {
                  setOpen(false);
                  item.onClick?.();
                }}
              >
                {inner}
              </button>
            )}
          </React.Fragment>
        );
      })}
    </div>
  ) : null;

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        aria-haspopup="menu"
        aria-expanded={open}
        aria-label={triggerLabel}
        title={triggerLabel}
        onClick={() => setOpen((v) => !v)}
        className={cn(
          'inline-flex items-center justify-center rounded-lg p-2 text-text-muted',
          'hover:bg-surface-hover hover:text-text-main transition-colors',
          'focus:outline-none focus:ring-2 focus:ring-primary/50',
          open && 'bg-surface-hover text-text-main',
          className,
        )}
      >
        <MoreHorizontal className="w-4 h-4" />
      </button>

      {typeof document !== 'undefined' && menu
        ? createPortal(menu, document.body)
        : null}

      <style>{`
        @keyframes actionmenu-in {
          from { opacity: 0; transform: translateY(-4px) scale(0.98); }
          to   { opacity: 1; transform: translateY(0)    scale(1); }
        }
      `}</style>
    </>
  );
}
