// src/app/dashboard/coins/page.tsx
// Manual coin credit / debit. Admin can award or deduct coins for fraud/promotions.
// All changes are logged in coin_transactions for full audit trail.

import { adminDb } from '@/lib/admin-clients';
import { CoinForm } from '@/components/coin-form';

async function getRecentCoinTx() {
    const { data } = await adminDb
        .from('coin_transactions')
        .select('id, user_id, amount, transaction_type, description, created_at, users(name, phone)')
        .in('transaction_type', ['manual_credit', 'manual_debit', 'admin_credit', 'admin_debit'])
        .order('created_at', { ascending: false })
        .limit(50);
    return data ?? [];
}

export default async function CoinsPage() {
    const txs = await getRecentCoinTx();

    return (
        <div>
            <div className="mb-8">
                <h1 className="text-white text-2xl font-bold">Coins</h1>
                <p className="text-gray-400 text-sm mt-1">Manual credit / debit for any user account</p>
            </div>

            {/* Manual credit/debit form */}
            <CoinForm />

            {/* Recent manual adjustments */}
            <div className="mt-8">
                <h2 className="text-white font-semibold mb-4">Recent Manual Adjustments</h2>
                <div className="bg-gray-900 border border-gray-800 rounded-2xl overflow-hidden">
                    <table className="w-full text-sm">
                        <thead>
                            <tr className="border-b border-gray-800">
                                {['User', 'Type', 'Amount', 'Description', 'Date'].map(h => (
                                    <th key={h} className="text-left px-5 py-4 text-gray-400 font-medium">{h}</th>
                                ))}
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-800">
                            {txs.map(tx => {
                                const user = Array.isArray(tx.users) ? tx.users[0] : tx.users;
                                const credit = String(tx.transaction_type).includes('credit');
                                return (
                                    <tr key={tx.id} className="hover:bg-gray-800/50 transition-colors">
                                        <td className="px-5 py-4">
                                            <div className="text-white">{user?.name ?? '—'}</div>
                                            <div className="text-gray-500 text-xs">{user?.phone ?? '—'}</div>
                                        </td>
                                        <td className="px-5 py-4">
                                            <span className={`text-xs px-2 py-1 rounded-md ${credit ? 'bg-green-900/40 text-green-300' : 'bg-red-900/40 text-red-300'
                                                }`}>{String(tx.transaction_type).replace(/_/g, ' ')}</span>
                                        </td>
                                        <td className={`px-5 py-4 font-mono font-semibold ${credit ? 'text-green-400' : 'text-red-400'}`}>
                                            {credit ? '+' : '-'}{Math.abs(tx.amount as number).toLocaleString()}
                                        </td>
                                        <td className="px-5 py-4 text-gray-300 max-w-xs truncate">{tx.description as string ?? '—'}</td>
                                        <td className="px-5 py-4 text-gray-500 text-xs">
                                            {new Date(tx.created_at as string).toLocaleString('en-IN')}
                                        </td>
                                    </tr>
                                );
                            })}
                            {txs.length === 0 && (
                                <tr>
                                    <td colSpan={5} className="px-5 py-12 text-center text-gray-500">No manual adjustments yet</td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
