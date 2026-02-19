-- Merchant Analytics SQL Functions
-- Execute these in Supabase SQL Editor

-- Function 1: Get Revenue Trend
-- Returns daily revenue data for charts
CREATE OR REPLACE FUNCTION get_merchant_revenue_trend(
  merchant_uuid UUID,
  start_date DATE,
  end_date DATE
)
RETURNS JSON AS $$
DECLARE
  result JSON;
  daily_data JSON;
BEGIN
  -- Generate series of all dates in range
  WITH date_series AS (
    SELECT generate_series(
      start_date::timestamp,
      end_date::timestamp,
      '1 day'::interval
    )::date AS date
  ),
  daily_revenue AS (
    SELECT 
      DATE(t.created_at) AS date,
      COALESCE(SUM(t.gross_amount), 0.0) AS revenue
    FROM transactions t
    WHERE t.merchant_id = merchant_uuid
      AND DATE(t.created_at) >= start_date
      AND DATE(t.created_at) <= end_date
      AND t.status = 'success'
    GROUP BY DATE(t.created_at)
  ),
  filled_data AS (
    SELECT 
      ds.date,
      COALESCE(dr.revenue, 0.0) AS revenue
    FROM date_series ds
    LEFT JOIN daily_revenue dr ON ds.date = dr.date
    ORDER BY ds.date
  )
  SELECT json_build_object(
    'daily_values', COALESCE(array_agg(revenue ORDER BY date), ARRAY[]::numeric[]),
    'labels', COALESCE(array_agg(date::text ORDER BY date), ARRAY[]::text[]),
    'total_revenue', COALESCE(SUM(revenue), 0.0),
    'average_daily', COALESCE(AVG(revenue), 0.0),
    'period_start', start_date,
    'period_end', end_date
  ) INTO result
  FROM filled_data;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 2: Get Performance Metrics
-- Returns growth, peak hour, payment breakdown
CREATE OR REPLACE FUNCTION get_merchant_performance_metrics(
  merchant_uuid UUID,
  period_days INT
)
RETURNS JSON AS $$
DECLARE
  result JSON;
  current_period_start DATE;
  current_period_end DATE;
  previous_period_start DATE;
  previous_period_end DATE;
  current_revenue NUMERIC;
  previous_revenue NUMERIC;
  growth_percentage NUMERIC;
BEGIN
  current_period_end := CURRENT_DATE;
  current_period_start := CURRENT_DATE - period_days;
  previous_period_end := current_period_start - 1;
  previous_period_start := previous_period_end - period_days;

  -- Calculate current period revenue
  SELECT COALESCE(SUM(gross_amount), 0.0) INTO current_revenue
  FROM transactions
  WHERE merchant_id = merchant_uuid
    AND DATE(created_at) >= current_period_start
    AND DATE(created_at) <= current_period_end
    AND status = 'success';

  -- Calculate previous period revenue
  SELECT COALESCE(SUM(gross_amount), 0.0) INTO previous_revenue
  FROM transactions
  WHERE merchant_id = merchant_uuid
    AND DATE(created_at) >= previous_period_start
    AND DATE(created_at) <= previous_period_end
    AND status = 'success';

  -- Calculate growth percentage
  IF previous_revenue > 0 THEN
    growth_percentage := ((current_revenue - previous_revenue) / previous_revenue) * 100;
  ELSE
    growth_percentage := 0.0;
  END IF;

  -- Build result with all metrics
  WITH hourly_stats AS (
    SELECT 
      EXTRACT(HOUR FROM created_at) AS hour,
      SUM(gross_amount) AS revenue
    FROM transactions
    WHERE merchant_id = merchant_uuid
      AND DATE(created_at) >= current_period_start
      AND DATE(created_at) <= current_period_end
      AND status = 'success'
    GROUP BY EXTRACT(HOUR FROM created_at)
    ORDER BY revenue DESC
    LIMIT 1
  ),
  payment_methods AS (
    SELECT 
      CASE 
        WHEN coins_applied > 0 THEN 'coins'
        ELSE 'cash'
      END AS method,
      SUM(gross_amount) AS amount,
      COUNT(*) AS count
    FROM transactions
    WHERE merchant_id = merchant_uuid
      AND DATE(created_at) >= current_period_start
      AND DATE(created_at) <= current_period_end
      AND status = 'success'
    GROUP BY CASE WHEN coins_applied > 0 THEN 'coins' ELSE 'cash' END
  ),
  total_amount AS (
    SELECT SUM(amount) AS total FROM payment_methods
  )
  SELECT json_build_object(
    'week_over_week_growth', growth_percentage,
    'peak_hour', COALESCE((SELECT hour FROM hourly_stats), 12),
    'peak_hour_revenue', COALESCE((SELECT revenue FROM hourly_stats), 0.0),
    'payment_method_breakdown', (
      SELECT json_object_agg(method, amount)
      FROM payment_methods
    ),
    'payment_method_counts', (
      SELECT json_object_agg(method, count)
      FROM payment_methods
    ),
    'cash_percentage', COALESCE(
      (SELECT (amount / total) * 100 FROM payment_methods, total_amount WHERE method = 'cash'),
      0.0
    ),
    'coins_percentage', COALESCE(
      (SELECT (amount / total) * 100 FROM payment_methods, total_amount WHERE method = 'coins'),
      0.0
    )
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 3: Get Customer Insights
-- Returns customer stats and top customers
CREATE OR REPLACE FUNCTION get_merchant_customer_insights(
  merchant_uuid UUID,
  period_days INT
)
RETURNS JSON AS $$
DECLARE
  result JSON;
  period_start DATE;
  period_end DATE;
BEGIN
  period_end := CURRENT_DATE;
  period_start := CURRENT_DATE - period_days;

  WITH customer_stats AS (
    SELECT 
      user_id,
      COUNT(*) AS order_count,
      SUM(gross_amount) AS total_spent
    FROM transactions
    WHERE merchant_id = merchant_uuid
      AND DATE(created_at) >= period_start
      AND DATE(created_at) <= period_end
      AND status = 'success'
    GROUP BY user_id
  ),
  aggregates AS (
    SELECT 
      COUNT(DISTINCT user_id) AS total_customers,
      COUNT(DISTINCT CASE WHEN order_count > 1 THEN user_id END) AS repeat_customers,
      COUNT(*) AS total_orders,
      COALESCE(AVG(total_spent), 0.0) AS avg_customer_value,
      COALESCE(AVG(total_spent / order_count), 0.0) AS avg_order_value
    FROM customer_stats
  ),
  top_5 AS (
    SELECT 
      user_id::text AS customer_id,
      order_count,
      total_spent
    FROM customer_stats
    ORDER BY total_spent DESC
    LIMIT 5
  )
  SELECT json_build_object(
    'total_customers', COALESCE((SELECT total_customers FROM aggregates), 0),
    'repeat_customers', COALESCE((SELECT repeat_customers FROM aggregates), 0),
    'repeat_customer_rate', CASE 
      WHEN (SELECT total_customers FROM aggregates) > 0 
      THEN ((SELECT repeat_customers FROM aggregates)::numeric / (SELECT total_customers FROM aggregates)::numeric) * 100
      ELSE 0.0
    END,
    'average_basket_size', COALESCE((SELECT avg_customer_value FROM aggregates), 0.0),
    'average_order_value', COALESCE((SELECT avg_order_value FROM aggregates), 0.0),
    'total_orders', COALESCE((SELECT total_orders FROM aggregates), 0),
    'top_customers', COALESCE(
      (SELECT json_agg(json_build_object(
        'customer_id', customer_id,
        'order_count', order_count,
        'total_spent', total_spent
      )) FROM top_5),
      '[]'::json
    )
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_merchant_revenue_trend TO authenticated;
GRANT EXECUTE ON FUNCTION get_merchant_revenue_trend TO service_role;

GRANT EXECUTE ON FUNCTION get_merchant_performance_metrics TO authenticated;
GRANT EXECUTE ON FUNCTION get_merchant_performance_metrics TO service_role;

GRANT EXECUTE ON FUNCTION get_merchant_customer_insights TO authenticated;
GRANT EXECUTE ON FUNCTION get_merchant_customer_insights TO service_role;

-- Success message
SELECT 'Analytics functions created successfully!' AS message;
