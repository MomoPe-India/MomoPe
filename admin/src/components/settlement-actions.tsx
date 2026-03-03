'use client';
// src/components/settlement-actions.tsx

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export function SettlementActions({ commissionId }: { commissionId: string }) {
    const router = useRouter();
    const [loading, setLoading] = useState(false);

    async function markSettled() {
        if (!confirm('Mark this commission as settled?')) return;
        setLoading(true);
        try {
            const res = await fetch('/api/settlements/settle', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ commission_id: commissionId }),
            });
            if (!res.ok) {
                const d = await res.json();
                alert(d.error ?? 'Failed');
            } else {
                router.refresh();
            }
        } finally {
            setLoading(false);
        }
    }

    return (
        <button onClick={markSettled} disabled={loading}
            className="px-2.5 py-1 bg-green-700/40 hover:bg-green-700/60 text-green-300 text-xs rounded-lg transition-colors disabled:opacity-50">
            {loading ? '…' : 'Mark Settled'}
        </button>
    );
}
