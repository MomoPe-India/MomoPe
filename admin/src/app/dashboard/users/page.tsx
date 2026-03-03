// src/app/dashboard/users/page.tsx
// List all customer accounts (role = customer) with coin balances. Paginated, searchable.
// Admin accounts are excluded — they are internal and have no coin balances.

import { adminDb } from '@/lib/admin-clients';

const PAGE_SIZE = 50;

async function getUsers(page: number, search: string) {
    const from = page * PAGE_SIZE;
    let q = adminDb
        .from('users')
        .select('id, name, phone, referral_code, created_at, momo_coin_balances(available_coins, locked_coins)')
        .neq('role', 'admin')        // exclude admin/internal accounts
        .order('created_at', { ascending: false })
        .range(from, from + PAGE_SIZE - 1);

    if (search) q = q.or(`name.ilike.%${search}%,phone.ilike.%${search}%`);

    const { data, count } = await q;
    return { users: data ?? [], total: count ?? 0 };
}

export default async function UsersPage({
    searchParams,
}: {
    searchParams: Promise<{ page?: string; search?: string }>;
}) {
    const { page: pageStr, search = '' } = await searchParams;
    const page = parseInt(pageStr ?? '0');
    const { users, total } = await getUsers(page, search);

    return (
        <div>
            <div className="flex items-center justify-between mb-8">
                <div>
                    <h1 className="text-white text-2xl font-bold">Users</h1>
                    <p className="text-gray-400 text-sm mt-1">{total.toLocaleString()} total users</p>
                </div>
            </div>

            {/* Search */}
            <form className="mb-4">
                <input
                    name="search" defaultValue={search}
                    placeholder="Search by name or phone…"
                    className="bg-gray-900 border border-gray-800 rounded-xl px-4 py-2.5 text-white placeholder-gray-600 focus:outline-none focus:border-purple-500 w-80 text-sm"
                />
                <button type="submit" className="ml-2 bg-purple-600 hover:bg-purple-500 text-white text-sm px-4 py-2.5 rounded-xl transition-colors">
                    Search
                </button>
            </form>

            <div className="bg-gray-900 border border-gray-800 rounded-2xl overflow-hidden">
                <table className="w-full text-sm">
                    <thead>
                        <tr className="border-b border-gray-800">
                            {['Name', 'Phone', 'Available Coins', 'Locked Coins', 'Referral Code', 'Joined'].map(h => (
                                <th key={h} className="text-left px-5 py-4 text-gray-400 font-medium">{h}</th>
                            ))}
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-800">
                        {users.map(u => {
                            const bal = Array.isArray(u.momo_coin_balances) ? u.momo_coin_balances[0] : u.momo_coin_balances;
                            return (
                                <tr key={u.id} className="hover:bg-gray-800/50 transition-colors">
                                    <td className="px-5 py-4">
                                        <div className="text-white font-medium">{u.name ?? '—'}</div>
                                        <div className="text-gray-500 text-xs font-mono">{(u.id as string).slice(0, 12)}…</div>
                                    </td>
                                    <td className="px-5 py-4 text-gray-300">{u.phone ?? '—'}</td>
                                    <td className="px-5 py-4 text-green-400 font-mono">
                                        {(bal?.available_coins ?? 0).toLocaleString()}
                                    </td>
                                    <td className="px-5 py-4 text-amber-400 font-mono">
                                        {(bal?.locked_coins ?? 0).toLocaleString()}
                                    </td>
                                    <td className="px-5 py-4 text-gray-300 font-mono text-xs">{u.referral_code ?? '—'}</td>
                                    <td className="px-5 py-4 text-gray-500 text-xs">
                                        {new Date(u.created_at as string).toLocaleDateString('en-IN')}
                                    </td>
                                </tr>
                            );
                        })}
                        {users.length === 0 && (
                            <tr>
                                <td colSpan={6} className="px-5 py-12 text-center text-gray-500">No customers found</td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {/* Pagination */}
            {total > PAGE_SIZE && (
                <div className="flex items-center justify-between mt-4 text-sm text-gray-400">
                    <span>Page {page + 1} of {Math.ceil(total / PAGE_SIZE)}</span>
                    <div className="flex gap-2">
                        {page > 0 && (
                            <a href={`?page=${page - 1}&search=${search}`}
                                className="px-3 py-1.5 bg-gray-800 hover:bg-gray-700 rounded-lg transition-colors">← Prev</a>
                        )}
                        {(page + 1) * PAGE_SIZE < total && (
                            <a href={`?page=${page + 1}&search=${search}`}
                                className="px-3 py-1.5 bg-gray-800 hover:bg-gray-700 rounded-lg transition-colors">Next →</a>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
}
