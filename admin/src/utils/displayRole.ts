// Resolves the display label for an admin's role.
//
// Backend quirk: POST/PUT /admin/users sends role_id (FK to roles table), but the
// response's `role` enum column is derived via a lossy `roleNameToEnum()` on the
// backend — unknown custom role names default to "admin". Only seeded system
// admins (operations/finance/support/superadmin) round-trip correctly in `role`.
// To show the correct label for user-created custom-role admins, resolve via
// role_id against the roles list (source of truth).
export interface AdminLike {
  role?: string | null;
  role_id?: string | null;
  role_name?: string | null;
}

export interface RoleDefLike {
  id: string;
  name: string;
}

export function displayRole(
  a: AdminLike,
  roleDefs?: readonly RoleDefLike[],
): string {
  if (a.role_id && roleDefs) {
    const def = roleDefs.find((r) => r.id === a.role_id);
    if (def?.name) return def.name;
  }
  return a.role_name || a.role || '';
}
