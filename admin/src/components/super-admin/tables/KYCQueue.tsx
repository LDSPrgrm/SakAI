// KYC verification queue — spec superadmin.md §4.6 & §2 tables
import React from 'react';
import { type ColumnDef } from '@tanstack/react-table';
import { DataTable } from './DataTable';
import { StatusBadge } from '../shared/StatusBadge';
import { DateDisplay } from '../shared/DateDisplay';
import type { KycEntry } from '@/types/super-admin';

interface KYCQueueProps {
  data: KycEntry[];
  onApprove?: (entry: KycEntry) => void;
  onReject?:  (entry: KycEntry) => void;
  className?: string;
}

export function KYCQueue({ data, onApprove, onReject, className }: KYCQueueProps) {
  const columns: ColumnDef<KycEntry>[] = [
    { accessorKey: 'driver_name',  header: 'Driver' },
    { accessorKey: 'submitted_at', header: 'Submitted', cell: ({ getValue }) => <DateDisplay iso={getValue() as string} format="relative" /> },
    { accessorKey: 'docs',         header: 'Documents', cell: ({ getValue }) => <span>{((getValue() as unknown[] | undefined) ?? []).length} docs</span> },
    { accessorKey: 'status',       header: 'Status',    cell: ({ getValue }) => <StatusBadge status={String(getValue())} /> },
    {
      id: 'actions',
      header: '',
      cell: ({ row }) => {
        const entry = row.original;
        if (entry.status !== 'pending') return null;
        return (
          <div className="flex gap-1">
            {onApprove && (
              <button onClick={() => onApprove(entry)} className="px-2 py-1 text-xs rounded bg-success/10 text-success hover:bg-success/20 transition-colors">
                Approve
              </button>
            )}
            {onReject && (
              <button onClick={() => onReject(entry)} className="px-2 py-1 text-xs rounded bg-danger/10 text-danger hover:bg-danger/20 transition-colors">
                Reject
              </button>
            )}
          </div>
        );
      },
    },
  ];

  return (
    <DataTable
      data={data}
      columns={columns}
      emptyMessage="No KYC submissions pending."
      className={className}
    />
  );
}
