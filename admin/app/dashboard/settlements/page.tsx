import { createClient } from '@/lib/supabase/server'
import {
    Clock, CheckCircle, Banknote, Store,
} from 'lucide-react'
import { format } from 'date-fns'
import SettlementActions from './SettlementActions'

export const revalidate = 60

type Settlement = {
    id: string
    merchant_id: string
    amount: number
    status: string
    requested_at: string
    processed_at: string | null
    merchants: { business_name: string } | { business_name: string }[] | null
}

function getMerchantName(m: Settlement['merchants']): string {
    if (!m) return 'Unknown Merchant'
    return Array.isArray(m) ? (m[0]?.business_name ?? 'Unknown') : m.business_name
}

const STATUS_STYLES: Record<string, string> = {
    pending: 'bg-amber-500/10 text-amber-400',
    settled: 'bg-emerald-500/10 text-emerald-400',
    rejected: 'bg-red-500/10 text-red-400',
}

export default async function SettlementsPage() {
    const supabase = await createClient()

    const { data: settlements } = await supabase
        .from('settlements')
        .select('id, merchant_id, amount, status, requested_at, processed_at, merchants(business_name)')
        .order('requested_at', { ascending: false })
        .limit(100)

    const pendingCount = (settlements ?? []).filter((s: Settlement) => s.status === 'pending').length
    const totalSettled = (settlements ?? [])
        .filter((s: Settlement) => s.status === 'settled')
        .reduce((sum: number, s: Settlement) => sum + (s.amount ?? 0), 0)

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-xl font-bold text-white">Settlements</h1>
                    <p className="text-sm text-slate-500 mt-0.5">Manage merchant settlement requests</p>
                </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-4">
                <div className="bg-[#111827] border border-white/[0.07] rounded-2xl p-5">
                    <div className="w-9 h-9 rounded-xl bg-amber-500/10 flex items-center justify-center mb-3">
                        <Clock className="w-4 h-4 text-amber-400" />
                    </div>
                    <p className="text-2xl font-bold text-amber-400">{pendingCount}</p>
                    <p className="text-xs text-slate-500 mt-1">Pending Requests</p>
                </div>
                <div className="bg-[#111827] border border-white/[0.07] rounded-2xl p-5">
                    <div className="w-9 h-9 rounded-xl bg-emerald-500/10 flex items-center justify-center mb-3">
                        <CheckCircle className="w-4 h-4 text-emerald-400" />
                    </div>
                    <p className="text-2xl font-bold text-emerald-400">
                        ₹{totalSettled.toLocaleString()}
                    </p>
                    <p className="text-xs text-slate-500 mt-1">Total Settled</p>
                </div>
                <div className="bg-[#111827] border border-white/[0.07] rounded-2xl p-5">
                    <div className="w-9 h-9 rounded-xl bg-blue-500/10 flex items-center justify-center mb-3">
                        <Store className="w-4 h-4 text-blue-400" />
                    </div>
                    <p className="text-2xl font-bold text-blue-400">{(settlements ?? []).length}</p>
                    <p className="text-xs text-slate-500 mt-1">Total Requests</p>
                </div>
            </div>

            {/* Table */}
            <div className="bg-[#111827] border border-white/[0.07] rounded-2xl overflow-hidden">
                <div className="px-5 py-4 border-b border-white/[0.06] flex items-center gap-3">
                    <Banknote className="w-4 h-4 text-[#00C4A7]" />
                    <h2 className="text-sm font-semibold text-white">Settlement Requests</h2>
                </div>

                {!settlements || settlements.length === 0 ? (
                    <div className="py-20 text-center text-slate-500 text-sm">No settlement requests yet</div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm">
                            <thead>
                                <tr className="border-b border-white/[0.06]">
                                    {['Merchant', 'Amount', 'Status', 'Requested', 'Processed', 'Actions'].map(h => (
                                        <th key={h} className="px-4 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wide">
                                            {h}
                                        </th>
                                    ))}
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-white/[0.04]">
                                {(settlements as Settlement[]).map((s) => (
                                    <tr key={s.id} className="hover:bg-white/[0.02] transition-colors">
                                        <td className="px-4 py-3 text-white font-medium">
                                            {getMerchantName(s.merchants)}
                                        </td>
                                        <td className="px-4 py-3 text-white font-semibold">
                                            ₹{Number(s.amount).toLocaleString()}
                                        </td>
                                        <td className="px-4 py-3">
                                            <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${STATUS_STYLES[s.status] ?? 'bg-slate-500/10 text-slate-400'}`}>
                                                {s.status}
                                            </span>
                                        </td>
                                        <td className="px-4 py-3 text-slate-400 text-xs">
                                            {format(new Date(s.requested_at), 'dd MMM yyyy, HH:mm')}
                                        </td>
                                        <td className="px-4 py-3 text-slate-400 text-xs">
                                            {s.processed_at
                                                ? format(new Date(s.processed_at), 'dd MMM yyyy, HH:mm')
                                                : '—'}
                                        </td>
                                        <td className="px-4 py-3">
                                            {s.status === 'pending' && (
                                                <SettlementActions settlementId={s.id} />
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
        </div>
    )
}
