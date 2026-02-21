import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import Sidebar from '@/components/Sidebar'

export default async function DashboardLayout({
    children,
}: {
    children: React.ReactNode
}) {
    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) {
        redirect('/login')
    }

    return (
        <div className="min-h-screen bg-[#0B0F19] flex">
            <Sidebar />
            {/* Main content — offset by sidebar width */}
            <main className="flex-1 ml-[240px] min-h-screen flex flex-col">
                {/* Top bar */}
                <header className="h-14 border-b border-white/[0.06] flex items-center px-6 bg-[#0B0F19]/80 backdrop-blur-sm sticky top-0 z-30">
                    <p className="text-xs text-slate-500 ml-auto font-mono">
                        {user.email}
                    </p>
                </header>
                <div className="flex-1 p-6">
                    {children}
                </div>
            </main>
        </div>
    )
}
