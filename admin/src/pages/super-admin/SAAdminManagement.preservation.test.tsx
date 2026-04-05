import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
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
 * Preservation Property Tests
 * 
 * **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
 * 
 * These tests observe and capture the CURRENT behavior on UNFIXED code
 * for scenarios that should NOT be affected by the bugfix:
 * - Successful admin creation with existing roles
 * - Admin updates
 * - Other error types (400, 500, network errors)
 * - Client-side validation failures
 * 
 * CRITICAL: These tests MUST PASS on unfixed code - they establish the baseline
 * behavior that must be preserved after the fix is implemented.
 */
describe('SAAdminManagement - Preservation Properties', () => {
  const mockExistingRoles: AdminRoleDefinition[] = [
    { id: '1', name: 'super_admin', description: 'Super Admin', is_system: true, permissions: [], admin_count: 1, created_by: 'system', created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z' },
    { id: '2', name: 'operations', description: 'Operations', is_system: true, permissions: [], admin_count: 0, created_by: 'system', created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z' },
    { id: '3', name: 'finance', description: 'Finance', is_system: true, permissions: [], admin_count: 0, created_by: 'system', created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z' },
    { id: '4', name: 'support', description: 'Support', is_system: true, permissions: [], admin_count: 0, created_by: 'system', created_at: '2024-01-01T00:00:00Z', updated_at: '2024-01-01T00:00:00Z' },
  ];

  const mockAdmins: AdminUser[] = [
    {
      id: 'admin-1',
      name: 'Test Admin',
      email: 'test@sakai.ph',
      role: 'support',
      status: 'active',
      created_at: '2024-01-01T00:00:00Z',
      last_login_at: null,
      created_by: null,
    },
  ];

  beforeEach(() => {
    vi.clearAllMocks();
    
    // Mock initial data load
    (adminApi.admins.list as any).mockResolvedValue(mockAdmins);
    (adminApi.roles.list as any).mockResolvedValue(mockExistingRoles);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  /**
   * Property 1: Successful Admin Creation with Existing Roles
   * 
   * **Validates: Requirement 3.1**
   * 
   * OBSERVATION: When creating an admin with an existing role (one that's already
   * in the roleDefs list), the system should:
   * - Successfully call the API with valid role_id
   * - Close the modal after successful creation
   * 
   * This behavior MUST be preserved after the fix.
   */
  it('Property 1: Successful admin creation with existing roles continues to work', async () => {
    const user = userEvent.setup();

    // Mock successful creation
    const createdAdmin: AdminUser = {
      id: 'new-admin-id',
      name: 'New Admin',
      email: 'newadmin@sakai.ph',
      role: 'support',
      status: 'active',
      created_at: new Date().toISOString(),
      last_login_at: null,
      created_by: 'current-user-id',
    };
    
    (adminApi.admins.create as any).mockResolvedValue(createdAdmin);

    // Render component
    const { unmount } = render(
      <BrowserRouter>
        <SAAdminManagement />
      </BrowserRouter>
    );

    // Wait for initial load
    await waitFor(() => {
      expect(adminApi.admins.list).toHaveBeenCalled();
    });

    // Open "Add Admin" modal
    const addButton = screen.getByRole('button', { name: /add admin/i });
    await user.click(addButton);

    // Wait for modal
    await waitFor(() => {
      expect(screen.getByRole('heading', { name: /add admin/i })).toBeInTheDocument();
    });

    // Fill form
    const nameInput = screen.getByPlaceholderText(/e\.g\. Maria Santos/i);
    const emailInput = screen.getByPlaceholderText(/e\.g\. maria@sakai\.ph/i);
    const roleSelects = screen.getAllByRole('combobox');
    const roleSelect = roleSelects[0];

    await user.clear(nameInput);
    await user.type(nameInput, 'New Admin');
    await user.clear(emailInput);
    await user.type(emailInput, 'newadmin@sakai.ph');
    await user.selectOptions(roleSelect, 'support');

    // Submit
    const saveButton = screen.getByRole('button', { name: /save/i });
    await user.click(saveButton);

    // OBSERVE: API should be called with valid role_id
    await waitFor(() => {
      expect(adminApi.admins.create).toHaveBeenCalled();
    }, { timeout: 3000 });

    const createCall = (adminApi.admins.create as any).mock.calls[0][0];
    
    // PRESERVATION: role_id should be defined for existing roles
    expect(createCall.role_id).toBeDefined();
    expect(createCall.role_id).not.toBeUndefined();
    
    // Find the expected role_id
    const expectedRole = mockExistingRoles.find(r => r.name === 'support');
    expect(createCall.role_id).toBe(expectedRole?.id);

    // PRESERVATION: Modal should close after successful creation
    await waitFor(() => {
      expect(screen.queryByRole('heading', { name: /add admin/i })).not.toBeInTheDocument();
    }, { timeout: 3000 });

    unmount();
  });

  /**
   * Property 2: Admin Updates Continue to Work
   * 
   * **Validates: Requirement 3.2**
   * 
   * OBSERVATION: When updating an existing admin, the system should:
   * - Successfully call the update API
   * - Close the modal after successful update
   * 
   * This behavior MUST be preserved after the fix.
   */
  it('Property 2: Admin updates continue to work correctly', async () => {
    const user = userEvent.setup();

    const existingAdmin: AdminUser = {
      id: 'existing-admin-id',
      name: 'Original Name',
      email: 'original@sakai.ph',
      role: 'support',
      status: 'active',
      created_at: '2024-01-01T00:00:00Z',
      last_login_at: null,
      created_by: null,
    };

    const updatedAdmin = { ...existingAdmin, name: 'Updated Name', email: 'updated@sakai.ph' };
    
    (adminApi.admins.list as any).mockResolvedValue([existingAdmin]);
    (adminApi.admins.update as any).mockResolvedValue(updatedAdmin);

    // Render component
    const { unmount } = render(
      <BrowserRouter>
        <SAAdminManagement />
      </BrowserRouter>
    );

    // Wait for initial load
    await waitFor(() => {
      expect(adminApi.admins.list).toHaveBeenCalled();
    });

    // Click edit button (use getAllByTitle and click the first one)
    const editButtons = screen.getAllByTitle('Edit admin');
    await user.click(editButtons[0]);

    // Wait for modal
    await waitFor(() => {
      expect(screen.getByRole('heading', { name: /edit admin/i })).toBeInTheDocument();
    });

    // Update form fields
    const nameInput = screen.getByPlaceholderText(/e\.g\. Maria Santos/i);
    const emailInput = screen.getByPlaceholderText(/e\.g\. maria@sakai\.ph/i);

    await user.clear(nameInput);
    await user.type(nameInput, 'Updated Name');
    await user.clear(emailInput);
    await user.type(emailInput, 'updated@sakai.ph');

    // Submit
    const saveButton = screen.getByRole('button', { name: /save/i });
    await user.click(saveButton);

    // OBSERVE: Update API should be called
    await waitFor(() => {
      expect(adminApi.admins.update).toHaveBeenCalled();
    }, { timeout: 3000 });

    const updateCall = (adminApi.admins.update as any).mock.calls[0];
    
    // PRESERVATION: Update should be called with admin ID
    expect(updateCall[0]).toBe(existingAdmin.id);
    
    // PRESERVATION: role_id should be included
    expect(updateCall[1].role_id).toBeDefined();

    // PRESERVATION: Modal should close after successful update
    await waitFor(() => {
      expect(screen.queryByRole('heading', { name: /edit admin/i })).not.toBeInTheDocument();
    }, { timeout: 3000 });

    unmount();
  });

  /**
   * Property 3: Client-Side Validation Continues to Work
   * 
   * **Validates: Requirement 3.3**
   * 
   * OBSERVATION: When form validation fails (invalid email, name too short, etc.),
   * the system should:
   * - Display validation errors
   * - NOT call the API
   * - Keep the modal open
   * 
   * This behavior MUST be preserved after the fix.
   */
  it('Property 3: Client-side validation prevents API calls', async () => {
    const user = userEvent.setup();

    // Render component
    const { unmount } = render(
      <BrowserRouter>
        <SAAdminManagement />
      </BrowserRouter>
    );

    // Wait for initial load
    await waitFor(() => {
      expect(adminApi.admins.list).toHaveBeenCalled();
    });

    // Open modal
    const addButton = screen.getByRole('button', { name: /add admin/i });
    await user.click(addButton);

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: /add admin/i })).toBeInTheDocument();
    });

    // Fill with invalid data (empty name and invalid email)
    const nameInput = screen.getByPlaceholderText(/e\.g\. Maria Santos/i);
    const emailInput = screen.getByPlaceholderText(/e\.g\. maria@sakai\.ph/i);

    await user.clear(nameInput);
    // Leave name empty
    
    await user.clear(emailInput);
    await user.type(emailInput, 'invalid-email');

    // Try to submit
    const saveButton = screen.getByRole('button', { name: /save/i });
    await user.click(saveButton);

    // PRESERVATION: API should NOT be called with invalid data
    await waitFor(() => {
      // Give it a moment to potentially call the API (it shouldn't)
      expect(adminApi.admins.create).not.toHaveBeenCalled();
    }, { timeout: 1000 });

    // PRESERVATION: Modal should remain open
    expect(screen.getByRole('heading', { name: /add admin/i })).toBeInTheDocument();

    unmount();
  });

  /**
   * Property 4: Other Error Types Are Handled Appropriately
   * 
   * **Validates: Requirement 3.4**
   * 
   * OBSERVATION: When the API returns errors other than 409 (network errors,
   * 400 validation, 500 server errors), the system should:
   * - Handle the error (may or may not display message in current implementation)
   * - Keep modal open (observe current behavior)
   * 
   * This behavior MUST be preserved after the fix.
   */
  it('Property 4: Other error types are handled consistently', async () => {
    const user = userEvent.setup();

    // Create a 500 error
    const mockError: any = new Error('HTTP 500 error');
    mockError.status = 500;

    (adminApi.admins.create as any).mockRejectedValue(mockError);

    // Render component
    const { unmount } = render(
      <BrowserRouter>
        <SAAdminManagement />
      </BrowserRouter>
    );

    // Wait for initial load
    await waitFor(() => {
      expect(adminApi.admins.list).toHaveBeenCalled();
    });

    // Open modal
    const addButton = screen.getByRole('button', { name: /add admin/i });
    await user.click(addButton);

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: /add admin/i })).toBeInTheDocument();
    });

    // Fill form with valid data
    const nameInput = screen.getByPlaceholderText(/e\.g\. Maria Santos/i);
    const emailInput = screen.getByPlaceholderText(/e\.g\. maria@sakai\.ph/i);
    const roleSelects = screen.getAllByRole('combobox');
    const roleSelect = roleSelects[0];

    await user.clear(nameInput);
    await user.type(nameInput, 'Test User');
    await user.clear(emailInput);
    await user.type(emailInput, 'test@example.com');
    await user.selectOptions(roleSelect, 'support');

    // Submit
    const saveButton = screen.getByRole('button', { name: /save/i });
    
    // Catch unhandled rejection
    const errorHandler = vi.fn();
    window.addEventListener('unhandledrejection', errorHandler);
    
    await user.click(saveButton);

    // OBSERVE: API should be called
    await waitFor(() => {
      expect(adminApi.admins.create).toHaveBeenCalled();
    }, { timeout: 3000 });

    // PRESERVATION: Error should be handled (not crash the app)
    // The current implementation may or may not show an error message
    // We're just verifying the app doesn't crash and modal behavior is consistent
    
    // Wait a bit to see if modal closes or stays open
    await waitFor(() => {
      // Modal should still be present (error occurred)
      const modalHeading = screen.queryByRole('heading', { name: /add admin/i });
      // OBSERVE: In current implementation, modal likely stays open on error
      expect(modalHeading).toBeInTheDocument();
    }, { timeout: 1000 });

    window.removeEventListener('unhandledrejection', errorHandler);
    unmount();
  });
});
