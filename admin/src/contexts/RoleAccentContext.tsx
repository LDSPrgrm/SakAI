import React, { createContext, useContext, useMemo } from 'react';

export type AdminRole = 'admin' | 'super-admin';

export interface RoleAccent {
  role: AdminRole;
  kpiTone: 'primary' | 'sa-accent';
  queueTone: 'primary' | 'amber';
  cssVar: '--color-primary' | '--color-sa-accent';
  cssVarSoft: string;
  classes: {
    textBrand: string;
    bgBrandSoft: string;
    ringFocus: string;
    navActive: string;
    initialBlock: string;
  };
}

const ADMIN_ACCENT: RoleAccent = {
  role: 'admin',
  kpiTone: 'primary',
  queueTone: 'primary',
  cssVar: '--color-primary',
  cssVarSoft: 'rgba(26, 115, 232, 0.12)',
  classes: {
    textBrand: 'text-primary',
    bgBrandSoft: 'bg-primary/10',
    ringFocus: 'focus-visible:ring-primary',
    navActive: 'bg-primary/10 text-primary',
    initialBlock: 'bg-primary/20 text-primary',
  },
};

const SUPER_ADMIN_ACCENT: RoleAccent = {
  role: 'super-admin',
  kpiTone: 'sa-accent',
  queueTone: 'amber',
  cssVar: '--color-sa-accent',
  cssVarSoft: 'var(--color-sa-accent-soft)',
  classes: {
    textBrand: 'text-[var(--color-sa-accent)]',
    bgBrandSoft: 'bg-[var(--color-sa-accent-soft)]',
    ringFocus: 'focus-visible:ring-[var(--color-sa-accent)]',
    navActive: 'bg-[var(--color-sa-accent-soft)] text-[var(--color-sa-accent)]',
    initialBlock: 'bg-[var(--color-sa-accent-soft)] text-[var(--color-sa-accent)]',
  },
};

const RoleAccentContext = createContext<RoleAccent | null>(null);

interface RoleAccentProviderProps {
  role: AdminRole;
  children: React.ReactNode;
}

export function RoleAccentProvider({ role, children }: RoleAccentProviderProps) {
  const value = useMemo(() => (role === 'super-admin' ? SUPER_ADMIN_ACCENT : ADMIN_ACCENT), [role]);
  return <RoleAccentContext.Provider value={value}>{children}</RoleAccentContext.Provider>;
}

export function useRoleAccent(): RoleAccent {
  const ctx = useContext(RoleAccentContext);
  return ctx ?? ADMIN_ACCENT;
}
