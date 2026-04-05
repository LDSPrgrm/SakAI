import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { BrowserRouter } from 'react-router-dom';
import { SAAdminManagement } from './SAAdminManagement';
import { adminApi, AdminRoleDefinition, AdminUser } from '@/lib/admin-api';

// Mock the admin API
vi.mock('@/lib/admin-api', () => ({
  adminApi: {
    admins: {
      list: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
      resetPassword: vi.fn(),
    },
    roles: {
      list: vi.fn(),
    },
  },
  AdminRole: {},
  AdminStatus: {},
}));

/**
 * Bug Condition Exploration Test
 * 
 * **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**
 * 
 * This test demonstrates the bug that occurs when:
 * 1. Component loads with stale roleDefs (doesn't include newly created custom role)
 * 2. User attempts to create admin with newly created role "Regional Manager"
 * 3. selectedRoleDef becomes undefined (role not in stale list)
 * 4. role_id: undefined is sent to backend
 * 5. Backend returns 409 Conflict error
 * 6. Error is uncaught and no proper error message is displayed
 * 
 * CRITICAL: This test MUST FAIL on unfixed code - failure confirms the bug exists.
 * When this test passes after the fix, it confirms the expected behavior is satisfied.
 */
describe('SAAdminManagement - Bug Condition Exploration', () => {
  const mockExistingRoles: AdminRoleDefinition[] = [
    { id: '1', name: 'super_admin', permissions: [] },
    { id: '2', name: 'operations', permissions: [] },
    { id: '3', name: 'finance', permissions: [] },
    { id: '4', name: 'support', permissions: [] },
  ];

  const mockAdmins: AdminUser[] = [
    {
      id: 'admin-1',
      name: 'Test Admin',
      email: 'test@sakai.ph',
      role: 'support',
      status: 'active',
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
      last_login_at: null,
      created_by: null,
    },
  ];

  beforeEach(() => {
    vi.clearAllMocks();
    
    // Mock initial data load - roleDefs is STALE (doesn't include "Regional Manager")
    (adminApi.admins.list as any).mockResolvedValue(mockAdmins);
    (adminApi.roles.list as any).mockResolvedValue(mockExistingRoles);
  });

  it('should demonstrate bug: stale roleDefs causes undefined role_id and uncaught 409 error', async () => {
    const user = userEvent.setup();

    // Track unhandled errors
    let unhandledError: any = null;
    const originalOnError = window.onerror;
    window.onerror = (message, source, lineno, colno, error) => {
      unhandledError = error;
      return true; // Prevent default error handling
    };

    // Mock backend to return 409 error when role_id is undefined
    const mockError = new Error('Conflict: Invalid role_id');
    (mockError as any).status = 409;
    (adminApi.admins.create as any).mockRejectedValue(mockError);

    // Render component
    render(
      <BrowserRouter>
        <SAAdminManagement />
      </BrowserRouter>
    );

    // Wait for initial data load
    await waitFor(() => {
      expect(adminApi.admins.list).toHaveBeenCalled();
      expect(adminApi.roles.list).toHaveBeenCalled();
    });

    // Open "Add Admin" modal
    const addButton = screen.getByRole('button', { name: /add admin/i });
    await user.click(addButton);

    // Wait for modal to open
    await waitFor(() => {
      expect(screen.getByRole('heading', { name: /add admin/i })).toBeInTheDocument();
    });

    // VERIFY FIX: roleDefs should be refreshed when modal opens
    // roles.list should have been called twice: once on mount, once when modal opens
    await waitFor(() => {
      expect(adminApi.roles.list).toHaveBeenCalledTimes(2);
    });

    // Fill in form with newly created role "Regional Manager" (not in stale roleDefs)
    const nameInput = screen.getByPlaceholderText(/e\.g\. Maria Santos/i);
    const emailInput = screen.getByPlaceholderText(/e\.g\. maria@sakai\.ph/i);
    const roleSelects = screen.getAllByRole('combobox');
    const roleSelect = roleSelects[0]; // First combobox is the role select

    await user.clear(nameInput);
    await user.type(nameInput, 'New Admin');
    await user.clear(emailInput);
    await user.type(emailInput, 'newadmin@sakai.ph');

    // Simulate selecting "Regional Manager" from dropdown
    // In reality, this role would appear in the dropdown if it was just created
    // but roleDefs state is stale, so find() will return undefined
    // For testing purposes, we'll manually add the option to the select
    const regionalManagerOption = document.createElement('option');
    regionalManagerOption.value = 'Regional Manager';
    regionalManagerOption.textContent = 'Regional Manager';
    roleSelect.appendChild(regionalManagerOption);
    
    await user.selectOptions(roleSelect, 'Regional Manager');

    // Submit the form
    const saveButton = screen.getByRole('button', { name: /save/i });
    
    // Expect the API call to throw an error (which will be caught by our fix)
    await user.click(saveButton);

    // VERIFY FIX: selectedRoleDef is undefined, so error message should be displayed
    // The fix should prevent the API call and display an error message
    await waitFor(() => {
      const errorMessage = screen.getByText(/selected role not found/i);
      expect(errorMessage).toBeInTheDocument();
    });

    // VERIFY FIX: API should NOT be called because selectedRoleDef is undefined
    expect(adminApi.admins.create).not.toHaveBeenCalled();

    // VERIFY FIX: Modal should remain open with error message
    expect(screen.getByRole('heading', { name: /add admin/i })).toBeInTheDocument();

    // Restore original error handler
    window.onerror = originalOnError;

    // EXPECTED BEHAVIOR (after fix):
    // - roleDefs is refreshed when modal opens ✓
    // - selectedRoleDef is undefined (role not in refreshed list)
    // - Error message is displayed: "Selected role not found. Please refresh the page or select a different role." ✓
    // - API call is prevented ✓
    // - Modal remains open with clear feedback ✓
  });
});
