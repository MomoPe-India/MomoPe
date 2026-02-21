import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * process-expiry Edge Function
 * 
 * Purpose: Expire coin batches older than 90 days
 * Trigger: Scheduled cron job (daily 2 AM IST) or authorized internal call
 * Batch Size: 1000 batches per run (prevent timeout)
 * 
 * Security: Requires X-Internal-Secret header to prevent unauthorized triggering.
 * 
 * Flow:
 * 1. Verify caller secret
 * 2. Query coin_batches where expiry_date < today
 * 3. Mark as expired
 * 4. Insert coin_transactions (type='expire')
 * 5. Update momo_coin_balances
 */

serve(async (req) => {
    try {
        // ✅ SECURITY FIX: Prevent anyone from triggering mass coin expiry.
        // This function must only be called by the cron scheduler or trusted internal services.
        const internalSecret = Deno.env.get("INTERNAL_SECRET");
        if (!internalSecret) {
            console.error("[process-expiry] INTERNAL_SECRET not configured");
            return new Response(
                JSON.stringify({ error: "Server misconfiguration" }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }
        const callerSecret = req.headers.get("X-Internal-Secret");
        if (!callerSecret || callerSecret !== internalSecret) {
            console.warn("[process-expiry] Rejected unauthorized request");
            return new Response(
                JSON.stringify({ error: "Forbidden" }),
                { status: 403, headers: { "Content-Type": "application/json" } }
            );
        }

        console.log("Starting coin expiry job:", new Date().toISOString());

        const supabase = createClient(
            Deno.env.get("SUPABASE_URL")!,
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
        );

        // Call database function to expire old coins (idempotent: only targets unexpired batches)
        const { data, error } = await supabase.rpc("expire_old_coins", {
            p_batch_limit: 1000,
        });

        if (error) {
            console.error("Expiry job failed:", error);
            return new Response(
                JSON.stringify({
                    error: "Expiry failed",
                    details: error.message,
                }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        const expiredCount = data || 0;
        console.log(`Expired ${expiredCount} coin batches`);

        return new Response(
            JSON.stringify({
                success: true,
                expired_count: expiredCount,
                timestamp: new Date().toISOString(),
            }),
            { status: 200, headers: { "Content-Type": "application/json" } }
        );
    } catch (error) {
        console.error("Unexpected error:", error);
        return new Response(
            JSON.stringify({ error: "Internal server error" }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
});
