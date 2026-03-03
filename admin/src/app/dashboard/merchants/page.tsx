// src/app/dashboard/merchants/page.tsx
// List all merchants with KYC status. Admin can approve/reject KYC and deactivate.

import { adminDb } from '@/lib/admin-clients';
import { MerchantActions } from '@/components/merchant-actions';

async function getMerchants(filter?: string) {
    let q = adminDb.from('merchants').select('*').order('created_at', { ascending: false });
    if (filter === 'pending_kyc') q = q.eq('kyc_status', 'pending');
    const { data } = await q;
    return data ?? [];
}

const KYC_BADGE: Record<string, string> = {
    pending: 'bg-amber-900/40  text-amber-300  border-amber-700',
    approved: 'bg-green-900/40  text-green-300  border-green-700',
    rejected: 'bg-red-900/40    text-red-300    border-red-700',
};

export default async function MerchantsPage({
    searchParams,
}: {
    searchParams: Promise<{ filter?: string }>;
}) {
    const { filter } = await searchParams;
    const merchants = await getMerchants(filter);

    return (
        <div>
            <div className="flex items-center justify-between mb-8">
                <div>
                    <h1 className="text-white text-2xl font-bold">Merchants</h1>
                    <p className="text-gray-400 text-sm mt-1">{merchants.length} merchants{filter ? ` (${filter})` : ''}</p>
                </div>
                <div className="flex gap-2">
                    {(['all', 'pending_kyc'] as const).map(f => (
                        <a key={f} href={f === 'all' ? '/dashboard/merchants' : `?filter=${f}`}
                            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${(filter ?? 'all') === f
                                    ? 'bg-purple-600 text-white'
                                    : 'bg-gray-800 text-gray-400 hover:text-white'
                                }`}>
                            {f === 'all' ? 'All' : 'Pending KYC'}
                        </a>
                    ))}
                </div>
            </div>

            <div className="bg-gray-900 border border-gray-800 rounded-2xl overflow-hidden">
                <table className="w-full text-sm">
                    <thead>
                        <tr className="border-b border-gray-800">
                            {['Business', 'Category', 'KYC Status', 'Active', 'Created', 'Actions'].map(h => (
                                <th key={h} className="text-left px-5 py-4 text-gray-400 font-medium">{h}</th>
                            ))}
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-800">
                        {merchants.map(m => (
                            <tr key={m.id} className="hover:bg-gray-800/50 transition-colors">
                                <td className="px-5 py-4">
                                    <div className="text-white font-medium">{m.business_name}</div>
                                    <div className="text-gray-500 text-xs">{m.id}</div>
                                </td>
                                <td className="px-5 py-4 text-gray-300">{(m.category as string).replace(/_/g, ' ')}</td>
                                <td className="px-5 py-4">
                                    <span className={`px-2 py-1 rounded-md text-xs border ${KYC_BADGE[m.kyc_status as string] ?? 'bg-gray-800 text-gray-400'}`}>
                                        {m.kyc_status as string}
                                    </span>
                                </td>
                                <td className="px-5 py-4">
                                    <span className={`text-xs ${m.is_active ? 'text-green-400' : 'text-red-400'}`}>
                                        {m.is_active ? '✓ Active' : '✗ Inactive'}
                                    </span>
                                </td>
                                <td className="px-5 py-4 text-gray-500 text-xs">
                                    {new Date(m.created_at as string).toLocaleDateString('en-IN')}
                                </td>
                                <td className="px-5 py-4">
                                    <MerchantActions
                                        id={m.id as string}
                                        kycStatus={m.kyc_status as string}
                                        isActive={m.is_active as boolean}
                                    />
                                </td>
                            </tr>
                        ))}
                        {merchants.length === 0 && (
                            <tr>
                                <td colSpan={6} className="px-5 py-12 text-center text-gray-500">
                                    No merchants found
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
