-- Orders delivered later than the estimated date have an average logistics time of over 25 days. --
WITH late_deliver AS (#CTE to get orders deliver after estimate time 
    SELECT
      *
    FROM `ecom_pro.orders`
    WHERE
      order_status = 'delivered'
      AND DATE(order_delivered_customer_date)
        > DATE(order_estimated_delivery_date)
  ),
  logistic_time AS (#CTE to get how much time taken to deliver the order after the dispatch
    SELECT
      *,
      TIMESTAMP_DIFF(
        order_delivered_customer_date, order_delivered_carrier_date, DAY)
        AS logistic
    FROM late_deliver
  )
SELECT round(avg(logistic), 0) AS avg_logistic_time_for_late_delivery
FROM logistic_time;

-- Orders delivered after the estimated delivery date have an average dispatch time of more than 5 days. --
WITH
  late_deliver AS (#CTE to get orders deliver after estimate time
    SELECT
      *
    FROM `ecom_pro.orders`
    WHERE
      order_status = 'delivered'
      AND DATE(order_delivered_customer_date)
        > DATE(order_estimated_delivery_date)
  ),
  order_handover AS (#CTE to get how much time taken to hand over order to logistic partner
    SELECT
      *,
      TIMESTAMP_DIFF(
        order_delivered_carrier_date, order_purchase_timestamp, DAY)
        AS order_handover_time
    FROM late_deliver
  )
SELECT
  round(avg(order_handover_time), 0)
    AS avg_handover_time_to_logistic_for_late_delivery
FROM order_handover;

-- Overall avg time of order delivery is 12 Days but for late delivered order it's 33 Days --
WITH
  late_deliver AS (#CTE to get orders deliver after estimate time
    SELECT
      *
    FROM `ecom_pro.orders`
    WHERE
      order_status = 'delivered'
      AND DATE(order_delivered_customer_date)
        > DATE(order_estimated_delivery_date)
  ),
  overall AS (#CTE to get how much time taken to deliver order to customer after purchase 
    SELECT
      *,
      TIMESTAMP_DIFF(
        order_delivered_customer_date, order_purchase_timestamp, DAY)
        AS overall_time
    FROM late_deliver
  )
SELECT
  round(avg(overall_time), 0)
    AS overall_time_for_late_delivery
FROM overall
