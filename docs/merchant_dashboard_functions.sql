-- Function to get daily stats for a merchant
CREATE OR REPLACE FUNCTION get_merchant_daily_stats(
  merchant_uuid UUID,
  stats_date DATE
)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  -- Check if merchant has any transactions first to avoid NULL issues
  IF NOT EXISTS (SELECT 1 FROM transactions WHERE merchant_id = merchant_uuid) THEN
    RETURN json_build_object(
      'transaction_count', 0,
      'total_revenue', 0,
      'net_revenue', 0,
      'pending_settlement', 0,
      'customers_served', 0
    );
  END IF;

  SELECT json_build_object(
    'transaction_count', COUNT(*),
    'total_revenue', COALESCE(SUM(c.gross_revenue), 0.0),
    'net_revenue', COALESCE(SUM(c.net_revenue), 0.0),
    'pending_settlement', (
      SELECT COALESCE(SUM(net_revenue), 0.0)
      FROM commissions
      WHERE merchant_id = merchant_uuid
        AND is_settled = false
    ),
    'customers_served', COUNT(DISTINCT t.user_id)
  ) INTO result
  FROM transactions t
  LEFT JOIN commissions c ON c.transaction_id = t.id
  WHERE t.merchant_id = merchant_uuid
    AND DATE(t.created_at) = stats_date
    AND t.status = 'success';
  
  -- Handle case where no transactions for today but pending settlement exists
  IF result IS NULL THEN
     SELECT json_build_object(
      'transaction_count', 0,
      'total_revenue', 0,
      'net_revenue', 0,
      'pending_settlement', (
        SELECT COALESCE(SUM(net_revenue), 0.0)
        FROM commissions
        WHERE merchant_id = merchant_uuid
          AND is_settled = false
      ),
      'customers_served', 0
    ) INTO result;
  END IF;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get recent transactions with commission details
CREATE OR REPLACE FUNCTION get_merchant_transaction_summary(
  merchant_uuid UUID,
  limit_count INT DEFAULT 10
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  gross_amount DECIMAL,
  coins_applied DECIMAL,
  fiat_amount DECIMAL,
  rewards_earned INT,
  status TEXT,
  payment_method TEXT,
  commission_rate DECIMAL,
  gross_revenue DECIMAL,
  net_revenue DECIMAL,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.user_id,
    t.gross_amount,
    t.coins_applied,
    t.fiat_amount,
    t.rewards_earned,
    t.status,
    t.payment_method,
    c.commission_rate,
    c.gross_revenue,
    c.net_revenue,
    t.created_at
  FROM transactions t
  LEFT JOIN commissions c ON c.transaction_id = t.id
  WHERE t.merchant_id = merchant_uuid
  ORDER BY t.created_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions for authenticated users (merchants)
GRANT EXECUTE ON FUNCTION get_merchant_daily_stats(UUID, DATE) TO authenticated;
GRANT EXECUTE ON FUNCTION get_merchant_daily_stats(UUID, DATE) TO service_role;

GRANT EXECUTE ON FUNCTION get_merchant_transaction_summary TO authenticated;
GRANT EXECUTE ON FUNCTION get_merchant_transaction_summary TO service_role;
