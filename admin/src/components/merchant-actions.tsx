'use client';
// src/components/merchant-actions.tsx
// Approve KYC, reject KYC, toggle active status.

import { useState } from 'react';
import { useRouter } from 'next/navigation';

interface Props {
    id: string;
    kycStatus: string;
    isActive: boolean;
}

export function MerchantActions({ id, kycStatus, isActive }: Props) {
    const router = useRouter();
    const [loading, setLoading] = useState(false);

    async function act(action: string, body?: Record<string, unknown>) {
        setLoading(true);
        try {
            const res = await fetch('/api/merchants/action', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id, action, ...body }),
            });
            if (!res.ok) {
                const d = await res.json();
                alert(d.error ?? 'Action failed');
            } else {
                router.refresh();
            }
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className="flex items-center gap-2">
            {kycStatus === 'pending' && (
                <>
                    <button
                        onClick={() => act('approve_kyc')}
                        disabled={loading}
                        className="px-2.5 py-1 bg-green-700/40 hover:bg-green-700/60 text-green-300 text-xs rounded-lg transition-colors disabled:opacity-50">
                        Approve
                    </button>
                    <button
                        onClick={() => act('reject_kyc')}
                        disabled={loading}
                        className="px-2.5 py-1 bg-red-700/40 hover:bg-red-700/60 text-red-300 text-xs rounded-lg transition-colors disabled:opacity-50">
                        Reject
                    </button>
                </>
            )}
            <button
                onClick={() => act(isActive ? 'deactivate' : 'activate')}
                disabled={loading}
                className={`px-2.5 py-1 text-xs rounded-lg transition-colors disabled:opacity-50 ${isActive
                        ? 'bg-gray-700/40 hover:bg-gray-700/60 text-gray-300'
                        : 'bg-blue-700/40 hover:bg-blue-700/60 text-blue-300'
                    }`}>
                {isActive ? 'Deactivate' : 'Activate'}
            </button>
        </div>
    );
}
