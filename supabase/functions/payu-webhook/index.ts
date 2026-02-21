import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createHmac } from "https://deno.land/std@0.168.0/node/crypto.ts";

/**
 * payu-webhook Edge Function
 * 
 * Purpose: Process PayU payment webhook, award coins, calculate commissions
 * Trigger: POST from PayU after payment completion
 * Security: HMAC-SHA512 signature verification (CRITICAL)
 * 
 * Flow:
 * 1. Verify PayU signature (prevent fraud)
 * 2. Fetch transaction and merchant details
 * 3. Calculate commission breakdown
 * 4. Process coin redemption (FIFO)
 * 5. Award new coins (10% of fiat paid)
 * 6. Update transaction status
 */

interface PayUWebhookParams {
    key: string;
    txnid: string;
    amount: string;
    productinfo: string;
    firstname: string;
    email: string;
    mihpayid: string;
    status: string;
    hash: string;
    [key: string]: string; // Allow additional fields
}

serve(async (req) => {
    try {
        // Only allow POST requests
        if (req.method !== "POST") {
            return new Response("Method not allowed", { status: 405 });
        }

        // Parse form data (PayU sends application/x-www-form-urlencoded)
        const formData = await req.formData();
        const params: PayUWebhookParams = Object.fromEntries(
            formData
        ) as PayUWebhookParams;

        console.log("PayU Webhook received:", {
            txnid: params.txnid,
            status: params.status,
            amount: params.amount,
        });

        // ========================================================================
        // STEP 1: VERIFY PAYU SIGNATURE (CRITICAL SECURITY)
        // ========================================================================
        const salt = Deno.env.get("PAYU_SALT");
        if (!salt) {
            console.error("PAYU_SALT not configured");
            return new Response("Configuration error", { status: 500 });
        }

        const {
            key,
            txnid,
            amount,
            productinfo,
            firstname,
            email,
            mihpayid,
            status,
            hash: receivedHash,
        } = params;

        // Construct hash string (reverse order for response)
        const hashData = `${salt}|${status}||||||||||${email}|${firstname}|${productinfo}|${amount}|${txnid}|${key}`;
        const expectedHash = createHmac("sha512", salt)
            .update(hashData)
            .digest("hex");

        if (expectedHash !== receivedHash) {
            console.error("Invalid PayU signature", {
                expected: expectedHash,
                received: receivedHash,
            });
            return new Response("Unauthorized", { status: 401 });
        }

        console.log("Signature verified successfully");

        // ========================================================================
        // STEP 2: HANDLE NON-SUCCESS STATUSES
        // ========================================================================
        if (status !== "success") {
            const supabase = createClient(
                Deno.env.get("SUPABASE_URL")!,
                Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
            );

            await supabase
                .from("transactions")
                .update({ status: "failed" })
                .eq("id", txnid);

            return new Response("Payment failed", { status: 200 });
        }

        // ========================================================================
        // STEP 3: FETCH TRANSACTION AND MERCHANT DETAILS
        // ========================================================================
        const supabase = createClient(
            Deno.env.get("SUPABASE_URL")!,
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
        );

        const { data: transaction, error: txnError } = await supabase
            .from("transactions")
            .select(
                `
        id,
        user_id,
        merchant_id,
        gross_amount,
        fiat_amount,
        coins_applied,
        status,
        merchants (
          commission_rate
        )
      `
            )
            .eq("id", txnid)
            .single();

        if (txnError || !transaction) {
            console.error("Transaction not found:", txnid, txnError);
            return new Response("Transaction not found", { status: 404 });
        }

        if (transaction.status !== "initiated") {
            console.log("Transaction already processed:", transaction.status);
            return new Response("Already processed", { status: 200 });
        }

        // ========================================================================
        // STEP 4: CALCULATE MOMOPE REWARD PERCENTAGE (ALGORITHMIC)
        // ========================================================================

        // Parse transaction amounts first (needed for algorithm)
        const grossAmount = parseFloat(transaction.gross_amount);
        const fiatAmount = parseFloat(transaction.fiat_amount);
        const coinsApplied = parseFloat(transaction.coins_applied);

        /**
         * MomoPe Reward Algorithm (PRODUCTION)
         * 
         * Dynamically calculates reward percentage (2%-10%) based on:
         * 1. User Tier (transaction history)
         * 2. Platform Sustainability (liability management)
         * 3. Transaction Value (tiered rewards)
         * 4. Time-Based Factors (promotions, peak hours)
         * 
         * NOT merchant-specific - same algorithm applies to ALL merchants
         */
        async function calculateMomoPeReward(
            userId: string,
            fiatAmount: number,
            supabase: any
        ): Promise<number> {
            // =================================================================
            // STEP 1: BASE REWARD (User Guarantee)
            // =================================================================
            let rewardPercentage = 0.10; // Start at maximum 10%

            // =================================================================
            // STEP 2: USER TIER ANALYSIS (Transaction History)
            // =================================================================
            try {
                // Fetch user's transaction count
                const { count: txnCount } = await supabase
                    .from("transactions")
                    .select("*", { count: "exact", head: true })
                    .eq("user_id", userId)
                    .eq("status", "success");

                // User Tier Logic
                if (txnCount === 0 || txnCount === 1) {
                    // NEW USER BOOST: First transaction gets maximum rewards
                    rewardPercentage = 0.10; // 10% (acquisition incentive)
                    console.log(`User tier: NEW (txn ${txnCount}) → 10% reward`);
                } else if (txnCount >= 2 && txnCount <= 5) {
                    // ENGAGED USER: Maintain high rewards to build habit
                    rewardPercentage = 0.09; // 9%
                    console.log(`User tier: ENGAGED (${txnCount} txns) → 9% reward`);
                } else if (txnCount >= 6 && txnCount <= 20) {
                    // REGULAR USER: Slightly lower but still attractive
                    rewardPercentage = 0.08; // 8%
                    console.log(`User tier: REGULAR (${txnCount} txns) → 8% reward`);
                } else {
                    // LOYAL USER: Moderate rewards (already retained)
                    rewardPercentage = 0.07; // 7%
                    console.log(`User tier: LOYAL (${txnCount} txns) → 7% reward`);
                }
            } catch (error) {
                console.error("User tier calculation error:", error);
                // Default to 10% on error (safe fallback)
                rewardPercentage = 0.10;
            }

            // =================================================================
            // STEP 3: PLATFORM SUSTAINABILITY (Liability Management)
            // =================================================================
            try {
                // Get total platform liability (unexpired coins)
                const { data: totalLiability } = await supabase.rpc(
                    "get_total_coin_liability"
                );

                const liabilityThreshold = 100000; // ₹1 Lakh threshold

                if (totalLiability && totalLiability > liabilityThreshold) {
                    // High liability → Reduce rewards to manage risk
                    const reductionFactor = 0.02; // Reduce by 2%
                    rewardPercentage -= reductionFactor;
                    console.log(
                        `Platform liability: ₹${totalLiability} (> threshold) → Reduced by ${reductionFactor * 100}%`
                    );
                }
            } catch (error) {
                console.error("Liability calculation error:", error);
                // Continue without adjustment on error
            }

            // =================================================================
            // STEP 4: TRANSACTION VALUE TIERS (Encourage Higher GMV)
            // =================================================================
            if (fiatAmount >= 5000) {
                // HIGH-VALUE: Bonus for large transactions
                rewardPercentage += 0.01; // +1% bonus
                console.log(`High-value txn: ₹${fiatAmount} → +1% bonus`);
            } else if (fiatAmount < 100) {
                // MICRO-TRANSACTION: Reduce rewards for very small txns
                rewardPercentage -= 0.02; // -2%
                console.log(`Micro txn: ₹${fiatAmount} → -2% penalty`);
            }

            // =================================================================
            // STEP 5: TIME-BASED FACTORS (Promotions, Peak Hours)
            // =================================================================
            const currentHour = new Date().getHours();
            const dayOfWeek = new Date().getDay();

            // Weekend boost (Saturday = 6, Sunday = 0)
            if (dayOfWeek === 0 || dayOfWeek === 6) {
                rewardPercentage += 0.005; // +0.5% on weekends
                console.log("Weekend boost: +0.5%");
            }

            // Off-peak hours boost (10 AM - 4 PM)
            if (currentHour >= 10 && currentHour < 16) {
                rewardPercentage += 0.005; // +0.5% during off-peak
                console.log("Off-peak hours: +0.5%");
            }

            // =================================================================
            // STEP 6: ENFORCE BOUNDARIES (2% - 10%)
            // =================================================================
            rewardPercentage = Math.max(0.02, Math.min(0.10, rewardPercentage));

            console.log(
                `Final reward percentage: ${(rewardPercentage * 100).toFixed(2)}%`
            );

            return rewardPercentage;
        }

        // Calculate reward percentage (MomoPe algorithm, NOT merchant data)
        const rewardPercentage = await calculateMomoPeReward(
            transaction.user_id,
            fiatAmount,
            supabase
        );

        // ========================================================================
        // STEP 5: CALCULATE COMMISSION BREAKDOWN
        // ========================================================================
        const commissionRate = transaction.merchants.commission_rate;

        const totalCommission = grossAmount * commissionRate;
        const coinsEarned = Math.floor(fiatAmount * rewardPercentage); // ALGORITHMIC
        const rewardCost = coinsEarned * 1.0;
        const netRevenue = totalCommission - rewardCost;

        console.log("Commission calculation:", {
            grossAmount,
            fiatAmount,
            commissionRate,
            rewardPercentage, // Logged for transparency
            coinsEarned,
            rewardCost,
            netRevenue,
        });

        // ========================================================================
        // STEP 5: PROCESS TRANSACTION (ATOMIC)
        // ========================================================================
        const { error: processError } = await supabase.rpc(
            "process_transaction_success",
            {
                p_transaction_id: txnid,
                p_payu_mihpayid: mihpayid,
                p_total_commission: totalCommission,
                p_reward_cost: rewardCost,
                p_net_revenue: netRevenue,
                p_coins_to_redeem: coinsApplied,
                p_coins_to_earn: coinsEarned,
            }
        );

        if (processError) {
            console.error("Transaction processing failed:", processError);
            return new Response("Processing failed", { status: 500 });
        }

        console.log("Transaction processed successfully:", txnid);

        // ========================================================================
        // STEP 6: TRIGGER REFERRAL REWARD (if applicable)
        // Fire-and-forget: process-referral checks if user was referred
        // Only triggers on qualifying payments (fiat_amount >= 100)
        // ========================================================================
        if (fiatAmount >= 100) {
            const referralUrl = `${Deno.env.get('SUPABASE_URL')}/functions/v1/process-referral`;
            fetch(referralUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`,
                    'X-Internal-Secret': Deno.env.get('INTERNAL_SECRET') ?? '',
                },
                body: JSON.stringify({
                    user_id: transaction.user_id,
                    transaction_id: txnid,
                    fiat_amount: fiatAmount,
                }),
            }).catch((err: Error) => console.warn('[payu-webhook] Referral trigger failed (non-critical):', err));
        }

        // ========================================================================
        // STEP 7: SEND PUSH NOTIFICATIONS (Fire-and-forget)
        // ========================================================================
        const notifyUrl = `${Deno.env.get('SUPABASE_URL')}/functions/v1/send-notification`;
        // ✅ Include X-Internal-Secret so send-notification can verify this is a trusted caller
        const notifyHeaders = {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`,
            'X-Internal-Secret': Deno.env.get('INTERNAL_SECRET') ?? '',
        };

        // Notify user: payment success + coins earned
        fetch(notifyUrl, {
            method: 'POST',
            headers: notifyHeaders,
            body: JSON.stringify({
                user_id: transaction.user_id,
                title: '✅ Payment Successful!',
                body: `₹${fiatAmount.toFixed(0)} paid. You earned ${coinsEarned} MomoPe coins! 🎉`,
                data: {
                    type: 'payment_success',
                    transaction_id: txnid,
                    coins_earned: String(coinsEarned),
                },
            }),
        }).catch((err: Error) => console.warn('[payu-webhook] User notification failed (non-critical):', err));

        // Notify merchant: payment received
        fetch(notifyUrl, {
            method: 'POST',
            headers: notifyHeaders,
            body: JSON.stringify({
                merchant_id: transaction.merchant_id,
                title: '💰 Payment Received!',
                body: `₹${grossAmount.toFixed(0)} received from a customer.`,
                data: {
                    type: 'payment_received',
                    transaction_id: txnid,
                    amount: String(grossAmount),
                },
            }),
        }).catch((err: Error) => console.warn('[payu-webhook] Merchant notification failed (non-critical):', err));

        return new Response("OK", { status: 200 });
    } catch (error) {
        console.error("Unexpected error:", error);
        return new Response("Internal server error", { status: 500 });
    }
});
