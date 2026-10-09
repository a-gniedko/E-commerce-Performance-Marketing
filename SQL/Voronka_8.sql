#  Этап 8. Анализ заказов и выручки
# количество заказов
SELECT 
    COUNT(*) AS total_order
    FROM fact_orders;
# Всего создано 700 заказов

SELECT 
    COUNT(*) AS total_order,
    SUM(CASE WHEN order_status IN('cancelled','refunded') THEN 1 ELSE 0 END) AS refunded_cancel_order,
    SUM(CASE WHEN order_status IN('paid','completed') THEN 1 ELSE 0 END) AS paid_completed_order
FROM fact_orders;
# Всего создано 700 заказов. Из них 63 отменённых и возвращённых заказов
# 637- оплаченных и завершенных заказов

# количество отменённых и возвращённых заказов. Отдельно посчитано;
SELECT 
COUNT(*) AS cnt_cancel_order
FROM fact_orders
WHERE order_status='cancelled' OR order_status='refunded';

# долю refunded и cancelled;
SELECT 
COUNT(*) AS count_cancel_order,
(SELECT COUNT(*) AS CNT FROM fact_orders) AS total_orders,
ROUND(COUNT(*)*100/(SELECT COUNT(*) AS CNT FROM fact_orders),2) AS rate_cancel_order_cnt
FROM fact_orders
WHERE order_status IN ('cancelled','refunded');
# Доля отменённых и возвращённых заказов составляет 9%, то есть примерно каждый одиннадцатый созданный заказ не был успешно завершён.

#средняя стоимость заказа Gross Order Value - фактически успешных продаж
SELECT 
ROUND(AVG(total_amount_eur),2) AS AVG_gross_order_value
FROM fact_orders
WHERE order_status IN ('completed','paid');
# Средняя стоимость заказа 154.17 eur

#среднее Net Order Value
SELECT 
ROUND(AVG(net_revenue_eur),2) AS AVG_net_order_value
FROM fact_orders
WHERE order_status IN ('completed','paid');
# 154.17 eur

#net_revenue_per_session
SELECT 
channel,
ROUND(SUM(net_revenue_eur)/COUNT(*),2) AS net_revenue_per_session
FROM fact_sessions
GROUP BY channel
ORDER BY net_revenue_per_session DESC;
/*
Наибольшую среднюю выручку на одну сессию демонстрирует канал email (19.06€),
немного уступает paid_search (18.73€). Это свидетельствует о высокой
эффективности этих каналов в привлечении платежеспособной аудитории.
Наименее эффективными являются paid_social (3.46€) и особенно referral (0.89€).
*/

#средний чек по каналам; 
SELECT 
s.channel,
COUNT(o.order_id) AS orders,
ROUND(AVG(o.total_amount_eur),2) AS avg_gross_order_value,
ROUND(AVG(o.net_revenue_eur),2) AS avg_net_order_value
FROM fact_orders o
JOIN fact_sessions s
ON o.session_id=s.session_id
WHERE o.order_status IN ('completed','paid')
GROUP BY s.channel
ORDER BY avg_net_order_value DESC;
# Наибольший ср.чек и кол-во заказов в канале paid_search

#средняя фактическая цена одной проданной единицы товара в категории.
#В этом расчёте средней фактической цены единицы товара и средней суммы заказа по категории сейчас учитываются все заказы, включая cancelled и refunded.
/*SELECT 
dp.category,
sum(oi.quantity) as units_sold,
SUM(oi.line_total_eur) AS amount,
ROUND(SUM(oi.line_total_eur)/NULLIF(SUM(oi.quantity),0),2) AS average_unit_selling_price  -- средняя фактическая цена одной проданной единицы товара в категории. 
FROM fact_order_items oi
JOIN dim_products dp
ON oi.product_id=dp.product_id
GROUP BY dp.category 
ORDER BY average_unit_selling_price DESC; */

#Чтобы сделать расчет сред. цены одной проданной ед.товара в категории для фактически проданных товаров, лучше соединить позиции с fact_orders и оставить только успешные статусы.
SELECT 
    p.category,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total_eur) AS merchandise_revenue,
    ROUND(
        SUM(oi.line_total_eur) / NULLIF(SUM(oi.quantity), 0),
        2
    ) AS average_unit_selling_price
FROM fact_order_items oi
JOIN dim_products p
    ON oi.product_id = p.product_id
JOIN fact_orders o
    ON oi.order_id = o.order_id
WHERE o.order_status IN ('paid', 'completed')
GROUP BY p.category
ORDER BY average_unit_selling_price DESC;
# Наименьшая средняя фактическая цена 1 проданной ед. товара в категории beauty (40.95€), а найбольшая в категории electronics (127.58€)

#средняя сумму заказа, содержащего категорию товаров (всех созданных заказов, в том числе cancelled и refunded)
# Если требуется именно средняя сумма заказа, содержащего категорию, нужно сначала сгруппировать позиции по заказу и категории, а затем рассчитать среднее.
SELECT
    category,
    ROUND(AVG(order_category_amount),2) AS avg_order_value
FROM (
    SELECT
        oi.order_id,
        p.category,
        SUM(oi.line_total_eur) AS order_category_amount
    FROM fact_order_items oi
    JOIN dim_products p
        ON oi.product_id = p.product_id
    GROUP BY
        oi.order_id,
        p.category
) t
GROUP BY category;
#Наибольшая сред сумма заказа в категориях electronics и fashion, наименьшая - в категории beauty

#средняя сумму товаров конкретной категории внутри заказа
SELECT
category,
ROUND(AVG(order_category_amount), 2) AS avg_order_category_amount
FROM (
SELECT
oi.order_id,
p.category,
SUM(oi.line_total_eur) AS order_category_amount
FROM fact_order_items oi
JOIN dim_products p
ON oi.product_id = p.product_id
JOIN fact_orders o
ON oi.order_id = o.order_id
WHERE o.order_status IN ('paid', 'completed')
GROUP BY
oi.order_id,
p.category
) t
GROUP BY category;
#Наибольшая сред сумма фактических продаж (только успешные заказы) в категориях electronics -164.79 и fashion - 146.30, 
# наименьшая - в категории beauty - 56.45

#общие gross revenue и net revenue 
SELECT 
SUM(net_revenue_eur) AS net_revenue,
SUM(total_amount_eur) AS gross_revenue
FROM fact_orders; 
#net revenue  98205.01€ gross revenue 108321.95€

# чистая выручка без отменённых и возвращённых заказов
SELECT 
COUNT(*) AS cnt_paid_order,
SUM(net_revenue_eur) AS net_revenue_wo_cancel
FROM fact_orders
WHERE order_status NOT IN ('cancelled','refunded');

# Товарная выручка по категориям успешных заказов, но без распределения общей скидки и доставки.
SELECT 
dp.category,
COUNT(DISTINCT o.order_id) AS orders,
SUM(oi.quantity) AS uits_sold,
SUM(oi.line_total_eur) AS merchandise_revenue
FROM fact_order_items oi
JOIN  dim_products dp
ON oi.product_id= dp.product_id
JOIN fact_orders o
ON oi.order_id=o.order_id
WHERE o.order_status IN ('paid', 'completed')
GROUP BY dp.category
ORDER BY merchandise_revenue DESC;
# Наибольшая товарная выручка в категории fashion - 31016.19€  

#Для более точного Net Revenue по категориям скидку заказа можно распределить между позициями пропорционально их стоимости:
select
    p.category,
    round(sum(
        case
            when o.order_status in ('paid', 'completed')
            then oi.line_total_eur
                 / nullif(o.subtotal_eur, 0)
                 * (o.subtotal_eur - o.discount_eur)
            else 0
        end
    ), 2) as net_merchandise_revenue
from fact_order_items oi
join dim_products p
    on oi.product_id = p.product_id
join fact_orders o
    on oi.order_id = o.order_id
group by p.category
order by net_merchandise_revenue desc;
/* Здесь доставка не распределяется по категориям, потому что это не выручка от конкретного товара. Для товарного анализа это более понятный вариант.
Почему это улучшит работу: выручка заказа не будет многократно повторяться после соединения с позициями, а скидка будет распределена между категориями пропорционально.*/

#  Отмены и возвраты по категориям
select
    p.category,
    count(distinct o.order_id) as all_orders,
    count(distinct case
        when o.order_status in ('cancelled', 'refunded')
        then o.order_id
    end) as cancelled_refunded_orders,
    round(
        count(distinct case
            when o.order_status in ('cancelled', 'refunded')
            then o.order_id
        end) * 100.0 /
        nullif(count(distinct o.order_id), 0),
        2
    ) as cancelled_refunded_rate_pct
from fact_order_items oi
join dim_products p
    on oi.product_id = p.product_id
join fact_orders o
    on oi.order_id = o.order_id
group by p.category
order by cancelled_refunded_rate_pct desc;
#Категория Beauty имеет наиболее высокую долю заказов с отменой или возвратом».

/*
## Общий вывод

За анализируемый период было оформлено 700 заказов, из которых :
637 (91%) были успешно оплачены или завершены,
63 (9%) - отменены или возвращены. 
Таким образом, примерно каждый одиннадцатый заказ не был успешно завершен.

Средние Gross Order Value и Net Order Value для успешно завершённых заказов совпадают и составляю 154,17 €, поскольку в данной модели данных net_revenue_eur для заказов со статусами paid и completed равен итоговой сумме заказа total_amount_eur. 
Отменённые и возвращённые заказы в этот расчёт не входят.
Анализ среднего чека показал, что Paid Search не только обеспечивает наибольшее количество заказов, но и имеет самый высокий средний чек.

Наиболее высокий средний чек заказа характерен для категорий Electronics и Fashion, тогда как категория Beauty имеет наименьший средний чек.

Общая валовая выручка (Gross Revenue) составила 108 321,95 €, а чистая выручка (Net Revenue) — 98 205,01 €.

Наибольшую товарную выручку приносит категория Fashion (31 016,19 €), что свидетельствует о ее ключевой роли в формировании дохода интернет-магазина. После распределения скидок пропорционально стоимости товаров лидерство категории сохраняется и по чистой товарной выручке.

Анализ отмен и возвратов показал, что наиболее высокая доля отмененных и возвращенных заказов приходится на категорию Beauty.
Поэтому категория Beauty требует дополнительного анализа причин отмен и возвратов. 
Для подтверждения причин понадобились бы данные о причинах возврата, отзывах, товарах и сроках доставки.

В целом анализ показывает, что найбольшую выручку интернет-магазину приносят канал Paid Search и категории Fashion и Electronics, 
тогда как категория Beauty характеризуется наиболее низкой стоимостью товаров и наиболее высокой долей отмен и возвратов.

*/