// src/app/api/settlements/settle/route.ts
// Mark a single commission record as settled.

import { NextRequest, NextResponse } from 'next/server';
import { adminDb } from '@/lib/admin-clients';
import { randomUUID } from 'crypto';

export async function POST(req: NextRequest) {
    try {
        const { commission_id } = await req.json() as { commission_id: string };
        if (!commission_id) return NextResponse.json({ error: 'Missing commission_id' }, { status: 400 });

        const batchId = randomUUID();

        const { error } = await adminDb
            .from('commissions')
            .update({
                is_settled: true,
                settlement_batch_id: batchId,
                updated_at: new Date().toISOString(),
            })
            .eq('id', commission_id)
            .eq('is_settled', false); // prevent double-settle

        if (error) throw error;

        return NextResponse.json({ ok: true, batch_id: batchId });
    } catch (err) {
        console.error('[settle]', err);
        return NextResponse.json({ error: String(err) }, { status: 500 });
    }
}
