// src/app/api/auth/login/route.ts
// Sets the session cookie after successful Firebase sign-in from the browser.

import { NextRequest, NextResponse } from 'next/server';
import { adminAuth, adminDb } from '@/lib/admin-clients';

export async function POST(req: NextRequest) {
    try {
        const { token } = await req.json() as { token: string };
        if (!token) return NextResponse.json({ error: 'No token' }, { status: 401 });

        const decoded = await adminAuth().verifyIdToken(token);

        // Role gate
        const { data: user } = await adminDb
            .from('users')
            .select('role, name')
            .eq('id', decoded.uid)
            .single();

        if (!user || user.role !== 'admin') {
            return NextResponse.json({ error: 'Access denied' }, { status: 403 });
        }

        const cookieName = process.env.AUTH_COOKIE_NAME ?? 'momope_admin_session';
        const res = NextResponse.json({ ok: true, name: user.name });
        res.cookies.set(cookieName, token, {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'lax',
            maxAge: 60 * 60, // 1 hour
            path: '/',
        });
        return res;
    } catch (err) {
        console.error('[login]', err);
        return NextResponse.json({ error: 'Login failed' }, { status: 401 });
    }
}

export async function DELETE() {
    const cookieName = process.env.AUTH_COOKIE_NAME ?? 'momope_admin_session';
    const res = NextResponse.json({ ok: true });
    res.cookies.delete(cookieName);
    return res;
}
