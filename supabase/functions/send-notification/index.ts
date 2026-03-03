// supabase/functions/send-notification/index.ts
//
// Sends FCM push notification to a user via their registered device tokens.
// Uses Firebase Admin REST API (not SDK — Deno compatible).

import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ── Notification templates ────────────────────────────────────────────────

type NotifType =
    | 'payment_success'
    | 'payment_failure'
    | 'coins_expiring'
    | 'referral_completed'
    | 'kyc_approved'
    | 'kyc_rejected'
    | 'new_payment_received';

function buildNotification(type: NotifType, data: Record<string, unknown>): { title: string; body: string } {
    switch (type) {
        case 'payment_success':
            return {
                title: 'Payment Successful 🎉',
                body: `You earned ${data['coins_earned']} Momo Coins!`,
            };
        case 'payment_failure':
            return {
                title: 'Payment Failed',
                body: 'Your payment could not be completed. Your coins have been restored.',
            };
        case 'coins_expiring':
            return {
                title: '⏰ Coins Expiring Soon!',
                body: `${data['coins']} coins expire in 7 days. Use them before they\'re gone!`,
            };
        case 'referral_completed':
            return {
                title: 'Referral Bonus 🤝',
                body: `Your friend joined MomoPe! You earned ${data['coins']} bonus coins.`,
            };
        case 'kyc_approved':
            return {
                title: 'KYC Approved ✅',
                body: 'Your business is now verified on MomoPe. Start accepting payments!',
            };
        case 'kyc_rejected':
            return {
                title: 'KYC Rejected',
                body: `Reason: ${data['reason'] ?? 'Please review and resubmit.'}`,
            };
        case 'new_payment_received':
            return {
                title: 'Payment Received 💰',
                body: `₹${data['amount']} payment received.`,
            };
        default:
            return { title: 'MomoPe', body: 'You have a new notification.' };
    }
}

// ── Get Firebase OAuth 2.0 access token for FCM v1 API ───────────────────

async function getAccessToken(): Promise<string> {
    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
    if (!serviceAccountJson) throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON not set');

    const sa = JSON.parse(serviceAccountJson);

    const now = Math.floor(Date.now() / 1000);
    const header = btoa(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
    const claimset = btoa(JSON.stringify({
        iss: sa.client_email,
        scope: 'https://www.googleapis.com/auth/firebase.messaging',
        aud: 'https://oauth2.googleapis.com/token',
        iat: now,
        exp: now + 3600,
    }));

    const signingInput = `${header}.${claimset}`;
    const encoder = new TextEncoder();
    const keyData = sa.private_key
        .replace(/-----BEGIN PRIVATE KEY-----/, '')
        .replace(/-----END PRIVATE KEY-----/, '')
        .replace(/\n/g, '');
    const binaryKey = Uint8Array.from(atob(keyData), c => c.charCodeAt(0));
    const privateKey = await crypto.subtle.importKey(
        'pkcs8', binaryKey,
        { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
        false, ['sign'],
    );
    const sig = await crypto.subtle.sign(
        'RSASSA-PKCS1-v1_5', privateKey, encoder.encode(signingInput));
    const sigBase64 = btoa(String.fromCharCode(...new Uint8Array(sig)));
    const jwt = `${signingInput}.${sigBase64}`;

    const tokenResp = await fetch('https://oauth2.googleapis.com/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            assertion: jwt,
        }),
    });
    const tokenData = await tokenResp.json();
    return tokenData.access_token;
}

// ── Main handler ──────────────────────────────────────────────────────────

serve(async (req) => {
    const authHeader = req.headers.get('Authorization') ?? '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    if (!serviceKey || !authHeader.includes(serviceKey)) {
        return new Response('Unauthorized', { status: 401 });
    }

    try {
        const { user_id, type, data } = await req.json() as {
            user_id: string;
            type: NotifType;
            data: Record<string, unknown>;
        };

        const serviceSupabase = createClient(
            Deno.env.get('SUPABASE_URL')!,
            serviceKey,
        );

        // Get all FCM tokens for user
        const { data: tokens, error: tokenErr } = await serviceSupabase
            .from('fcm_tokens')
            .select('device_token')
            .eq('user_id', user_id);

        if (tokenErr || !tokens || tokens.length === 0) {
            console.log('No FCM tokens for user:', user_id);
            return new Response(JSON.stringify({ skipped: true }), {
                headers: { 'Content-Type': 'application/json' },
            });
        }

        const { title, body } = buildNotification(type, data);
        const projectId = Deno.env.get('FIREBASE_PROJECT_ID')!;
        const accessToken = await getAccessToken();

        // Send to each token
        const results = await Promise.allSettled(
            tokens.map(({ device_token }) =>
                fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
                    method: 'POST',
                    headers: {
                        Authorization: `Bearer ${accessToken}`,
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        message: {
                            token: device_token,
                            notification: { title, body },
                            android: { priority: 'HIGH' },
                            data: Object.fromEntries(
                                Object.entries(data).map(([k, v]) => [k, String(v)])
                            ),
                        },
                    }),
                })
            )
        );

        const sent = results.filter(r => r.status === 'fulfilled').length;
        const failed = results.filter(r => r.status === 'rejected').length;

        console.log(`Notifications: ${sent} sent, ${failed} failed`);
        return new Response(JSON.stringify({ success: true, sent, failed }), {
            headers: { 'Content-Type': 'application/json' },
        });

    } catch (e) {
        console.error('send-notification error:', e);
        return new Response(JSON.stringify({ error: String(e) }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        });
    }
});
