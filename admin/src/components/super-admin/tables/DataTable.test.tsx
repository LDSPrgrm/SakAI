import { describe, it, expect } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { type ColumnDef } from '@tanstack/react-table';
import { DataTable } from './DataTable';

type Person = { id: number; name: string; role: string };

const columns: ColumnDef<Person>[] = [
  { accessorKey: 'id',   header: 'ID' },
  { accessorKey: 'name', header: 'Name' },
  { accessorKey: 'role', header: 'Role' },
];

const data: Person[] = [
  { id: 1, name: 'Alice',   role: 'super_admin' },
  { id: 2, name: 'Bob',     role: 'finance'     },
  { id: 3, name: 'Charlie', role: 'support'     },
];

describe('DataTable', () => {
  it('renders column headers', () => {
    render(<DataTable data={data} columns={columns} />);
    expect(screen.getByText('ID')).toBeInTheDocument();
    expect(screen.getByText('Name')).toBeInTheDocument();
    expect(screen.getByText('Role')).toBeInTheDocument();
  });

  it('renders all data rows', () => {
    render(<DataTable data={data} columns={columns} />);
    expect(screen.getByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('Bob')).toBeInTheDocument();
    expect(screen.getByText('Charlie')).toBeInTheDocument();
  });

  it('shows the empty message when data is empty', () => {
    render(<DataTable data={[]} columns={columns} emptyMessage="No admins found." />);
    expect(screen.getByText('No admins found.')).toBeInTheDocument();
  });

  it('shows default empty message when data is empty and no emptyMessage prop', () => {
    render(<DataTable data={[]} columns={columns} />);
    expect(screen.getByText('No results found.')).toBeInTheDocument();
  });

  it('does not render a search input when searchable is not set', () => {
    render(<DataTable data={data} columns={columns} />);
    expect(screen.queryByPlaceholderText('Search…')).toBeNull();
  });

  it('renders a search input when searchable=true', () => {
    render(<DataTable data={data} columns={columns} searchable />);
    expect(screen.getByPlaceholderText('Search…')).toBeInTheDocument();
  });

  it('filters rows when typing in the search input', () => {
    render(<DataTable data={data} columns={columns} searchable />);
    fireEvent.change(screen.getByPlaceholderText('Search…'), { target: { value: 'Bob' } });
    expect(screen.getByText('Bob')).toBeInTheDocument();
    expect(screen.queryByText('Alice')).toBeNull();
    expect(screen.queryByText('Charlie')).toBeNull();
  });

  it('uses a custom search placeholder', () => {
    render(<DataTable data={data} columns={columns} searchable searchPlaceholder="Filter admins…" />);
    expect(screen.getByPlaceholderText('Filter admins…')).toBeInTheDocument();
  });

  it('does not render pagination when all rows fit on one page', () => {
    render(<DataTable data={data} columns={columns} pageSize={10} />);
    expect(screen.queryByText(/Page \d+ of/)).toBeNull();
  });

  it('renders pagination when rows exceed pageSize', () => {
    render(<DataTable data={data} columns={columns} pageSize={2} />);
    expect(screen.getByText(/Page 1 of 2/)).toBeInTheDocument();
  });
});
