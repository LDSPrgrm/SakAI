// Thin re-export of the AuthContext hook. Kept as a dedicated file so the
// spec's directory layout (superadmin.md §2) is honored and future refactors
// can replace the underlying AuthContext without touching call sites.

export { useAuth } from '@/contexts/AuthContext';
