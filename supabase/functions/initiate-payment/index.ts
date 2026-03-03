// supabase/functions/initiate-payment/index.ts
//
// Auth: Firebase ID token verified via Firebase REST API (same as get-profile).
// All DB operations use SUPABASE_SERVICE_ROLE_KEY to bypass RLS.
// Returns signed PayU payment params for the Flutter SDK.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const PAYU_MERCHANT_KEY = Deno.env.get('PAYU_MERCHANT_KEY') || 'U1Zax8';
const PAYU_SALT = Deno.env.get('PAYU_SALT') || 'BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt';
// Firebase Web API key (client-side key, same fallback as get-profile)
const FIREBASE_API_KEY = Deno.env.get('FIREBASE_WEB_API_KEY') ?? 'AIzaSyDsk8QXGdI97hxlLWrRRQ--2jfM_TDgK5o';
const SUPABASE_WEBHOOK = `${SUPABASE_URL}/functions/v1/payu-webhook`;

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });

// ── Firebase JWT verification (same pattern as get-profile) ───────────────────
async function verifyFirebaseToken(idToken: string): Promise<string | null> {
  try {
    const res = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${FIREBASE_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ idToken }),
      },
    );
    const data = await res.json() as Record<string, unknown>;
    if (!res.ok || data['error']) {
      console.error('[initiate-payment] Firebase verify failed:', JSON.stringify(data));
      return null;
    }
    const users = data['users'] as Array<{ localId: string }> | undefined;
    if (!users || users.length === 0) return null;
    return users[0].localId; // Firebase UID
  } catch (e) {
    console.error('[initiate-payment] Firebase verify exception:', e);
    return null;
  }
}

// ── SHA-512 hash for PayU ─────────────────────────────────────────────────────
async function sha512(input: string): Promise<string> {
  const buf = await crypto.subtle.digest('SHA-512', new TextEncoder().encode(input));
  return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, '0')).join('');
}

// ── Supabase REST helper (service-role, bypasses RLS) ────────────────────────
async function dbFetch(path: string, opts: RequestInit = {}): Promise<Response> {
  return fetch(`${SUPABASE_URL}/rest/v1${path}`, {
    ...opts,
    headers: {
      'apikey': SERVICE_ROLE_KEY,
      'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...(opts.headers as Record<string, string> ?? {}),
    },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response(null, { headers: CORS });

  try {
    // ── 1. Verify Firebase token ──────────────────────────────────────────────
    const auth = req.headers.get('Authorization') ?? '';
    const idToken = auth.replace(/^Bearer\s+/i, '').trim();
    if (!idToken) return json({ success: false, error: 'Missing token', code: 'UNAUTHORIZED' }, 401);

    const uid = await verifyFirebaseToken(idToken);
    if (!uid) return json({ success: false, error: 'Invalid Firebase JWT', code: 'UNAUTHORIZED' }, 401);

    // -- Rate limit: max 3 payment initiations per 60 seconds per user --
    const rateLimitWindow = new Date(Date.now() - 60_000).toISOString();
    const rateLimitResp = await dbFetch(
      `/transactions?user_id=eq.${encodeURIComponent(uid)}&created_at=gte.${encodeURIComponent(rateLimitWindow)}&select=id`,
    );
    if (rateLimitResp.ok) {
      const recentTxns = await rateLimitResp.json() as unknown[];
      if (recentTxns.length >= 3) {
        console.warn('[initiate-payment] Rate limit hit for uid:', uid);
        return json({ success: false, error: 'Too many requests. Please wait a moment.', code: 'RATE_LIMITED' }, 429);
      }
    }

    // -- 2. Parse body --
    const body = await req.json() as Record<string, unknown>;
    const merchant_id = body['merchant_id'] as string;
    const gross_amount = body['gross_amount'] as number;
    const coins_to_use = (body['coins_to_use'] as number) ?? 0;

    if (!merchant_id) return json({ success: false, error: 'merchant_id required', code: 'INVALID_INPUT' }, 400);
    if (!gross_amount || gross_amount <= 0) return json({ success: false, error: 'gross_amount must be > 0', code: 'INVALID_INPUT' }, 400);
    if (coins_to_use < 0) return json({ success: false, error: 'coins_to_use must be >= 0', code: 'INVALID_INPUT' }, 400);

    const fiat_amount = gross_amount - coins_to_use;
    if (fiat_amount < 1) return json({ success: false, error: 'Fiat amount must be at least ₹1', code: 'INVALID_INPUT' }, 400);

    // ── 3. Fetch user profile (service-role, bypasses RLS) ───────────────────
    const userResp = await dbFetch(
      `/users?id=eq.${encodeURIComponent(uid)}&select=name,phone`,
      { headers: { 'Accept': 'application/vnd.pgrst.object+json' } },
    );
    if (!userResp.ok) return json({ success: false, error: 'User profile not found', code: 'NOT_FOUND' }, 404);
    const userProfile = await userResp.json() as { name: string; phone: string };

    // ── 4. Validate merchant (approved + active) ──────────────────────────────
    const mResp = await dbFetch(
      `/merchants?id=eq.${encodeURIComponent(merchant_id)}&kyc_status=eq.approved&is_active=eq.true&select=id,business_name,commission_rate`,
      { headers: { 'Accept': 'application/vnd.pgrst.object+json' } },
    );
    if (!mResp.ok) return json({ success: false, error: 'Merchant not found or not approved', code: 'MERCHANT_NOT_APPROVED' }, 404);
    const merchant = await mResp.json() as { id: string; business_name: string; commission_rate: number };

    // ── 5. Validate coin redemption (80% rule) ────────────────────────────────
    if (coins_to_use > 0) {
      const rpcResp = await fetch(
        `${SUPABASE_URL}/rest/v1/rpc/calculate_max_redeemable`,
        {
          method: 'POST',
          headers: {
            'apikey': SERVICE_ROLE_KEY,
            'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ p_user_id: uid, p_bill_amount: gross_amount }),
        },
      );
      const maxRedeemable = rpcResp.ok ? ((await rpcResp.json()) as number) : 0;
      if (coins_to_use > maxRedeemable) {
        return json({ success: false, error: 'coins_to_use exceeds max redeemable (80% rule)', code: 'INSUFFICIENT_BALANCE' }, 400);
      }
    }

    // ── 6. Create transaction record ──────────────────────────────────────────
    // Short txnid: MMO<base36 timestamp><4 random chars> ≈ 16 chars (PayU max 25)
    // IMPORTANT: PayU requires txnid to be STRICTLY ALPHANUMERIC. No underscores!
    const ts36 = Date.now().toString(36).toUpperCase();
    const rnd = Math.random().toString(36).substring(2, 6).toUpperCase();
    const payu_txnid = `MMO${ts36}${rnd}`;

    const txnResp = await dbFetch('/transactions?select=id,payu_txnid', {
      method: 'POST',
      headers: { 'Prefer': 'return=representation' },
      body: JSON.stringify({
        user_id: uid,
        merchant_id: merchant.id,
        gross_amount,
        fiat_amount,
        coins_applied: coins_to_use,
        payu_txnid,
        status: 'initiated',
      }),
    });
    if (!txnResp.ok) {
      const errBody = await txnResp.text();
      console.error('[initiate-payment] txn insert error:', errBody);
      return json({ success: false, error: 'Failed to create transaction', code: 'INTERNAL_ERROR' }, 500);
    }
    const txnArr = await txnResp.json() as Array<{ id: string }>;
    const txn = txnArr[0];

    // ── 7. Lock coins (available → locked) ───────────────────────────────────
    if (coins_to_use > 0) {
      const lockResp = await fetch(`${SUPABASE_URL}/rest/v1/rpc/lock_customer_coins`, {
        method: 'POST',
        headers: {
          'apikey': SERVICE_ROLE_KEY,
          'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ p_user_id: uid, p_coins: coins_to_use }),
      });
      if (!lockResp.ok) {
        const lockErr = await lockResp.text();
        console.error('[initiate-payment] coin lock error:', lockErr);
        await dbFetch(`/transactions?id=eq.${txn.id}`, { method: 'DELETE' });
        return json({ success: false, error: 'Failed to lock coins', code: 'INSUFFICIENT_BALANCE' }, 400);
      }
    }

    // ── 8. Compute PayU HMAC-SHA512 Static Hashes ──────────────────────────────
    const amount = fiat_amount.toFixed(2);
    const productinfo = 'MomoPe Payment';
    const firstname = (userProfile.name || 'Customer').substring(0, 50);
    const email = 'noreply@momope.com';
    const udf1 = txn.id; // transaction UUID for webhook lookup
    const userCredential = `default`; // Optional user credential identifier

    // A. Main Payment Hash
    // FORMAT MUST BE EXACT: key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||SALT
    // Exactly 10 pipes between email and salt.
    // Index mapping from email (index 5) to SALT:
    // 5: email
    // 6: udf1
    // 7: udf2
    // 8: udf3
    // 9: udf4
    // 10: udf5
    // 11: empty
    // 12: empty
    // 13: empty
    // 14: empty
    // 15: empty (10 total pipes between email and SALT)

    const paymentHashInput = `${PAYU_MERCHANT_KEY}|${payu_txnid}|${amount}|${productinfo}|${firstname}|${email}|${udf1}|||||||||${PAYU_SALT}`;
    const paymentHash = await sha512(paymentHashInput);

    // B. payment_related_details_for_mobile_sdk Hash
    // Format: key|payment_related_details_for_mobile_sdk|userCredential|SALT
    const prdHashInput = `${PAYU_MERCHANT_KEY}|payment_related_details_for_mobile_sdk|${userCredential}|${PAYU_SALT}`;
    const prdHash = await sha512(prdHashInput);

    // C. vas_for_mobile_sdk Hash
    // Format: key|vas_for_mobile_sdk|userCredential|SALT
    const vasHashInput = `${PAYU_MERCHANT_KEY}|vas_for_mobile_sdk|${userCredential}|${PAYU_SALT}`;
    const vasHash = await sha512(vasHashInput);

    console.log(`[initiate-payment] Hashes ready. txn=${txn.id} | payu_txnid=${payu_txnid} | fiat=₹${amount}`);

    return json({
      success: true,
      data: {
        transaction_id: txn.id,
        payu_txnid,
        key: PAYU_MERCHANT_KEY,
        amount,
        productinfo,
        firstname,
        email,
        phone: userProfile.phone ?? '',
        userCredential,
        // The three static hashes PayU Checkout Pro requires to initialize:
        payment_hash: paymentHash,
        prd_hash: prdHash,
        vas_hash: vasHash,
        surl: SUPABASE_WEBHOOK,
        furl: SUPABASE_WEBHOOK,
        udf1,
        gross_amount,
        fiat_amount,
        coins_locked: coins_to_use,
        merchant_name: merchant.business_name,
      },
    });

  } catch (e) {
    console.error('[initiate-payment] unhandled error:', e);
    return json({ success: false, error: 'Internal server error', code: 'INTERNAL_ERROR' }, 500);
  }
});
