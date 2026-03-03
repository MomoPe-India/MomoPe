// supabase/functions/payu-webhook/index.ts
//
// Receives PayU payment result callbacks (success/failure).
// Auth: HMAC-SHA512 reverse hash verification (not Firebase JWT)
// Must verify hash BEFORE any DB writes.

import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { crypto as webCrypto } from 'https://deno.land/std@0.208.0/crypto/mod.ts';

function response(body: string, status = 200) {
    return new Response(body, { status, headers: { 'Content-Type': 'text/plain' } });
}

async function sha512(input: string): Promise<string> {
    const buffer = await webCrypto.subtle.digest('SHA-512', new TextEncoder().encode(input));
    return Array.from(new Uint8Array(buffer)).map(b => b.toString(16).padStart(2, '0')).join('');
}

/** Tier-based earn rate by transaction count */
function earnRate(txnCount: number): number {
    if (txnCount <= 1) return 0.10;  // New:     0–1 txns
    if (txnCount <= 5) return 0.09;  // Engaged: 2–5
    if (txnCount <= 20) return 0.08; // Regular: 6–20
    return 0.07;                     // Loyal:   21+
}

serve(async (req) => {
    if (req.method !== 'POST') return response('Method Not Allowed', 405);

    try {
        // PayU sends form-encoded data
        const body = await req.text();
        const params = new URLSearchParams(body);

        const status = params.get('status') ?? '';
        const txnid = params.get('txnid') ?? '';
        const amount = params.get('amount') ?? '';
        const productinfo = params.get('productinfo') ?? '';
        const firstname = params.get('firstname') ?? '';
        const email = params.get('email') ?? '';
        const udf1 = params.get('udf1') ?? '';
        const udf2 = params.get('udf2') ?? '';
        const udf3 = params.get('udf3') ?? '';
        const udf4 = params.get('udf4') ?? '';
        const udf5 = params.get('udf5') ?? '';
        const mihpayid = params.get('mihpayid') ?? '';
        const receivedHash = params.get('hash') ?? '';

        // Fallback to hardcoded test credentials if env secrets are empty
        const payuSalt = Deno.env.get('PAYU_SALT') || 'BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt';
        const payuKey = Deno.env.get('PAYU_MERCHANT_KEY') || 'U1Zax8';

        console.log('[payu-webhook] Incoming txnid:', txnid, '| status:', status, '| mihpayid:', mihpayid);

        // ── HMAC Verification ──────────────────────────────────────────────────
        // PayU reverse hash format:
        // SHA512(SALT|status|udf5|udf4|udf3|udf2|udf1|email|firstname|productinfo|amount|txnid|KEY)
        const reverseHashInput = [
            payuSalt, status, udf5, udf4, udf3, udf2, udf1,
            email, firstname, productinfo, amount, txnid, payuKey,
        ].join('|');

        const computedHash = await sha512(reverseHashInput);

        if (computedHash.toLowerCase() !== receivedHash.toLowerCase()) {
            console.error('[payu-webhook] HMAC MISMATCH — rejecting request. txnid:', txnid);
            return response('Hash mismatch', 403);
        }

        console.log('[payu-webhook] HMAC verified OK for txnid:', txnid);

        // ── Supabase client (service role) ──────────────────────────────────────
        const serviceSupabase = createClient(
            Deno.env.get('SUPABASE_URL')!,
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
        );

        // ── Fetch transaction record ────────────────────────────────────────────
        const { data: txn, error: txnErr } = await serviceSupabase
            .from('transactions')
            .select('id, user_id, merchant_id, gross_amount, fiat_amount, coins_applied, status')
            .eq('payu_txnid', txnid)
            .single();

        if (txnErr || !txn) {
            console.error('[payu-webhook] Transaction not found for txnid:', txnid, txnErr?.message);
            return response('Transaction not found', 404);
        }

        console.log('[payu-webhook] Found txn:', txn.id, 'current status:', txn.status);

        // Idempotency guard — already processed by a previous callback
        if (txn.status === 'success' || txn.status === 'failed') {
            console.log('[payu-webhook] Already processed:', txn.id, txn.status);
            return response('Already processed', 200);
        }

        if (status === 'success') {
            // ── Success path ──────────────────────────────────────────────────
            // Step 1: Move transaction to 'pending' first (required by process_transaction_success)
            const { error: pendErr } = await serviceSupabase
                .from('transactions')
                .update({ status: 'pending', payu_mihpayid: mihpayid })
                .eq('id', txn.id);

            if (pendErr) {
                console.error('[payu-webhook] Failed to move txn to pending:', pendErr.message);
                return response('DB update failed', 500);
            }

            console.log('[payu-webhook] Moved txn to pending');

            // Step 2: Count user's successful txns to determine earn rate tier
            const { count: txnCount } = await serviceSupabase
                .from('transactions')
                .select('*', { count: 'exact', head: true })
                .eq('user_id', txn.user_id)
                .eq('status', 'success');

            let rate = earnRate((txnCount ?? 0) + 1); // +1 for this new transaction
            if (txn.gross_amount >= 5000) rate += 0.01; // large txn bonus

            const coins_to_award = Math.floor(txn.fiat_amount * rate);
            console.log('[payu-webhook] Awarding coins:', coins_to_award, 'at rate', rate, 'for fiat_amount:', txn.fiat_amount);

            // Step 3: Atomically process success (redeem old + award new + commission + mark success)
            const { error: processErr } = await serviceSupabase.rpc('process_transaction_success', {
                p_transaction_id: txn.id,
                p_mihpayid: mihpayid,
                p_coins_to_award: coins_to_award,
            });

            if (processErr) {
                console.error('[payu-webhook] process_transaction_success failed:', processErr.message);
                return response('Processing failed', 500);
            }

            console.log('[payu-webhook] ✅ Transaction success processed. coins_awarded:', coins_to_award);

            // Step 4: Fire-and-forget side effects
            const surl = Deno.env.get('SUPABASE_URL')!;
            const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

            // Check if this is user's first transaction (trigger referral reward)
            const { count: successCount } = await serviceSupabase
                .from('transactions')
                .select('*', { count: 'exact', head: true })
                .eq('user_id', txn.user_id)
                .eq('status', 'success');

            if (successCount === 1) {
                fetch(`${surl}/functions/v1/process-referral`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${serviceKey}`,
                    },
                    body: JSON.stringify({ transaction_id: txn.id, user_id: txn.user_id }),
                }).catch(e => console.error('[payu-webhook] referral error:', e));
            }

            // Notify customer
            fetch(`${surl}/functions/v1/send-notification`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${serviceKey}` },
                body: JSON.stringify({
                    user_id: txn.user_id,
                    type: 'payment_success',
                    data: { transaction_id: txn.id, coins_earned: coins_to_award },
                }),
            }).catch(e => console.error('[payu-webhook] notify customer error:', e));

            // Notify merchant
            const { data: merchant } = await serviceSupabase
                .from('merchants')
                .select('user_id')
                .eq('id', txn.merchant_id)
                .single();
            if (merchant) {
                fetch(`${surl}/functions/v1/send-notification`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${serviceKey}` },
                    body: JSON.stringify({
                        user_id: merchant.user_id,
                        type: 'new_payment_received',
                        data: { amount: txn.gross_amount },
                    }),
                }).catch(e => console.error('[payu-webhook] notify merchant error:', e));
            }

        } else {
            // ── Failure path ──────────────────────────────────────────────────
            await serviceSupabase
                .from('transactions')
                .update({ status: 'failed', payu_mihpayid: mihpayid })
                .eq('id', txn.id);

            // Unlock locked coins (if any were applied during initiation)
            if (txn.coins_applied > 0) {
                await serviceSupabase.rpc('unlock_coins_on_failure', {
                    p_user_id: txn.user_id,
                    p_amount: txn.coins_applied,
                });
            }

            console.log('[payu-webhook] ❌ Transaction failed:', txn.id);

            const surl = Deno.env.get('SUPABASE_URL')!;
            const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
            fetch(`${surl}/functions/v1/send-notification`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${serviceKey}` },
                body: JSON.stringify({ user_id: txn.user_id, type: 'payment_failure', data: {} }),
            }).catch(e => console.error('[payu-webhook] notify failure error:', e));
        }

        return response('OK', 200);

    } catch (e) {
        console.error('[payu-webhook] unhandled error:', e);
        return response('Internal Server Error', 500);
    }
});
