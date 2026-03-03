// src/app/dashboard/page.tsx
// Live metrics dashboard — users, GMV, commissions, coin liability, coverage ratio.

import { adminDb } from '@/lib/admin-clients';

async function getMetrics() {
    const [
        { count: totalUsers },
        { data: txData },
        { data: commData },
        { data: coinData },
    ] = await Promise.all([
        adminDb.from('users').select('*', { count: 'exact', head: true }).neq('role', 'admin'),
        adminDb.from('transactions').select('gross_amount, fiat_amount, status').eq('status', 'completed'),
        adminDb.from('commissions').select('commission_amount, is_settled'),
        adminDb.from('momo_coin_balances').select('available_coins, locked_coins, total_coins'),
    ]);

    const gmv = txData?.reduce((s, t) => s + (t.gross_amount ?? 0), 0) ?? 0;
    const totalCommission = commData?.reduce((s, c) => s + (c.commission_amount ?? 0), 0) ?? 0;
    const unsettled = commData?.filter(c => !c.is_settled).reduce((s, c) => s + (c.commission_amount ?? 0), 0) ?? 0;
    const activeLiability = coinData?.reduce((s, b) => s + (b.available_coins ?? 0) + (b.locked_coins ?? 0), 0) ?? 0;
    const totalCoinsEarned = coinData?.reduce((s, b) => s + (b.total_coins ?? 0), 0) ?? 0;

    // Coverage ratio: what % of GMV is locked in active coin obligations
    // A ratio of 8% means ₹8 of every ₹100 of GMV is owed back as coins.
    const coverageRatio = gmv > 0 ? (activeLiability / gmv) * 100 : 0;

    return { totalUsers, gmv, totalCommission, unsettled, activeLiability, totalCoinsEarned, coverageRatio };
}

function StatCard({ label, value, sub, color = 'purple' }: {
    label: string; value: string; sub?: string; color?: string
}) {
    const colors: Record<string, string> = {
        purple: 'from-purple-500/10 to-purple-700/10 border-purple-800/40',
        green: 'from-green-500/10  to-green-700/10  border-green-800/40',
        amber: 'from-amber-500/10  to-amber-700/10  border-amber-800/40',
        blue: 'from-blue-500/10   to-blue-700/10   border-blue-800/40',
        red: 'from-red-500/10    to-red-700/10    border-red-800/40',
    };
    return (
        <div className={`bg-gradient-to-br ${colors[color]} border rounded-2xl p-6`}>
            <p className="text-gray-400 text-sm mb-2">{label}</p>
            <p className="text-white text-3xl font-bold">{value}</p>
            {sub && <p className="text-gray-500 text-xs mt-1">{sub}</p>}
        </div>
    );
}

export default async function DashboardPage() {
    const { totalUsers, gmv, totalCommission, unsettled, activeLiability, totalCoinsEarned, coverageRatio } = await getMetrics();

    const fmt = (n: number) => '₹' + new Intl.NumberFormat('en-IN').format(Math.round(n));
    const fmtInt = (n: number | null) => new Intl.NumberFormat('en-IN').format(n ?? 0);

    // Coverage ratio color coding
    const coverageColor = coverageRatio >= 30 ? 'red' : coverageRatio >= 15 ? 'amber' : 'green';
    const coverageLabel = coverageRatio >= 30
        ? 'High — review coin issuance rate'
        : coverageRatio >= 15
            ? 'Moderate — within normal range'
            : 'Low — healthy for business';

    return (
        <div>
            <div className="mb-8">
                <h1 className="text-white text-2xl font-bold">Dashboard</h1>
                <p className="text-gray-400 text-sm mt-1">Real-time business metrics</p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4 mb-8">
                <StatCard label="Total Customers" value={fmtInt(totalUsers)} color="purple" />
                <StatCard label="Gross GMV" value={fmt(gmv)} color="green" />
                <StatCard label="Total Commission" value={fmt(totalCommission)} sub={`₹${new Intl.NumberFormat('en-IN').format(Math.round(unsettled))} unsettled`} color="blue" />
                <StatCard label="Active Coin Liability" value={fmtInt(activeLiability) + ' coins'} sub={`${fmtInt(totalCoinsEarned)} total earned`} color="amber" />
                <StatCard label="Unsettled Amount" value={fmt(unsettled)} color="red" />
                <StatCard
                    label="Coverage Ratio"
                    value={`${coverageRatio.toFixed(1)}%`}
                    sub={coverageLabel}
                    color={coverageColor}
                />
            </div>

            <div className="bg-gray-900 border border-gray-800 rounded-2xl p-6">
                <h2 className="text-white font-semibold mb-4">Quick Actions</h2>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                    {[
                        { href: '/dashboard/merchants?filter=pending_kyc', label: 'Pending KYC' },
                        { href: '/dashboard/coins', label: 'Manual Credit' },
                        { href: '/dashboard/settlements', label: 'Mark Settled' },
                        { href: '/dashboard/users', label: 'View Users' },
                    ].map(a => (
                        <a key={a.href} href={a.href}
                            className="block p-4 bg-gray-800 hover:bg-gray-700 rounded-xl text-center text-sm text-gray-300 hover:text-white transition-colors">
                            {a.label}
                        </a>
                    ))}
                </div>
            </div>
        </div>
    );
}
