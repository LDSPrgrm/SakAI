// Emergency incident log table — spec superadmin.md §4.6 Safety & Compliance
import React from 'react';
import { type ColumnDef } from '@tanstack/react-table';
import { DataTable } from './DataTable';
import { StatusBadge } from '../shared/StatusBadge';
import { DateDisplay } from '../shared/DateDisplay';
import { EntityId } from '@/components/ui/EntityId';
import type { Incident } from '@/types/super-admin';

interface IncidentTableProps {
  data: Incident[];
  onResolve?: (incident: Incident) => void;
  className?: string;
}

export function IncidentTable({ data, onResolve, className }: IncidentTableProps) {
  const columns: ColumnDef<Incident>[] = [
    { accessorKey: 'id',           header: 'ID',            cell: ({ row }) => <EntityId displayId={(row.original as any).display_id} uuid={row.original.id} fallbackPrefix="INC" /> },
    { accessorKey: 'created_at',   header: 'Date/Time',     cell: ({ getValue }) => <DateDisplay iso={getValue() as string} format="datetime" /> },
    { accessorKey: 'ride_id',      header: 'Ride ID',       cell: ({ row }) => <EntityId displayId={(row.original as any).ride_display_id} uuid={row.original.ride_id} fallbackPrefix="RIDE" /> },
    { accessorKey: 'triggered_by', header: 'Triggered By',  cell: ({ getValue }) => <span className="capitalize">{String(getValue())}</span> },
    { accessorKey: 'rider_name',   header: 'Rider' },
    { accessorKey: 'driver_name',  header: 'Driver' },
    { accessorKey: 'severity',     header: 'Severity',      cell: ({ getValue }) => getValue() ? <StatusBadge status={String(getValue())} /> : <span className="text-text-muted">—</span> },
    { accessorKey: 'status',       header: 'Status',        cell: ({ getValue }) => <StatusBadge status={String(getValue())} /> },
    {
      id: 'actions',
      header: '',
      cell: ({ row }) => {
        const incident = row.original;
        if (!onResolve || incident.status === 'resolved') return null;
        return (
          <button
            onClick={() => onResolve(incident)}
            className="px-2 py-1 text-xs rounded bg-success/10 text-success hover:bg-success/20 transition-colors"
          >
            Resolve
          </button>
        );
      },
    },
  ];

  return (
    <DataTable
      data={data}
      columns={columns}
      searchable
      searchPlaceholder="Search incidents…"
      emptyMessage="No incidents found."
      className={className}
    />
  );
}
