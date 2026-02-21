import { createClient } from '@/lib/supabase/server'
import StatsCard from '@/components/StatsCard'
import OverviewCharts from '@/components/OverviewCharts'
import {
    Users, Store, ArrowLeftRight, Coins,
    TrendingUp, AlertCircle,
} from 'lucide-react'
import { format, subDays, startOfDay } from 'date-fns'

export const revalidate = 60

type RecentTxn = {
    id: string
    amount: number
    status: string
    created_at: string
    merchant_id: string
    merchants: { business_name: string } | { business_name: string }[] | null
}

function getMerchantName(m: RecentTxn['merchants']): string {
    if (!m) return 'Unknown Merchant'
    return Array.isArray(m) ? (m[0]?.business_name ?? 'Unknown') : m.business_name
}

const STATUS_COLORS: Record<string, string> = {
    success: 'bg-emerald-500/10 text-emerald-400',
    pending: 'bg-amber-500/10 text-amber-400',
    failed: 'bg-red-500/10 text-red-400',
}

// Build 7-day buckets for charts
function buildChartData(
    transactions: { amount: number; created_at: string; status: string }[],
    coinEarnHistory: { coins_earned: number; created_at: string }[]
) {
    const days = Array.from({ length: 7 }, (_, i) => {
        const d = subDays(new Date(), 6 - i)
        return { date: format(d, 'EEE'), day: startOfDay(d).toISOString().slice(0, 10) }
    })

    const volumeData = days.map(({ date, day }) => {
        const dayTxns = transactions.filter(
            t => t.status === 'success' && t.created_at.slice(0, 10) === day
        )
        return {
            date,
            amount: dayTxns.reduce((s, t) => s + Number(t.amount), 0),
            count: dayTxns.length,
        }
    })

    // Real coin issuance per day from coin_transactions
    const coinTrendData = days.map(({ date, day }) => ({
        date,
        coins: coinEarnHistory
            .filter(e => e.created_at.slice(0, 10) === day)
            .reduce((s, e) => s + (e.coins_earned ?? 0), 0),
    }))

    return { volumeData, coinTrendData }
}

export default async function DashboardPage() {
    const supabase = await createClient()

    const sevenDaysAgo = subDays(new Date(), 7).toISOString()

    const [
        { count: totalUsers },
        { count: totalMerchants },
        { count: pendingMerchants },
        { count: totalTxns },
        { data: recentTxns },
        { data: coinStats },
        { data: weekTxns },
        { data: coinEarnHistory },
    ] = await Promise.all([
        supabase.from('users').select('*', { count: 'exact', head: true }),
        supabase.from('merchants').select('*', { count: 'exact', head: true }),
        supabase.from('merchants').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
        supabase.from('transactions').select('*', { count: 'exact', head: true }),
        supabase
            .from('transactions')
            .select('id, amount, status, created_at, merchant_id, merchants(business_name)')
            .order('created_at', { ascending: false })
            .limit(8),
        // ✅ FIX: Query correct table 'momo_coin_balances' with column 'available_coins'
        supabase.from('momo_coin_balances').select('available_coins').limit(1000),
        supabase
            .from('transactions')
            .select('amount, created_at, status')
            .gte('created_at', sevenDaysAgo),
        // ✅ FIX: Real coin issuance data from coin_transactions instead of fake approximation
        supabase
            .from('coin_transactions')
            .select('coins_earned, created_at')
            .eq('type', 'earn')
            .gte('created_at', sevenDaysAgo),
    ])

    const totalCoins = (coinStats ?? []).reduce(
        (sum: number, row: { available_coins: number }) => sum + (row.available_coins ?? 0), 0
    )

    const { volumeData, coinTrendData } = buildChartData(
        (weekTxns ?? []) as { amount: number; created_at: string; status: string }[],
        (coinEarnHistory ?? []) as { coins_earned: number; created_at: string }[]
    )

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-xl font-bold text-white">Overview</h1>
                <p className="text-sm text-slate-500 mt-0.5">Platform health at a glance</p>
            </div>

            {/* Stats grid */}
            <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
                <StatsCard title="Total Users" value={(totalUsers ?? 0).toLocaleString()} icon={Users} accent="teal" />
                <StatsCard
                    title="Total Merchants"
                    value={(totalMerchants ?? 0).toLocaleString()}
                    subtitle={(pendingMerchants ?? 0) > 0 ? `${pendingMerchants} pending approval` : undefined}
                    icon={Store}
                    accent="blue"
                />
                <StatsCard title="Total Transactions" value={(totalTxns ?? 0).toLocaleString()} icon={ArrowLeftRight} accent="purple" />
                <StatsCard title="Coins in Circulation" value={totalCoins.toLocaleString()} icon={Coins} accent="amber" />
            </div>

            {/* Analytics charts — client component */}
            <OverviewCharts volumeData={volumeData} coinTrendData={coinTrendData} />

            {/* Recent transactions */}
            <div className="bg-[#111827] border border-white/[0.07] rounded-2xl overflow-hidden">
                <div className="flex items-center justify-between px-5 py-4 border-b border-white/[0.06]">
                    <h2 className="text-sm font-semibold text-white">Recent Transactions</h2>
                    <a href="/dashboard/transactions" className="text-xs text-[#00C4A7] hover:underline">View all →</a>
                </div>
                {!recentTxns || recentTxns.length === 0 ? (
                    <div className="py-16 text-center text-slate-500 text-sm">No transactions yet</div>
                ) : (
                    <div className="divide-y divide-white/[0.04]">
                        {(recentTxns as RecentTxn[]).map((txn) => (
                            <div key={txn.id} className="flex items-center justify-between px-5 py-3 hover:bg-white/[0.02] transition-colors">
                                <div className="flex items-center gap-3">
                                    <div className="w-8 h-8 rounded-lg bg-white/[0.05] flex items-center justify-center">
                                        <ArrowLeftRight className="w-3.5 h-3.5 text-slate-400" />
                                    </div>
                                    <div>
                                        <p className="text-sm text-white font-medium">{getMerchantName(txn.merchants)}</p>
                                        <p className="text-xs text-slate-500 font-mono">{txn.id.slice(0, 8)}…</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-4">
                                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${STATUS_COLORS[txn.status] ?? 'bg-slate-500/10 text-slate-400'}`}>
                                        {txn.status}
                                    </span>
                                    <span className="text-sm font-semibold text-white">₹{Number(txn.amount).toFixed(0)}</span>
                                    <span className="text-xs text-slate-500 w-28 text-right">
                                        {format(new Date(txn.created_at), 'dd MMM, HH:mm')}
                                    </span>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            {/* Quick links */}
            <div className="grid grid-cols-2 gap-4">
                <a href="/dashboard/merchants"
                    className="bg-[#111827] border border-white/[0.07] rounded-2xl p-5 hover:border-[#00C4A7]/30 transition-all group">
                    <div className="flex items-center gap-3 mb-3">
                        <div className="w-9 h-9 rounded-xl bg-amber-500/10 flex items-center justify-center">
                            <AlertCircle className="w-4 h-4 text-amber-400" />
                        </div>
                        <span className="text-sm font-semibold text-white">Pending Approvals</span>
                    </div>
                    <p className="text-3xl font-bold text-amber-400">{pendingMerchants ?? 0}</p>
                    <p className="text-xs text-slate-500 mt-1">merchants awaiting review</p>
                </a>
                <a href="/dashboard/treasury"
                    className="bg-[#111827] border border-white/[0.07] rounded-2xl p-5 hover:border-[#00C4A7]/30 transition-all group">
                    <div className="flex items-center gap-3 mb-3">
                        <div className="w-9 h-9 rounded-xl bg-[#00C4A7]/10 flex items-center justify-center">
                            <TrendingUp className="w-4 h-4 text-[#00C4A7]" />
                        </div>
                        <span className="text-sm font-semibold text-white">Coin Treasury</span>
                    </div>
                    <p className="text-3xl font-bold text-[#00C4A7]">{totalCoins.toLocaleString()}</p>
                    <p className="text-xs text-slate-500 mt-1">MomoCoins in active circulation</p>
                </a>
            </div>
        </div>
    )
}
