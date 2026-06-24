
SELECT * FROM customer

-- -- 1. We find the sum of purchase_amount of both genders

select gender,SUM(purchase_amount) as revenue
from customer
group by gender

-- -- 2.We find those person who spend more than average purchase amount even after applying the discoun

select customer_id,purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount >= (select AVG(purchase_amount) from customer)

-- -- 3.We calculate top 5 products with highest average review rating

select item_purchased, ROUND(AVG(review_rating::numeric),2) AS "average product review"
from customer
group by item_purchased
order by AVG(review_rating) desc
limit 5

-- -- 4.We then compare express and standard shipping with avg purchase amount

select shipping_type,
ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type

-- -- 5.We then check which customer whether subscribed or non-subscribed spend more or less?Compare it

select subscription_status,
COUNT(customer_id) as total_customer,
ROUND(AVG(purchase_amount),2) as avg_amount,
ROUND(AVG(purchase_amount),2) as total_amount
from customer
group by subscription_status
order by avg_amount, total_amount desc;

-- 6.Which are the top 5 products with hghest percentage of purchase with discount applied?

select item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;	

-- 7.We the find out cusmtomer in 3 types.Whether they are new,returning or loyal
with customer_type as (
select customer_id, previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 and 10 THEN 'Returning'
	ELSE 'Loyal'
	END AS customer_segment
from customer
)

select customer_segment, count(*) as "Number of customer"
from customer_type
group by customer_segment

-- 8.What are the top 3 most purchased products within each categoty?

with item_counts as (
select category,
item_purchased,
COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count (customer_id)DESC) as item_rank
from customer
group by category, item_purchased
)

select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <= 3;

-- 9.Are customer who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status

-- 10.Lastly we then find which type of age group contribute to revenue

select age_group,
SUM(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;


