import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * process-expiry Edge Function
 * 
 * Purpose: Expire coin batches older than 90 days
 * Trigger: Scheduled cron job (daily 2 AM IST)
 * Batch Size: 1000 batches per run (prevent timeout)
 * 
 * Flow:
 * 1. Query coin_batches where expiry_date < today
 * 2. Mark as expired
 * 3. Insert coin_transactions (type='expire')
 * 4. Update momo_coin_balances
 */

serve(async (req) => {
    try {
        console.log("Starting coin expiry job:", new Date().toISOString());

        const supabase = createClient(
            Deno.env.get("SUPABASE_URL")!,
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
        );

        // Call database function to expire old coins
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
