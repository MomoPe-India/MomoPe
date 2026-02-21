'use client'

import { useCallback, useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { ArrowLeftRight, RefreshCw, Search, Download } from 'lucide-react'
import { format } from 'date-fns'

type Transaction = {
    id: string
    amount: number
    fiat_amount: number
    coins_redeemed: number
    status: string
    created_at: string
    payu_txn_id: string | null
    merchants: { business_name: string } | { business_name: string }[] | null
    users: { email: string } | { email: string }[] | null
}

function getMerchantName(m: Transaction['merchants']): string {
    if (!m) return '—'
    return Array.isArray(m) ? (m[0]?.business_name ?? '—') : m.business_name
}

function getUserEmail(u: Transaction['users']): string {
    if (!u) return '—'
    return Array.isArray(u) ? (u[0]?.email ?? '—') : u.email
}

const STATUS_COLORS: Record<string, string> = {
    success: 'bg-emerald-500/10 text-emerald-400',
    pending: 'bg-amber-500/10 text-amber-400',
    failed: 'bg-red-500/10 text-red-400',
}

const STATUS_FILTERS = ['all', 'success', 'pending', 'failed']

export default function TransactionsPage() {
    const [txns, setTxns] = useState<Transaction[]>([])
    const [filter, setFilter] = useState('all')
    const [search, setSearch] = useState('')
    const [loading, setLoading] = useState(true)

    const load = useCallback(async () => {
        setLoading(true)
        const supabase = createClient()
        let query = supabase
            .from('transactions')
            .select(`
        id, amount, fiat_amount, coins_redeemed, status, created_at, payu_txn_id,
        merchants ( business_name ),
        users ( email )
      `)
            .order('created_at', { ascending: false })
            .limit(100)

        if (filter !== 'all') query = query.eq('status', filter)
        const { data } = await query
        setTxns((data as unknown as Transaction[]) ?? [])
        setLoading(false)
    }, [filter])

    useEffect(() => { load() }, [load])

    const filtered = txns.filter(t => {
        const s = search.toLowerCase()
        return (
            t.id.toLowerCase().includes(s) ||
            getMerchantName(t.merchants).toLowerCase().includes(s) ||
            getUserEmail(t.users).toLowerCase().includes(s) ||
            (t.payu_txn_id ?? '').toLowerCase().includes(s)
        )
    })

    const exportToCsv = () => {
        const headers = ['ID', 'Merchant', 'User Email', 'Amount (₹)', 'Fiat Amount (₹)', 'Coins Redeemed', 'Status', 'PayU Txn ID', 'Date']
        const rows = filtered.map(t => [
            t.id,
            getMerchantName(t.merchants),
            getUserEmail(t.users),
            Number(t.amount).toFixed(2),
            Number(t.fiat_amount ?? t.amount).toFixed(2),
            t.coins_redeemed ?? 0,
            t.status,
            t.payu_txn_id ?? '',
            format(new Date(t.created_at), 'yyyy-MM-dd HH:mm:ss'),
        ])
        const csv = [headers, ...rows].map(r => r.map(v => `"${String(v).replace(/"/g, '""')}"`).join(',')).join('\n')
        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
        const url = URL.createObjectURL(blob)
        const link = document.createElement('a')
        link.href = url
        link.download = `momope-transactions-${format(new Date(), 'yyyy-MM-dd')}.csv`
        link.click()
        URL.revokeObjectURL(url)
    }

    return (
        <div className="space-y-5">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-xl font-bold text-white">Transactions</h1>
                    <p className="text-sm text-slate-500 mt-0.5">Live payment feed — last 100</p>
                </div>
                <div className="flex items-center gap-2">
                    <button
                        onClick={exportToCsv}
                        disabled={loading || filtered.length === 0}
                        title="Export to CSV"
                        className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-[#00C4A7]/10 text-[#00C4A7] text-sm font-medium hover:bg-[#00C4A7]/20 transition-colors disabled:opacity-40"
                    >
                        <Download className="w-3.5 h-3.5" />
                        Export CSV
                    </button>
                    <button onClick={load} className="p-2 rounded-lg bg-white/[0.05] hover:bg-white/[0.09] text-slate-400 transition-colors">
                        <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                    </button>
                </div>
            </div>

            {/* Filters + Search */}
            <div className="flex items-center gap-3 flex-wrap">
                <div className="relative flex-1 min-w-[200px]">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
                    <input
                        value={search}
                        onChange={e => setSearch(e.target.value)}
                        placeholder="Search by ID, merchant, user, or PayU txn…"
                        className="w-full pl-9 pr-4 py-2.5 rounded-xl bg-white/[0.05] border border-white/[0.08] text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-1 focus:ring-[#00C4A7]/50"
                    />
                </div>
                {STATUS_FILTERS.map(f => (
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
                <table className="w-full text-sm min-w-[800px]">
                    <thead>
                        <tr className="border-b border-white/[0.06] text-xs text-slate-500 uppercase tracking-wide">
                            <th className="text-left px-5 py-3 font-medium">ID</th>
                            <th className="text-left px-5 py-3 font-medium">Merchant</th>
                            <th className="text-left px-5 py-3 font-medium">User</th>
                            <th className="text-left px-5 py-3 font-medium">Amount</th>
                            <th className="text-left px-5 py-3 font-medium">Coins Used</th>
                            <th className="text-left px-5 py-3 font-medium">Status</th>
                            <th className="text-left px-5 py-3 font-medium">Date</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-white/[0.04]">
                        {loading ? (
                            <tr><td colSpan={7} className="py-16 text-center text-slate-500">Loading…</td></tr>
                        ) : filtered.length === 0 ? (
                            <tr><td colSpan={7} className="py-16 text-center text-slate-500">No transactions found</td></tr>
                        ) : filtered.map(t => (
                            <tr key={t.id} className="hover:bg-white/[0.02] transition-colors">
                                <td className="px-5 py-3.5">
                                    <div className="flex items-center gap-2">
                                        <div className="w-7 h-7 rounded-lg bg-white/[0.05] flex items-center justify-center">
                                            <ArrowLeftRight className="w-3 h-3 text-slate-500" />
                                        </div>
                                        <span className="font-mono text-xs text-slate-400">{t.id.slice(0, 8)}…</span>
                                    </div>
                                </td>
                                <td className="px-5 py-3.5 text-white font-medium">{getMerchantName(t.merchants)}</td>
                                <td className="px-5 py-3.5 text-slate-400 text-xs">{getUserEmail(t.users)}</td>
                                <td className="px-5 py-3.5">
                                    <div>
                                        <span className="text-white font-semibold">₹{Number(t.amount).toFixed(0)}</span>
                                        {t.fiat_amount !== t.amount && (
                                            <span className="text-xs text-slate-500 ml-1">(₹{Number(t.fiat_amount).toFixed(0)} cash)</span>
                                        )}
                                    </div>
                                </td>
                                <td className="px-5 py-3.5 text-[#00C4A7] font-medium">
                                    {t.coins_redeemed ? `${t.coins_redeemed} 🪙` : '—'}
                                </td>
                                <td className="px-5 py-3.5">
                                    <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${STATUS_COLORS[t.status] ?? 'bg-slate-500/10 text-slate-400'}`}>
                                        {t.status}
                                    </span>
                                </td>
                                <td className="px-5 py-3.5 text-slate-500 text-xs">
                                    {format(new Date(t.created_at), 'dd MMM, HH:mm')}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    )
}
