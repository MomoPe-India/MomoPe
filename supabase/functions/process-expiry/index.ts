// supabase/functions/process-expiry/index.ts
//
// Triggered nightly by pg_cron. Expires coin batches past their 90-day window.
// Auth: Service role (called from pg_cron via http_post, not from clients)

import { serve } from 'https://deno.land/std@0.208.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
    // Basic auth check: only service role (from pg_cron) can call this
    const authHeader = req.headers.get('Authorization') ?? '';
    if (!authHeader.includes(Deno.env.get('SB_SERVICE_ROLE_KEY') ?? 'MISSING')) {
        return new Response('Unauthorized', { status: 401 });
    }

    try {
        const serviceSupabase = createClient(
            Deno.env.get('SUPABASE_URL')!,
            Deno.env.get('SB_SERVICE_ROLE_KEY')!
        );

        const { data, error } = await serviceSupabase.rpc('expire_old_coins');
        if (error) throw error;

        console.log('Expiry job result:', data);
        return new Response(JSON.stringify({ success: true, result: data }), {
            headers: { 'Content-Type': 'application/json' },
        });
    } catch (e) {
        console.error('process-expiry error:', e);
        return new Response(JSON.stringify({ error: String(e) }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        });
    }
});
