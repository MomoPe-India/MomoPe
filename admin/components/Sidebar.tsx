'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import {
    LayoutDashboard,
    Store,
    ArrowLeftRight,
    Users,
    Coins,
    LogOut,
    ShieldCheck,
    Banknote,
} from 'lucide-react'

const NAV_ITEMS = [
    { href: '/dashboard', label: 'Overview', icon: LayoutDashboard, exact: true },
    { href: '/dashboard/merchants', label: 'Merchants', icon: Store },
    { href: '/dashboard/transactions', label: 'Transactions', icon: ArrowLeftRight },
    { href: '/dashboard/users', label: 'Users', icon: Users },
    { href: '/dashboard/treasury', label: 'Treasury', icon: Coins },
    { href: '/dashboard/settlements', label: 'Settlements', icon: Banknote },
]

export default function Sidebar() {
    const pathname = usePathname()
    const router = useRouter()

    const isActive = (href: string, exact?: boolean) =>
        exact ? pathname === href : pathname.startsWith(href)

    const handleSignOut = async () => {
        const supabase = createClient()
        await supabase.auth.signOut()
        router.push('/login')
    }

    return (
        <aside className="fixed left-0 top-0 h-full w-[240px] bg-[#0D1321] border-r border-white/[0.06] flex flex-col z-40">
            {/* Brand */}
            <div className="px-6 py-5 border-b border-white/[0.06]">
                <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#00C4A7] to-[#00E5CC] flex items-center justify-center shadow-md shadow-[#00C4A7]/20">
                        <ShieldCheck className="w-4 h-4 text-[#0B0F19]" />
                    </div>
                    <div>
                        <p className="text-sm font-bold text-white leading-none">MomoPe</p>
                        <p className="text-[10px] text-[#00C4A7] font-medium mt-0.5">Admin Console</p>
                    </div>
                </div>
            </div>

            {/* Navigation */}
            <nav className="flex-1 px-3 py-4 space-y-0.5 overflow-y-auto">
                {NAV_ITEMS.map(({ href, label, icon: Icon, exact }) => {
                    const active = isActive(href, exact)
                    return (
                        <Link
                            key={href}
                            href={href}
                            className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all group ${active
                                ? 'bg-[#00C4A7]/10 text-[#00C4A7]'
                                : 'text-slate-400 hover:bg-white/[0.04] hover:text-slate-200'
                                }`}
                        >
                            <Icon
                                className={`w-4 h-4 shrink-0 transition-colors ${active ? 'text-[#00C4A7]' : 'text-slate-500 group-hover:text-slate-300'
                                    }`}
                            />
                            {label}
                            {active && (
                                <span className="ml-auto w-1.5 h-1.5 rounded-full bg-[#00C4A7]" />
                            )}
                        </Link>
                    )
                })}
            </nav>

            {/* Sign out */}
            <div className="px-3 pb-4 border-t border-white/[0.06] pt-3">
                <button
                    onClick={handleSignOut}
                    className="flex items-center gap-3 w-full px-3 py-2.5 rounded-xl text-sm font-medium text-slate-400 hover:bg-red-500/10 hover:text-red-400 transition-all group"
                >
                    <LogOut className="w-4 h-4 shrink-0 text-slate-500 group-hover:text-red-400 transition-colors" />
                    Sign Out
                </button>
            </div>
        </aside>
    )
}
