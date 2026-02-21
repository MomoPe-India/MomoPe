import { createClient } from '@/lib/supabase/server'
import { Coins, TrendingUp, Clock, Users } from 'lucide-react'
import StatsCard from '@/components/StatsCard'
import CoinControls from './CoinControls'

export const revalidate = 60

type CoinBalance = { user_id: string; balance: number; updated_at: string }
type Referral = { id: string; status: string; created_at: string; referrer_id: string; referee_id: string }
type CoinTx = { id: string; amount: number; reason: string; created_at: string }

export default async function TreasuryPage() {
    const supabase = await createClient()

    const [
        { data: balances },
        { data: expiryData },
        { data: referrals },
        { data: recentMints },
    ] = await Promise.all([
        supabase.from('coin_balances').select('user_id, balance, updated_at').order('balance', { ascending: false }).limit(50),
        supabase.from('coin_balances').select('balance').limit(1000),
        supabase.from('referrals').select('id, status, created_at, referrer_id, referee_id').order('created_at', { ascending: false }).limit(20),
        supabase.from('coin_transactions').select('id, amount, reason, created_at').order('created_at', { ascending: false }).limit(20),
    ])

    const totalCoins = (expiryData ?? []).reduce((sum, r: { balance: number }) => sum + (r.balance ?? 0), 0)
    const holdersWithCoins = (expiryData ?? []).filter((r: { balance: number }) => r.balance > 0).length
    const pendingReferrals = (referrals ?? []).filter((r: Referral) => r.status === 'pending').length
    const completedReferrals = (referrals ?? []).filter((r: Referral) => r.status === 'completed').length

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-xl font-bold text-white">Treasury</h1>
                <p className="text-sm text-slate-500 mt-0.5">MomoCoin supply and referral system</p>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
                <StatsCard title="Total Coins in Circulation" value={totalCoins.toLocaleString()} icon={Coins} accent="amber" />
                <StatsCard title="Active Coin Holders" value={holdersWithCoins.toLocaleString()} icon={Users} accent="teal" />
                <StatsCard title="Pending Referrals" value={pendingReferrals} icon={Clock} accent="blue" subtitle="Awaiting qualifying payment" />
                <StatsCard title="Completed Referrals" value={completedReferrals} icon={TrendingUp} accent="purple" />
            </div>

            <div className="grid grid-cols-1 xl:grid-cols-2 gap-5">
                {/* Top coin holders */}
                <div className="bg-[#111827] border border-white/[0.07] rounded-2xl overflow-hidden">
                    <div className="px-5 py-4 border-b border-white/[0.06]">
                        <h2 className="text-sm font-semibold text-white">Top Coin Holders</h2>
                    </div>
                    <div className="divide-y divide-white/[0.04]">
                        {(balances ?? []).slice(0, 10).map((b: CoinBalance, i: number) => (
                            <div key={b.user_id} className="flex items-center justify-between px-5 py-3 hover:bg-white/[0.02] transition-colors">
                                <div className="flex items-center gap-3">
                                    <span className="w-6 text-xs text-slate-500 font-mono text-right shrink-0">#{i + 1}</span>
                                    <span className="text-slate-400 font-mono text-xs">{b.user_id.slice(0, 12)}…</span>
                                </div>
                                <div className="flex items-center gap-1.5">
                                    <Coins className="w-3.5 h-3.5 text-amber-400" />
                                    <span className="text-amber-400 font-bold">{b.balance.toLocaleString()}</span>
                                </div>
                            </div>
                        ))}
                        {(balances ?? []).length === 0 && (
                            <div className="py-10 text-center text-slate-500 text-sm">No data yet</div>
                        )}
                    </div>
                </div>

                {/* Recent referrals */}
                <div className="bg-[#111827] border border-white/[0.07] rounded-2xl overflow-hidden">
                    <div className="px-5 py-4 border-b border-white/[0.06]">
                        <h2 className="text-sm font-semibold text-white">Recent Referrals</h2>
                    </div>
                    <div className="divide-y divide-white/[0.04]">
                        {(referrals ?? []).map((r: Referral) => (
                            <div key={r.id} className="flex items-center justify-between px-5 py-3 hover:bg-white/[0.02]">
                                <div>
                                    <p className="text-xs text-white font-mono">{r.referrer_id.slice(0, 10)}… → {r.referee_id.slice(0, 10)}…</p>
                                    <p className="text-[10px] text-slate-500 mt-0.5">
                                        {new Date(r.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })}
                                    </p>
                                </div>
                                <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${r.status === 'completed' ? 'bg-emerald-500/10 text-emerald-400' : 'bg-amber-500/10 text-amber-400'
                                    }`}>
                                    {r.status}
                                </span>
                            </div>
                        ))}
                        {(referrals ?? []).length === 0 && (
                            <div className="py-10 text-center text-slate-500 text-sm">No referrals yet</div>
                        )}
                    </div>
                </div>
            </div>

            {/* Recent coin transactions */}
            {(recentMints ?? []).length > 0 && (
                <div className="bg-[#111827] border border-white/[0.07] rounded-2xl overflow-hidden">
                    <div className="px-5 py-4 border-b border-white/[0.06]">
                        <h2 className="text-sm font-semibold text-white">Recent Coin Transactions</h2>
                    </div>
                    <div className="divide-y divide-white/[0.04]">
                        {(recentMints ?? []).map((tx: CoinTx) => (
                            <div key={tx.id} className="flex items-center justify-between px-5 py-3 hover:bg-white/[0.02]">
                                <div className="flex items-center gap-3">
                                    <div className="w-7 h-7 rounded-lg bg-amber-500/10 flex items-center justify-center">
                                        <Coins className="w-3.5 h-3.5 text-amber-400" />
                                    </div>
                                    <div>
                                        <p className="text-sm text-white capitalize">{(tx.reason ?? 'credit').replace(/_/g, ' ')}</p>
                                        <p className="text-xs text-slate-500 font-mono">{tx.id.slice(0, 8)}…</p>
                                    </div>
                                </div>
                                <div className="text-right">
                                    <p className="text-amber-400 font-bold">+{tx.amount} 🪙</p>
                                    <p className="text-xs text-slate-500">
                                        {new Date(tx.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })}
                                    </p>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            )}

            {/* Admin Coin Controls */}
            <CoinControls />
        </div>
    )
}
