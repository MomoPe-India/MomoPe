// supabase/functions/get-profile/index.ts
//
// Verifies a Firebase ID token via Firebase REST API (identitytoolkit accounts:lookup),
// then returns the user's Supabase profile using the service-role key (bypasses RLS).
//
// verify_jwt=false — Firebase JWTs are not Supabase JWTs.
// The function verifies identity itself via Firebase REST API.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
// Firebase Web API key (client-side key, safe to embed)
const FIREBASE_API_KEY = Deno.env.get('FIREBASE_WEB_API_KEY') ?? 'AIzaSyDsk8QXGdI97hxlLWrRRQ--2jfM_TDgK5o';

const CORS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, content-type, apikey',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req: Request) => {
    if (req.method === 'OPTIONS') return new Response(null, { headers: CORS });

    const json = (body: unknown, status = 200) =>
        new Response(JSON.stringify(body), {
            status,
            headers: { ...CORS, 'Content-Type': 'application/json' },
        });

    // ── Extract Bearer token ─────────────────────────────────────────────────
    const auth = req.headers.get('Authorization') ?? '';
    const idToken = auth.replace(/^Bearer\s+/i, '').trim();
    if (!idToken) return json({ error: 'missing_token' }, 401);

    // ── Verify token via Firebase REST API ──────────────────────────────────
    let uid: string;
    try {
        const firebaseResp = await fetch(
            `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${FIREBASE_API_KEY}`,
            {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ idToken }),
            },
        );

        const payload = await firebaseResp.json() as Record<string, unknown>;

        if (!firebaseResp.ok || payload['error']) {
            console.error('[get-profile] Firebase verify failed:', JSON.stringify(payload));
            return json({ error: 'invalid_token', detail: payload }, 401);
        }

        const users = payload['users'] as Array<{ localId: string }>;
        if (!users || users.length === 0) return json({ error: 'invalid_token' }, 401);

        uid = users[0].localId;
        console.log('[get-profile] Verified UID:', uid);
    } catch (err) {
        console.error('[get-profile] Firebase verify exception:', err);
        return json({ error: 'internal_error', detail: String(err) }, 500);
    }

    // ── Fetch profile from Supabase (service-role bypasses RLS) ─────────────
    const profileUrl =
        `${SUPABASE_URL}/rest/v1/users` +
        `?id=eq.${encodeURIComponent(uid)}` +
        `&select=id,name,phone,role,pin_hash,referral_code,referred_by,created_at`;

    try {
        const dbResp = await fetch(profileUrl, {
            headers: {
                'apikey': SERVICE_ROLE_KEY,
                'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
                'Content-Type': 'application/json',
                'Accept': 'application/vnd.pgrst.object+json',
                'Prefer': 'return=representation',
            },
        });

        // 406 = no row found (single-row mode, no match)
        if (dbResp.status === 406) return json({ uid, profile: null });

        if (!dbResp.ok) {
            const errBody = await dbResp.text();
            console.error('[get-profile] DB error:', errBody);
            return json({ error: 'db_error', detail: errBody }, 500);
        }

        const profile = await dbResp.json();
        console.log('[get-profile] Profile found for UID:', uid);
        return json({ uid, profile });
    } catch (err) {
        console.error('[get-profile] DB fetch exception:', err);
        return json({ error: 'internal_error', detail: String(err) }, 500);
    }
});
