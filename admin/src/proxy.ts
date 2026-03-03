// src/proxy.ts
// Runs on every request to /dashboard/* routes.
// Verifies the Firebase ID token from the session cookie,
// checks role == 'admin', redirects to /login if invalid.
// NOTE: Named 'proxy' as required by Next.js 16+

import { NextRequest, NextResponse } from 'next/server';

const PROTECTED = ['/dashboard'];

export async function proxy(req: NextRequest) {
    const { pathname } = req.nextUrl;

    // Only protect dashboard routes
    if (!PROTECTED.some(p => pathname.startsWith(p))) {
        return NextResponse.next();
    }

    // Allow API routes to handle their own auth
    if (pathname.startsWith('/api/')) return NextResponse.next();

    // Check for session cookie set after login
    const token = req.cookies.get(process.env.AUTH_COOKIE_NAME ?? 'momope_admin_session')?.value;

    if (!token) {
        return NextResponse.redirect(new URL('/login', req.url));
    }

    // Verify token server-side via our API route (avoids importing firebase-admin in edge)
    const verifyUrl = new URL('/api/auth/verify', req.url);
    const resp = await fetch(verifyUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token }),
    });

    if (!resp.ok) {
        const res = NextResponse.redirect(new URL('/login', req.url));
        res.cookies.delete(process.env.AUTH_COOKIE_NAME ?? 'momope_admin_session');
        return res;
    }

    return NextResponse.next();
}

export const config = {
    matcher: ['/dashboard/:path*'],
};
