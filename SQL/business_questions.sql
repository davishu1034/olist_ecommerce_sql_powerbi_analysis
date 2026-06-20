-- Average Delivery time by state (Days) --

SELECT
  g.geolocation_state,
  round(
    avg(
      timestamp_diff(
        o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)),
    2) AS delivery_time
FROM `ecom_pro.orders` o
JOIN `ecom_pro.customers` c    #Join to get customer zipcode
  ON o.customer_id = c.customer_id
JOIN `ecom_pro.geo_location` g #Join to get state name
  ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE o.order_status = 'delivered'
GROUP BY g.geolocation_state
ORDER BY delivery_time DESC;

-- Most revenue genrating product category--

SELECT
  pc.product_category_name_english AS category,
  round(sum(p.payment_value) / 1000000, 2)
    AS total_revenue_per_category
FROM `ecom_pro.order_payments` p
JOIN `ecom_pro.order_items` oi           #join to get product id
  ON p.order_id = oi.order_id
JOIN `ecom_pro.products` pr              #join to get product category name(prtuguese)
  ON oi.product_id = pr.product_id
JOIN `ecom_pro.product_category_name` pc #join to get translation of product category name(English)
  ON pr.product_category_name = pc.product_category_name
GROUP BY pc.product_category_name_english
ORDER BY total_revenue_per_category DESC
LIMIT 5;

-- Orders that deliver after estimated date (Late Deliveries) --

SELECT
  COUNT(order_id) AS Late_delivery
FROM `ecom_pro.orders`
WHERE
  order_status = 'delivered'
  AND DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date);

-- repeat purchase rate for customers within 6 months --

WITH customer_orders AS ( #CTE to get all customer and order details
  SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp,
    LAG(o.order_purchase_timestamp)
      OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp)
      AS prev_order_timestamp
  FROM `ecom_pro.orders` o
  JOIN `ecom_pro.customers` c #Join to get customer unique id
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
),

repeat_customers AS ( #CTE to get customer who purchase again with in 6 month
  SELECT
    customer_unique_id,
    CASE
      WHEN DATE_DIFF(
        DATE(order_purchase_timestamp),
        DATE(prev_order_timestamp),
        DAY
      ) <= 180
      THEN 1 ELSE 0
    END AS is_repeat_within_6m
  FROM customer_orders
  WHERE prev_order_timestamp IS NOT NULL
),

summary AS ( #CTE to get count of repeat customers
  SELECT
    COUNT(DISTINCT c.customer_unique_id)                                         AS total_customers,
    COUNT(DISTINCT IF(r.is_repeat_within_6m = 1, r.customer_unique_id, NULL))    AS repeat_customers
  FROM `ecom_pro.customers` c
  LEFT JOIN repeat_customers r USING (customer_unique_id) #Left join to get count of all the customer unique id
)

SELECT
  total_customers,
  repeat_customers,
  ROUND(repeat_customers / total_customers * 100, 2) AS repeat_purchase_rate_pct
FROM summary;

-- Sellers have the highest reveiw score with more than 50 orders --

WITH
  clean_review AS ( #CTE some order have more than 1 review to do avg of them 
    SELECT 
       order_id ,
      AVG(review_score) AS review_score
    FROM `ecom_pro.order_reviews`
    GROUP BY order_id
  ),
  all_orders AS (
    SELECT
      oi.seller_id,
      COUNT(DISTINCT o.order_id) AS Count_of_order,
      ROUND(AVG(re.review_score), 2) AS Avg_rating
    FROM ecom_pro.orders o
    JOIN `ecom_pro.order_items` oi #Join to get sellers id
      ON o.order_id = oi.order_id
    JOIN clean_review re           #Join to get avg review rating
      ON o.order_id = re.order_id
    WHERE order_status = 'delivered'
    GROUP BY oi.seller_id
  )
SELECT
  *
FROM all_orders
WHERE Count_of_order >= 50
ORDER BY Avg_rating DESC





