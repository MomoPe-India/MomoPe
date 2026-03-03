// src/app/dashboard/layout.tsx
// Shared dashboard shell: sidebar nav + top bar with sign-out.

import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { SidebarNav } from '@/components/sidebar-nav';

export const metadata = { title: 'MomoPe Admin' };

async function getAdminName(): Promise<string> {
    const cookieStore = await cookies();
    const token = cookieStore.get(process.env.AUTH_COOKIE_NAME ?? 'momope_admin_session')?.value;
    if (!token) redirect('/login');
    return 'Admin';
}

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
    await getAdminName();

    return (
        <div className="min-h-screen bg-gray-950 flex">
            <SidebarNav />
            <main className="flex-1 p-8 overflow-auto">
                {children}
            </main>
        </div>
    );
}
