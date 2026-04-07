# Stale Role Definitions Bugfix Design

## Overview

This bugfix addresses the 409 Conflict error that occurs when an admin attempts to create a new admin account with a newly created custom role. The root cause is that the component loads role definitions once on mount (line 95), but when a user creates a new custom role in the Role Management page and returns to Admin Management, the `roleDefs` state is stale. When creating an admin with the new role, `roleDefs.find(r => r.name === values.role)` returns undefined, causing `role_id: undefined` to be sent to the backend. The backend returns a 409 Conflict error, which is uncaught and displays a misleading "email already registered" message. The fix implements proper role definition refreshing, undefined handling, and error display.

## Glossary

- **Bug_Condition (C)**: The condition that triggers the bug - when a user creates a new custom role and attempts to use it before roleDefs is refreshed, causing selectedRoleDef to be undefined
- **Property (P)**: The desired behavior - refresh roleDefs when modal opens, handle undefined selectedRoleDef gracefully, catch and display actual backend errors
- **Preservation**: Existing successful admin creation/update flows and error handling that must remain unchanged by the fix
- **roleDefs**: React state array containing AdminRoleDefinition objects, loaded once on component mount (line 95)
- **selectedRoleDef**: The result of `roleDefs.find(r => r.name === values.role)` which can be undefined if the role doesn't exist in the stale list
- **onSubmit**: The form submission handler in `SAAdminManagement.tsx` that calls `adminApi.admins.create()` or `adminApi.admins.update()`
- **modalOpen**: The React state that controls whether the Add/Edit Admin modal is visible

## Bug Details

### Bug Condition

The bug manifests when:
1. Component loads and fetches roleDefs once on mount (line 95: `adminApi.roles.list().then(setRoleDefs)`)
2. User navigates to Role Management page and creates a new custom role
3. User returns to Admin Management page (roleDefs state is stale - doesn't include new role)
4. User opens "Add Admin" modal and selects the newly created role from the dropdown
5. User submits the form
6. Line 130: `const selectedRoleDef = roleDefs.find(r => r.name === values.role)` returns undefined
7. Line 135/142: `role_id: selectedRoleDef?.id` sends `role_id: undefined` to backend
8. Backend returns 409 Conflict error (or validation error) because role_id is missing/invalid
9. Error is uncaught in onSubmit, displays misleading error message

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type { email: string, name: string, role: string, status: AdminStatus, password: string }
  OUTPUT: boolean
  
  RETURN input.role NOT_IN roleDefs
         AND selectedRoleDef = roleDefs.find(r => r.name === input.role) === undefined
         AND adminApi.admins.create({...input, role_id: undefined}) throws Error
         AND error.status === 409 OR error.message CONTAINS "409"
         AND NO proper error message displayed to user
END FUNCTION
```

### Examples

- User creates custom role "Regional Manager" in Role Management, returns to Admin Management, tries to create admin with that role → selectedRoleDef is undefined → role_id: undefined sent → 409 error → misleading "email already registered" message
- User creates custom role "Warehouse Supervisor", navigates back, selects it in dropdown, submits → roleDefs is stale → find() returns undefined → backend rejects with 409 → uncaught error
- Edge case: User creates admin with existing role (e.g., "support") → Should succeed (not a bug condition, roleDefs contains it)
- Edge case: User updates existing admin → Should succeed (not affected by stale roleDefs for new roles)

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Successful admin creation with existing roles must continue to close the modal and refresh the admin list
- Admin updates must continue to work correctly
- Form validation errors (client-side) must continue to display before any API call is made
- Other API errors (network errors, 400 validation errors, 500 server errors) must continue to be handled appropriately

**Scope:**
All inputs that do NOT involve newly created custom roles should be completely unaffected by this fix. This includes:
- Successful POST /api/admin/users requests with existing roles
- PUT /api/admin/users/{id} requests (updates)
- Other error responses (400, 401, 403, 500, 503)
- Client-side validation failures

## Hypothesized Root Cause

Based on the bug description and code analysis, the root cause is:

1. **Stale roleDefs State**: The component loads roleDefs once on mount (line 95: `adminApi.roles.list().then(setRoleDefs)`). When a user creates a new custom role in another page and returns, the roleDefs state is not refreshed.

2. **Undefined selectedRoleDef**: Line 130 performs `const selectedRoleDef = roleDefs.find(r => r.name === values.role)`. When the selected role is newly created and not in the stale roleDefs list, this returns undefined.

3. **Undefined role_id Sent to Backend**: Lines 135 and 142 send `role_id: selectedRoleDef?.id` to the backend. When selectedRoleDef is undefined, this sends `role_id: undefined`, which the backend rejects.

4. **Backend Returns 409**: The backend returns a 409 Conflict error (or validation error) because role_id is missing or invalid.

5. **Missing Error Handling in onSubmit**: The `onSubmit` function (lines 128-145) does not have a try-catch block to handle errors from `adminApi.admins.create()` or `adminApi.admins.update()`.

6. **No Error State in Form**: The component does not have a state variable to store and display error messages from API calls.

7. **Misleading Error Message**: The uncaught error displays as "email already registered" instead of the actual problem (invalid role_id).

## Correctness Properties

Property 1: Bug Condition - Stale Role Definitions Handling

_For any_ admin creation request where the selected role is newly created and not in the current roleDefs state (resulting in selectedRoleDef being undefined), the fixed code SHALL refresh roleDefs when the modal opens, correctly resolve the role_id, or display a clear error message if the role cannot be found. If the backend returns an error, it SHALL be caught and displayed with the actual error message.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**

Property 2: Preservation - Non-Stale Role Behavior

_For any_ admin creation or update request that uses an existing role already in roleDefs (successful requests, updates, other error types), the fixed code SHALL produce exactly the same behavior as the original code, preserving successful registration flows, update flows, and existing error handling.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**File**: `admin/src/pages/super-admin/SAAdminManagement.tsx`

**Specific Changes**:

1. **Refresh roleDefs When Modal Opens**: Modify `openAdd()` and `openEdit()` functions to refresh roleDefs
   - Add `await adminApi.roles.list().then(setRoleDefs)` before opening modal
   - Or add a useEffect that refreshes roleDefs when modalOpen becomes true
   - This ensures the role list is up-to-date when the user opens the form

2. **Add Error State**: Add a new state variable to store API error messages
   - `const [apiError, setApiError] = useState<string | null>(null);`

3. **Wrap API Calls in Try-Catch**: Modify the `onSubmit` function to catch errors
   - Wrap `adminApi.admins.create()` and `adminApi.admins.update()` in try-catch blocks
   - Catch and display the actual error message from the backend
   - Clear apiError on successful submission

4. **Handle Undefined selectedRoleDef**: Add validation before sending to backend
   - Check if `selectedRoleDef` is undefined before calling the API
   - If undefined, display error: "Selected role not found. Please refresh the page or select a different role."
   - Prevent API call when selectedRoleDef is undefined

5. **Display Error in Modal**: Add error message display in the modal
   - Show red alert/banner when `apiError` is not null
   - Display the actual error message from the backend
   - Clear error when modal closes or when user modifies the form

6. **Clear Error on Modal Close**: Reset `apiError` state when modal is closed or when form is reset
   - Add `setApiError(null)` in modal close handlers

**Alternative Approach** (simpler):
- Just refresh roleDefs when modal opens (fixes the stale state issue)
- Add try-catch to display actual backend errors (fixes misleading error message)
- This addresses both the root cause and the symptom

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm or refute the root cause analysis.

**Test Plan**: Simulate the scenario where a user creates a new custom role and attempts to use it before roleDefs is refreshed. Run these tests on the UNFIXED code to observe failures.

**Test Cases**:
1. **Stale roleDefs Test**: Mock roleDefs with existing roles, attempt to create admin with a role not in the list (simulating newly created role) - verify selectedRoleDef is undefined
2. **Undefined role_id Test**: Verify that when selectedRoleDef is undefined, role_id: undefined is sent to backend
3. **409 Error Test**: Verify that backend returns 409 or validation error when role_id is undefined
4. **Uncaught Error Test**: Verify that error is not caught and no proper error message is displayed
5. **Misleading Message Test**: Verify that error displays as "email already registered" or similar misleading message

**Expected Counterexamples**:
- selectedRoleDef is undefined when role is newly created
- role_id: undefined sent to backend
- 409 error returned by backend
- Error is uncaught, no user feedback or misleading error message

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition(input) DO
  result := onSubmit_fixed(input)
  ASSERT roleDefs is refreshed when modal opens
  ASSERT selectedRoleDef is found OR error message displayed
  ASSERT role_id is valid OR API call prevented
  ASSERT any backend error is caught and displayed with actual message
  ASSERT modal remains open with clear feedback
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  ASSERT onSubmit_original(input) = onSubmit_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking.

**Test Plan**: Observe behavior on UNFIXED code first for successful admin creation with existing roles, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Successful Creation Preservation**: Creating admin with existing role (e.g., "support") closes modal and refreshes list
2. **Update Flow Preservation**: Updating admin works correctly
3. **Other Error Handling Preservation**: Network errors, 500 errors, validation errors are handled appropriately
4. **Client Validation Preservation**: Client-side validation (empty fields, invalid email) works correctly

### Unit Tests

- Test that roleDefs is refreshed when modal opens
- Test that selectedRoleDef is correctly found after refresh
- Test that undefined selectedRoleDef is handled gracefully (error message or prevented API call)
- Test that onSubmit catches backend errors and sets appropriate error state
- Test that error message is displayed in the modal when apiError state is set
- Test that error is cleared when modal is closed
- Test that actual backend error message is displayed (not misleading message)

### Property-Based Tests

- Generate random admin data with existing roles and verify successful creation flow continues to work
- Generate random admin data with non-existent roles and verify error handling
- Generate random error responses (400, 401, 500) and verify they are handled appropriately
- Test that form validation continues to work across many input combinations

### Integration Tests

- Test full flow: create custom role in Role Management, return to Admin Management, create admin with new role
- Test that roleDefs refresh ensures newly created roles are available
- Test that after seeing error, user can correct and successfully submit
- Test that switching between add and edit modes clears error state appropriately
