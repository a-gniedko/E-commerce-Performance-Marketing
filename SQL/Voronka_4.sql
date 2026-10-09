# Этап 4. Анализ воронки продаж
# сколько сессий дошло до каждого этапа;
SELECT
	COUNT(*) AS all_session,
	SUM(CASE WHEN product_views>0 THEN 1 ELSE 0 END) AS session_product_views,
    SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END) AS session_add_to_card,
    SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END) AS session_checkout_started,
    SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END) AS session_purchase_completed
FROM fact_sessions;

/*
Всего зафиксировано 7 629 сессий, из них:
— 6 155 сессий с просмотром товаров;
— 1 848 сессий с добавлением товаров в корзину;
— 1 033 сессии дошли до оформления заказа;
— 700 сессий завершились покупкой.
*/
 
#конверсию из сессии в просмотр товара; 
SELECT
	ROUND(SUM(product_views>0)/ COUNT(*)*100,2) AS CR_session_to_product_views_pct
FROM fact_sessions;

#конверсию из просмотра товара в корзину;
SELECT
	ROUND
    (
    SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)/
    SUM(CASE WHEN product_views>0 THEN 1 ELSE 0 END)*100,2
    ) AS CR_product_views_to_add_card_pct
FROM fact_sessions;

#конверсию из корзины в checkout;
SELECT
	ROUND
    (
    SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)/
    SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)*100,2
    ) AS CR_add_card_to_checkout_pct
FROM fact_sessions;
#конверсию из checkout в покупку;
SELECT
	ROUND
    (
    SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/
    SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)*100,2
    ) AS CR_checkout_to_purchase_pct
FROM fact_sessions;
#общую конверсию из сессии в покупку.
SELECT
	ROUND(SUM(purchase_completed>0)/COUNT(*)*100,2) AS CR_session_to_purchase_pct
FROM fact_sessions;
/*
Общая конверсия из сессии в покупку составляет 9,18%. Это означает, что примерно 9 из 100 сессий заканчиваются покупкой. 
*/
# какая конверсия на каждом этапе в одной таблице
SELECT
	ROUND(SUM(product_views>0)/ COUNT(*)*100,2) AS CR_session_to_product_views_pct,
    ROUND(SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN product_views>0 THEN 1 ELSE 0 END)*100,2) AS CR_product_views_to_add_card_pct,
    ROUND(SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)*100,2) AS CR_add_card_to_checkout_pct,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)*100,2) AS CR_checkout_to_purchase_pct,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS CR_purchase_to_session_pct
FROM fact_sessions;
/*
Общая конверсия из посещения сайта в покупку составляет 9,18%.
Самый большой отток происходит на этапе перехода от просмотра товара к добавлению в корзину: только 30,02% переходят к следующему шагу - добавлению товара в корзину.
Поэтому основной потенциал роста общей конверсии связан с улучшением карточек товара, ценового предложения, условий доставки и удобства добавления в корзину. 

*/
#потери между этапами: сколько сессий потеряно после каждого шага и какой это процент.
# этап, количество сессий, конверсия к предыдущему этапу и потери
SELECT
    'Session' AS stage,
    COUNT(*) AS sessions,
    100.00 AS CR_to_prev_step,
    0 AS lost_sessions,
    0.00 AS loss_percent
FROM fact_sessions
UNION ALL
SELECT
    'Product View',
    SUM(product_views > 0),
    ROUND(SUM(product_views>0)*100/COUNT(*),2),
    COUNT(*)-SUM(product_views > 0),
    ROUND((COUNT(*)-SUM(product_views > 0))*100/COUNT(*),2)
FROM fact_sessions
UNION ALL
SELECT
    'Add to Cart',
    SUM(add_to_cart_count > 0),
    ROUND(SUM(add_to_cart_count>0)/SUM(product_views>0)*100,2),
	SUM(product_views > 0)-SUM(add_to_cart_count>0),
    ROUND((SUM(product_views > 0)-SUM(add_to_cart_count>0))*100/SUM(product_views>0),2)
FROM fact_sessions
UNION ALL
SELECT
    'Checkout',
    SUM(checkout_started =1),
    ROUND(SUM(checkout_started>0)*100/SUM(add_to_cart_count>0),2) ,
	SUM(add_to_cart_count>0)-SUM(checkout_started>0),
	ROUND((SUM(add_to_cart_count>0)-SUM(checkout_started>0))/SUM(add_to_cart_count>0)*100,2) 
FROM fact_sessions
UNION ALL
SELECT
    'Purchase',
    SUM(purchase_completed = 1),
    ROUND(SUM(purchase_completed>0)/ SUM(checkout_started>0)*100,2) ,
	SUM(checkout_started>0)-SUM(purchase_completed > 0),
    ROUND((SUM(checkout_started>0)-SUM(purchase_completed > 0))/SUM(checkout_started>0)*100,2) 
FROM fact_sessions;

#по каналам
SELECT
	channel,
	ROUND(SUM(product_views>0)/ COUNT(*)*100,2) AS CR_session_to_product_views,
    ROUND(SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN product_views>0 THEN 1 ELSE 0 END)*100,2) AS CR_product_views_to_add_card,
    ROUND(SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)*100,2) AS CR_add_card_to_checkout,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)*100,2) AS CR_checkout_to_purchase,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS CR_purchase_to_session
FROM fact_sessions
GROUP BY channel;
/* Анализ конверсии по каналам:
Email: самый эффективный канал. Максимальная итоговая конверсия из сессии в покупку - 13,63%. Также показывает лучшие результаты на этапах просмотр  -> корзина (38,24%) и оформление  -> покупка (72,73%).
Paid Search: второй по эффективности канал с итоговой конверсией 12,29%. Имеет самую высокую конверсию из сессии в просмотр товара - 85,67%.
Direct : итоговая конверсия 11,84%, хорошие показатели на всех этапах воронки без значительных провалов.
Affiliate и Organic Search показывают близкие результаты: 9,90% и 9,69% соответственно.
Paid Social имеет низкую итоговую конверсию - 2,31%. Основные потери происходят при переходе от просмотра товара к добавлению в корзину (17,77%).
Referral : наименее эффективный канал. Итоговая конверсия составляет 1,08%. Особенно заметны потери на этапах просмотр -> корзина (13,70%) и оформление -> покупка (16,67%).

Вывод: наиболее результативные каналы - Email, Paid Search и Direct.
Каналы Referral и Paid Social требуют оптимизации, так как имеют самые низкие показатели конверсии в покупку.
*/
# по кампаниям;
SELECT
	campaign_id,
	ROUND(SUM(product_views>0)/ COUNT(*)*100,2) AS CR_session_to_product_views,
    ROUND(SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN product_views>0 THEN 1 ELSE 0 END)*100,2) AS CR_product_views_to_add_card,
    ROUND(SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)*100,2) AS CR_add_card_to_checkout,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)*100,2) AS CR_checkout_to_purchase,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS CR_purchase_to_session
FROM fact_sessions
GROUP BY campaign_id;
/*
ТОП-3 самых эффективных кампаний по общей конверсии в покупку:
camp_email_cart - 13,91%
camp_email_weekly - 13,46%
camp_ps_generic - 12,51%
Приоритетными для оптимизации являются кампании camp_meta_prospect, camp_tiktok_summer и camp_referral_influencer, где наблюдаются наибольшие потери пользователей на пути к покупке. 
*/
# по каналам и по кампаниям;
SELECT
	channel,
    campaign_id,
	ROUND(SUM(product_views>0)/ COUNT(*)*100,2) AS CR_session_to_product_views,
    ROUND(SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN product_views>0 THEN 1 ELSE 0 END)*100,2) AS CR_product_views_to_add_card,
    ROUND(SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)*100,2) AS CR_add_card_to_checkout,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)*100,2) AS CR_checkout_to_purchase,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS CR_purchase_to_session
FROM fact_sessions
GROUP BY 1,2
ORDER BY 1,2;

# по устройствам;
SELECT
	device,
	ROUND(SUM(product_views>0)/ COUNT(*)*100,2) AS CR_session_to_product_views,
    ROUND(SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN product_views>0 THEN 1 ELSE 0 END)*100,2) AS CR_product_views_to_add_card,
    ROUND(SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)*100,2) AS CR_add_card_to_checkout,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)*100,2) AS CR_checkout_to_purchase,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS CR_purchase_to_session
FROM fact_sessions
GROUP BY device;
/*
Несмотря на то что основная часть трафика приходится на мобильные устройства, 
именно на них наблюдается наиболее низкая конверсия на всех этапах воронки. 
Это может указывать на наличие проблем с мобильной версией сайта или на различия в поведении пользователей.
*/

# по месяцам;
SELECT
	month(session_date) AS month,
	ROUND(SUM(product_views>0)/ COUNT(*)*100,2) AS CR_session_to_product_views,
    ROUND(SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN product_views>0 THEN 1 ELSE 0 END)*100,2) AS CR_product_views_to_add_card,
    ROUND(SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)*100,2) AS CR_add_card_to_checkout,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)*100,2) AS CR_checkout_to_purchase,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS CR_purchase_to_session
FROM fact_sessions
GROUP BY 1;
/*
При анализе помесячной динамики видно, что в 6-м месяце конверсия снизилась по сравнению с предыдущими 2-мя месяцами, несмотря на существенный рост трафика. 
Это может свидетельствовать о снижении качества привлекаемого трафика или об изменении эффективности рекламных кампаний после их масштабирования. 
Это хорошо согласуется с предыдущим анализом: в 6 месяце резко вырос трафик за счет paid_social и paid_search, но одновременно снизилась конверсия. 
Это позволяет предположить, что дополнительный трафик был менее качественным по сравнению с трафиком предыдущих месяцев. 
*/
# по странам.
SELECT
	country,
	ROUND(SUM(product_views>0)/ COUNT(*)*100,2) AS CR_session_to_product_views,
    ROUND(SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN product_views>0 THEN 1 ELSE 0 END)*100,2) AS CR_product_views_to_add_card,
    ROUND(SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN add_to_cart_count>0 THEN 1 ELSE 0 END)*100,2) AS CR_add_card_to_checkout,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/
		  SUM(CASE WHEN checkout_started>0 THEN 1 ELSE 0 END)*100,2) AS CR_checkout_to_purchase,
    ROUND(SUM(CASE WHEN purchase_completed>0 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS CR_purchase_to_session
FROM fact_sessions
GROUP BY country;
/*
Конверсия на всех этапах воронки остается примерно одинаковой для всех стран. 
Существенных различий в поведении пользователей между странами не наблюдается.
*/

/* Общий вывод
Анализ всех этапов воронки показывает, что наибольшая потеря пользователей происходит на этапе перехода от просмотра товара к добавлению в корзину.
Именно на этом этапе наблюдается самая низкая конверсия, что свидетельствует о том, что значительная часть пользователей просматривает товары, но не добавляет их в корзину.
Такой результат может указывать на недостаточную привлекательность товаров, неудобство интерфейса карточек товара или другие факторы, влияющие на решение пользователя добавить товар в корзину. 
*/