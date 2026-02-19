// Deno edge function to initiate payment
// ✅ FIX: Trust Supabase auth gateway, extract user ID from validated JWT
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        // Service role client for database operations
        const supabaseAdmin = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
        );

        // ✅ FIX: Extract user ID from JWT payload (already validated by Supabase gateway)
        const authHeader = req.headers.get('Authorization');

        if (!authHeader) {
            throw new Error('Missing Authorization header');
        }

        const token = authHeader.replace('Bearer ', '');

        // Decode JWT payload (Supabase gateway already validated it)
        let userId: string;
        try {
            const payload = JSON.parse(atob(token.split('.')[1]));
            userId = payload.sub;

            if (!userId) {
                throw new Error('Missing user ID in token');
            }

            console.log('✅ Processing transaction for user:', payload.email || userId);
        } catch (decodeError) {
            console.error('❌ Failed to decode JWT:', decodeError);
            throw new Error('Invalid token format');
        }

        // Parse request body
        const {
            transactionId,
            merchantId,
            grossAmount,
            fiatAmount,
            coinsApplied,
        } = await req.json();

        console.log('Creating transaction:', {
            transactionId,
            userId,
            merchantId,
            grossAmount,
            fiatAmount,
            coinsApplied,
        });

        // Create transaction with service role (bypasses RLS)
        const { data: transaction, error: txError } = await supabaseAdmin
            .from('transactions')
            .insert({
                id: transactionId,
                user_id: userId,
                merchant_id: merchantId,
                gross_amount: grossAmount,
                fiat_amount: fiatAmount,
                coins_applied: coinsApplied,
                status: 'initiated',
            })
            .select()
            .single();

        if (txError) {
            console.error('❌ Transaction creation error:', txError);
            throw txError;
        }

        console.log('✅ Transaction created successfully:', transaction.id);

        return new Response(
            JSON.stringify({ success: true, transaction }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            },
        );
    } catch (error) {
        console.error('❌ Edge function error:', error);
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 400,
            },
        );
    }
});
