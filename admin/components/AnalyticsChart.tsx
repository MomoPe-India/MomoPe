'use client'

import {
    BarChart, Bar,
    LineChart, Line,
    XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
} from 'recharts'

interface DailyVolume {
    date: string   // "Mon", "Tue", etc.
    amount: number
    count: number
}

interface CoinTrend {
    date: string
    coins: number
}

interface AnalyticsChartsProps {
    volumeData: DailyVolume[]
    coinTrendData: CoinTrend[]
}

const CustomTooltip = ({ active, payload, label }: {
    active?: boolean
    payload?: { value: number; name: string }[]
    label?: string
}) => {
    if (!active || !payload?.length) return null
    return (
        <div className="bg-[#1a2235] border border-white/[0.08] rounded-xl px-3 py-2 shadow-xl">
            <p className="text-xs text-slate-400 mb-1">{label}</p>
            {payload.map((p) => (
                <p key={p.name} className="text-sm font-semibold text-white">
                    {p.name === 'amount' ? `₹${p.value.toLocaleString()}` : p.value.toLocaleString()}
                </p>
            ))}
        </div>
    )
}

export function TransactionVolumeChart({ data }: { data: DailyVolume[] }) {
    return (
        <div className="bg-[#111827] border border-white/[0.07] rounded-2xl p-5">
            <div className="flex items-center justify-between mb-4">
                <div>
                    <h3 className="text-sm font-semibold text-white">Transaction Volume</h3>
                    <p className="text-xs text-slate-500 mt-0.5">Last 7 days (₹)</p>
                </div>
            </div>
            <ResponsiveContainer width="100%" height={180}>
                <BarChart data={data} barSize={20}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" vertical={false} />
                    <XAxis
                        dataKey="date"
                        tick={{ fill: '#64748b', fontSize: 11 }}
                        axisLine={false}
                        tickLine={false}
                    />
                    <YAxis
                        tick={{ fill: '#64748b', fontSize: 11 }}
                        axisLine={false}
                        tickLine={false}
                        tickFormatter={(v) => `₹${v >= 1000 ? `${(v / 1000).toFixed(0)}k` : v}`}
                        width={45}
                    />
                    <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(255,255,255,0.03)' }} />
                    <Bar dataKey="amount" fill="#00C4A7" radius={[4, 4, 0, 0]} />
                </BarChart>
            </ResponsiveContainer>
        </div>
    )
}

export function CoinCirculationChart({ data }: { data: CoinTrend[] }) {
    return (
        <div className="bg-[#111827] border border-white/[0.07] rounded-2xl p-5">
            <div className="flex items-center justify-between mb-4">
                <div>
                    <h3 className="text-sm font-semibold text-white">Coin Circulation</h3>
                    <p className="text-xs text-slate-500 mt-0.5">Last 7 days trend</p>
                </div>
            </div>
            <ResponsiveContainer width="100%" height={180}>
                <LineChart data={data}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" vertical={false} />
                    <XAxis
                        dataKey="date"
                        tick={{ fill: '#64748b', fontSize: 11 }}
                        axisLine={false}
                        tickLine={false}
                    />
                    <YAxis
                        tick={{ fill: '#64748b', fontSize: 11 }}
                        axisLine={false}
                        tickLine={false}
                        width={45}
                    />
                    <Tooltip content={<CustomTooltip />} />
                    <Line
                        type="monotone"
                        dataKey="coins"
                        stroke="#a78bfa"
                        strokeWidth={2}
                        dot={{ fill: '#a78bfa', r: 3 }}
                        activeDot={{ r: 5, fill: '#a78bfa' }}
                    />
                </LineChart>
            </ResponsiveContainer>
        </div>
    )
}
