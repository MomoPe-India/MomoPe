'use client'

import { useCallback, useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Users, Search, RefreshCw, Coins } from 'lucide-react'
import { format } from 'date-fns'

type User = {
    id: string
    email: string
    full_name: string | null
    referral_code: string | null
    referred_by: string | null
    created_at: string
    coin_balance: number
}

export default function UsersPage() {
    const [users, setUsers] = useState<User[]>([])
    const [search, setSearch] = useState('')
    const [loading, setLoading] = useState(true)

    const load = useCallback(async () => {
        setLoading(true)
        const supabase = createClient()
        const { data } = await supabase
            .from('users')
            .select('id, email, full_name, referral_code, referred_by, created_at')
            .order('created_at', { ascending: false })
            .limit(200)

        if (!data) { setLoading(false); return }

        // Fetch coin balances for all users
        const ids = data.map(u => u.id)
        const { data: balances } = await supabase
            .from('coin_balances')
            .select('user_id, balance')
            .in('user_id', ids)

        const balanceMap = Object.fromEntries(
            (balances ?? []).map((b: { user_id: string; balance: number }) => [b.user_id, b.balance])
        )

        setUsers(data.map(u => ({ ...u, coin_balance: balanceMap[u.id] ?? 0 })))
        setLoading(false)
    }, [])

    useEffect(() => { load() }, [load])

    const filtered = users.filter(u => {
        const s = search.toLowerCase()
        return (
            (u.email ?? '').toLowerCase().includes(s) ||
            (u.full_name ?? '').toLowerCase().includes(s) ||
            (u.referral_code ?? '').toLowerCase().includes(s)
        )
    })

    return (
        <div className="space-y-5">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-xl font-bold text-white">Users</h1>
                    <p className="text-sm text-slate-500 mt-0.5">All registered customer accounts</p>
                </div>
                <button onClick={load} className="p-2 rounded-lg bg-white/[0.05] hover:bg-white/[0.09] text-slate-400 transition-colors">
                    <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                </button>
            </div>

            {/* Search */}
            <div className="relative max-w-md">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
                <input
                    value={search}
                    onChange={e => setSearch(e.target.value)}
                    placeholder="Search by email, name or referral code…"
                    className="w-full pl-9 pr-4 py-2.5 rounded-xl bg-white/[0.05] border border-white/[0.08] text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-1 focus:ring-[#00C4A7]/50"
                />
            </div>

            {/* Stats bar */}
            <div className="flex items-center gap-2 text-xs text-slate-500">
                <Users className="w-3.5 h-3.5" />
                <span>{filtered.length} of {users.length} users</span>
            </div>

            {/* Table */}
            <div className="bg-[#111827] border border-white/[0.07] rounded-2xl overflow-auto">
                <table className="w-full text-sm min-w-[760px]">
                    <thead>
                        <tr className="border-b border-white/[0.06] text-xs text-slate-500 uppercase tracking-wide">
                            <th className="text-left px-5 py-3 font-medium">User</th>
                            <th className="text-left px-5 py-3 font-medium">Referral Code</th>
                            <th className="text-left px-5 py-3 font-medium">Referred By</th>
                            <th className="text-left px-5 py-3 font-medium">Coin Balance</th>
                            <th className="text-left px-5 py-3 font-medium">Joined</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-white/[0.04]">
                        {loading ? (
                            <tr><td colSpan={5} className="py-16 text-center text-slate-500">Loading…</td></tr>
                        ) : filtered.length === 0 ? (
                            <tr><td colSpan={5} className="py-16 text-center text-slate-500">No users found</td></tr>
                        ) : filtered.map(u => (
                            <tr key={u.id} className="hover:bg-white/[0.02] transition-colors">
                                <td className="px-5 py-3.5">
                                    <div className="flex items-center gap-3">
                                        <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#00C4A7]/20 to-[#00C4A7]/5 flex items-center justify-center border border-[#00C4A7]/20">
                                            <span className="text-[#00C4A7] text-xs font-bold">
                                                {(u.full_name ?? u.email ?? '?')[0].toUpperCase()}
                                            </span>
                                        </div>
                                        <div>
                                            <p className="text-white font-medium text-sm">{u.full_name ?? '—'}</p>
                                            <p className="text-slate-500 text-xs">{u.email}</p>
                                        </div>
                                    </div>
                                </td>
                                <td className="px-5 py-3.5">
                                    {u.referral_code ? (
                                        <span className="font-mono text-xs bg-white/[0.06] px-2 py-1 rounded-lg text-[#00C4A7]">
                                            {u.referral_code}
                                        </span>
                                    ) : '—'}
                                </td>
                                <td className="px-5 py-3.5 text-slate-400 text-xs font-mono">
                                    {u.referred_by ? u.referred_by.slice(0, 8) + '…' : '—'}
                                </td>
                                <td className="px-5 py-3.5">
                                    <div className="flex items-center gap-1.5">
                                        <Coins className="w-3.5 h-3.5 text-amber-400" />
                                        <span className="text-amber-400 font-semibold">{u.coin_balance.toLocaleString()}</span>
                                    </div>
                                </td>
                                <td className="px-5 py-3.5 text-slate-500 text-xs">
                                    {format(new Date(u.created_at), 'dd MMM yyyy')}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    )
}
