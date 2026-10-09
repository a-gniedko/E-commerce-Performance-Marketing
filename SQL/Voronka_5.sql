#Этап 5. Анализ маркетинговых каналов
# Для каждого канала нужно посчитать:
SELECT 	*
FROM fact_sessions;

# sessions;
SELECT 
	channel,
	COUNT(*) AS count_sessions
FROM fact_sessions
GROUP BY channel
ORDER BY count_sessions DESC;
/*
Наибольшее количество сессий привлекают каналы paid_social (1865) и paid_search (1765)
Минимальный объем трафика привлекает канал referral (93 сессии)
*/
# users;
SELECT 
	channel,
    COUNT(DISTINCT user_id) AS uniq_users
FROM fact_sessions
GROUP BY channel
ORDER BY uniq_users DESC;
/*
Наибольшее количество уникальных пользователей привлечено каналом paid_social (991) и paid_search (917), а наименьшее - referral (90).
Поскольку в канале referral зафиксировано 93 сессии и 90 уникальных пользователей, можно сказать, что у канала почти нет повторных сессий от одних и тех же пользователей
(очень низкая доля повторных визитов)
*/
/*Пользователь может быть уникальным в рамках канала, но не новым для бизнеса.
Проверим новых пользователей по каналам*/

SELECT 
	channel,
	COUNT(*) AS sessions,
    SUM(is_new_user_session) AS new_user_session,
    ROUND(SUM(is_new_user_session)*100/COUNT(*),2) AS new_user_session_rate_pct
FROM fact_sessions
GROUP BY channel
ORDER BY new_user_session_rate_pct DESC;

# orders;
SELECT 
	channel,
    COUNT(DISTINCT 
				CASE WHEN TRIM(order_id) <> '' THEN order_id -- Если order_id не пустой, вернуть его, иначе вернуть NULL (т.к. ELSE не указан)
				END
		  ) AS orders
FROM fact_sessions
GROUP BY channel
ORDER BY orders DESC;
/*
Набольшее кол-во заказов принес канал paid_search (217), наименьшее канал referral (1)
*/
# sessions; users; orders;
SELECT
    channel,
    COUNT(*) AS sessions,
    COUNT(DISTINCT user_id) AS users,
    COUNT(DISTINCT CASE WHEN TRIM(order_id) <> '' THEN order_id END) AS orders
FROM fact_sessions
GROUP BY channel
ORDER BY sessions DESC;
/*
Канал paid_social обеспечивает самый большой объем трафика, однако
формирует всего 43 заказа, что свидетельствует о низкой эффективности
привлекаемой аудитории.
Лидером по количеству заказов является paid_search (217 заказов)
Наименее результативным является referral — 93 сессии, 90 пользователей
и всего 1 заказ.
*/
# conversion rate - конверсию из сессии в заказ по каждому каналу
SELECT 	
	channel,
	COUNT(*) AS session, 
	COUNT(DISTINCT CASE WHEN TRIM(order_id)<> '' THEN order_id END) AS orders,
	ROUND(COUNT(DISTINCT CASE WHEN TRIM(order_id)<> '' THEN order_id END)/COUNT(*)*100,2) AS CR
    FROM fact_sessions
GROUP BY channel
ORDER BY CR DESC;
/*
Самым эффективным каналом по конверсии из сессии в заказ является Email (13,63%), за ним следуют Paid Search (12,29%) и Direct (11,84%).
Наименее эффективными являются Paid Social (2,31%) и Referral (1,08%).
*/

# gross revenue; # net revenue;
SELECT 	
	channel,
    SUM(gross_order_amount_eur) AS Gross_revenue,
    SUM(net_revenue_eur) AS Net_revenue
FROM fact_sessions
GROUP BY channel
ORDER BY Net_revenue DESC;
/*
Найбольшая выручка у канала paid_search: Gross Revenue - 35 389,73 и Net Revenue - 33 052,30
, наименьшая выручка у канала referral - 82,32
*/
# marketing spend;
SELECT 
channel,
SUM(spend_eur) AS Ad_Spend
FROM fact_marketing_spend 
GROUP BY channel
ORDER BY Ad_Spend DESC;
/*
Наибольшие рекламные расходы приходятся на канал paid_social - 32 627,09, наименьшее у канала email - 3470,96, при этом ранее он показал наивысшую конверсию в покупку (13,63%), что свидетельствует
о высокой эффективности использования рекламного бюджета.
*/

# clicks; # impressions;
SELECT 
channel,
SUM(clicks) AS clicks,
SUM(impressions) AS impressions
FROM fact_marketing_spend
GROUP BY channel;

# CPC - скільки коштує 1 клік
SELECT 
channel,
SUM(spend_eur) AS Cost,
SUM(clicks) AS Clicks,
ROUND(SUM(spend_eur)/NULLIF(SUM(clicks),0),2) AS CPC_Eur
FROM fact_marketing_spend
GROUP BY channel
ORDER BY CPC_Eur DESC;
/*
Наибольшая цена за клик у канала paid_search - 0,79 Eur, наименьшая у email всего 0,08 Eur
*/

#CTR
SELECT 
channel,
SUM(impressions),
SUM(clicks),
ROUND(SUM(clicks)/NULLIF(SUM(impressions),0)*100,2) AS CTR
FROM fact_marketing_spend
GROUP BY channel
ORDER BY CTR DESC;
/*
Наибольший CTR демонстрирует канал email - 8,49%, что свидетельствует
о высокой вовлеченности аудитории и эффективности email-рассылок.
Несмотря на самое большое количество показов (3 618 910) и кликов (64 974),
paid_social имеет самый низкий CTR - 1,80%, что может указывать на
низкую привлекательность рекламных объявлений или недостаточно точный
таргетинг аудитории.
Для каналов direct и organic_search показатель CTR не рассчитывается,
так как они не используют показы и клики рекламных объявлений.
*/

# ROAS
SELECT 	
s.channel,
s.Net_revenue,
m.Ad_Spend,
CASE
	WHEN m.Ad_Spend>0  -- если у канала нет spend, ROAS либо не рассчитывается, либо становится некорректным для сравнения
	THEN ROUND(s.Net_revenue/m.Ad_Spend,2) 
    ELSE NULL
END AS ROAS
FROM 
	(SELECT 
		channel,
		SUM(net_revenue_eur) AS Net_revenue
	FROM fact_sessions
	GROUP BY channel
    ) s
LEFT JOIN (SELECT 
				channel,
				SUM(spend_eur) AS Ad_Spend
				FROM fact_marketing_spend
				GROUP BY channel) as m
ON s.channel=m.channel
ORDER BY ROAS DESC;

/*
Самым эффективным каналом оказался e-mail. Его ROAS = 4,51, то есть каждый 1 € рекламных расходов принес 4,51 € выручки. 
Вторым по эффективности является канал paid_search с ROAS = 1,16. 
Наименее эффективными оказались каналы paid_social, affiliate и referral. Их ROAS < 1, что означает, что расходы на рекламу по этим каналам не окупаются.

*/

/* Общий вывод:
Сравнение каналов показывает, что e-mail является наиболее эффективным каналом привлечения пользователей: он сочетает высокий ROAS, низкую стоимость клика и самую высокую конверсию. 
Напротив, каналы paid_social, affiliate и referral, несмотря на привлечение трафика, работают неэффективно с точки зрения окупаемости рекламных расходов. 
Для этих каналов целесообразно пересмотреть стратегию привлечения аудитории и оптимизировать рекламные кампании. 

*/