'use client'

import { useCallback, useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Store, CheckCircle, Clock, XCircle, Search, RefreshCw } from 'lucide-react'
import { format } from 'date-fns'

type Merchant = {
    id: string
    user_id: string
    business_name: string
    business_type: string
    upi_id: string
    status: 'pending' | 'active' | 'suspended'
    created_at: string
}

const STATUS_CONFIG = {
    active: { icon: CheckCircle, label: 'Active', cls: 'bg-emerald-500/10 text-emerald-400' },
    pending: { icon: Clock, label: 'Pending', cls: 'bg-amber-500/10 text-amber-400' },
    suspended: { icon: XCircle, label: 'Suspended', cls: 'bg-red-500/10 text-red-400' },
}

export default function MerchantsPage() {
    const [merchants, setMerchants] = useState<Merchant[]>([])
    const [filter, setFilter] = useState<'all' | 'pending' | 'active' | 'suspended'>('all')
    const [search, setSearch] = useState('')
    const [loading, setLoading] = useState(true)
    const [actionLoading, setActionLoading] = useState<string | null>(null)

    const load = useCallback(async () => {
        setLoading(true)
        const supabase = createClient()
        let query = supabase
            .from('merchants')
            .select('id, user_id, business_name, business_type, upi_id, status, created_at')
            .order('created_at', { ascending: false })

        if (filter !== 'all') query = query.eq('status', filter)
        const { data } = await query
        setMerchants(data ?? [])
        setLoading(false)
    }, [filter])

    useEffect(() => { load() }, [load])

    const updateStatus = async (id: string, status: 'active' | 'suspended') => {
        setActionLoading(id)
        const supabase = createClient()
        await supabase.from('merchants').update({ status }).eq('id', id)
        await load()
        setActionLoading(null)
    }

    const filtered = merchants.filter(m =>
        m.business_name.toLowerCase().includes(search.toLowerCase()) ||
        m.upi_id.toLowerCase().includes(search.toLowerCase())
    )

    return (
        <div className="space-y-5">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-xl font-bold text-white">Merchants</h1>
                    <p className="text-sm text-slate-500 mt-0.5">Manage and approve merchant accounts</p>
                </div>
                <button onClick={load} className="p-2 rounded-lg bg-white/[0.05] hover:bg-white/[0.09] text-slate-400 transition-colors">
                    <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                </button>
            </div>

            {/* Filters + Search */}
            <div className="flex items-center gap-3 flex-wrap">
                <div className="relative flex-1 min-w-[200px]">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
                    <input
                        value={search}
                        onChange={e => setSearch(e.target.value)}
                        placeholder="Search by name or UPI…"
                        className="w-full pl-9 pr-4 py-2.5 rounded-xl bg-white/[0.05] border border-white/[0.08] text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-1 focus:ring-[#00C4A7]/50"
                    />
                </div>
                {(['all', 'pending', 'active', 'suspended'] as const).map(f => (
                    <button
                        key={f}
                        onClick={() => setFilter(f)}
                        className={`px-3 py-2 rounded-xl text-sm font-medium capitalize transition-all ${filter === f
                                ? 'bg-[#00C4A7]/15 text-[#00C4A7] border border-[#00C4A7]/30'
                                : 'bg-white/[0.04] text-slate-400 border border-white/[0.06] hover:border-white/[0.12]'
                            }`}
                    >
                        {f}
                    </button>
                ))}
            </div>

            {/* Table */}
            <div className="bg-[#111827] border border-white/[0.07] rounded-2xl overflow-auto">
                <table className="w-full text-sm">
                    <thead>
                        <tr className="border-b border-white/[0.06] text-xs text-slate-500 uppercase tracking-wide">
                            <th className="text-left px-5 py-3 font-medium">Business</th>
                            <th className="text-left px-5 py-3 font-medium">UPI ID</th>
                            <th className="text-left px-5 py-3 font-medium">Type</th>
                            <th className="text-left px-5 py-3 font-medium">Status</th>
                            <th className="text-left px-5 py-3 font-medium">Joined</th>
                            <th className="text-right px-5 py-3 font-medium">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-white/[0.04]">
                        {loading ? (
                            <tr><td colSpan={6} className="py-16 text-center text-slate-500">Loading…</td></tr>
                        ) : filtered.length === 0 ? (
                            <tr><td colSpan={6} className="py-16 text-center text-slate-500">No merchants found</td></tr>
                        ) : filtered.map(m => {
                            const sc = STATUS_CONFIG[m.status] ?? STATUS_CONFIG.pending
                            const Icon = sc.icon
                            const isActing = actionLoading === m.id
                            return (
                                <tr key={m.id} className="hover:bg-white/[0.02] transition-colors">
                                    <td className="px-5 py-3.5">
                                        <div className="flex items-center gap-3">
                                            <div className="w-8 h-8 rounded-lg bg-white/[0.06] flex items-center justify-center shrink-0">
                                                <Store className="w-3.5 h-3.5 text-slate-400" />
                                            </div>
                                            <span className="font-medium text-white">{m.business_name}</span>
                                        </div>
                                    </td>
                                    <td className="px-5 py-3.5 text-slate-400 font-mono text-xs">{m.upi_id}</td>
                                    <td className="px-5 py-3.5 text-slate-400 capitalize">{m.business_type}</td>
                                    <td className="px-5 py-3.5">
                                        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${sc.cls}`}>
                                            <Icon className="w-3 h-3" />
                                            {sc.label}
                                        </span>
                                    </td>
                                    <td className="px-5 py-3.5 text-slate-500 text-xs">
                                        {format(new Date(m.created_at), 'dd MMM yyyy')}
                                    </td>
                                    <td className="px-5 py-3.5 text-right">
                                        <div className="flex items-center justify-end gap-2">
                                            {m.status !== 'active' && (
                                                <button
                                                    onClick={() => updateStatus(m.id, 'active')}
                                                    disabled={isActing}
                                                    className="px-3 py-1.5 rounded-lg bg-emerald-500/10 text-emerald-400 text-xs font-medium hover:bg-emerald-500/20 transition-colors disabled:opacity-50"
                                                >
                                                    {isActing ? '…' : 'Approve'}
                                                </button>
                                            )}
                                            {m.status !== 'suspended' && (
                                                <button
                                                    onClick={() => updateStatus(m.id, 'suspended')}
                                                    disabled={isActing}
                                                    className="px-3 py-1.5 rounded-lg bg-red-500/10 text-red-400 text-xs font-medium hover:bg-red-500/20 transition-colors disabled:opacity-50"
                                                >
                                                    {isActing ? '…' : 'Suspend'}
                                                </button>
                                            )}
                                        </div>
                                    </td>
                                </tr>
                            )
                        })}
                    </tbody>
                </table>
            </div>
        </div>
    )
}
