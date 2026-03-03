// src/app/api/auth/verify/route.ts
// Verifies a Firebase ID token and checks role == 'admin'.
// Called by middleware (avoids firebase-admin in Edge runtime).

import { NextRequest, NextResponse } from 'next/server';
import { adminAuth, adminDb } from '@/lib/admin-clients';

export async function POST(req: NextRequest) {
    try {
        const { token } = await req.json() as { token: string };
        if (!token) return NextResponse.json({ error: 'No token' }, { status: 401 });

        // Verify Firebase token
        const decoded = await adminAuth().verifyIdToken(token);
        const uid = decoded.uid;

        // Check role == 'admin' in users table
        const { data: user, error } = await adminDb
            .from('users')
            .select('role')
            .eq('id', uid)
            .single();

        if (error || !user || user.role !== 'admin') {
            return NextResponse.json({ error: 'Not an admin' }, { status: 403 });
        }

        return NextResponse.json({ uid, role: 'admin' });
    } catch (err) {
        console.error('[verify]', err);
        return NextResponse.json({ error: 'Invalid token' }, { status: 401 });
    }
}
