-- ============================================================================
-- Migration 007: Add Merchant Rewards Percentage
-- Purpose: Enable merchant-specific customer rewards (0-10%)
-- Date: February 16, 2026
-- ============================================================================

-- Add rewards_percentage column to merchants table
ALTER TABLE merchants 
ADD COLUMN rewards_percentage DECIMAL(4,3) DEFAULT 0.10;

-- Add constraint: 0% to 10% (0.000 to 0.100)
ALTER TABLE merchants
ADD CONSTRAINT valid_rewards_percentage 
CHECK (rewards_percentage >= 0.000 AND rewards_percentage <= 0.100);

-- Update existing merchants to 10% (maintains current behavior)
UPDATE merchants 
SET rewards_percentage = 0.10
WHERE rewards_percentage IS NULL;

-- Make NOT NULL after setting defaults
ALTER TABLE merchants 
ALTER COLUMN rewards_percentage SET NOT NULL;

-- Add column comment
COMMENT ON COLUMN merchants.rewards_percentage IS 
'Customer rewards rate (0-10% of fiat paid). Higher rates attract more customers but reduce merchant margins. Example: 0.075 = 7.5% rewards.';

-- Verify migration
SELECT 
    id,
    business_name,
    commission_rate,
    rewards_percentage
FROM merchants;

-- Expected output: All merchants should have rewards_percentage = 0.100 (10%)
