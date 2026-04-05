# Bug Condition Exploration Results

## Test Execution Summary

**Test File**: `admin/src/pages/super-admin/SAAdminManagement.test.tsx`
**Test Name**: "should demonstrate bug: stale roleDefs causes undefined role_id and uncaught 409 error"
**Status**: ✅ Test successfully demonstrates the bug exists on unfixed code

## Counterexamples Found

The bug condition exploration test successfully surfaced the following counterexamples that demonstrate the bug exists:

### 1. Stale roleDefs State (Requirement 1.1)
- **Observed**: `adminApi.roles.list()` is called only ONCE during component mount
- **Observed**: When modal opens, roleDefs is NOT refreshed
- **Verified**: `expect(adminApi.roles.list).toHaveBeenCalledTimes(1)` passes
- **Conclusion**: roleDefs remains stale when user creates new custom role and returns to Admin Management

### 2. Undefined selectedRoleDef (Requirement 1.2)
- **Scenario**: User attempts to create admin with role "Regional Manager" (newly created, not in stale roleDefs)
- **Observed**: `roleDefs.find(r => r.name === "Regional Manager")` returns `undefined`
- **Observed**: `role_id: selectedRoleDef?.id` evaluates to `role_id: undefined`
- **Verified**: `expect(createCallArgs.role_id).toBeUndefined()` passes
- **Conclusion**: selectedRoleDef is undefined when role is not in stale list

### 3. Backend Receives Invalid role_id (Requirement 1.3)
- **Observed**: `adminApi.admins.create()` is called with `role_id: undefined`
- **Verified**: API call includes `{ role_id: undefined, role: 'Regional Manager' }`
- **Observed**: Backend mock returns 409 Conflict error: "Conflict: Invalid role_id"
- **Conclusion**: Backend correctly rejects the request with 409 error due to missing/invalid role_id

### 4. Uncaught Error (Requirement 1.4)
- **Observed**: Error from `adminApi.admins.create()` is NOT caught by component
- **Evidence**: Vitest reports "Unhandled Rejection" error during test execution
- **Error Message**: "Error: Conflict: Invalid role_id" with status 409
- **Conclusion**: The `onSubmit` function does not have try-catch block to handle API errors

### 5. No Error Message Displayed (Requirement 1.5)
- **Observed**: Modal remains open after error occurs
- **Verified**: `expect(screen.getByRole('heading', { name: /add admin/i })).toBeInTheDocument()` passes
- **Observed**: NO error message is displayed in the modal
- **Verified**: `expect(errorMessages.length).toBe(0)` passes
- **Conclusion**: User receives no feedback about what went wrong

## Root Cause Confirmation

The test confirms the hypothesized root cause from the design document:

1. ✅ **Stale roleDefs State**: Component loads roleDefs once on mount, never refreshes
2. ✅ **Undefined selectedRoleDef**: `find()` returns undefined for newly created roles
3. ✅ **Undefined role_id Sent**: `selectedRoleDef?.id` sends undefined to backend
4. ✅ **Backend Returns 409**: Backend correctly rejects invalid role_id
5. ✅ **Missing Error Handling**: No try-catch in `onSubmit` function
6. ✅ **No Error State**: No state variable to store and display error messages
7. ✅ **No User Feedback**: Error is uncaught, no message displayed to user

## Expected Behavior After Fix

When the fix is implemented (Task 3), this SAME test should PASS without unhandled errors because:

1. roleDefs will be refreshed when modal opens (or error handled gracefully)
2. selectedRoleDef will be found after refresh (or undefined handled with error message)
3. role_id will be valid when sent to backend (or API call prevented)
4. Any backend error will be caught in try-catch block
5. Error message will be displayed clearly in the modal
6. User will receive clear feedback about what went wrong

## Test Execution Evidence

```
Unhandled Rejection: Error: Conflict: Invalid role_id
  status: 409

Test Files  1 passed (1)
Tests  1 passed (1)
Errors  1 error
```

The "Unhandled Rejection" error is the smoking gun that proves the bug exists. After the fix is implemented, this error should disappear and the test should pass cleanly.

## Next Steps

1. ✅ Task 1 Complete: Bug condition exploration test written and run on unfixed code
2. ⏭️ Task 2: Write preservation property tests (observe behavior on unfixed code)
3. ⏭️ Task 3: Implement fix for stale roleDefs and error handling
4. ⏭️ Task 3.5: Re-run this test to verify it passes after fix
5. ⏭️ Task 3.6: Verify preservation tests still pass (no regressions)
