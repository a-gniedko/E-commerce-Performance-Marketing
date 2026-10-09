CREATE DATABASE voronka;
USE voronka;
CREATE TABLE dim_users (
	user_id VARCHAR(25) PRIMARY KEY,
	signup_date DATE,
	country  VARCHAR(100),
	city  VARCHAR(100),
	age_group  VARCHAR(100),
	gender  VARCHAR(100),
	customer_segment  VARCHAR(100),
	marketing_consent BOOLEAN
);
CREATE TABLE dim_products (
	product_id VARCHAR(25) PRIMARY KEY,
	category VARCHAR(150),
	product_name VARCHAR(150),
	brand VARCHAR(100),
	base_price_eur DECIMAL(10,2),
	margin_rate DECIMAL(10,2),
	is_active INT
);
CREATE TABLE dim_campaigns ( 
	campaign_id VARCHAR(25) PRIMARY KEY,
	channel VARCHAR(150),
	campaign_name VARCHAR(150),
	campaign_type VARCHAR(150),
	start_date DATE,
	end_date DATE,
	target_segment VARCHAR(100)
);
CREATE TABLE fact_marketing_spend (
	spend_date DATE,
	campaign_id VARCHAR(25),
	channel VARCHAR(50),
	spend_eur DECIMAL(10,2),
	impressions INT,
	clicks INT,
PRIMARY KEY (spend_date, campaign_id) ,
CONSTRAINT fk_marketing_spend_campaign
	FOREIGN KEY (campaign_id)
	REFERENCES dim_campaigns(campaign_id) 
);
CREATE TABLE fact_sessions (
	session_id VARCHAR(25) PRIMARY KEY,
	user_id VARCHAR(25),
	session_start DATETIME,
	session_date DATE,
	device VARCHAR(50),
	country VARCHAR(100),
	channel VARCHAR(50),
	campaign_id VARCHAR(25),
	landing_page VARCHAR(100),
	product_views INT,
	add_to_cart_count INT,
	checkout_started INT,
	purchase_completed INT,
	session_duration_sec INT,
	checkout_flow_version VARCHAR(100),
	order_id VARCHAR(25),
	gross_order_amount_eur DECIMAL(10,2),
	net_revenue_eur DECIMAL(10,2),
	is_new_user_session BOOLEAN,
CONSTRAINT fk_sessions_users 
	FOREIGN KEY (user_id)
	REFERENCES dim_users(user_id) ,
CONSTRAINT fk_sessions_campaign
	FOREIGN KEY (campaign_id)
	REFERENCES dim_campaigns(campaign_id) 
);
CREATE TABLE fact_orders (
	order_id VARCHAR(25) PRIMARY KEY,
	user_id VARCHAR(25),
	session_id VARCHAR(25),
	order_date DATE,
	order_timestamp DATETIME,
	order_status VARCHAR(50),
	payment_method  VARCHAR(50),
	subtotal_eur DECIMAL(10,2),
	discount_eur DECIMAL(10,2),
	shipping_fee_eur DECIMAL(10,2),
	total_amount_eur DECIMAL(10,2),
	net_revenue_eur DECIMAL(10,2),
	CONSTRAINT fk_orders_users
		FOREIGN KEY(user_id)
		REFERENCES dim_users(user_id),
	CONSTRAINT fk_orders_sessions
		FOREIGN KEY(session_id)
		REFERENCES fact_sessions(session_id)
); 
CREATE TABLE fact_order_items (
	order_item_id VARCHAR(25) PRIMARY KEY,
	order_id VARCHAR(25),
	product_id VARCHAR(25),
	quantity INT,
	unit_price_eur DECIMAL(10,2),
	line_total_eur DECIMAL(10,2),
CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id)
REFERENCES fact_orders(order_id),
CONSTRAINT fk_order_items_products
FOREIGN KEY (product_id)
REFERENCES dim_products(product_id) 
);
CREATE TABLE fact_events (
	event_id VARCHAR(25) PRIMARY KEY,
	session_id VARCHAR(25),
	user_id VARCHAR(25),
	event_time DATETIME,
	event_date DATE,
	event_type VARCHAR(100),
	product_id VARCHAR(25),
	order_id VARCHAR(25),
	device VARCHAR(100),
	channel  VARCHAR(100),
	campaign_id VARCHAR(25)	
);

# Этап 2. Проверка качества данных
# есть ли дубликаты по ключам;
SELECT 
	order_id,	
	count(*) as count_orders
FROM fact_orders
GROUP BY order_id
HAVING count(*)>1;

SELECT
    spend_date,
    campaign_id,
    COUNT(*) AS cnt
FROM fact_marketing_spend
GROUP BY spend_date, campaign_id
HAVING COUNT(*) > 1;

# сравнение общего количество строк и уникальных ключей
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids
FROM fact_orders;

SELECT 
	COUNT(session_id) AS total_session
    , COUNT(DISTINCT session_id) AS uniq_session
FROM fact_sessions;

#есть ли пустые значения в важных полях;
#Сколько строк имеют хотя бы одно пустое или NULL значение?
#dim_users
SELECT 
	COUNT(*) AS missing_items
FROM dim_users
WHERE
user_id IS NULL
OR signup_date IS NULL
OR marketing_consent IS NULL   ;

#dim_products
SELECT 
	COUNT(*) AS missing_items
FROM dim_products
WHERE 
product_id IS NULL
OR category IS NULL
OR product_name IS NULL
OR brand IS NULL
OR base_price_eur IS NULL
OR margin_rate IS NULL 
OR is_active IS NULL;
#dim_campaigns
SELECT 
	COUNT(*) AS missing_items
FROM dim_campaigns
WHERE
campaign_id IS NULL
OR channel IS NULL
OR campaign_name IS NULL
OR campaign_type IS NULL
OR start_date IS NULL
OR end_date IS NULL
OR target_segment IS NULL;

#проверка пустых значений в fact_events

#product_id должен быть только у событий product_view и add_to_cart. У событий session_start и page_view этого поля может не быть.
#Поэтому проверять наличие product_id на заполненность нужно только для событий product_view и add_to_cart.
#Для остальных событий пустое значение product_id считается нормальным и не является ошибкой.
SELECT
COUNT(*) AS product_events_without_product_id
FROM fact_events
WHERE event_type IN ('product_view', 'add_to_cart')
  AND (product_id IS NULL OR TRIM(product_id) = '');

#order_id должен быть только у событий со статусом payment_success. Поэтому проверку наличия order_id нужно выполнять только для этих событий.
SELECT
    COUNT(*) AS payment_events_without_order_id
FROM fact_events
WHERE event_type = 'payment_success'
  AND (order_id IS NULL OR TRIM(order_id) = '');

# fact_marketing_spend
SELECT COUNT(*) AS missing_items
FROM fact_marketing_spend
WHERE spend_date IS NULL
OR campaign_id IS NULL
OR channel IS NULL
OR spend_eur IS NULL
OR impressions IS NULL
OR clicks IS NULL;
# fact_order_items
SELECT COUNT(*) AS missing_items
FROM fact_order_items
WHERE order_item_id IS NULL
OR order_id IS NULL
OR product_id IS NULL
OR quantity IS NULL
OR unit_price_eur IS NULL
OR line_total_eur IS NULL;
#fact_orders
SELECT 
	COUNT(*) AS missing
FROM fact_orders
WHERE order_id IS NULL
OR user_id IS NULL
OR session_id IS NULL
OR order_date IS NULL
OR order_timestamp IS NULL
OR order_status IS NULL
OR payment_method IS NULL
OR subtotal_eur IS NULL
OR discount_eur IS NULL
OR shipping_fee_eur IS NULL
OR total_amount_eur IS NULL
OR net_revenue_eur IS NULL;

# fact_sessions
#есть ли сессии с покупкой, но без order_id;
SELECT *
FROM fact_sessions
WHERE purchase_completed = 1
AND (order_id IS NULL OR TRIM(order_id) = ''); -- пустой order_id важен только там, где сессия завершилась покупкой. Для обычной сессии без покупки пустой order_id нормален.

# есть ли заказы без сессий;
SELECT *
FROM  fact_orders o
LEFT JOIN fact_sessions s
ON o.session_id=s.session_id
WHERE s.session_id IS NULL;

#есть ли маркетинговые расходы без кампании;
SELECT 
	COUNT(*) AS spend_without_campaign
FROM  fact_marketing_spend
WHERE spend_eur>0
AND (campaign_id IS NULL OR TRIM(campaign_id)=''); 

# существуют ли все campaign_id из fact_marketing_spend в dim_campaigns
SELECT
m.*
FROM fact_marketing_spend m
LEFT JOIN dim_campaigns c
ON m.campaign_id = c.campaign_id
WHERE c.campaign_id IS NULL;

#есть ли кампании без сессий: для всех кампаний из справочника проверяем были ли по ним сессии
SELECT
	c.campaign_id,
    c.campaign_name
FROM dim_campaigns c
LEFT JOIN fact_sessions s
    ON c.campaign_id = s.campaign_id
WHERE s.session_id IS NULL;

#сколько уникальных пользователей, сессий, заказов;
SELECT 
	COUNT(*) AS total_session,
    COUNT(DISTINCT session_id) AS uniq_session
FROM fact_sessions;

SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT order_id) AS unique_order_id
FROM fact_orders;

SELECT
    COUNT(*) AS total_users,
    COUNT(DISTINCT user_id) AS unique_user_id
FROM dim_users;

#есть ли дубликаты session_id, order_id, user_id;
SELECT
	user_id,
    COUNT(*) AS duplicate_users
FROM dim_users
GROUP BY user_id
HAVING COUNT(*)>1;

SELECT 
	session_id,
	COUNT(*) AS duplicate_sessions
FROM fact_sessions
GROUP BY session_id
HAVING COUNT(*)>1;

SELECT 
	order_id,
	COUNT(*) AS duplicate_orders
FROM fact_orders
GROUP BY order_id
HAVING COUNT(*)>1;

#сколько пользователей без сессий; 
SELECT 
	COUNT(*) AS users_without_sessions
FROM dim_users u
LEFT JOIN fact_sessions s
ON u.user_id = s.user_id
WHERE s.user_id IS NULL;

# какие именно пользователи без сессий
SELECT u.*, s.session_id
FROM dim_users u
LEFT JOIN fact_sessions s
ON u.user_id=s.user_id
WHERE s.user_id IS NULL;

#Сколько сессий не имеют user_id?
# Здесь мы оцениваем именно качество таблицы сессий: если сессия существует, но user_id отсутствует, это потенциальная проблема для анализа поведения пользователей.
SELECT
	COUNT(*) AS sessions_without_user_id
FROM fact_sessions
WHERE user_id IS NULL OR trim(user_id) = '';

#сколько заказов со статусами refunded и cancelled;
SELECT 
	COUNT(*) AS order_ref_cancel
FROM fact_orders
WHERE order_status='cancelled' OR  order_status='refunded';

#какая минимальная и максимальная дата в каждой факт-таблице
SELECT 
	MIN(order_date) AS Min_date_order,
	MAX(order_date) AS Max_date_order
FROM fact_orders;

SELECT 
	MIN(spend_date) AS Min_spend_date,
	MAX(spend_date) AS Max_spend_date
FROM fact_marketing_spend;

SELECT 
	MIN(event_date) AS Min_date_event,
	MAX(event_date) AS Max_date_event
FROM fact_events;

SELECT 
	MIN(session_date) AS Min_session_date,
	MAX(session_date) AS Max_session_date
FROM fact_sessions;

/*
Уникальных сессий  - 7629
Уникальных заказов  - 700
Уникальных пользователей - 1300
Заказов со статусами refunded и cancelled - 63

*/