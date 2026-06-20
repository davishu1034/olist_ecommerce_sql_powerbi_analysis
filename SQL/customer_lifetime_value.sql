WITH
  All_order_data AS (#CTE to get orders,customers and paymnet details
    SELECT
      c.customer_unique_id,
      COUNT(o.order_id) AS count_of_orders,
      ROUND(SUM(p.payment_value), 2) AS total_value,
      MIN(o.order_purchase_timestamp) AS first_order,
      MAX(o.order_purchase_timestamp) AS last_order
    FROM ecom_pro.orders o
    JOIN `ecom_pro.customers` c        #Join to get customer unique id
      ON o.customer_id = c.customer_id
    JOIN `ecom_pro.order_payments` p   #Join to get payment values
      ON o.order_id = p.order_id
    WHERE order_status = 'delivered'
    GROUP BY c.customer_unique_id
  ),
  clv_rank AS (#CTE to get customer life time value score on basis of order value and order count
    SELECT
      customer_unique_id,
      count_of_orders,
      total_value,
      ROUND(total_value / count_of_orders, 2) AS Avg_order_value,
      NTILE(3)
        OVER (ORDER BY(total_value * 0.6) + (count_of_orders * 0.4) DESC) AS clv_score
    FROM All_order_data
  )
SELECT
  customer_unique_id,
  count_of_orders,
  total_value,
  Avg_order_value,
  CASE
    WHEN clv_score = 1 THEN "HIGH"
    WHEN clv_score = 2 THEN "MID"
    ELSE "LOW"
  END as clv_segment #Case statment to asign CLV segment on basis of CLV score
FROM clv_rank
