import clsx from 'clsx'
import { LucideIcon } from 'lucide-react'

interface StatsCardProps {
    title: string
    value: string | number
    subtitle?: string
    icon: LucideIcon
    trend?: { value: number; label: string }
    accent?: 'teal' | 'blue' | 'purple' | 'amber' | 'red'
}

const ACCENT_MAP = {
    teal: { bg: 'bg-[#00C4A7]/10', text: 'text-[#00C4A7]', trend: 'text-[#00C4A7]' },
    blue: { bg: 'bg-blue-500/10', text: 'text-blue-400', trend: 'text-blue-400' },
    purple: { bg: 'bg-purple-500/10', text: 'text-purple-400', trend: 'text-purple-400' },
    amber: { bg: 'bg-amber-500/10', text: 'text-amber-400', trend: 'text-amber-400' },
    red: { bg: 'bg-red-500/10', text: 'text-red-400', trend: 'text-red-400' },
}

export default function StatsCard({ title, value, subtitle, icon: Icon, trend, accent = 'teal' }: StatsCardProps) {
    const colors = ACCENT_MAP[accent]

    return (
        <div className="bg-[#111827] border border-white/[0.07] rounded-2xl p-5 hover:border-white/[0.12] transition-colors">
            <div className="flex items-start justify-between mb-4">
                <div className={clsx('w-10 h-10 rounded-xl flex items-center justify-center', colors.bg)}>
                    <Icon className={clsx('w-5 h-5', colors.text)} />
                </div>
                {trend && (
                    <span className={clsx('text-xs font-medium', trend.value >= 0 ? 'text-emerald-400' : 'text-red-400')}>
                        {trend.value >= 0 ? '↑' : '↓'} {Math.abs(trend.value)}% {trend.label}
                    </span>
                )}
            </div>
            <p className="text-2xl font-bold text-white mb-1">{value}</p>
            <p className="text-sm text-slate-400">{title}</p>
            {subtitle && <p className="text-xs text-slate-500 mt-1">{subtitle}</p>}
        </div>
    )
}
