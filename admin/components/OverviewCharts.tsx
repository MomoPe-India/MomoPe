'use client'

import { TransactionVolumeChart, CoinCirculationChart } from '@/components/AnalyticsChart'

interface DailyVolume { date: string; amount: number; count: number }
interface CoinTrend { date: string; coins: number }

export default function OverviewCharts({
    volumeData,
    coinTrendData,
}: {
    volumeData: DailyVolume[]
    coinTrendData: CoinTrend[]
}) {
    return (
        <div className="grid grid-cols-1 xl:grid-cols-2 gap-4">
            <TransactionVolumeChart data={volumeData} />
            <CoinCirculationChart data={coinTrendData} />
        </div>
    )
}
