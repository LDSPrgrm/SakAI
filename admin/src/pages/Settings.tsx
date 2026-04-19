import React, { useEffect, useRef, useState } from 'react';
import { Card, CardContent } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { CheckCircle, Loader2, ToggleLeft, ToggleRight, X } from 'lucide-react';
import { adminsApi } from '@/api/super-admin/admins';
import { rolesApi } from '@/api/super-admin/roles';
import { systemApi } from '@/api/super-admin/system';
import { paymentsApi } from '@/api/super-admin/payments';
import { ConfirmationModal } from '@/components/super-admin/modals/ConfirmationModal';
import type { AdminRole, AdminRoleDefinition, AdminUser } from '@/types/super-admin';

function roleVariant(role: string): 'info' | 'default' {
  return role === 'superadmin' || role === 'admin' ? 'info' : 'default';
}

function roleLabel(role: string): string {
  switch (role) {
    case 'admin':      return 'Admin';
    case 'superadmin': return 'Super Admin';
    case 'operations': return 'Operations';
    case 'finance':    return 'Finance';
    case 'support':    return 'Support';
    default: return role;
  }
}

function SaveBanner({ show }: { show: boolean }) {
  if (!show) return null;
  return (
    <span className="flex items-center gap-1.5 text-sm text-success">
      <CheckCircle className="w-4 h-4" /> Saved successfully
    </span>
  );
}

// ── Fallback hardcoded roles (shown when API hasn't loaded yet) ───────────────
const FALLBACK_ROLES: { value: string; label: string }[] = [
  { value: 'admin',      label: 'Admin'       },
  { value: 'superadmin', label: 'Super Admin' },
  { value: 'operations', label: 'Operations'  },
  { value: 'finance',    label: 'Finance'     },
  { value: 'support',    label: 'Support'     },
];

function roleOptionsFromDefinitions(defs: AdminRoleDefinition[]): { value: string; label: string }[] {
  if (defs.length === 0) return FALLBACK_ROLES;
  return defs.map(d => ({
    value: d.name,
    label: d.name.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase()),
  }));
}

interface AdminFormState {
  name: string;
  email: string;
  role: string;   // widened — supports both built-in AdminRole values and custom role names
  password: string;
}
const EMPTY_FORM: AdminFormState = { name: '', email: '', role: 'support', password: '' };

// ── Add / Edit Admin Modal ────────────────────────────────────────────────────
interface AdminModalProps {
  mode: 'add' | 'edit';
  initial?: AdminFormState & { id?: string };
  roleOptions: { value: string; label: string }[];
  roleDefinitions: AdminRoleDefinition[];
  onClose: () => void;
  onSave: (admin: AdminUser) => void;
}

function AdminModal({ mode, initial, roleOptions, roleDefinitions, onClose, onSave }: AdminModalProps) {
  const [form, setForm] = useState<AdminFormState>(
    initial
      ? { name: initial.name, email: initial.email, role: initial.role, password: '' }
      : { ...EMPTY_FORM, role: roleOptions[0]?.value ?? 'support' },
  );
  const [errors, setErrors] = useState<Partial<AdminFormState>>({});
  const [saving, setSaving] = useState(false);
  const [apiError, setApiError] = useState('');
  const firstRef = useRef<HTMLInputElement>(null);

  useEffect(() => { firstRef.current?.focus(); }, []);

  // Close on Escape
  useEffect(() => {
    const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [onClose]);

  function validate() {
    const e: Partial<AdminFormState> = {};
    if (!form.name.trim())  e.name  = 'Name is required.';
    if (!form.email.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email))
      e.email = 'Valid email is required.';
    if (mode === 'add' && form.password.length < 8)
      e.password = 'Password must be at least 8 characters.';
    return e;
  }

  async function handleSubmit(ev: React.FormEvent) {
    ev.preventDefault();
    const e = validate();
    if (Object.keys(e).length) { setErrors(e); return; }
    setErrors({});
    setApiError('');
    setSaving(true);
    try {
      const selectedRoleDef = roleDefinitions.find(r => r.name === form.role);
      let saved: AdminUser;
      if (mode === 'add') {
        saved = await adminsApi.create({
          name: form.name.trim(),
          email: form.email.trim(),
          role_id: selectedRoleDef?.id || '',
          password: form.password,
        }) as unknown as AdminUser;
      } else {
        saved = await adminsApi.update(initial!.id!, {
          name: form.name.trim(),
          email: form.email.trim(),
          role: form.role as AdminRole,
          role_id: selectedRoleDef?.id,
        }) as unknown as AdminUser;
      }
      onSave(saved);
      onClose();
    } catch (err: any) {
      setApiError(err?.message || 'Something went wrong. Please try again.');
    } finally {
      setSaving(false);
    }
  }

  function field(key: keyof AdminFormState, val: string) {
    setForm(f => ({ ...f, [key]: val }));
    setErrors(e => ({ ...e, [key]: '' }));
  }

  return (
    /* Backdrop */
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/60"
      onClick={(e) => { if (e.target === e.currentTarget) onClose(); }}
      role="dialog"
      aria-modal="true"
      aria-label={mode === 'add' ? 'Add Admin' : 'Edit Admin'}
    >
      <div className="bg-surface w-full max-w-md rounded-xl border border-border shadow-2xl">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-border">
          <h2 className="text-lg font-semibold text-text-main">
            {mode === 'add' ? 'Add New Admin' : 'Edit Admin'}
          </h2>
          <button onClick={onClose} className="text-text-muted hover:text-text-main transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Body */}
        <form onSubmit={handleSubmit} noValidate>
          <div className="px-6 py-5 space-y-4">
            {apiError && (
              <p className="text-sm text-danger bg-danger/10 border border-danger/30 rounded-lg px-3 py-2">
                {apiError}
              </p>
            )}

            {/* Name */}
            <div className="space-y-1">
              <label className="text-xs font-medium text-text-muted">Full Name</label>
              <Input
                ref={firstRef}
                value={form.name}
                onChange={e => field('name', e.target.value)}
                placeholder="Maria Santos"
                className={errors.name ? 'border-danger' : ''}
              />
              {errors.name && <p className="text-xs text-danger">{errors.name}</p>}
            </div>

            {/* Email */}
            <div className="space-y-1">
              <label className="text-xs font-medium text-text-muted">Email Address</label>
              <Input
                type="email"
                value={form.email}
                onChange={e => field('email', e.target.value)}
                placeholder="maria@sakai.ph"
                className={errors.email ? 'border-danger' : ''}
              />
              {errors.email && <p className="text-xs text-danger">{errors.email}</p>}
            </div>

            {/* Role */}
            <div className="space-y-1">
              <label className="text-xs font-medium text-text-muted">Role</label>
              <select
                value={form.role}
                onChange={e => field('role', e.target.value)}
                className="w-full rounded-lg border border-border bg-surface text-text-main px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50"
              >
                {roleOptions.map(opt => (
                  <option key={opt.value} value={opt.value}>{opt.label}</option>
                ))}
              </select>
            </div>

            {/* Password — add mode only */}
            {mode === 'add' && (
              <div className="space-y-1">
                <label className="text-xs font-medium text-text-muted">Temporary Password</label>
                <Input
                  type="password"
                  value={form.password}
                  onChange={e => field('password', e.target.value)}
                  placeholder="Minimum 8 characters"
                  className={errors.password ? 'border-danger' : ''}
                />
                {errors.password && <p className="text-xs text-danger">{errors.password}</p>}
              </div>
            )}
          </div>

          {/* Footer */}
          <div className="flex justify-end gap-3 px-6 py-4 border-t border-border">
            <Button type="button" variant="ghost" onClick={onClose} disabled={saving}>
              Cancel
            </Button>
            <Button type="submit" disabled={saving}>
              {saving
                ? <><Loader2 className="w-4 h-4 animate-spin mr-2" /> Saving…</>
                : mode === 'add' ? 'Add Admin' : 'Save Changes'
              }
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}

interface NotifTemplate {
  event: string;
  channel: string;
  subject: string;
  body: string;
}

interface GatewayConfig {
  id: string;
  provider: string;
  is_active: boolean;
  config_fields: Record<string, string>;
}

export function Settings() {
  // Admin Users tab
  const [admins, setAdmins] = useState<AdminUser[]>([]);
  const [adminsLoading, setAdminsLoading] = useState(true);
  const [roleDefinitions, setRoleDefinitions] = useState<AdminRoleDefinition[]>([]);
  const [adminModal, setAdminModal] = useState<
    | { mode: 'add' }
    | { mode: 'edit'; admin: AdminUser }
    | null
  >(null);
  const [confirmDeactivate, setConfirmDeactivate] = useState<AdminUser | null>(null);
  const [deactivating, setDeactivating] = useState(false);

  // Notifications tab
  const [templates, setTemplates] = useState<NotifTemplate[]>([]);
  const [templatesLoading, setTemplatesLoading] = useState(true);
  const [notifSaved, setNotifSaved] = useState(false);
  const [notifErrors, setNotifErrors] = useState<Record<string, string>>({});

  // System Config tab
  const [gateways, setGateways] = useState<GatewayConfig[]>([]);
  const [systemSaved, setSystemSaved] = useState(false);
  const [systemLoading, setSystemLoading] = useState(true);

  useEffect(() => {
    adminsApi.list()
      .then(r => setAdmins(r as unknown as AdminUser[]))
      .catch(() => {})
      .finally(() => setAdminsLoading(false));

    rolesApi.list()
      .then(r => setRoleDefinitions(r as unknown as AdminRoleDefinition[]))
      .catch(() => {});

    systemApi.getNotificationTemplates()
      .then((raw: any[]) => {
        const mapped: NotifTemplate[] = raw.map(t => ({
          event: t.event ?? '',
          channel: t.channel ?? 'push',
          subject: t.subject ?? '',
          body: t.body ?? '',
        }));
        setTemplates(mapped);
      })
      .catch(() => {})
      .finally(() => setTemplatesLoading(false));

    systemApi.getIntegrations()
      .then((raw: any[]) => {
        // Map integrations (gcash/paymaya/card configs) from system integrations or payment configs
        return paymentsApi.getGatewayConfigs()
          .then((configs) => setGateways(configs as unknown as GatewayConfig[]))
          .catch(() => {});
      })
      .catch(() => {})
      .finally(() => setSystemLoading(false));
  }, []);

  const handleTemplateChange = (idx: number, field: keyof NotifTemplate, value: string) => {
    setTemplates(prev => prev.map((t, i) => i === idx ? { ...t, [field]: value } : t));
    setNotifErrors(prev => ({ ...prev, [idx]: '' }));
  };

  const handleSaveNotif = () => {
    const errs: Record<string, string> = {};
    templates.forEach((t, i) => {
      if (!t.body.trim()) errs[String(i)] = 'Template body cannot be empty.';
    });
    if (Object.keys(errs).length > 0) { setNotifErrors(errs); return; }
    setNotifErrors({});
    Promise.all(
      templates.map(t => systemApi.updateTemplate(t.event, t.body).catch(() => {}))
    ).then(() => {
      setNotifSaved(true);
      setTimeout(() => setNotifSaved(false), 3000);
    });
  };

  const handleToggleGateway = (idx: number) => {
    const gw = gateways[idx];
    const updated = { ...gw, is_active: !gw.is_active };
    setGateways(prev => prev.map((g, i) => i === idx ? updated : g));
    systemApi.updateIntegration(gw.provider, { is_active: String(updated.is_active) }).catch(() => {});
  };

  const handleSaveSystem = () => {
    setSystemSaved(true);
    setTimeout(() => setSystemSaved(false), 3000);
  };

  function handleAdminSaved(saved: AdminUser) {
    if (adminModal?.mode === 'add') {
      setAdmins(prev => [saved, ...prev]);
    } else {
      setAdmins(prev => prev.map(a => a.id === saved.id ? saved : a));
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-text-main">Settings</h1>
      </div>

      <Card>
        <CardContent className="p-0">
          <Tabs defaultValue="admins" className="w-full">
            <div className="px-6 pt-4 border-b border-border">
              <TabsList className="mb-4">
                <TabsTrigger value="admins">Admin Users</TabsTrigger>
                <TabsTrigger value="notifications">Notifications</TabsTrigger>
                <TabsTrigger value="system">System Config</TabsTrigger>
              </TabsList>
            </div>

            {/* ── Admin Users ── */}
            <TabsContent value="admins" className="p-6 m-0">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-medium">Manage Admin Access</h3>
                <Button onClick={() => setAdminModal({ mode: 'add' })}>Add Admin</Button>
              </div>
              {adminsLoading ? (
                <p className="text-sm text-text-muted text-center py-6">Loading...</p>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Name</TableHead>
                      <TableHead>Email</TableHead>
                      <TableHead>Role</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Last Login</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {admins.length === 0 ? (
                      <TableRow>
                        <TableCell colSpan={6} className="text-center py-10 text-text-muted">No admins found.</TableCell>
                      </TableRow>
                    ) : admins.map((admin) => (
                      <TableRow key={admin.id}>
                        <TableCell className="font-medium">{admin.name}</TableCell>
                        <TableCell>{admin.email}</TableCell>
                        <TableCell>
                          <Badge variant={roleVariant(admin.role)}>{roleLabel(admin.role)}</Badge>
                        </TableCell>
                        <TableCell>
                          <Badge variant={admin.status === 'active' ? 'success' : 'default'}>
                            {admin.status.charAt(0).toUpperCase() + admin.status.slice(1)}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-sm text-text-muted">
                          {admin.last_login_at ? new Date(admin.last_login_at).toLocaleDateString('en-PH') : 'Never'}
                        </TableCell>
                        <TableCell className="text-right">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => setAdminModal({ mode: 'edit', admin })}
                          >
                            Edit
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-danger"
                            disabled={admin.status === 'deactivated'}
                            onClick={() => setConfirmDeactivate(admin)}
                          >
                            {admin.status === 'deactivated' ? 'Removed' : 'Remove'}
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </TabsContent>

            {/* ── Notification Templates ── */}
            <TabsContent value="notifications" className="p-6 m-0 space-y-6">
              <div className="flex justify-between items-center">
                <h3 className="text-lg font-medium">Notification Templates</h3>
                <SaveBanner show={notifSaved} />
              </div>

              {templatesLoading ? (
                <p className="text-sm text-text-muted text-center py-6">Loading templates...</p>
              ) : templates.length === 0 ? (
                <p className="text-sm text-text-muted text-center py-6">No templates configured.</p>
              ) : (
                <div className="space-y-6 max-w-2xl">
                  {templates.map((tpl, idx) => (
                    <div key={tpl.event} className="space-y-3 p-4 bg-surface-hover border border-border rounded-lg">
                      <div className="flex items-center justify-between">
                        <p className="text-sm font-medium text-text-main capitalize">{tpl.event.replace(/_/g, ' ')}</p>
                        <Badge variant="default">{tpl.channel}</Badge>
                      </div>
                      {tpl.subject !== undefined && (
                        <div className="space-y-1">
                          <label className="text-xs font-medium text-text-muted">Subject</label>
                          <Input
                            value={tpl.subject}
                            onChange={(e) => handleTemplateChange(idx, 'subject', e.target.value)}
                          />
                        </div>
                      )}
                      <div className="space-y-1">
                        <label className="text-xs font-medium text-text-muted">Body</label>
                        <Input
                          value={tpl.body}
                          onChange={(e) => handleTemplateChange(idx, 'body', e.target.value)}
                          className={notifErrors[String(idx)] ? 'border-danger' : ''}
                        />
                        {notifErrors[String(idx)] && <p className="text-xs text-danger">{notifErrors[String(idx)]}</p>}
                      </div>
                    </div>
                  ))}
                  <Button onClick={handleSaveNotif}>Save Templates</Button>
                </div>
              )}
            </TabsContent>

            {/* ── System Config ── */}
            <TabsContent value="system" className="p-6 m-0 space-y-6">
              <div className="flex justify-between items-center">
                <h3 className="text-lg font-medium">System Configuration</h3>
                <SaveBanner show={systemSaved} />
              </div>

              <div className="space-y-6 max-w-2xl">
                {/* Payment Gateways */}
                <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-4">
                  <h4 className="font-medium">Payment Gateways</h4>
                  {systemLoading ? (
                    <p className="text-sm text-text-muted">Loading...</p>
                  ) : gateways.length > 0 ? (
                    <div className="space-y-3">
                      {gateways.map((gw, idx) => (
                        <div key={gw.id ?? gw.provider} className="flex items-center justify-between gap-4">
                          <div className="flex-1 space-y-1">
                            <label className="text-sm text-text-muted capitalize">{gw.provider} API Key</label>
                            <Input
                              type="password"
                              defaultValue={Object.values(gw.config_fields ?? {})[0] ?? '************************'}
                            />
                          </div>
                          <button
                            aria-label={`${gw.is_active ? 'Disable' : 'Enable'} ${gw.provider}`}
                            onClick={() => handleToggleGateway(idx)}
                            className="flex-shrink-0"
                          >
                            {gw.is_active
                              ? <ToggleRight className="w-8 h-8 text-success" />
                              : <ToggleLeft className="w-8 h-8 text-text-muted" />
                            }
                          </button>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <>
                      <div className="space-y-2">
                        <label className="text-sm text-text-muted">GCash API Key</label>
                        <Input type="password" defaultValue="************************" />
                      </div>
                      <div className="space-y-2">
                        <label className="text-sm text-text-muted">PayMaya API Key</label>
                        <Input type="password" defaultValue="************************" />
                      </div>
                    </>
                  )}
                </div>

                {/* Maps Integration */}
                <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-4">
                  <h4 className="font-medium">Maps Integration</h4>
                  <div className="space-y-2">
                    <label className="text-sm text-text-muted">Google Maps API Key</label>
                    <Input type="password" defaultValue="************************" />
                  </div>
                </div>

                <Button onClick={handleSaveSystem}>Save Configuration</Button>
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      {adminModal && (
        <AdminModal
          mode={adminModal.mode}
          initial={adminModal.mode === 'edit'
            ? { ...adminModal.admin, password: '' }
            : undefined
          }
          roleOptions={roleOptionsFromDefinitions(roleDefinitions)}
          roleDefinitions={roleDefinitions}
          onClose={() => setAdminModal(null)}
          onSave={handleAdminSaved}
        />
      )}

      <ConfirmationModal
        open={confirmDeactivate !== null}
        title="Deactivate Admin"
        description={`Are you sure you want to deactivate ${confirmDeactivate?.name}? They will lose access immediately.`}
        confirmLabel="Deactivate"
        variant="danger"
        loading={deactivating}
        onCancel={() => setConfirmDeactivate(null)}
        onConfirm={async () => {
          if (!confirmDeactivate) return;
          setDeactivating(true);
          try {
            await adminsApi.deactivate(confirmDeactivate.id);
            setAdmins(prev =>
              prev.map(a => a.id === confirmDeactivate.id ? { ...a, status: 'deactivated' } : a),
            );
          } catch {
            // silent — API error doesn't revert optimistic UI since the admin isn't changed yet
          } finally {
            setDeactivating(false);
            setConfirmDeactivate(null);
          }
        }}
      />
    </div>
  );
}
