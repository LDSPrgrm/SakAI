// Admin user list table — spec superadmin.md §4.2 Admin User Management
import React from 'react';
import { type ColumnDef } from '@tanstack/react-table';
import { MoreHorizontal } from 'lucide-react';
import { DataTable } from './DataTable';
import { StatusBadge } from '../shared/StatusBadge';
import { RoleBadge } from '../shared/RoleBadge';
import { DateDisplay } from '../shared/DateDisplay';
import type { AdminUser } from '@/lib/admin-api';

interface AdminTableProps {
  data: AdminUser[];
  onEdit?:    (user: AdminUser) => void;
  onSuspend?: (user: AdminUser) => void;
  onDeactivate?: (user: AdminUser) => void;
  className?: string;
}

export function AdminTable({ data, onEdit, onSuspend, onDeactivate, className }: AdminTableProps) {
  const columns: ColumnDef<AdminUser>[] = [
    { accessorKey: 'name',          header: 'Name' },
    { accessorKey: 'email',         header: 'Email' },
    { accessorKey: 'role',          header: 'Role',         cell: ({ getValue }) => <RoleBadge role={String(getValue())} /> },
    { accessorKey: 'status',        header: 'Status',       cell: ({ getValue }) => <StatusBadge status={String(getValue())} /> },
    { accessorKey: 'last_login_at', header: 'Last Login',   cell: ({ getValue }) => <DateDisplay iso={getValue() as string | null} format="relative" /> },
    { accessorKey: 'created_at',    header: 'Created',      cell: ({ getValue }) => <DateDisplay iso={getValue() as string} format="date" /> },
    {
      id: 'actions',
      header: '',
      cell: ({ row }) => {
        const user = row.original;
        return (
          <div className="flex items-center gap-1">
            {onEdit && (
              <button onClick={() => onEdit(user)} className="px-2 py-1 text-xs rounded bg-primary/10 text-primary hover:bg-primary/20 transition-colors">
                Edit
              </button>
            )}
            {onSuspend && user.status === 'active' && (
              <button onClick={() => onSuspend(user)} className="px-2 py-1 text-xs rounded bg-warning/10 text-warning hover:bg-warning/20 transition-colors">
                Suspend
              </button>
            )}
            {onDeactivate && user.status !== 'deactivated' && (
              <button onClick={() => onDeactivate(user)} className="px-2 py-1 text-xs rounded bg-danger/10 text-danger hover:bg-danger/20 transition-colors">
                Deactivate
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
      searchable
      searchPlaceholder="Search admins…"
      emptyMessage="No admins found."
      className={className}
    />
  );
}
