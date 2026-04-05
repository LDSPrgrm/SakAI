# Bugfix Requirements Document

## Introduction

The admin interface currently fails when attempting to create an admin with a newly created custom role. The component loads role definitions once on mount, but when a user creates a new custom role in the Role Management page and returns to Admin Management, the role list is stale. When creating an admin with the new role, the system sends `role_id: undefined` to the backend, which returns a 409 Conflict error. This error is uncaught and displays a misleading "email already registered" message. This bugfix ensures the role definitions are refreshed appropriately and errors are properly handled and displayed.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a user creates a new custom role in Role Management and returns to Admin Management THEN the roleDefs state remains stale and does not include the newly created role

1.2 WHEN creating an admin with a newly created custom role THEN the system sends `role_id: undefined` to the backend because `roleDefs.find(r => r.name === values.role)` returns undefined

1.3 WHEN the backend receives `role_id: undefined` THEN it returns a 409 Conflict error (or validation error) due to missing/invalid role_id

1.4 WHEN the 409 error occurs THEN the error is uncaught and displays as "email already registered" (misleading error message)

1.5 WHEN the error occurs THEN the modal remains open with no clear feedback about what went wrong

### Expected Behavior (Correct)

2.1 WHEN the Admin Management modal opens THEN the system SHALL refresh the roleDefs to include any newly created roles

2.2 WHEN creating an admin with any role (including newly created ones) THEN the system SHALL find the correct role_id and send it to the backend

2.3 WHEN selectedRoleDef is undefined (role not found in roleDefs) THEN the system SHALL display a user-friendly error message indicating the role is not available and suggest refreshing

2.4 WHEN the backend returns a 409 or validation error THEN the system SHALL catch the error and display the actual error message from the backend

2.5 WHEN any error occurs during admin creation THEN the system SHALL display a clear, user-friendly error message that accurately describes the problem

### Unchanged Behavior (Regression Prevention)

3.1 WHEN an admin successfully creates a new admin account with an existing role THEN the system SHALL CONTINUE TO create the admin, close the modal, and refresh the admin list

3.2 WHEN an admin updates an existing admin account THEN the system SHALL CONTINUE TO update the admin successfully

3.3 WHEN the form validation fails before submission THEN the system SHALL CONTINUE TO display validation errors without making an API call

3.4 WHEN the roleDefs list is already up-to-date THEN the system SHALL CONTINUE TO work correctly without unnecessary API calls
