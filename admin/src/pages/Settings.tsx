import React, { useState } from 'react';
import { Card, CardContent } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { CheckCircle } from 'lucide-react';

const admins = [
  { id: 1, name: 'Admin User', email: 'admin@sakai.ph', role: 'Super Admin', status: 'Active' },
  { id: 2, name: 'Finance Team', email: 'finance@sakai.ph', role: 'Finance', status: 'Active' },
  { id: 3, name: 'Support Lead', email: 'support@sakai.ph', role: 'Support', status: 'Active' },
];

function SaveBanner({ show }: { show: boolean }) {
  if (!show) return null;
  return (
    <span className="flex items-center gap-1.5 text-sm text-success">
      <CheckCircle className="w-4 h-4" /> Saved successfully
    </span>
  );
}

export function Settings() {
  const [notifTemplates, setNotifTemplates] = useState({
    rideAccepted: 'Your driver {driver_name} is on the way! ETA: {eta} mins.',
    surgePricing: 'High demand in your area. Fares are currently {surge_multiplier}x higher.',
    payout: 'Your weekly payout of {amount} has been sent to your {payment_method}.',
  });
  const [notifSaved, setNotifSaved] = useState(false);
  const [notifErrors, setNotifErrors] = useState<Record<string, string>>({});

  const [systemSaved, setSystemSaved] = useState(false);

  const validateNotif = () => {
    const errs: Record<string, string> = {};
    if (!notifTemplates.rideAccepted.trim()) errs.rideAccepted = 'Template cannot be empty.';
    if (!notifTemplates.surgePricing.trim()) errs.surgePricing = 'Template cannot be empty.';
    if (!notifTemplates.payout.trim()) errs.payout = 'Template cannot be empty.';
    return errs;
  };

  const handleSaveNotif = () => {
    const errs = validateNotif();
    if (Object.keys(errs).length > 0) { setNotifErrors(errs); return; }
    setNotifErrors({});
    setNotifSaved(true);
    setTimeout(() => setNotifSaved(false), 3000);
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

            <TabsContent value="admins" className="p-6 m-0">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-medium">Manage Admin Access</h3>
                <Button>Add Admin</Button>
              </div>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Email</TableHead>
                    <TableHead>Role</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {admins.map((admin) => (
                    <TableRow key={admin.id}>
                      <TableCell className="font-medium">{admin.name}</TableCell>
                      <TableCell>{admin.email}</TableCell>
                      <TableCell>
                        <Badge variant={admin.role === 'Super Admin' ? 'info' : 'default'}>{admin.role}</Badge>
                      </TableCell>
                      <TableCell>
                        <Badge variant="success">{admin.status}</Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <Button variant="ghost" size="sm">Edit</Button>
                        <Button variant="ghost" size="sm" className="text-danger">Remove</Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TabsContent>

            <TabsContent value="notifications" className="p-6 m-0 space-y-6">
              <div className="flex justify-between items-center">
                <h3 className="text-lg font-medium">Push Notification Templates</h3>
                <SaveBanner show={notifSaved} />
              </div>

              <div className="space-y-4 max-w-2xl">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-text-muted">Ride Accepted (Rider)</label>
                  <Input
                    value={notifTemplates.rideAccepted}
                    onChange={(e) => { setNotifTemplates(p => ({ ...p, rideAccepted: e.target.value })); setNotifErrors(p => ({ ...p, rideAccepted: '' })); }}
                    className={notifErrors.rideAccepted ? 'border-danger' : ''}
                  />
                  {notifErrors.rideAccepted && <p className="text-xs text-danger">{notifErrors.rideAccepted}</p>}
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-text-muted">Surge Pricing Alert (Rider)</label>
                  <Input
                    value={notifTemplates.surgePricing}
                    onChange={(e) => { setNotifTemplates(p => ({ ...p, surgePricing: e.target.value })); setNotifErrors(p => ({ ...p, surgePricing: '' })); }}
                    className={notifErrors.surgePricing ? 'border-danger' : ''}
                  />
                  {notifErrors.surgePricing && <p className="text-xs text-danger">{notifErrors.surgePricing}</p>}
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-text-muted">Payout Processed (Driver)</label>
                  <Input
                    value={notifTemplates.payout}
                    onChange={(e) => { setNotifTemplates(p => ({ ...p, payout: e.target.value })); setNotifErrors(p => ({ ...p, payout: '' })); }}
                    className={notifErrors.payout ? 'border-danger' : ''}
                  />
                  {notifErrors.payout && <p className="text-xs text-danger">{notifErrors.payout}</p>}
                </div>
                <Button onClick={handleSaveNotif}>Save Templates</Button>
              </div>
            </TabsContent>

            <TabsContent value="system" className="p-6 m-0 space-y-6">
              <div className="flex justify-between items-center">
                <h3 className="text-lg font-medium">System Configuration</h3>
                <SaveBanner show={systemSaved} />
              </div>

              <div className="space-y-6 max-w-2xl">
                <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-4">
                  <h4 className="font-medium">Payment Gateways</h4>
                  <div className="space-y-2">
                    <label className="text-sm text-text-muted">GCash API Key</label>
                    <Input type="password" defaultValue="************************" />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm text-text-muted">PayMaya API Key</label>
                    <Input type="password" defaultValue="************************" />
                  </div>
                </div>

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
