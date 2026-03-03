// supabase/functions/process-referral/index.ts
//
// Called by payu-webhook on user's FIRST successful transaction.
// Checks for a pending referral and awards coins to both parties.

import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
    const authHeader = req.headers.get('Authorization') ?? '';
    if (!authHeader.includes(Deno.env.get('SB_SERVICE_ROLE_KEY') ?? 'MISSING')) {
        return new Response('Unauthorized', { status: 401 });
    }

    try {
        const { user_id } = await req.json();
        if (!user_id) return new Response('user_id required', { status: 400 });

        const serviceSupabase = createClient(
            Deno.env.get('SUPABASE_URL')!,
            Deno.env.get('SB_SERVICE_ROLE_KEY')!
        );

        // Find pending referral where this user is the referee
        const { data: referral } = await serviceSupabase
            .from('referrals')
            .select('id')
            .eq('referee_id', user_id)
            .eq('status', 'pending')
            .maybeSingle();

        if (!referral) {
            console.log('No pending referral for user:', user_id);
            return new Response(JSON.stringify({ skipped: true }), {
                headers: { 'Content-Type': 'application/json' },
            });
        }

        const { error } = await serviceSupabase.rpc('process_referral_reward', {
            p_referral_id: referral.id,
        });

        if (error) throw error;

        console.log('Referral processed:', referral.id);
        return new Response(JSON.stringify({ success: true, referral_id: referral.id }), {
            headers: { 'Content-Type': 'application/json' },
        });
    } catch (e) {
        console.error('process-referral error:', e);
        return new Response(JSON.stringify({ error: String(e) }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        });
    }
});
