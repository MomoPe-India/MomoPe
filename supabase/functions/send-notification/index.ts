import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * send-notification Edge Function
 *
 * Sends FCM push notifications via Firebase HTTP v1 API
 * Uses service account key stored in Supabase Vault
 *
 * Body: { user_id?, merchant_id?, title, body, data? }
 *
 * Security: Requires X-Internal-Secret header to prevent public abuse.
 * Only trusted edge functions (payu-webhook, etc.) may call this.
 */

// -------------------------------------------------------------------------
// JWT helper: sign a service account JWT for FCM OAuth2
// -------------------------------------------------------------------------
async function getAccessToken(serviceAccount: Record<string, string>): Promise<string> {
    const now = Math.floor(Date.now() / 1000);
    const header = { alg: "RS256", typ: "JWT" };
    const payload = {
        iss: serviceAccount.client_email,
        scope: "https://www.googleapis.com/auth/firebase.messaging",
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
    };

    const encode = (obj: object) =>
        btoa(JSON.stringify(obj))
            .replace(/\+/g, "-")
            .replace(/\//g, "_")
            .replace(/=/g, "");

    const signingInput = `${encode(header)}.${encode(payload)}`;

    // Import the private key
    const privateKeyPem = serviceAccount.private_key
        .replace(/\\n/g, "\n")
        .replace("-----BEGIN PRIVATE KEY-----", "")
        .replace("-----END PRIVATE KEY-----", "")
        .replace(/\s/g, "");

    const keyData = Uint8Array.from(atob(privateKeyPem), (c) => c.charCodeAt(0));

    const cryptoKey = await crypto.subtle.importKey(
        "pkcs8",
        keyData,
        { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
        false,
        ["sign"]
    );

    const signature = await crypto.subtle.sign(
        "RSASSA-PKCS1-v1_5",
        cryptoKey,
        new TextEncoder().encode(signingInput)
    );

    const sigB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
        .replace(/\+/g, "-")
        .replace(/\//g, "_")
        .replace(/=/g, "");

    const jwt = `${signingInput}.${sigB64}`;

    // Exchange JWT for access token
    const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
    });

    const tokenData = await tokenRes.json();
    if (!tokenData.access_token) {
        throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`);
    }
    return tokenData.access_token;
}

// -------------------------------------------------------------------------
// Send one FCM message
// -------------------------------------------------------------------------
async function sendFcmMessage(
    fcmToken: string,
    title: string,
    body: string,
    data: Record<string, string>,
    projectId: string,
    accessToken: string
): Promise<boolean> {
    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    const message = {
        message: {
            token: fcmToken,
            notification: { title, body },
            data,
            android: {
                notification: {
                    channel_id: "momope_payments",
                    priority: "high",
                },
                priority: "high",
            },
        },
    };

    const res = await fetch(url, {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${accessToken}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify(message),
    });

    const result = await res.json();
    if (!res.ok) {
        console.error("[send-notification] FCM error:", result);
        return false;
    }

    console.log("[send-notification] FCM sent:", result.name);
    return true;
}

// -------------------------------------------------------------------------
// Main handler
// -------------------------------------------------------------------------
serve(async (req) => {
    try {
        if (req.method !== "POST") {
            return new Response("Method not allowed", { status: 405 });
        }

        // ✅ SECURITY FIX: Verify internal secret to prevent public abuse.
        // Only trusted internal edge functions (payu-webhook, etc.) may call this.
        const internalSecret = Deno.env.get("INTERNAL_SECRET");
        if (!internalSecret) {
            console.error("[send-notification] INTERNAL_SECRET not configured");
            return new Response("Server misconfiguration", { status: 500 });
        }
        const callerSecret = req.headers.get("X-Internal-Secret");
        if (!callerSecret || callerSecret !== internalSecret) {
            console.warn("[send-notification] Rejected request with invalid or missing X-Internal-Secret");
            return new Response("Forbidden", { status: 403 });
        }

        const {
            user_id,
            merchant_id,
            title,
            body,
            data = {},
        } = await req.json();

        if (!title || !body) {
            return new Response("title and body are required", { status: 400 });
        }

        if (!user_id && !merchant_id) {
            return new Response("user_id or merchant_id is required", { status: 400 });
        }

        // 1. Get service account from Vault
        const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
        if (!serviceAccountJson) {
            console.error("[send-notification] FIREBASE_SERVICE_ACCOUNT not set");
            return new Response("Not configured", { status: 500 });
        }

        const serviceAccount = JSON.parse(serviceAccountJson);
        const projectId = serviceAccount.project_id;

        // 2. Get FCM access token
        const accessToken = await getAccessToken(serviceAccount);

        // 3. Look up FCM token from Supabase
        const supabase = createClient(
            Deno.env.get("SUPABASE_URL")!,
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
        );

        let fcmToken: string | null = null;

        if (user_id) {
            const { data: user } = await supabase
                .from("users")
                .select("fcm_token")
                .eq("id", user_id)
                .single();
            fcmToken = user?.fcm_token ?? null;
        } else if (merchant_id) {
            const { data: merchant } = await supabase
                .from("merchants")
                .select("fcm_token")
                .eq("id", merchant_id)
                .single();
            fcmToken = merchant?.fcm_token ?? null;
        }

        if (!fcmToken) {
            console.log("[send-notification] No FCM token found — user may not have granted permission");
            return new Response("No FCM token", { status: 200 }); // Not an error
        }

        // 4. Send the notification
        const sent = await sendFcmMessage(
            fcmToken,
            title,
            body,
            { ...data, click_action: "FLUTTER_NOTIFICATION_CLICK" },
            projectId,
            accessToken
        );

        return new Response(
            JSON.stringify({ success: sent }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    } catch (error) {
        console.error("[send-notification] Error:", error);
        return new Response("Internal server error", { status: 500 });
    }
});
