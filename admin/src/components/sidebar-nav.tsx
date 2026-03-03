'use client';
// src/components/sidebar-nav.tsx

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';

const NAV = [
    { href: '/dashboard', label: 'Dashboard', icon: '📊' },
    { href: '/dashboard/merchants', label: 'Merchants', icon: '🏪' },
    { href: '/dashboard/users', label: 'Users', icon: '👥' },
    { href: '/dashboard/coins', label: 'Coins', icon: '🪙' },
    { href: '/dashboard/settlements', label: 'Settlements', icon: '💰' },
];

export function SidebarNav() {
    const pathname = usePathname();
    const router = useRouter();

    async function signOut() {
        await fetch('/api/auth/login', { method: 'DELETE' });
        router.refresh(); // Clear any cached layout state
        router.push('/login');
    }

    return (
        <aside className="w-60 bg-gray-900 border-r border-gray-800 flex flex-col min-h-screen">
            {/* Logo */}
            <div className="flex items-center gap-3 px-6 py-6 border-b border-gray-800">
                <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-500 to-purple-700 flex items-center justify-center text-white font-bold text-sm">M</div>
                <span className="text-white font-bold">MomoPe Admin</span>
            </div>

            {/* Nav */}
            <nav className="flex-1 px-3 py-4 space-y-1">
                {NAV.map(({ href, label, icon }) => {
                    const active = pathname === href || (href !== '/dashboard' && pathname.startsWith(href));
                    return (
                        <Link key={href} href={href}
                            className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors ${active
                                ? 'bg-purple-600/20 text-purple-300'
                                : 'text-gray-400 hover:text-white hover:bg-gray-800'
                                }`}>
                            <span className="text-base">{icon}</span>
                            {label}
                        </Link>
                    );
                })}
            </nav>

            {/* Sign out */}
            <div className="px-3 py-4 border-t border-gray-800">
                <button onClick={signOut}
                    className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm text-gray-400 hover:text-white hover:bg-gray-800 transition-colors">
                    <span>🚪</span> Sign out
                </button>
            </div>
        </aside>
    );
}
