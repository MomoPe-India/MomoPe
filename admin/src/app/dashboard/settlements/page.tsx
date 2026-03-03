// src/app/dashboard/settlements/page.tsx
// View all commissions grouped by merchant. Admin can mark them as settled.

import { adminDb } from '@/lib/admin-clients';
import { SettlementActions } from '@/components/settlement-actions';

async function getCommissions() {
    const { data } = await adminDb
        .from('commissions')
        .select('id, merchant_id, commission_amount, is_settled, created_at, settlement_batch_id, merchants(business_name, bank_account_number)')
        .order('created_at', { ascending: false })
        .limit(200);
    return data ?? [];
}

export default async function SettlementsPage() {
    const commissions = await getCommissions();

    const unsettled = commissions.filter(c => !c.is_settled);
    const settled = commissions.filter(c => c.is_settled);
    const totalUnsettled = unsettled.reduce((s, c) => s + (c.commission_amount as number ?? 0), 0);

    const fmt = (n: number) => '₹' + new Intl.NumberFormat('en-IN', { minimumFractionDigits: 2 }).format(n);

    return (
        <div>
            <div className="flex items-center justify-between mb-8">
                <div>
                    <h1 className="text-white text-2xl font-bold">Settlements</h1>
                    <p className="text-gray-400 text-sm mt-1">
                        {unsettled.length} unsettled — {fmt(totalUnsettled)} due
                    </p>
                </div>
                {unsettled.length > 0 && (
                    <div className="text-right">
                        <p className="text-amber-400 font-bold text-lg">{fmt(totalUnsettled)}</p>
                        <p className="text-gray-500 text-xs">Total due to merchants</p>
                    </div>
                )}
            </div>

            {/* Unsettled */}
            <h2 className="text-white font-semibold mb-3">Unsettled Commissions</h2>
            <div className="bg-gray-900 border border-gray-800 rounded-2xl overflow-hidden mb-8">
                <table className="w-full text-sm">
                    <thead>
                        <tr className="border-b border-gray-800">
                            {['Merchant', 'Bank Account', 'Amount', 'Date', 'Actions'].map(h => (
                                <th key={h} className="text-left px-5 py-4 text-gray-400 font-medium">{h}</th>
                            ))}
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-800">
                        {unsettled.map(c => {
                            const merchant = Array.isArray(c.merchants) ? c.merchants[0] : c.merchants;
                            return (
                                <tr key={c.id} className="hover:bg-gray-800/50 transition-colors">
                                    <td className="px-5 py-4 text-white font-medium">{merchant?.business_name ?? c.merchant_id}</td>
                                    <td className="px-5 py-4 text-gray-400 font-mono text-xs">{merchant?.bank_account_number ?? '—'}</td>
                                    <td className="px-5 py-4 text-amber-400 font-semibold">{fmt(c.commission_amount as number ?? 0)}</td>
                                    <td className="px-5 py-4 text-gray-500 text-xs">
                                        {new Date(c.created_at as string).toLocaleDateString('en-IN')}
                                    </td>
                                    <td className="px-5 py-4">
                                        <SettlementActions commissionId={c.id as string} />
                                    </td>
                                </tr>
                            );
                        })}
                        {unsettled.length === 0 && (
                            <tr>
                                <td colSpan={5} className="px-5 py-12 text-center text-gray-500">
                                    🎉 All commissions settled!
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {/* Settled history */}
            <h2 className="text-white font-semibold mb-3">Settled History</h2>
            <div className="bg-gray-900 border border-gray-800 rounded-2xl overflow-hidden">
                <table className="w-full text-sm">
                    <thead>
                        <tr className="border-b border-gray-800">
                            {['Merchant', 'Amount', 'Batch ID', 'Date'].map(h => (
                                <th key={h} className="text-left px-5 py-4 text-gray-400 font-medium">{h}</th>
                            ))}
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-800">
                        {settled.slice(0, 50).map(c => {
                            const merchant = Array.isArray(c.merchants) ? c.merchants[0] : c.merchants;
                            return (
                                <tr key={c.id} className="hover:bg-gray-800/50 transition-colors">
                                    <td className="px-5 py-4 text-white">{merchant?.business_name ?? c.merchant_id}</td>
                                    <td className="px-5 py-4 text-green-400 font-semibold">{fmt(c.commission_amount as number ?? 0)}</td>
                                    <td className="px-5 py-4 text-gray-500 font-mono text-xs">{c.settlement_batch_id ?? '—'}</td>
                                    <td className="px-5 py-4 text-gray-500 text-xs">
                                        {new Date(c.created_at as string).toLocaleDateString('en-IN')}
                                    </td>
                                </tr>
                            );
                        })}
                        {settled.length === 0 && (
                            <tr><td colSpan={4} className="px-5 py-8 text-center text-gray-600">No settled commissions yet</td></tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
