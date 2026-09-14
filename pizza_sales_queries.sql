-- 1. overall pizza sales performance : calculates total sales, total orders, total pizzas sold, and aov
select 
  round(sum(od.quantity * p.price), 2) as total_sales,
  count(distinct o.order_id) as total_orders,
  sum(od.quantity) as total_pizza_sold,
  round(safe_divide(sum(od.quantity * p.price), count(distinct o.order_id)), 2) as aov
from pizza_sales.orders o
join pizza_sales.order_details od on o.order_id = od.order_id
join pizza_sales.pizzas p on od.pizza_id = p.pizza_id;


-- 2. active periods : calculates total active days, iso weeks, and active months
select
  count(distinct date) as total_hari_aktif,
  count(distinct date_trunc(date, isoweek)) as total_minggu_aktif,
  count(distinct date_trunc(date, month)) as total_bulan_aktif
from pizza_sales.orders;

-- 3. monthly sales growth and contribution : calculates monthly sales and mom growth
with monthly_sales as (
  select 
    extract(month from o.date) as month_num,
    format_date('%B', o.date) as month,
    round(sum(od.quantity * p.price), 1) as total_sales
  from pizza_sales.orders o
  join pizza_sales.order_details od on o.order_id = od.order_id
  join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
  group by month_num, month)
select 
  month,
  total_sales,
  round(
    (total_sales - lag(total_sales) over (order by month_num)) 
    / lag(total_sales) over (order by month_num) 
    * 100, 2) as growth_pct,
from monthly_sales
order by month_num;

-- 4. category drivers for november sales lift : analyzes categories pizza fueling the revenue surge in november

with monthly_summary as (
  select
    pt.category as category,
    extract(month from o.date) as month_num,
    sum(od.quantity) as qty,
    round(sum(od.quantity * p.price), 2) as sales
  from pizza_sales.orders o
  join pizza_sales.order_details od on o.order_id = od.order_id
  join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
  join pizza_sales.pizza_types pt on p.pizza_type_id = pt.pizza_type_id
  where extract(month from o.date) in (10, 11)
  group by 1, 2)
select
  nov.category,
  (nov.qty - okt.qty) as qty_growth,
  round(safe_divide(nov.qty - okt.qty, okt.qty) * 100, 2) as qty_growth_pct,
  round(nov.sales - okt.sales, 2) as growth_nominal,
  round(safe_divide(nov.sales - okt.sales, okt.sales) * 100, 2) as growth_pct,
  round(safe_divide(nov.sales - okt.sales, 
  sum(nov.sales - okt.sales) over ()) * 100, 2) as contribution_pct
from monthly_summary nov
join monthly_summary okt 
  on nov.category = okt.category and okt.month_num = 10
where nov.month_num = 11
order by growth_nominal desc
limit 2;

-- 5. top performing months : identifies top 2 months for sales, orders, and pizzas sold
with monthly_perf as (
  select 
    format_date('%B', o.date) as month,
    round(sum(od.quantity * p.price), 2) as total_sales,
    count(distinct o.order_id) as total_orders,
    sum(od.quantity) as total_pizza_sold
  from pizza_sales.orders o
  join pizza_sales.order_details od on o.order_id = od.order_id
  join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
  group by month
)
select 
  array_agg(struct(month, total_sales) order by total_sales desc limit 2) as top_sales,
  array_agg(struct(month, total_orders) order by total_orders desc limit 2) as top_orders,
  array_agg(struct(month, total_pizza_sold) order by total_pizza_sold desc limit 2) as top_pizzas_sold
from monthly_perf;

-- 6. top category by volume (may & july) : identifies the top 2 pizzas sold by quantity
select
  format_date('%B', o.date) as bulan,
  pt.category as category,
  sum(od.quantity) as total_qty
from pizza_sales.orders o
join pizza_sales.order_details od on o.order_id = od.order_id
join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
join pizza_sales.pizza_types pt on p.pizza_type_id = pt.pizza_type_id
where extract(month from o.date) in (7, 5)
group by bulan, category
qualify row_number() over (partition by bulan order by total_qty desc) <= 2
order by min(extract(month from o.date)), total_qty desc;

-- 7. daily sales performance by day of week : calculates total revenue and daily averages for revenue, orders, and pizzas sold

with daily_stats as (
  select
    o.date,
    format_date('%A', o.date) as day_name,
    format_date('%u', o.date) as day_num,
    sum(od.quantity * p.price) as daily_revenue,
    count(distinct o.order_id) as daily_orders,
    sum(od.quantity) as daily_pizzas
  from pizza_sales.orders o
  join pizza_sales.order_details od on o.order_id = od.order_id
  join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
  group by o.date, day_name, day_num
)
select
  day_name,
  round(sum(daily_revenue), 1) as total_revenue,
  round(avg(daily_revenue), 1) as avg_revenue,
  round(avg(daily_orders)) as avg_orders,
  round(avg(daily_pizzas)) as avg_pizzas,
  count(date) as total_active_days
from daily_stats
group by day_name
order by total_revenue desc;

-- 8. peak hours analysis : calculates total orders, pizzas sold, revenue, daily averages, and active days grouped by hour of the day
select 
  extract(hour from o.time) as order_hour,
  count(distinct o.order_id) as total_orders,
  sum(od.quantity) as total_pizzas,
  round(sum(od.quantity * p.price), 1) as total_revenue,
  count(distinct o.date) as total_active_days
from pizza_sales.orders o
join pizza_sales.order_details od on o.order_id = od.order_id
join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
group by order_hour
order by total_orders desc;

-- 9. top pizzas and sizes during peak lunch and dinner hours : top 3 variations by quantity
select
  case
    when extract(hour from o.time) between 12 and 14 then '12:00 - 14:59 (Lunch)'
    else '17:00 - 19:59 (Dinner)'
  end as meal_window,
  pt.name as pizza_name,
  p.size as pizza_size,
  sum(od.quantity) as total_qty,
from pizza_sales.orders o
join pizza_sales.order_details od on o.order_id = od.order_id
join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
join pizza_sales.pizza_types pt on p.pizza_type_id = pt.pizza_type_id
where extract(hour from o.time) between 12 and 14
   or extract(hour from o.time) between 17 and 19
group by meal_window, pizza_name, pizza_size
qualify row_number() over (partition by meal_window order by total_qty desc) <= 3
order by meal_window, total_qty desc;

-- 10. top categories by order volume : ranks categories by distinct orders (orders table omitted)
select
  pt.category,
  count(distinct od.order_id) as total_orders,
  sum(od.quantity) as total_qty,
  round(sum(od.quantity * p.price), 1) as total_revenue
from pizza_sales.order_details od
join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
join pizza_sales.pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category
order by total_orders desc;

-- 11. top product and size combinations by volume : identifies best-selling sizes by quantity sold
select
  pt.name as pizza_name,
  p.size,
  sum(od.quantity) as total_qty,
  round(sum(od.quantity * p.price), 1) as total_revenue
from pizza_sales.order_details od
join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
join pizza_sales.pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pizza_name, p.size
order by total_qty desc
limit 5;

-- 12. product with lowest revenue
select
  pt.name as pizza_name,
  pt.category,
  sum(od.quantity) as total_qty,
  round(sum(od.quantity * p.price), 1) as total_revenue,
  count(distinct(od.order_id)) as total_order
from pizza_sales.order_details od
join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
join pizza_sales.pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pizza_name, category
order by total_revenue asc
limit 5;

-- 13. top product per category by revenue
select
  pt.category,
  pt.name as pizza_name,
  sum(od.quantity) as total_qty,
  round(sum(od.quantity * p.price), 1) as total_revenue
from pizza_sales.order_details od
join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
join pizza_sales.pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by category, pizza_name
qualify row_number() over (partition by category order by total_revenue desc) = 1
order by total_revenue desc;

-- 14. top pizza size per category by volume
select
  pt.category,
  p.size as pizza_size,
  sum(od.quantity) as total_qty,
  round(sum(od.quantity * p.price), 2) as total_revenue
from pizza_sales.order_details od
join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
join pizza_sales.pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by category, pizza_size
qualify row_number() over (partition by category order by total_qty desc) = 1
order by total_qty desc;

-- 15. most consumed ingredients : flattens ingredients directly to calculate dish count
select
  trim(ingredient) as ingredient_name,
  sum(od.quantity) as total_usage_count
from pizza_sales.order_details od
join pizza_sales.pizzas p on od.pizza_id = p.pizza_id
join pizza_sales.pizza_types pt on p.pizza_type_id = pt.pizza_type_id,
unnest(split(pt.ingredients, ',')) as ingredient
group by ingredient_name
order by total_usage_count desc
limit 10;