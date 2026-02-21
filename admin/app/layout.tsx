import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
    title: 'MomoPe Admin',
    description: 'Super Admin Dashboard — MomoPe Internal',
}

export default function RootLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <html lang="en" suppressHydrationWarning>
            <body>{children}</body>
        </html>
    )
}
