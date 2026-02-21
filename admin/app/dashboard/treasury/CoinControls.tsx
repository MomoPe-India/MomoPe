'use client'

import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Coins, PlusCircle, MinusCircle, Loader2, CheckCircle } from 'lucide-react'
import { useRouter } from 'next/navigation'

type ActionType = 'mint' | 'burn'

export default function CoinControls() {
    const router = useRouter()
    const [action, setAction] = useState<ActionType>('mint')
    const [userId, setUserId] = useState('')
    const [amount, setAmount] = useState('')
    const [reason, setReason] = useState('')
    const [loading, setLoading] = useState(false)
    const [result, setResult] = useState<{ success: boolean; message: string } | null>(null)

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()
        if (!userId.trim() || !amount || Number(amount) <= 0) return

        setLoading(true)
        setResult(null)

        try {
            const supabase = createClient()
            const fnName = action === 'mint' ? 'admin_mint_coins' : 'admin_burn_coins'
            const { data, error } = await supabase.rpc(fnName, {
                target_user_id: userId.trim(),
                coin_amount: Math.floor(Number(amount)),
                reason: reason.trim() || (action === 'mint' ? 'Admin mint' : 'Admin burn'),
            })

            if (error) throw error

            const d = data as { success: boolean; minted?: number; burned?: number; balance_after: number }
            const changed = action === 'mint' ? d.minted : d.burned
            setResult({
                success: true,
                message: `✅ ${action === 'mint' ? 'Minted' : 'Burned'} ${changed} coins. New balance: ${d.balance_after}`,
            })
            setUserId('')
            setAmount('')
            setReason('')
            router.refresh()
        } catch (err) {
            setResult({ success: false, message: `❌ Error: ${(err as Error).message}` })
        } finally {
            setLoading(false)
        }
    }

    return (
        <div className="bg-[#111827] border border-white/[0.07] rounded-2xl p-5 space-y-4">
            <div className="flex items-center gap-3 border-b border-white/[0.06] pb-4">
                <div className="w-9 h-9 rounded-xl bg-[#00C4A7]/10 flex items-center justify-center">
                    <Coins className="w-4 h-4 text-[#00C4A7]" />
                </div>
                <div>
                    <h3 className="text-sm font-semibold text-white">Admin Coin Controls</h3>
                    <p className="text-xs text-slate-500">Mint or burn coins for any user account</p>
                </div>
            </div>

            {/* Action toggle */}
            <div className="flex rounded-xl overflow-hidden border border-white/[0.08] w-fit">
                {(['mint', 'burn'] as ActionType[]).map(a => (
                    <button
                        key={a}
                        onClick={() => setAction(a)}
                        className={`flex items-center gap-1.5 px-4 py-2 text-sm font-medium capitalize transition-colors ${action === a
                            ? a === 'mint'
                                ? 'bg-emerald-500/15 text-emerald-400'
                                : 'bg-red-500/15 text-red-400'
                            : 'text-slate-400 hover:text-slate-200 hover:bg-white/[0.04]'
                            }`}
                    >
                        {a === 'mint'
                            ? <PlusCircle className="w-3.5 h-3.5" />
                            : <MinusCircle className="w-3.5 h-3.5" />}
                        {a}
                    </button>
                ))}
            </div>

            <form onSubmit={handleSubmit} className="space-y-3">
                <div>
                    <label className="text-xs font-medium text-slate-400 block mb-1.5">User ID (UUID)</label>
                    <input
                        value={userId}
                        onChange={e => setUserId(e.target.value)}
                        placeholder="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
                        required
                        className="w-full px-3 py-2.5 rounded-xl bg-white/[0.05] border border-white/[0.08] text-sm text-white font-mono placeholder-slate-600 focus:outline-none focus:ring-1 focus:ring-[#00C4A7]/50"
                    />
                </div>
                <div className="grid grid-cols-2 gap-3">
                    <div>
                        <label className="text-xs font-medium text-slate-400 block mb-1.5">Amount (coins)</label>
                        <input
                            type="number"
                            min={1}
                            value={amount}
                            onChange={e => setAmount(e.target.value)}
                            placeholder="100"
                            required
                            className="w-full px-3 py-2.5 rounded-xl bg-white/[0.05] border border-white/[0.08] text-sm text-white placeholder-slate-600 focus:outline-none focus:ring-1 focus:ring-[#00C4A7]/50"
                        />
                    </div>
                    <div>
                        <label className="text-xs font-medium text-slate-400 block mb-1.5">Reason (optional)</label>
                        <input
                            value={reason}
                            onChange={e => setReason(e.target.value)}
                            placeholder={action === 'mint' ? 'Promotion bonus' : 'Fraud remediation'}
                            className="w-full px-3 py-2.5 rounded-xl bg-white/[0.05] border border-white/[0.08] text-sm text-white placeholder-slate-600 focus:outline-none focus:ring-1 focus:ring-[#00C4A7]/50"
                        />
                    </div>
                </div>

                <button
                    type="submit"
                    disabled={loading}
                    className={`flex items-center justify-center gap-2 w-full py-2.5 rounded-xl text-sm font-semibold transition-all ${action === 'mint'
                        ? 'bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20 border border-emerald-500/20'
                        : 'bg-red-500/10 text-red-400 hover:bg-red-500/20 border border-red-500/20'
                        } disabled:opacity-50`}
                >
                    {loading
                        ? <Loader2 className="w-4 h-4 animate-spin" />
                        : action === 'mint'
                            ? <><PlusCircle className="w-4 h-4" /> Mint Coins</>
                            : <><MinusCircle className="w-4 h-4" /> Burn Coins</>
                    }
                </button>
            </form>

            {result && (
                <div className={`flex items-start gap-2 p-3 rounded-xl text-sm ${result.success
                    ? 'bg-emerald-500/10 text-emerald-300 border border-emerald-500/20'
                    : 'bg-red-500/10 text-red-300 border border-red-500/20'
                    }`}>
                    {result.success && <CheckCircle className="w-4 h-4 shrink-0 mt-0.5" />}
                    {result.message}
                </div>
            )}
        </div>
    )
}
