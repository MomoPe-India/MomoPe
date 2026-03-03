// src/app/api/merchants/action/route.ts
// approve_kyc | reject_kyc | activate | deactivate

import { NextRequest, NextResponse } from 'next/server';
import { adminDb } from '@/lib/admin-clients';
import { sendPushNotification } from '@/lib/notifications';

export async function POST(req: NextRequest) {
    try {
        const { id, action } = await req.json() as { id: string; action: string };
        if (!id || !action) return NextResponse.json({ error: 'Missing params' }, { status: 400 });

        let update: Record<string, unknown> = {};
        switch (action) {
            case 'approve_kyc': update = { kyc_status: 'approved', is_active: true }; break;
            case 'reject_kyc': update = { kyc_status: 'rejected' }; break;
            case 'deactivate': update = { is_active: false }; break;
            case 'activate': update = { is_active: true }; break;
            default: return NextResponse.json({ error: 'Unknown action' }, { status: 400 });
        }

        const { error } = await adminDb.from('merchants').update(update).eq('id', id);
        if (error) throw error;

        // Trigger notification
        if (action === 'approve_kyc') {
            await sendPushNotification(id, {
                title: 'KYC Approved! 🎉',
                body: 'Your business is now verified. You can start accepting payments.',
                data: { type: 'kyc_approved' }
            });
        } else if (action === 'reject_kyc') {
            await sendPushNotification(id, {
                title: 'KYC Update Required ⚠️',
                body: 'Your documents were not approved. Please check your profile to see the reason and re-submit.',
                data: { type: 'kyc_rejected' }
            });
        }

        return NextResponse.json({ ok: true });
    } catch (err) {
        console.error('[merchant-action]', err);
        return NextResponse.json({ error: String(err) }, { status: 500 });
    }
}
