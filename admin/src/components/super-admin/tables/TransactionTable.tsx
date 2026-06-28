// Transaction history table — spec superadmin.md §4.5 Payments
import React from 'react';
import { type ColumnDef } from '@tanstack/react-table';
import { DataTable } from './DataTable';
import { StatusBadge } from '../shared/StatusBadge';
import { CurrencyDisplay } from '../shared/CurrencyDisplay';
import { DateDisplay } from '../shared/DateDisplay';
import { EntityId } from '@/components/ui/EntityId';
import type { Transaction } from '@/types/super-admin';

const COLUMNS: ColumnDef<Transaction>[] = [
  { accessorKey: 'id',             header: 'Txn ID',          cell: ({ row }) => <EntityId displayId={(row.original as any).display_id} uuid={row.original.id} fallbackPrefix="TXN" /> },
  { accessorKey: 'ride_id',        header: 'Ride ID',         cell: ({ row }) => <EntityId displayId={(row.original as any).ride_display_id} uuid={row.original.ride_id} fallbackPrefix="RIDE" /> },
  { accessorKey: 'rider_name',     header: 'Rider' },
  { accessorKey: 'driver_name',    header: 'Driver' },
  { accessorKey: 'amount',         header: 'Amount',          cell: ({ getValue }) => <CurrencyDisplay amount={getValue() as number} /> },
  { accessorKey: 'payment_method', header: 'Method',          cell: ({ getValue }) => <span className="capitalize">{String(getValue())}</span> },
  { accessorKey: 'status',         header: 'Status',          cell: ({ getValue }) => <StatusBadge status={String(getValue())} /> },
  { accessorKey: 'commission',     header: 'Commission',      cell: ({ getValue }) => <CurrencyDisplay amount={getValue() as number} /> },
  { accessorKey: 'created_at',     header: 'Date',            cell: ({ getValue }) => <DateDisplay iso={getValue() as string} format="datetime" /> },
];

interface TransactionTableProps {
  data: Transaction[];
  className?: string;
}

export function TransactionTable({ data, className }: TransactionTableProps) {
  return (
    <DataTable
      data={data}
      columns={COLUMNS}
      searchable
      searchPlaceholder="Search by rider, driver, or txn ID…"
      emptyMessage="No transactions found."
      className={className}
    />
  );
}
