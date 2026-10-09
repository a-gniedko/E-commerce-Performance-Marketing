#Этап 7. Анализ устройств
SELECT *
FROM fact_sessions;

#сессии по устройствам;
SELECT 
	device,
    COUNT(*) AS session
	FROM fact_sessions
GROUP BY device
ORDER BY session DESC;
/* Лидер по кол-ву сессий mobile - 4852 сессий */

# Есть ли просадка помесячно
SELECT 
	device,
    month(session_date) AS month,
    COUNT(*) as session
FROM fact_sessions
GROUP BY device,month
ORDER BY device;
# На мобильных устройствах наблюдается положительная ежемесячная динамика количества сессий.

#заказы по устройствам;
SELECT 
	device,
    SUM(purchase_completed) AS order_by_device
	FROM fact_sessions
GROUP BY device
ORDER BY order_by_device DESC;
/* наибольшее кол-ву заказов у mobile - 383 заказа*/

SELECT 
	device,
    month(session_date) AS month,
	COUNT(*) as session,
	SUM(purchase_completed) AS order_by_device
FROM fact_sessions
GROUP BY device, month
ORDER BY device;
/*на мобильных устройствах в июне несмотря на значительный рост числа сессий, количество заказов уменьшилось.
Это свидетельствует о том, что дополнительный мобильный трафик оказался менее качественным либо пользователи стали чаще покидать воронку до завершения покупки.
*/
# конверсия по устройствам;
SELECT 
	device,
	COUNT(*) AS session_by_device,
    SUM(purchase_completed) AS purchases,
	ROUND(SUM(purchase_completed)/COUNT(*)*100,2) AS CR_by_device
FROM fact_sessions
GROUP BY device
ORDER BY CR_by_device DESC;

/*
Наибольшую конверсию из сессии в покупку демонстрируют пользователи
настольных устройств (Desktop) — 11,49%. Практически такой же показатель
у планшетов (Tablet) — 11,15%.
При этом основная доля трафика приходится на мобильные устройства
(4 852 сессии), однако их конверсия значительно ниже — 7,89%.
Это свидетельствует о необходимости оптимизации мобильной версии сайта и процесса оформления заказа.
*/
# воронка по устройствам;
SELECT
    device,
    COUNT(*) AS sessions,
    SUM(product_views > 0) AS product_views,
    SUM(add_to_cart_count > 0) AS add_to_cart,
    SUM(checkout_started =1) AS checkout,
    SUM(purchase_completed = 1) AS purchases
FROM fact_sessions
GROUP BY device;

# конверсия на каждом этапе воронки по устройствам;
SELECT 
	device,
	ROUND(SUM(product_views>0)*100/COUNT(*),2) AS CR_session_to_product_view,
    ROUND(SUM(add_to_cart_count>0)*100/SUM(product_views>0),2) AS CR_product_view_to_add_card,
	ROUND(SUM(checkout_started=1)*100/SUM(add_to_cart_count>0),2) AS CR_add_card_to_checkout,
    ROUND(SUM(purchase_completed=1)*100/SUM(checkout_started=1),2) AS CR_checkout_purchase,
    ROUND(SUM(purchase_completed=1)/COUNT(*)*100,2) AS CR_session_to_purchase
FROM fact_sessions
GROUP BY device;
/* На всех этапах воронки самая низкая конверсия у мобильных устройств */

#Анализ воронки мобильных пользователей
SELECT 
	month(session_date) AS month,
	ROUND(SUM(product_views>0)*100/COUNT(*),2) AS CR_session_to_product_view,
    ROUND(SUM(add_to_cart_count>0)*100/SUM(product_views>0),2) AS CR_product_view_to_add_card,
	ROUND(SUM(checkout_started=1)*100/SUM(add_to_cart_count>0),2) AS CR_add_card_to_checkout,
    ROUND(SUM(purchase_completed=1)*100/SUM(checkout_started=1),2) AS CR_checkout_purchase,
    ROUND(SUM(purchase_completed=1)/COUNT(*)*100,2) AS CR_session_to_purchase
FROM fact_sessions
WHERE device ='mobile'
GROUP BY month;

/* Анализ воронки мобильных пользователей
В июне наблюдается существенное снижение общей конверсии мобильных устройств
из сессии в покупку — с 10,39% в мае до 4,98% в июне. Просадка наблюдается на всех этапах воронки.
Однако найболее существенная просадка наблюдается на этапах:
Add to Cart -> Checkout: снижение с 59,15% до 44,72%.
Checkout -> Purchase: снижение с 70,95% до 53,70%,
*/
#Новые и повторные пользователи
SELECT
	device,
    month(session_date) AS month,
    COUNT(DISTINCT user_id) AS all_users,
	COUNT(DISTINCT CASE WHEN is_new_user_session=1 THEN user_id END) AS new_user,
	COUNT(DISTINCT CASE WHEN is_new_user_session=0 THEN user_id END) AS return_users,
    ROUND(COUNT(DISTINCT CASE WHEN is_new_user_session=1 THEN user_id END)*100/COUNT(DISTINCT user_id),2) AS rate_new_user_cnt,
	ROUND(COUNT(DISTINCT CASE WHEN is_new_user_session=0 THEN user_id END)*100/COUNT(DISTINCT user_id),2) AS rate_return_user_cnt
FROM fact_sessions
GROUP BY device,month
order BY device;

/*Однако один пользователь теоретически может иметь в месяце и новую, и последующие повторные сессии.
Тогда он попадёт в обе категории (выше запрос это показывает). Поэтому для строгого деления пользователей лучше определить дату первой сессии каждого пользователя и сравнить её с анализируемым месяцем.*/
WITH first_date as (SELECT
user_id,
MIN(session_date) AS first_session_date
FROM fact_sessions
GROUP BY user_id)
SELECT
s.device,
month(s.session_date) as month,
COUNT(DISTINCT s.user_id) AS all_users,
COUNT(DISTINCT CASE WHEN month(s.session_date)= month(f.first_session_date) AND YEAR(s.session_date)=YEAR(f.first_session_date) THEN s.user_id
      END
	 ) AS new_users,
COUNT(DISTINCT CASE WHEN f.first_session_date<date_format(s.session_date, '%Y-%m-01') THEN s.user_id
	  END
     ) AS return_users,
ROUND(COUNT(DISTINCT CASE WHEN month(s.session_date)= month(f.first_session_date) AND YEAR(s.session_date)=YEAR(f.first_session_date) THEN s.user_id
      END
	 )*100/COUNT(DISTINCT s.user_id),2) AS rate_new_users_cnt,
ROUND(COUNT(DISTINCT CASE WHEN f.first_session_date<date_format(s.session_date, '%Y-%m-01') THEN s.user_id
	  END
     ) *100/COUNT(DISTINCT s.user_id),2) AS rate_return_users_cnt
FROM fact_sessions s
JOIN first_date f
ON f.user_id=s.user_id
GROUP BY s.device,  MONTH(s.session_date)
ORDER BY s.device,  MONTH(s.session_date);

/*
В апреле на всех устройствах доля новых пользователей составила 100%.

В мае и особенно в июне на всех типах устройств наблюдается
снижение доли новых пользователей и рост доли вернувшихся пользователей. 

Таким образом, июньский рост трафика был обеспечен преимущественно за счет возвращающихся пользователей, однако это не привело
к увеличению количества заказов и выручки.

Следовательно, снижение мобильной конверсии связано не с увеличением доли
новых пользователей, а с ухудшением эффективности прохождения воронки или качества привлекаемого мобильного трафика.
*/

# средний чек по устройствам помесячно;
SELECT
    s.device,
    month(o.order_date) as month,
    ROUND(AVG(o.total_amount_eur), 2) AS avg_gross_order_value,
    ROUND(AVG(CASE
					WHEN o.order_status IN ('paid', 'completed')
					THEN o.net_revenue_eur
			 END), 2) AS avg_net_order_value
FROM fact_orders o
JOIN fact_sessions s
    ON o.session_id = s.session_id
GROUP BY s.device, month(o.order_date)
ORDER BY s.device, month;
# на всех устройствах средний чек снижается с каждым месяцем. Найбольшее снижение ср. чека было на планшетах.

# средяя выручка на одну сессию по устройствам помесячно;
SELECT 
	device,
    month(session_date) AS month,
    ROUND(SUM(gross_order_amount_eur)/COUNT(*),2) AS gross_revenue_per_session, -- COUNT(*) считает все сессии, включая сессии без покупки.
	ROUND(SUM(net_revenue_eur)/COUNT(*),2) AS net_revenue_per_session
FROM fact_sessions
GROUP BY device, month
ORDER BY device;
# на всех устройствах средняя выручка на 1 сессию снижается с каждым месяцем. На мобильных устройствах самый низкиая средняя выручка

# выручка по устройствам помесячно
SELECT 
	device,
    month(session_date) AS month,
	COUNT(*) as session,
	SUM(purchase_completed) AS order_by_device,
    SUM(gross_order_amount_eur) AS gross_revenue,
    ROUND(SUM(gross_order_amount_eur)*100/SUM(SUM(gross_order_amount_eur)) OVER(),2) AS gross_revenue_rate_pct,
	SUM(net_revenue_eur) AS net_revenue,
	ROUND(SUM(net_revenue_eur) * 100.0 / SUM(SUM(net_revenue_eur)) OVER (), 2) AS net_revenue_rate_pct
FROM fact_sessions
GROUP BY device, month
ORDER BY device;
/* 
Наибольшая выручка у мобильных устройств: их Gross и Net выручка составляет более 50% от всей выручки
Однако несмотря на то что мобильные устройства остаются основным источником выручки, в июне их финансовые показатели заметно ухудшились.
*/ 

# проверим кол-во сессий мобильных устройств по кампаниям помесячно
SELECT 
	campaign_id,
    month(session_date) as month,
    COUNT(*) as session
FROM fact_sessions
WHERE  device='mobile'
GROUP BY campaign_id, month    
ORDER BY campaign_id;
/*
На мобильных устройствах по большинству кампаний наблюдается рост количества сессий от месяца к месяцу.
Исключение составляет camp_email_weekly, где в июне число мобильных сессий снизилось по сравнению с маем.
Особенно заметный рост показала кампания camp_tiktok_summer, количество мобильных сессий которой увеличилось с 55 в мае до 560 в июне.
Для camp_referral_influencer данные за апрель отсутствуют, поэтому динамику можно оценить только с мая по июнь, где также наблюдается рост.
*/
# Анализ кампаний мобильных устройств
WITH first_date as (SELECT
user_id,
MIN(session_date) AS first_session_date
FROM fact_sessions
GROUP BY user_id)
SELECT 
    s.campaign_id,
    month(s.session_date) AS month,
    COUNT(*) as session,
    SUM(s.purchase_completed) as orders,
	COUNT(DISTINCT s.user_id) AS all_users,
	COUNT(DISTINCT CASE WHEN month(s.session_date)= month(f.first_session_date) AND YEAR(s.session_date)=YEAR(f.first_session_date) THEN s.user_id END) AS new_users,
	COUNT(DISTINCT CASE WHEN f.first_session_date<date_format(s.session_date, '%Y-%m-01') THEN s.user_id END) AS return_users,
	ROUND(COUNT(DISTINCT CASE WHEN month(s.session_date)= month(f.first_session_date) AND YEAR(s.session_date)=YEAR(f.first_session_date) THEN s.user_id
      END)*100/COUNT(DISTINCT s.user_id),2) AS rate_new_users_cnt,
	ROUND(COUNT(DISTINCT CASE WHEN f.first_session_date<date_format(s.session_date, '%Y-%m-01') THEN s.user_id
	  END) *100/COUNT(DISTINCT s.user_id),2) AS rate_return_users_cnt,
    SUM(gross_order_amount_eur) AS gross_revenue,
    SUM(net_revenue_eur) AS net_revenue
FROM fact_sessions s
JOIN first_date f
ON f.user_id=s.user_id
WHERE device='mobile'
GROUP BY s.campaign_id,month(s.session_date)
order by s.campaign_id,month(s.session_date);

/* Вывод: Анализ кампаний мобильных устройств
В апреле у всех кампаний доля новых пользователей составила 100%.
camp_direct - Не смотря на то что в июне кол-во сессий увеличилось, выручка и кол-во заказов снизилось. 
camp_email_weekly - в июне снизились сессии, но заказы остались практически на том же уровне
camp_meta_prospect - несмотря на то что кол-во сессий в июне увеличилось в 1,8 раза по сравнению с маем, ко-во заказов осталось на том же уровне
camp_organic_seo - в июне увеличилось сессии , но заказы упали (c 40 до 17)
camp_ps_brand - в июне увеличилось сессии , но число заказов и выручка снизились.
camp_tiktok_summer - при сильном росте сесий (с 55 до 560) кол-во заказов увечилось незначительно (2 → 6) и выручка выросла несущественно.

В мае и особенно в июне для всех кампаний наблюдается
снижение доли новых пользователей и рост доли вернувшихся пользователей. 
Таким образом, июньский рост трафика был обеспечен преимущественно за счет возвращающихся пользователей, однако это не привело
к увеличению количества заказов и выручки.
Это подтверждает, что снижение эффективности мобильных кампаний связано не с изменением состава аудитории, а, вероятнее всего, с ухудшением конверсии или качества мобильного трафика.
*/

SELECT
    device,
    checkout_flow_version,
    month(session_date) AS month,
    COUNT(*) AS sessions,
    SUM(checkout_started) AS checkout_started,
    SUM(purchase_completed) AS purchases,
    ROUND(SUM(purchase_completed) * 100.0/NULLIF(SUM(checkout_started),0),2) AS checkout_to_purchase_cr,
    ROUND(SUM(purchase_completed) * 100.0 /COUNT(*),2) AS session_to_purchase_cr
FROM fact_sessions
GROUP BY
    device,
    checkout_flow_version,
    month(session_date)
ORDER BY device, month, checkout_flow_version;
/*
В июне на мобильных устройствах было 2 версии checkout. Выявлена существенная разница в эффективности между ними.
Версия standard работает стабильно:
апрель: 67.82%
май:70.95%
июнь:66.39%
Падение в июне небольшое и не объясняет резкое снижение общей конверсии.
Проблема сосредоточена в mobile_checkout_v2
Checkout -> Purchase CR всего 38.14%, что почти в 2 раза ниже, чем у standard (66.39%).
Session -> Purchase CR — 3.22% против 6.71% у стандартной версии в том же месяце.

Это указывает на то, что снижение мобильной конверсии в июне, вероятнее всего, связано с внедрением новой версии checkout,
 а не только с изменением качества трафика.
 */


/*  Общий вывод:
Мобильные устройства являются основным источником трафика и выручки интернет-магазина: 
на них приходится наибольшее количество сессий (4 852), заказов (383), а также более 50% Gross и Net выручки.

При этом в июне, несмотря на значительный рост числа мобильных сессий, количество заказов и выручка снизились. 
Одновременно общая конверсия мобильных пользователей из сессии в покупку сократилась более чем в 2 раза — с 10,39% до 4,98%.
Анализ воронки показал, что снижение эффективности наблюдается на всех этапах пути пользователя.
 
В апреле все мобильные пользователи в рамках анализируемого периода относились к новым. К июню доля новых пользователей снизилась до 16,5%, тогда как доля вернувшихся пользователей выросла до 83,5%. 
Однако рост доли возвращающихся пользователей не привел к увеличению количества заказов и выручки.

Анализ мобильных кампаний показал, что рост трафика в июне во многих случаях не сопровождался ростом заказов и выручки.
Особенно это заметно для кампаний camp_meta_prospect, camp_organic_seo, camp_ps_brand и camp_tiktok_summer, где увеличение количества сессий не привело к сопоставимому росту продаж.
Дополнительный анализ поля checkout_flow_version показал, что в июне на мобильных устройствах использовались 2 версии checkout.
Версия standard сохранила стабильный уровень конверсии, тогда как mobile_checkout_v2 показала почти вдвое более низкую конверсию из этапа checkout в покупку. 
Это позволяет предположить, что снижение мобильной конверсии в июне могло быть связано с внедрением новой версии mobile_checkout_v2.

 */