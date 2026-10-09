# Этап 3. Базовый анализ трафика
#количество сессий по дням;
SELECT 
	session_date,
	COUNT(*) AS count_sessions_by_day	
FROM fact_sessions
GROUP BY session_date
ORDER BY session_date;

#количество сессий по неделям;
SELECT
    YEAR(session_start) AS year,
    WEEK(session_start, 1) AS week, -- неделя начинается с понедельника
    COUNT(*) AS count_sessions
FROM fact_sessions
GROUP BY  YEAR(session_start), WEEK(session_start, 1)
ORDER BY year, week;

#количество сессий по месяцам;
SELECT
	YEAR(session_start) AS year,
    MONTH(session_start) AS month,
	COUNT(*) AS count_sessions
FROM fact_sessions
GROUP BY year, month
ORDER BY year, month;

#количество пользователей в справочнике;
SELECT
	COUNT(*) AS registered_users
FROM dim_users;

#количество активных пользователей, то есть тех, у кого были сессии в анализируемом периоде
SELECT
	COUNT(distinct user_id) AS active_users
FROM fact_sessions;

#долю новых пользовательских сессий;
SELECT 
	COUNT(*) AS all_sessions,
	SUM(is_new_user_session) AS new_user_session,
	ROUND(100*SUM(is_new_user_session)/COUNT(*),2) AS new_user_session_rate_pct
FROM fact_sessions;

#распределение трафика по каналам;
SELECT
	channel,
	COUNT(*) AS count_sessions_by_channel
FROM fact_sessions
GROUP BY channel;

# Основной канал привлечения трафика paid_social (1865) и paid_search (1765)

#распределение трафика по каналам и по месяцам
# можем посмотреть динамику роста по каналам, связан ли рост трафика с конкретным каналом;
SELECT
    month(session_date) as month,
	channel,
	COUNT(*) AS count_sessions_by_channel
FROM fact_sessions
GROUP BY channel, month
ORDER BY channel ,month;
/*
Анализ ежемесячной динамики по каналам привлечения показывает, что по большинству каналов трафик рос постепенно.
Исключением стали каналы paid_social и paid_search, где в 6 месяце наблюдался резкий рост.
Наиболее значительное увеличение произошло в канале paid_social - объем трафика вырос почти в 4 раза по сравнению с предыдущими месяцами. 
*/
#распределение трафика по устройствам.
SELECT
	device,
	COUNT(*) AS count_sessions_by_device
FROM fact_sessions
GROUP BY device;
# Mobile даёт наибольшую долю сессий (4852), поэтому на следующих этапах важно проверить мобильную конверсию

#распределение трафика по campaigns
SELECT
	month(session_date) AS month_campaign,
    channel,
	campaign_id,
	COUNT(*) AS count_sessions_by_campaign
FROM fact_sessions
GROUP BY month_campaign, campaign_id, channel
ORDER BY campaign_id,  month_campaign, channel;
/* В 6 месяце масштабировались 2 кампании в канале paid_social: camp_meta_prospect и camp_tiktok_summer, именно за их счет произошло резкое увеличение трафика. */

#количество пользователей по каналам 
SELECT
    channel,
    COUNT(distinct user_id) AS count_users_by_channel
FROM fact_sessions
GROUP BY channel;
# Найбольшее кол-во пользователей привел канал paid_search (917) и organic_search (830)

/* На протяжении трех месяцев наблюдался плавный рост трафика. Однако в 6 месяце по сравнению с 4 объем трафика вырос почти в два раза. Основной прирост пришелся на мобильные устройства.
Основным источником привлечения трафика был канал paid_social. В шестом месяце были масштабированы две рекламные кампании в этом канале, что и стало основной причиной резкого увеличения трафика.
*/


