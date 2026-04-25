import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Pencil, Trash2 } from 'lucide-react';
import { ActionMenu, type ActionMenuItem } from './ActionMenu';

function renderMenu(items: ActionMenuItem[]) {
  return render(
    <MemoryRouter>
      <ActionMenu items={items} />
    </MemoryRouter>,
  );
}

describe('ActionMenu', () => {
  it('does not render the menu items until trigger is clicked', () => {
    const onEdit = vi.fn();
    renderMenu([{ key: 'edit', label: 'Edit admin', icon: Pencil, onClick: onEdit }]);
    expect(screen.queryByRole('menuitem', { name: /edit admin/i })).toBeNull();
  });

  it('opens the menu and fires the item callback on click', () => {
    const onEdit = vi.fn();
    renderMenu([{ key: 'edit', label: 'Edit admin', icon: Pencil, onClick: onEdit }]);

    fireEvent.click(screen.getByRole('button', { name: /open actions/i }));
    const item = screen.getByRole('menuitem', { name: /edit admin/i });
    fireEvent.click(item);

    expect(onEdit).toHaveBeenCalledTimes(1);
  });

  it('closes when Escape is pressed', () => {
    renderMenu([
      { key: 'edit', label: 'Edit admin', icon: Pencil, onClick: vi.fn() },
    ]);

    fireEvent.click(screen.getByRole('button', { name: /open actions/i }));
    expect(screen.getByRole('menuitem', { name: /edit admin/i })).toBeInTheDocument();

    fireEvent.keyDown(document, { key: 'Escape' });
    expect(screen.queryByRole('menuitem', { name: /edit admin/i })).toBeNull();
  });

  it('closes on outside click', () => {
    renderMenu([
      { key: 'edit', label: 'Edit admin', icon: Pencil, onClick: vi.fn() },
    ]);

    fireEvent.click(screen.getByRole('button', { name: /open actions/i }));
    fireEvent.mouseDown(document.body);
    expect(screen.queryByRole('menuitem', { name: /edit admin/i })).toBeNull();
  });

  it('renders a separator before items flagged separatorBefore', () => {
    renderMenu([
      { key: 'edit',       label: 'Edit',       icon: Pencil, onClick: vi.fn() },
      { key: 'deactivate', label: 'Deactivate', icon: Trash2, variant: 'danger', onClick: vi.fn(), separatorBefore: true },
    ]);

    fireEvent.click(screen.getByRole('button', { name: /open actions/i }));
    expect(screen.getByRole('separator')).toBeInTheDocument();
  });
});
