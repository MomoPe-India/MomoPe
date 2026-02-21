'use client'

import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { CheckCircle, XCircle, Loader2 } from 'lucide-react'
import { useRouter } from 'next/navigation'

export default function SettlementActions({ settlementId }: { settlementId: string }) {
    const [loading, setLoading] = useState<'settle' | 'reject' | null>(null)
    const router = useRouter()

    const handleAction = async (action: 'settle' | 'reject') => {
        setLoading(action)
        const supabase = createClient()
        await supabase
            .from('settlements')
            .update({
                status: action === 'settle' ? 'settled' : 'rejected',
                processed_at: new Date().toISOString(),
            })
            .eq('id', settlementId)
        setLoading(null)
        router.refresh()
    }

    return (
        <div className="flex items-center gap-2">
            <button
                onClick={() => handleAction('settle')}
                disabled={loading !== null}
                className="flex items-center gap-1.5 text-xs px-2.5 py-1.5 rounded-lg bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20 transition-colors disabled:opacity-50"
            >
                {loading === 'settle'
                    ? <Loader2 className="w-3 h-3 animate-spin" />
                    : <CheckCircle className="w-3 h-3" />}
                Settle
            </button>
            <button
                onClick={() => handleAction('reject')}
                disabled={loading !== null}
                className="flex items-center gap-1.5 text-xs px-2.5 py-1.5 rounded-lg bg-red-500/10 text-red-400 hover:bg-red-500/20 transition-colors disabled:opacity-50"
            >
                {loading === 'reject'
                    ? <Loader2 className="w-3 h-3 animate-spin" />
                    : <XCircle className="w-3 h-3" />}
                Reject
            </button>
        </div>
    )
}
