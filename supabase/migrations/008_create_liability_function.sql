-- ============================================================================
-- Create Platform Liability Calculation Function
-- Purpose: Calculate total unexpired coin liability for reward algorithm
-- Date: February 16, 2026
-- ============================================================================

CREATE OR REPLACE FUNCTION get_total_coin_liability()
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    total_liability BIGINT;
BEGIN
    -- Calculate sum of all unexpired, unredeemed coins
    SELECT COALESCE(SUM(coins_remaining), 0)
    INTO total_liability
    FROM momo_coin_batches
    WHERE expires_at > NOW()
    AND coins_remaining > 0;
    
    RETURN total_liability;
END;
$$;

-- Grant execute to authenticated users (edge function uses service role)
GRANT EXECUTE ON FUNCTION get_total_coin_liability() TO authenticated;
GRANT EXECUTE ON FUNCTION get_total_coin_liability() TO service_role;

-- Add comment
COMMENT ON FUNCTION get_total_coin_liability() IS 
'Calculates total platform coin liability (unexpired, unredeemed coins) for reward algorithm sustainability checks';

-- Test function
SELECT get_total_coin_liability() AS current_liability;
