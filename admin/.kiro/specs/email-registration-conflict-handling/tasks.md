# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - Stale roleDefs Causes Undefined role_id
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: Scope the property to concrete failing case - admin creation with newly created custom role
  - Test scenario: Mock roleDefs with existing roles (e.g., ["super_admin", "operations", "finance", "support"]), attempt to create admin with role "Regional Manager" (simulating newly created role not in stale list)
  - Verify that `roleDefs.find(r => r.name === "Regional Manager")` returns undefined
  - Verify that `role_id: undefined` is sent to backend
  - Verify that backend returns 409 or validation error
  - Verify that error is NOT caught and NO proper error message is displayed (or misleading message shown)
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found: selectedRoleDef undefined, role_id undefined sent, 409 error, uncaught/misleading error message
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Existing Role Behavior Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for successful admin creation with existing roles (e.g., "support", "operations")
  - Observe behavior on UNFIXED code for admin updates
  - Observe behavior on UNFIXED code for other error types (400, 500, network errors)
  - Observe behavior on UNFIXED code for client-side validation failures
  - Write property-based tests capturing observed behavior patterns from Preservation Requirements
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 3. Fix for stale roleDefs and error handling

  - [ ] 3.1 Implement roleDefs refresh when modal opens
    - Modify `openAdd()` function to refresh roleDefs before opening modal
    - Add `await adminApi.roles.list().then(setRoleDefs)` or similar
    - Modify `openEdit()` function to refresh roleDefs before opening modal
    - Alternative: Add useEffect that refreshes roleDefs when modalOpen becomes true
    - This ensures the role list includes any newly created custom roles
    - _Bug_Condition: roleDefs is stale when user creates new custom role and returns to Admin Management_
    - _Expected_Behavior: roleDefs is refreshed when modal opens, ensuring newly created roles are available_
    - _Requirements: 1.1, 2.1_

  - [ ] 3.2 Add error state and error handling in onSubmit
    - Add error state variable: `const [apiError, setApiError] = useState<string | null>(null);`
    - Wrap `adminApi.admins.create()` and `adminApi.admins.update()` calls in try-catch block in `onSubmit` function
    - Catch any errors thrown by the API calls
    - Set `apiError` state with the actual error message from the backend
    - For generic errors, display: "Failed to save admin. Please try again."
    - Clear `apiError` on successful submission
    - _Bug_Condition: Errors from backend are uncaught and display misleading messages_
    - _Expected_Behavior: Errors are caught and actual error message is displayed_
    - _Requirements: 1.4, 1.5, 2.4, 2.5_

  - [ ] 3.3 Handle undefined selectedRoleDef gracefully
    - Before calling API, check if `selectedRoleDef` is undefined
    - If undefined, set error message: "Selected role not found. Please refresh the page or select a different role."
    - Prevent API call when selectedRoleDef is undefined
    - Alternative: Log warning and allow API call to fail with proper error handling from 3.2
    - _Bug_Condition: selectedRoleDef is undefined when role not in stale roleDefs list_
    - _Expected_Behavior: Undefined selectedRoleDef is handled gracefully with clear error message_
    - _Requirements: 1.2, 1.3, 2.2, 2.3_

  - [ ] 3.4 Display error message in modal UI
    - Add error message display component in modal (red alert/banner above form fields)
    - Show when `apiError` is not null
    - Display the error message from `apiError` state
    - Clear `apiError` when modal closes (in modal close handlers)
    - Clear `apiError` when form is reset
    - Optional: Clear `apiError` when user modifies form fields
    - _Expected_Behavior: Error messages are clearly displayed to user in modal_
    - _Requirements: 2.5_

  - [ ] 3.5 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Stale roleDefs Properly Handled
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - Verify roleDefs is refreshed when modal opens (or error is handled gracefully)
    - Verify selectedRoleDef is found after refresh (or undefined is handled)
    - Verify role_id is valid when sent to backend (or API call prevented)
    - Verify any backend error is caught and displayed with actual message
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ] 3.6 Verify preservation tests still pass
    - **Property 2: Preservation** - No Regressions Introduced
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm successful admin creation with existing roles still works
    - Confirm admin updates still work correctly
    - Confirm other error handling still works appropriately
    - Confirm client-side validation still works
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 4. Checkpoint - Ensure all tests pass
  - Run all tests (bug condition + preservation)
  - Verify all tests pass
  - Manually test the flow: create custom role in Role Management, return to Admin Management, create admin with new role
  - Verify roleDefs is refreshed and new role is available
  - Manually test error scenarios: verify actual error messages are displayed (not misleading messages)
  - Ask the user if questions arise
