# Этап 9. Анализ повторных покупок
/*Дополнительно можно посмотреть поведение пользователей.*/

#сколько пользователей сделали хотя бы один заказ;
SELECT 
COUNT(DISTINCT user_id) AS users_with_order
FROM fact_orders
WHERE TRIM(order_id) <> '';
# 520 пользователей сделали хотя бы 1 заказ

#сколько пользователей совершили хотя бы одну успешную завершенную покупку
SELECT 
COUNT(DISTINCT user_id) AS users_with_order
FROM fact_orders
WHERE order_status IN ('paid', 'completed');
# 486 пользователей совершили хотя бы 1 успешную покупку

#сколько пользователей сделали повторный заказ
#только реальные успешные покупки, без cancelled и refunded.
SELECT 
COUNT(*) AS repeat_users
FROM
    (SELECT
		user_id,
		COUNT(*) AS orders
	FROM fact_orders
	WHERE order_status IN ('paid', 'completed')
	GROUP BY user_id
    HAVING COUNT(DISTINCT order_id) >= 2
    ) AS t;
# 119 пользователй совершили повторную покупку

SELECT 
orders,
COUNT(*) AS user_cnt
FROM (
		SELECT
			user_id,
			COUNT(*) AS orders
		FROM fact_orders
        WHERE order_status IN ('paid', 'completed')
		GROUP BY user_id
        ) as T
	GROUP BY orders 
    ORDER BY orders ASC ;
/*1 заказ сделали 367 пользователей
  2 заказа сделали 92 пользователей
  3 заказа сделали 23 пользователей
  4 заказа сделали 3 пользователя
  5 заказов сделал 1 пользователь */

#repeat purchase rate - доля покупателей, которые совершили 2 и более заказа
SELECT
    COUNT(*) AS buyers,
    SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) AS repeat_buyers,
    ROUND(SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repeat_purchase_rate
FROM (
    SELECT
        user_id,
        COUNT(*) AS orders
    FROM fact_orders
    WHERE order_status IN ('paid', 'completed')
    GROUP BY user_id
) t;
/* За анализируемый период 119 из 486 покупателей совершили более одной успешной покупки. 
24,49% покупателей совершили более одной успешной покупки в анализируемом периоде
*/

#какие каналы чаще приводят повторных покупателей (т.е.через какой канал пользователь пришёл или совершил первую успешную покупку, а затем стал повторным покупателем)
WITH successful_orders AS (
    SELECT
        o.order_id,
        o.user_id,
        o.order_timestamp,
        s.channel,
        ROW_NUMBER() OVER (
            PARTITION BY o.user_id
            ORDER BY o.order_timestamp, o.order_id
        ) AS order_number,
        COUNT(*) OVER (
            PARTITION BY o.user_id
        ) AS orders_cnt
    FROM fact_orders o
    JOIN fact_sessions s
        ON o.session_id = s.session_id
    WHERE o.order_status IN ('paid', 'completed')
),
acquisition_channel AS (
    SELECT
        user_id,
        channel,
        orders_cnt
    FROM successful_orders
    WHERE order_number = 1
)
SELECT
channel,
    COUNT(*) AS buyers,
    SUM(CASE WHEN orders_cnt >= 2 THEN 1 ELSE 0 END) AS repeat_buyers,
    ROUND(
        SUM(CASE WHEN orders_cnt >= 2 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS repeat_purchase_rate
FROM acquisition_channel
GROUP BY channel
ORDER BY repeat_purchase_rate DESC;
# Наиболее высокая доля повторных покупателей наблюдается у каналов affiliate(36.84%) и direct (26.53%).
# Это говорит о том, что именно эти каналы привлекают пользователей, которые чаще совершают повторные покупки. 

#расчет среднего чека заказов покупателей, которые совершили только одну покупку и покупателей, которые совершили несколько покупок.
#сравнение заказов разовых и повторных покупателей;
SELECT
    customer_type,
    COUNT(*) AS orders,
    ROUND(AVG(total_amount_eur), 2) AS avg_order_value
FROM (
    SELECT
        o.order_id,
        o.total_amount_eur,
        CASE
            WHEN u.orders_cnt = 1 THEN 'One-time buyers'
            ELSE 'Repeat buyers'
        END AS customer_type
    FROM fact_orders o
    JOIN (
        SELECT
            user_id,
            COUNT(DISTINCT order_id) AS orders_cnt
        FROM fact_orders
        WHERE order_status IN ('paid', 'completed')
        GROUP BY user_id
    ) u
        ON o.user_id = u.user_id
    WHERE o.order_status IN ('paid', 'completed')
) t
GROUP BY customer_type;
#Средний чек у repeat buyers (покупателей, которые совершили несколько заказов ) составляет 155,65 €, а у one-time buyers(покупатели, совершившие 1 покупку) — 153,07 €.
#Разница всего 2,58 € (1,7%), поэтому существенного различия в размере заказа между группами нет.

#отличается ли средний чек первого и последующих заказов.
#сравнить первый заказ пользователя с его последующими заказами,  для этого нужно классифицировать каждый заказ по порядковому номеру.
WITH successful_orders AS (
    SELECT
        order_id,
        user_id,
        total_amount_eur,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY order_timestamp, order_id
        ) AS order_number
    FROM fact_orders
    WHERE order_status IN ('paid', 'completed')
)
SELECT
    CASE
        WHEN order_number = 1 THEN 'First order'
        ELSE 'Repeat order'
    END AS order_type,
    COUNT(*) AS orders,
    ROUND(AVG(total_amount_eur), 2) AS avg_order_value
FROM successful_orders
GROUP BY order_type;
#Средний чек первого заказа составляет 154.75€, а средний чек повторных заказов 152.30 €
  
/* За анализируемый период 119 из 486 покупателей совершили более одной успешной покупки. 
Таким образом, Repeat Purchase Rate составляет 24,49%, . 
При этом большинство покупателей остаются разовыми: 367 из 486 пользователей совершили только одну успешную покупку. 
Это указывает на значительный потенциал для повышения повторных продаж и удержания клиентов.

Наибольшую долю повторных покупателей привлекают каналы Direct и Affiliate.
Это означает, что пользователи, впервые совершившие покупку через эти каналы, чаще возвращаются за повторной покупкой.
При этом средний чек первого заказа незначительно выше среднего чека повторных заказов.

Следовательно, потенциал роста выручки от повторных клиентов связан преимущественно с увеличением количества повторных покупок, а не с ростом среднего чека.
 Одним из потенциальных направлений роста выручки является повышение доли покупателей, совершающих повторные покупки, поскольку большинство покупателей в анализируемом периоде совершили только одну успешную покупку.
*/
    
