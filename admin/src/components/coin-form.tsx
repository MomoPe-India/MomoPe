'use client';
// src/components/coin-form.tsx
// Form to manually credit or debit coins for any user. Looks up user by phone number.

import { useState } from 'react';

export function CoinForm() {
    const [phone, setPhone] = useState('');
    const [amount, setAmount] = useState('');
    const [type, setType] = useState<'credit' | 'debit'>('credit');
    const [reason, setReason] = useState('');
    const [loading, setLoading] = useState(false);
    const [result, setResult] = useState<{ ok?: boolean; message?: string; error?: string } | null>(null);

    async function handleSubmit(e: React.FormEvent) {
        e.preventDefault();
        setLoading(true);
        setResult(null);
        try {
            const res = await fetch('/api/coins/adjust', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ phone, amount: Number(amount), type, reason }),
            });
            const data = await res.json();
            setResult(data);
            if (data.ok) { setPhone(''); setAmount(''); setReason(''); }
        } finally {
            setLoading(false);
        }
    }

    return (
        <form onSubmit={handleSubmit}
            className="bg-gray-900 border border-gray-800 rounded-2xl p-6 max-w-lg">
            <h2 className="text-white font-semibold mb-5">Manual Coin Adjustment</h2>

            <div className="space-y-4">
                <div>
                    <label className="block text-xs text-gray-400 mb-1.5">Customer Phone Number</label>
                    <input value={phone} onChange={e => setPhone(e.target.value)} required
                        placeholder="9999999999"
                        className="w-full bg-gray-800 border border-gray-700 rounded-xl px-4 py-2.5 text-white placeholder-gray-600 focus:outline-none focus:border-purple-500 text-sm" />
                </div>

                <div className="grid grid-cols-2 gap-3">
                    <div>
                        <label className="block text-xs text-gray-400 mb-1.5">Type</label>
                        <select value={type} onChange={e => setType(e.target.value as 'credit' | 'debit')}
                            className="w-full bg-gray-800 border border-gray-700 rounded-xl px-4 py-2.5 text-white focus:outline-none focus:border-purple-500 text-sm">
                            <option value="credit">Credit (add coins)</option>
                            <option value="debit">Debit (remove coins)</option>
                        </select>
                    </div>
                    <div>
                        <label className="block text-xs text-gray-400 mb-1.5">Amount (coins)</label>
                        <input value={amount} onChange={e => setAmount(e.target.value)} required min={1} type="number"
                            placeholder="100"
                            className="w-full bg-gray-800 border border-gray-700 rounded-xl px-4 py-2.5 text-white placeholder-gray-600 focus:outline-none focus:border-purple-500 text-sm" />
                    </div>
                </div>

                <div>
                    <label className="block text-xs text-gray-400 mb-1.5">Reason / Description</label>
                    <input value={reason} onChange={e => setReason(e.target.value)} required
                        placeholder="e.g. Promotional bonus, Fraud reversal…"
                        className="w-full bg-gray-800 border border-gray-700 rounded-xl px-4 py-2.5 text-white placeholder-gray-600 focus:outline-none focus:border-purple-500 text-sm" />
                </div>

                {result && (
                    <p className={`text-sm px-3 py-2 rounded-lg ${result.ok ? 'text-green-300 bg-green-900/30' : 'text-red-300 bg-red-900/30'}`}>
                        {result.ok ? `✓ ${result.message}` : `✗ ${result.error}`}
                    </p>
                )}

                <button type="submit" disabled={loading}
                    className="w-full bg-purple-600 hover:bg-purple-500 disabled:opacity-50 text-white font-semibold py-2.5 rounded-xl transition-colors text-sm">
                    {loading ? 'Processing…' : `${type === 'credit' ? 'Credit' : 'Debit'} Coins`}
                </button>
            </div>
        </form>
    );
}
