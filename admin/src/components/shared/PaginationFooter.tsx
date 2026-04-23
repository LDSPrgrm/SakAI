import React from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import type { PaginationMeta } from '@/api/super-admin/_request';

export interface PaginationFooterProps {
  meta?: PaginationMeta;
  page: number;
  onPageChange: (page: number) => void;
  /** Noun used in the "N {label}" suffix. Defaults to "items". */
  label?: string;
  className?: string;
}

export function PaginationFooter({
  meta,
  page,
  onPageChange,
  label = 'items',
  className = 'flex items-center justify-between text-sm text-text-muted',
}: PaginationFooterProps) {
  const totalPages = meta?.total_pages ?? 1;
  const totalItems = meta?.total_items ?? 0;
  if (totalPages <= 1 && totalItems === 0) return null;

  return (
    <div className={className}>
      <span>
        Page {page} of {totalPages} · {totalItems} {label}
      </span>
      <div className="flex items-center gap-1">
        <button
          type="button"
          onClick={() => onPageChange(page - 1)}
          disabled={page <= 1}
          aria-label="Previous page"
          className="p-1 rounded hover:bg-surface-hover disabled:opacity-30"
        >
          <ChevronLeft className="w-4 h-4" />
        </button>
        <button
          type="button"
          onClick={() => onPageChange(page + 1)}
          disabled={page >= totalPages}
          aria-label="Next page"
          className="p-1 rounded hover:bg-surface-hover disabled:opacity-30"
        >
          <ChevronRight className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
}
