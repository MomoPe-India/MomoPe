import { NextResponse, type NextRequest } from 'next/server'
import { createServerClient, type CookieOptions } from '@supabase/ssr'

export async function middleware(request: NextRequest) {
    let supabaseResponse = NextResponse.next({ request })

    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                getAll() {
                    return request.cookies.getAll()
                },
                setAll(cookiesToSet: { name: string; value: string; options: CookieOptions }[]) {
                    cookiesToSet.forEach(({ name, value }) =>
                        request.cookies.set(name, value)
                    )
                    supabaseResponse = NextResponse.next({ request })
                    cookiesToSet.forEach(({ name, value, options }) =>
                        supabaseResponse.cookies.set(name, value, options)
                    )
                },
            },
        }
    )

    // getUser() validates the JWT with the Supabase server — cannot be spoofed
    const { data: { user } } = await supabase.auth.getUser()

    const { pathname } = request.nextUrl

    // ── Unauthenticated → redirect to /login ────────────────────────────────
    if (pathname.startsWith('/dashboard') && !user) {
        return NextResponse.redirect(new URL('/login', request.url))
    }

    // ── Already authed → redirect away from /login ──────────────────────────
    if (pathname === '/login' && user) {
        return NextResponse.redirect(new URL('/dashboard', request.url))
    }

    // ── Admin role check for /dashboard routes ───────────────────────────────
    if (pathname.startsWith('/dashboard') && user) {
        // The custom_access_token_hook injects `user_role` into JWT claims.
        // It's also available immediately via the users table as a fallback.
        const jwtRole = (user.app_metadata as Record<string, unknown>)?.user_role as string | undefined

        let isAdmin = jwtRole === 'admin'

        // Fallback: check DB directly (covers cases before first token refresh)
        if (!isAdmin) {
            const { data } = await supabase
                .from('users')
                .select('role')
                .eq('id', user.id)
                .single()
            isAdmin = (data as { role?: string } | null)?.role === 'admin'
        }

        if (!isAdmin) {
            return NextResponse.redirect(new URL('/unauthorized', request.url))
        }
    }

    return supabaseResponse
}

export const config = {
    matcher: ['/dashboard/:path*', '/login'],
}
