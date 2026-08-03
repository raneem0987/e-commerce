create database ecommerce_db;
go

use ecommerce_db;


/*--------------------------- available tables ---------------------------*/

select table_name
from information_schema.tables
where table_type = 'base table';

select table_name
from information_schema.tables
order by table_name;


/*--------------------------- data cleaning ---------------------------*/

-- check orders with missing delivery date
select *
from orders_dataset
where order_delivered_customer_date is null;

-- check duplicate order ids
select order_id, count(*)
from orders_dataset
group by order_id
having count(*) > 1;


/*--------------------------- sales analysis ---------------------------*/

-- total number of orders
select count(*) as total_orders
from orders_dataset;

-- total revenue
select sum(price) as total_revenue
from order_items_dataset;

-- total unique orders
select count(distinct order_id)
from orders_dataset;

-- average order value
select sum(price)
/count(distinct order_id)
as avg_order_value
from order_items_dataset;

-- revenue by customer state
select c.customer_state,
sum(oi.price) revenue
from customers_dataset c
join orders_dataset o
on c.customer_id = o.customer_id
join order_items_dataset oi
on o.order_id = oi.order_id
group by c.customer_state
order by revenue desc;

-- revenue by month
select month(order_purchase_timestamp) order_month,
sum(price) as orders
from orders_dataset o
join order_items_dataset oi
on o.order_id = oi.order_id
group by month(order_purchase_timestamp)
order by order_month;

-- revenue by year
select year(order_purchase_timestamp) as order_year,
sum(price) as revenue
from orders_dataset o
join order_items_dataset oi
on o.order_id = oi.order_id
group by year(order_purchase_timestamp)
order by order_year;

-- revenue by year and month
select year(order_purchase_timestamp) as order_year,
month(order_purchase_timestamp) as order_month,
sum(price) as revenue
from orders_dataset o
join order_items_dataset oi
on o.order_id = oi.order_id
group by year(order_purchase_timestamp),
month(order_purchase_timestamp)
order by order_year,
order_month;


/*--------------------------- customer analysis ---------------------------*/

-- total customers
select count(*)
from customers_dataset;

-- unique customers
select count(distinct customer_unique_id) as total_customer
from customers_dataset;

-- top 10 cities by number of orders
select top 10 customer_city,
count(*) orders
from customers_dataset c
join orders_dataset o
on c.customer_id = o.customer_id
group by customer_city
order by orders desc;

-- top 10 states by number of customers
select top 10 customer_state,
count(*) as customers
from customers_dataset
group by customer_state
order by customers desc;

-- top 10 customers by total orders
select top 10 c.customer_unique_id,
count(o.order_id) as total_orders
from customers_dataset c
join orders_dataset o
on c.customer_id = o.customer_id
group by c.customer_unique_id
order by total_orders desc;

-- average order value by state
select c.customer_state,
avg(op.payment_value) as avg_order_value
from customers_dataset c
join orders_dataset o
on c.customer_id = o.customer_id
join order_payments_dataset op
on o.order_id = op.order_id
group by c.customer_state
order by avg_order_value desc;


/*--------------------------- product analysis ---------------------------*/

-- top 10 product categories by revenue
select top 10 p.product_category_name,
sum(oi.price) revenue
from order_items_dataset oi
join products_dataset p
on oi.product_id = p.product_id
group by p.product_category_name
order by revenue desc;

-- top 10 translated product categories by revenue
select top 10 pct.product_category_name_english,
sum(oi.price) as revenue
from order_items_dataset oi
join products_dataset p
on oi.product_id = p.product_id
join product_category_name_translation pct
on p.product_category_name = pct.product_category_name
group by pct.product_category_name_english
order by revenue desc;


/*--------------------------- seller analysis ---------------------------*/

-- top 10 sellers by revenue
select top 10 seller_id,
sum(price) revenue
from order_items_dataset
group by seller_id
order by revenue desc;

-- top 10 sellers by total orders
select top 10 seller_id,
count(distinct order_id) as total_orders
from order_items_dataset
group by seller_id
order by total_orders desc;


/*--------------------------- payment analysis ---------------------------*/

-- orders by payment type
select payment_type,
count(*) orders
from order_payments_dataset
group by payment_type;

-- total revenue by payment type
select payment_type,
sum(payment_value) as revenue
from order_payments_dataset
group by payment_type
order by revenue desc;

-- total revenue from payments
select sum(payment_value) as total_revenue
from order_payments_dataset;

-- average payment value
select avg(payment_value) as avg_order_payment
from order_payments_dataset;


/*--------------------------- order analysis ---------------------------*/

-- orders by status
select order_status,
count(*) orders
from orders_dataset
group by order_status;

-- order status distribution
select order_status,
count(*) as orders
from orders_dataset
group by order_status
order by orders desc;

-- percentage of each order status
select order_status,
count(*) as orders,
round(count(*) * 100.0 / (select count(*) from orders_dataset), 2) as percentage
from orders_dataset
group by order_status;


/*--------------------------- delivery analysis ---------------------------*/

-- average delivery days
select avg(datediff(day, order_purchase_timestamp, order_delivered_customer_date))
as avg_delivery_days
from orders_dataset
where order_delivered_customer_date is not null;

-- total late orders
select count(*) late_orders
from orders_dataset
where order_delivered_customer_date > order_estimated_delivery_date;


/*--------------------------- review analysis ---------------------------*/

-- average review score
select avg(review_score) as avg_review
from order_reviews_dataset;

-- average review score by state
select c.customer_state,
avg(r.review_score) as avg_review
from customers_dataset c
join orders_dataset o
on c.customer_id = o.customer_id
join order_reviews_dataset r
on o.order_id = r.order_id
group by c.customer_state
order by avg_review desc;