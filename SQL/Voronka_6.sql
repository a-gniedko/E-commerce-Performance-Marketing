# Этап 6. Анализ кампаний
# какие кампании дали больше всего сессий;
SELECT 	
	campaign_id,
	COUNT(*) AS session
FROM fact_sessions
GROUP BY campaign_id
ORDER BY session DESC;

# какие кампании дали больше всего заказов;
SELECT 	
	campaign_id,
	COUNT(*) AS session,
	COUNT(DISTINCT CASE WHEN trim(order_id) <> '' THEN order_id END) AS orders
FROM fact_sessions
GROUP BY campaign_id
ORDER BY orders DESC;
/*
Лидерами по количеству заказов являются кампании camp_direct и camp_ps_generic - по 152 заказа каждая.
Наименее результативными являются camp_tiktok_summer (10 заказов)
и camp_referral_influencer (1 заказ), несмотря на 750 и 93 сессии соответственно.
*/
# какие кампании дали больше всего выручки;
SELECT 	
	campaign_id,
	SUM(net_revenue_eur) AS Net_revenue
FROM fact_sessions
GROUP BY campaign_id
ORDER BY Net_revenue DESC;
/*
Найбольшую выручку приносят кампании: camp_ps_generic, camp_direct и camp_organic_seo.
Среди email-кампаний лидирует camp_email_weekly, обеспечивая более чем в два раза большую выручку, чем camp_email_cart.
camp_meta_prospect, camp_tiktok_summer и camp_referral_influencer демонстрируют низкую выручку и требуют оптимизации или пересмотра стратегии.
*/

# какие кампании имеют низкую конверсию;
SELECT 	
	campaign_id,
	COUNT(*) AS session,
	COUNT(DISTINCT CASE WHEN trim(order_id) <> '' THEN order_id END) AS orders,
	ROUND(COUNT(DISTINCT CASE WHEN trim(order_id) <> '' THEN order_id END)/COUNT(*) *100,2) AS CR
FROM fact_sessions
GROUP BY campaign_id
ORDER BY CR ASC;

/*
Наиболее низкая конверсия у кампаний camp_tiktok_summer и camp_referral_influencer, что подтверждает наши выводы о  необходимости
 оптимизации или пересмотра стратегии.
*/
# какие кампании имеют spend;
SELECT 
	campaign_id,
	SUM(spend_eur) AS Ad_spend
FROM fact_marketing_spend
GROUP BY campaign_id
ORDER BY  Ad_spend DESC;
/*
E-mail кампании имеею наименьшие расходы на рекламу,  при этом обеспечивают высокую конверсию и значительную выручку,
что свидетельствует об их высокой рентабельности.
Кампании camp_direct и camp_organic_seo не требуют рекламных
расходов, однако приносят значительную выручку за счет органического
и прямого трафика.
Наибольшие рекламные расходы приходятся на кампании camp_ps_generic, при этом эта кампания обеспечивая наибольшую выручку среди всех кампаний.

*/
# какие кампании имеют высокий spend, но слабый revenue;
SELECT 
	s.campaign_id,
	Ad_spend,
	Net_revenue,
    ROUND(Net_revenue/Ad_spend,2) AS ROAS
FROM
	( SELECT 
		campaign_id,
		SUM(spend_eur) AS Ad_spend
	  FROM fact_marketing_spend
	  GROUP BY campaign_id) m
LEFT JOIN	 (SELECT 	
				campaign_id,
				SUM(net_revenue_eur) AS Net_revenue
		  FROM fact_sessions
		  GROUP BY campaign_id) s
ON m.campaign_id=s.campaign_id
ORDER BY Ad_spend DESC, Net_revenue ASC;

# какие кампании выглядят проблемными.
SELECT 
	s.campaign_id,
	Ad_spend,
	Net_revenue,
    ROUND(Net_revenue/Ad_spend,2) AS ROAS
FROM
	( SELECT 
		campaign_id,
		SUM(spend_eur) AS Ad_spend
	  FROM fact_marketing_spend
	  GROUP BY campaign_id) m
LEFT JOIN	 (SELECT 	
				campaign_id,
				SUM(net_revenue_eur) AS Net_revenue
		  FROM fact_sessions
		  GROUP BY campaign_id) s
ON m.campaign_id=s.campaign_id
WHERE Ad_spend > 0 AND Net_revenue/Ad_spend < 1;

# основная таблица для анализа кампаний.
SELECT 
c.campaign_id,
c.campaign_name,
c.channel,
c.campaign_type,
COUNT(s.session_id) AS sessions, 
COUNT(DISTINCT CASE WHEN TRIM(s.user_id) <> '' THEN s.user_id END) AS users,
COUNT(DISTINCT CASE WHEN TRIM(s.order_id) <> '' THEN s.order_id END) AS orders,
ROUND(COUNT(DISTINCT CASE WHEN TRIM(s.order_id) <> '' THEN s.order_id END)*100/COUNT(s.session_id),2) AS CR_pct,
SUM(s.net_revenue_eur) AS Net_revenue,
m.Ad_spend,
CASE
	WHEN m.Ad_spend>0 THEN ROUND(SUM(s.net_revenue_eur)/m.Ad_spend,2) ELSE NULL
END AS ROAS
FROM dim_campaigns c
LEFT JOIN fact_sessions s 
ON c.campaign_id=s.campaign_id
LEFT JOIN 
			(SELECT 
				campaign_id,
				SUM(spend_eur) AS Ad_spend
                FROM fact_marketing_spend 
                GROUP BY campaign_id) m
ON m.campaign_id=c.campaign_id
GROUP BY 
c.campaign_id,
c.campaign_name,
c.channel,
c.campaign_type,
Ad_spend 
ORDER BY ROAS DESC;

/*  Вывод: 
Проблемными остаются 4 кампании, у которых ROAS < 1. Эти кампании не окупают рекламные расходы.
Среди платных кампаний положительный ROAS имеют:
camp_email_weekly
camp_email_cart
camp_ps_generic
camp_ps_brand
Стоит также выделить кампании camp_organic_seo и camp_direct. 
Они являются лидерами по количеству сессий и оформленных заказов, что говорит о хорошей поисковой оптимизации сайта и его высокой видимости в поисковых системах, а также о высокой доле прямых заходов пользователей. 
Кроме того, эти кампании принесли наибольшую выручку, при этом затраты на рекламу по ним отсутствовали. 

Рекомендации по кампаниям
Продолжаем работу над сайтом:
Для camp_organic_seo рекомендация: продолжать SEO-оптимизацию и работу с органической видимостью. 
Для camp_direct рекомендация: поддерживать бренд, лояльность, повторные визиты и удобство возврата пользователей на сайт.
Эти кампании обеспечивают наибольшее количество сессий, заказов и выручки, при этом не требуют рекламных затрат. 
Масштабировать:
camp_email_weekly
сamp_email_cart
Эти кампании демонстрируют положительный ROAS и высокую эффективность, поэтому их можно рассматривать для дальнейшего масштабирования через CRM-сегментацию, персонализацию, A/B-тесты и контроль частоты рассылок
Оставить и дополнительно оптимизировать: 
camp_ps_generic оставить и оптимизировать, потому что она даёт высокий объём заказов и выручки, а ROAS выше 1.
camp_ps_brand оставить под наблюдением и оптимизировать стоимость привлечения, потому что кампания окупается, но её можно улучшать: смотреть CPC, ключевые слова, аудитории, посадочные страницы и долю возвратов.
Остановить и пересмотреть:
camp_meta_prospect
camp_affiliate_blog
camp_tiktok_summer
camp_referral_influencer
У данных кампаний ROAS < 1, то есть рекламные расходы не окупаются. Целесообразно остановить эти кампании и проанализировать причины низкой эффективности, пересмотреть настройки таргетинга, креативы и аудитории.
*/

