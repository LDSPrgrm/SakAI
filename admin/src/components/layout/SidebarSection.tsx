import React from 'react';

interface SidebarSectionProps {
  label: string;
  children: React.ReactNode;
  isEmpty?: boolean;
}

export function SidebarSection({ label, children, isEmpty }: SidebarSectionProps) {
  if (isEmpty) return null;
  return (
    <div className="space-y-1">
      <div className="pt-4 pb-1 px-3 first:pt-1">
        <span className="text-[10px] font-semibold text-text-muted uppercase tracking-widest">
          {label}
        </span>
      </div>
      {children}
    </div>
  );
}
