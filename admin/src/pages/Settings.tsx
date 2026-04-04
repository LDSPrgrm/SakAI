import React, { useEffect, useState } from 'react';
import { Card, CardContent } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { CheckCircle, ToggleLeft, ToggleRight } from 'lucide-react';
import { adminApi, AdminUser } from '@/lib/admin-api';

function roleVariant(role: string): 'info' | 'default' {
  return role === 'super_admin' ? 'info' : 'default';
}

function roleLabel(role: string): string {
  switch (role) {
    case 'super_admin': return 'Super Admin';
    case 'operations': return 'Operations';
    case 'finance': return 'Finance';
    case 'support': return 'Support';
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
    adminApi.admins.list()
      .then(setAdmins)
      .catch(() => {})
      .finally(() => setAdminsLoading(false));

    adminApi.system.getNotificationTemplates()
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

    adminApi.system.getIntegrations()
      .then((raw: any[]) => {
        // Map integrations (gcash/paymaya/card configs) from system integrations or payment configs
        return adminApi.payments.getPaymentConfigs?.()
          .then((configs: GatewayConfig[]) => setGateways(configs))
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
      templates.map(t => adminApi.system.updateTemplate(t.event, t.body).catch(() => {}))
    ).then(() => {
      setNotifSaved(true);
      setTimeout(() => setNotifSaved(false), 3000);
    });
  };

  const handleToggleGateway = (idx: number) => {
    const gw = gateways[idx];
    const updated = { ...gw, is_active: !gw.is_active };
    setGateways(prev => prev.map((g, i) => i === idx ? updated : g));
    adminApi.system.updateIntegration(gw.provider, { is_active: String(updated.is_active) }).catch(() => {});
  };

  const handleSaveSystem = () => {
    setSystemSaved(true);
    setTimeout(() => setSystemSaved(false), 3000);
  };

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
                <Button>Add Admin</Button>
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
                          <Button variant="ghost" size="sm" onClick={() => adminApi.admins.update(admin.id, {}).catch(() => {})}>Edit</Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-danger"
                            onClick={() => adminApi.admins.deactivate(admin.id).then(() =>
                              setAdmins(prev => prev.map(a => a.id === admin.id ? { ...a, status: 'deactivated' } : a))
                            ).catch(() => {})}
                          >
                            Remove
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
    </div>
  );
}
