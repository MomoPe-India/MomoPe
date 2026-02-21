// Deno edge function to initiate payment
// ✅ FIX: Use auth client for cryptographic JWT verification (not manual base64 decode)
// ✅ FIX: Server-side validation of payment amounts to prevent manipulation
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
        const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
        const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
        const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

        // Service role client for database operations (bypasses RLS)
        const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

        // ✅ SECURITY FIX: Verify JWT cryptographically using Supabase auth client.
        // The old approach (atob(token.split('.')[1])) only base64-decoded the payload
        // without verifying the signature — a tampered token with a different user ID
        // would have passed. This uses the auth gateway to fully verify the token.
        const authHeader = req.headers.get('Authorization');
        if (!authHeader) {
            return new Response(
                JSON.stringify({ error: 'Missing Authorization header' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 401 }
            );
        }

        // Create a user-scoped client to verify the JWT via Supabase auth
        const supabaseUser = createClient(supabaseUrl, supabaseAnonKey, {
            global: { headers: { Authorization: authHeader } },
        });

        const { data: { user }, error: authError } = await supabaseUser.auth.getUser();

        if (authError || !user) {
            console.error('❌ Auth verification failed:', authError?.message);
            return new Response(
                JSON.stringify({ error: 'Unauthorized: invalid or expired token' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 401 }
            );
        }

        const userId = user.id;
        console.log('✅ Processing transaction for user:', user.email || userId);

        // Parse request body
        const {
            transactionId,
            merchantId,
            grossAmount,
            fiatAmount,
            coinsApplied,
        } = await req.json();

        // ✅ SECURITY FIX: Server-side validation of payment amounts.
        // Without this, a malicious client could send fiatAmount=0.01 and grossAmount=10000
        // to earn maximum coins for a near-zero payment.
        if (!transactionId || typeof transactionId !== 'string') {
            return new Response(
                JSON.stringify({ error: 'Invalid transactionId' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
            );
        }
        if (!merchantId || typeof merchantId !== 'string') {
            return new Response(
                JSON.stringify({ error: 'Invalid merchantId' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
            );
        }

        const parsedGross = Number(grossAmount);
        const parsedFiat = Number(fiatAmount);
        const parsedCoins = Number(coinsApplied ?? 0);

        if (!isFinite(parsedGross) || parsedGross <= 0) {
            return new Response(
                JSON.stringify({ error: 'grossAmount must be a positive number' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
            );
        }
        if (!isFinite(parsedFiat) || parsedFiat < 0) {
            return new Response(
                JSON.stringify({ error: 'fiatAmount must be a non-negative number' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
            );
        }
        if (parsedFiat > parsedGross) {
            return new Response(
                JSON.stringify({ error: 'fiatAmount cannot exceed grossAmount' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
            );
        }
        if (!isFinite(parsedCoins) || parsedCoins < 0) {
            return new Response(
                JSON.stringify({ error: 'coinsApplied must be a non-negative number' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
            );
        }
        // Sanity check: coins_applied = gross - fiat (within rounding tolerance)
        const expectedFiat = parsedGross - parsedCoins;
        if (Math.abs(expectedFiat - parsedFiat) > 1) { // 1 rupee tolerance for rounding
            return new Response(
                JSON.stringify({ error: 'Amount mismatch: grossAmount - coinsApplied ≠ fiatAmount' }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
            );
        }

        console.log('Creating transaction:', {
            transactionId,
            userId,
            merchantId,
            grossAmount: parsedGross,
            fiatAmount: parsedFiat,
            coinsApplied: parsedCoins,
        });

        // Create transaction with service role (bypasses RLS)
        const { data: transaction, error: txError } = await supabaseAdmin
            .from('transactions')
            .insert({
                id: transactionId,
                user_id: userId,
                merchant_id: merchantId,
                gross_amount: parsedGross,
                fiat_amount: parsedFiat,
                coins_applied: parsedCoins,
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
        const message = error instanceof Error ? error.message : String(error);
        return new Response(
            JSON.stringify({ error: message }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 400,
            },
        );
    }
});
