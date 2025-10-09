SELECT * FROM menswear_funnel_10000_users;

Select count(*) Total_task
 from menswear_funnel_10000_users  ;


/* This query will return the number of users completed a certain task up until purchasing 
the product  and  including the convertion rates of each transactions step in the website   */

WITH user_funnel AS (
				SELECT
				user_id,
				MIN(CASE WHEN event_name = 'visit_homepage' THEN timestamp END) AS visit_homepage,
				MIN(CASE WHEN event_name = 'view_product' THEN timestamp END) AS view_product,
				MIN(CASE WHEN event_name = 'add_to_cart' THEN timestamp END) AS add_to_cart,
				MIN(CASE WHEN event_name = 'start_checkout' THEN timestamp END) AS start_checkout,
				MIN(CASE WHEN event_name = 'complete_purchase' THEN timestamp END) AS complete_purchase
				FROM
				menswear_funnel_10000_users
				GROUP BY
				user_id
					),
counts AS (
				SELECT
				COUNT(*) AS total_users,
				COUNT(visit_homepage) AS homepage_visits,
				COUNT(view_product) AS product_views,
				COUNT(add_to_cart) AS added_to_cart,
				COUNT(start_checkout) AS started_checkout,
				COUNT(complete_purchase) AS completed_purchases
				FROM user_funnel
					)

SELECT
  total_users,
  homepage_visits,
  product_views,
  ROUND(product_views * 100.0 / homepage_visits, 2) AS view_conversion_rate,
  added_to_cart,
  ROUND(added_to_cart * 100.0 / homepage_visits, 2) AS cart_conversion_rate,
  started_checkout,
  ROUND(started_checkout * 100.0 / homepage_visits, 2) AS checkout_conversion_rate,
  completed_purchases,
  ROUND(completed_purchases * 100.0 / homepage_visits, 2) AS purchase_conversion_rate
FROM counts;

/*Funnel Breakdown by Device or Country */

WITH user_funnel AS (
				  SELECT
					user_id,
					MIN(CASE WHEN event_name = 'visit_homepage' THEN timestamp END) AS visit_homepage,
					MIN(CASE WHEN event_name = 'view_product' THEN timestamp END) AS view_product,
					MIN(CASE WHEN event_name = 'add_to_cart' THEN timestamp END) AS add_to_cart,
					MIN(CASE WHEN event_name = 'start_checkout' THEN timestamp END) AS start_checkout,
					MIN(CASE WHEN event_name = 'complete_purchase' THEN timestamp END) AS complete_purchase
				  FROM
					menswear_funnel_10000_users
				  GROUP BY user_id
					),
                    
user_metadata AS (
				  SELECT user_id, MAX(device) AS device, MAX(country) AS country
				  FROM menswear_funnel_10000_users
				  GROUP BY user_id
)
SELECT
  device,
  COUNT(*) AS total_users,
  COUNT(view_product) AS product_views,
  ROUND(COUNT(view_product) * 100.0 / COUNT(*), 2) AS view_conversion_rate,
  COUNT(add_to_cart) AS added_to_cart,
  ROUND(COUNT(add_to_cart) * 100.0 / COUNT(*), 2) AS cart_conversion_rate,
  COUNT(complete_purchase) AS completed_purchases,
  ROUND(COUNT(complete_purchase) * 100.0 / COUNT(*), 2) AS purchase_conversion_rate
FROM user_funnel uf
JOIN user_metadata md ON uf.user_id = md.user_id
GROUP BY device;







