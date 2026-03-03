// src/app/api/coins/adjust/route.ts
// Manual coin credit or debit by phone number.
// Inserts a coin_transactions record and updates momo_coin_balances.

import { NextRequest, NextResponse } from 'next/server';
import { adminDb } from '@/lib/admin-clients';

export async function POST(req: NextRequest) {
    try {
        const { phone, amount, type, reason } = await req.json() as {
            phone: string; amount: number; type: 'credit' | 'debit'; reason: string;
        };

        if (!phone || !amount || amount <= 0 || !type || !reason) {
            return NextResponse.json({ error: 'Invalid parameters' }, { status: 400 });
        }

        // Find user by phone
        const { data: user, error: userErr } = await adminDb
            .from('users').select('id').eq('phone', phone).single();
        if (userErr || !user) {
            return NextResponse.json({ error: `User not found for phone: ${phone}` }, { status: 404 });
        }
        const uid = user.id as string;

        // Get current balance
        const { data: bal, error: balErr } = await adminDb
            .from('momo_coin_balances').select('*').eq('user_id', uid).single();
        if (balErr || !bal) {
            return NextResponse.json({ error: 'No coin balance found for user' }, { status: 404 });
        }

        const availableCoins = bal.available_coins as number;
        if (type === 'debit' && availableCoins < amount) {
            return NextResponse.json({ error: `Insufficient balance: ${availableCoins} coins available` }, { status: 422 });
        }

        const newAvailable = type === 'credit' ? availableCoins + amount : availableCoins - amount;
        const newTotal = (bal.total_coins_earned as number) + (type === 'credit' ? amount : 0);
        const txType = type === 'credit' ? 'admin_credit' : 'admin_debit';

        // Update balance + insert audit record atomically
        const [{ error: balUpErr }, { error: txErr }] = await Promise.all([
            adminDb.from('momo_coin_balances').update({
                available_coins: newAvailable,
                total_coins_earned: newTotal,
                updated_at: new Date().toISOString(),
            }).eq('user_id', uid),

            adminDb.from('coin_transactions').insert({
                user_id: uid,
                amount: type === 'credit' ? amount : -amount,
                transaction_type: txType,
                description: reason,
            }),
        ]);

        if (balUpErr) throw balUpErr;
        if (txErr) throw txErr;

        return NextResponse.json({
            ok: true,
            message: `${type === 'credit' ? 'Credited' : 'Debited'} ${amount} coins. New balance: ${newAvailable}`,
        });
    } catch (err) {
        console.error('[coins-adjust]', err);
        return NextResponse.json({ error: String(err) }, { status: 500 });
    }
}
