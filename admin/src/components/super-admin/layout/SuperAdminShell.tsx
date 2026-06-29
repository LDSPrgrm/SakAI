import React, { useState } from 'react';
import { Outlet } from 'react-router-dom';
import { AppSidebar } from '@/components/layout/AppSidebar';
import { Header } from '@/components/Header';
import { ErrorBoundary } from '@/components/ErrorBoundary';
import { RoleAccentProvider } from '@/contexts/RoleAccentContext';
import { superAdminNavSections } from '@/nav/super-admin';

export function SuperAdminShell() {
    const [sidebarOpen, setSidebarOpen] = useState(false);

    return (
        <RoleAccentProvider role="super-admin">
            <div className="flex h-screen overflow-hidden bg-background">
                {sidebarOpen && (
                    <div
                        className="fixed inset-0 z-30 bg-black/60 md:hidden"
                        onClick={() => setSidebarOpen(false)}
                    />
                )}

                <AppSidebar
                    isOpen={sidebarOpen}
                    onClose={() => setSidebarOpen(false)}
                    sections={superAdminNavSections}
                    brandLabel="SakAI Super"
                    defaultUserInitial="S"
                    defaultUserName="Super Admin"
                    defaultUserRole="superadmin"
                />

                <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
                    <Header onMenuToggle={() => setSidebarOpen(true)} />
                    <main className="flex-1 overflow-y-auto p-4 md:p-6">
                        <ErrorBoundary>
                            <Outlet />
                        </ErrorBoundary>
                    </main>
                </div>
            </div>
        </RoleAccentProvider>
    );
}
