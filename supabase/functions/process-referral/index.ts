// Supabase Edge Function: process-referral
// Triggered by: payu-webhook after a 'success' transaction ≥ ₹100
// Purpose: Award 50 coins to referrer + 50 coins to referee on first qualifying payment

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface ReferralPayload {
    user_id: string;        // The payer (referee) who just completed a payment
    transaction_id: string; // The qualifying transaction
    fiat_amount: number;    // Must be >= 100 to qualify
}

serve(async (req: Request) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        // Only allow POST
        if (req.method !== 'POST') {
            return new Response(
                JSON.stringify({ error: 'Method not allowed' }),
                { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
        }

        const payload: ReferralPayload = await req.json();
        const { user_id, transaction_id, fiat_amount } = payload;

        // Validate required fields
        if (!user_id || !transaction_id) {
            return new Response(
                JSON.stringify({ error: 'Missing required fields: user_id, transaction_id' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
        }

        // Gate: only qualify transactions ≥ ₹100
        if (fiat_amount < 100) {
            return new Response(
                JSON.stringify({ success: false, reason: 'fiat_amount_below_threshold', threshold: 100 }),
                { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
        }

        // Create service-role Supabase client (full DB access, bypasses RLS)
        const supabase = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
            { auth: { persistSession: false } }
        );

        // Quick check: Does this user even have a pending referral?
        // (Avoids DB function call overhead for non-referred users)
        const { data: referral, error: checkError } = await supabase
            .from('referrals')
            .select('id, status')
            .eq('referee_id', user_id)
            .single();

        if (checkError || !referral) {
            // No referral found — this user wasn't referred, nothing to do
            return new Response(
                JSON.stringify({ success: false, reason: 'user_not_referred' }),
                { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
        }

        if (referral.status === 'rewarded') {
            // Already rewarded (idempotency guard)
            return new Response(
                JSON.stringify({ success: false, reason: 'already_rewarded' }),
                { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
        }

        // Call the atomic DB function that credits coins + marks referral as rewarded
        const { data: result, error: fnError } = await supabase.rpc(
            'process_referral_reward',
            { p_referee_id: user_id }
        );

        if (fnError) {
            console.error('[process-referral] DB function error:', fnError);
            return new Response(
                JSON.stringify({ success: false, error: fnError.message }),
                { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
        }

        console.log('[process-referral] Result:', result);

        return new Response(
            JSON.stringify(result),
            { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );

    } catch (err) {
        console.error('[process-referral] Unhandled error:', err);
        return new Response(
            JSON.stringify({ success: false, error: String(err) }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    }
});
