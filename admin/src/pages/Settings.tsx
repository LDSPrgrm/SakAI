import React from 'react';
import { Card, CardContent } from '@/components/ui/Card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { AdminsTab } from '@/pages/settings/AdminsTab';
import { NotificationsTab } from '@/pages/settings/NotificationsTab';
import { SystemConfigTab } from '@/pages/settings/SystemConfigTab';

export function Settings() {
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
              <AdminsTab />
            </TabsContent>

            <TabsContent value="notifications" className="p-6 m-0">
              <NotificationsTab />
            </TabsContent>

            <TabsContent value="system" className="p-6 m-0">
              <SystemConfigTab />
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  );
}
