use job


select * from cleaned_walmart

-- Count total records

select COUNT(*) from cleaned_walmart;

-- Count payment methods and number of transactions by payment method

select 
   payment_method,
   COUNT(*) as no_payment
from cleaned_walmart
group by payment_method;

-- Count distinct branches

select
   COUNT(distinct branch) 
from cleaned_walmart;

-- Find the minimum quantity sold

select
  min(quantity) 
from cleaned_walmart

-- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method

select 
   payment_method,
   COUNT(*) as no_payments,
   SUM(quantity) as no_qty_sold
from cleaned_walmart
group by payment_method;

-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating


select branch,category,avg_rating
from
(
 select
  branch,
  category,
  AVG(rating) as avg_rating,
  RANK() over(partition by branch order by avg(rating)DESC) as rank
 from cleaned_walmart
 group by branch,category
 )
 as ranked
 where rank = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions


select branch,day_name,no_transactions
from
(
select 
  branch,
  CAST(date as date) as day_name,
  COUNT(*) as no_transactions,
  RANK() over(partition by branch order by count(*) desc) as rank
  from cleaned_walmart
  group by branch,CAST(date as date) 
  ) as ranked
  where rank=1;

-- Q4: Calculate the total quantity of items sold per payment method

select
  payment_method,
  SUM(quantity) as no_qty_sold
from cleaned_walmart
group by payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city

select
  city,
  category,
  MIN(rating) as min_rating,
  MAX(rating) as max_rating,
  AVG(rating) as avg_rating
from cleaned_walmart
group by city,category;

-- Q6: Calculate the total profit for each category

select 
  category,
  round(SUM(quantity * total),2) as total_profit
from cleaned_walmart
group by category
order by total_profit desc;

-- Q7: Determine the most common payment method for each branch

with cte as
(
 select
  branch,
  payment_method,
  COUNT(*) as no_payment,
  RANK() over(partition by branch order by count(*) desc) as rank
 from cleaned_walmart
 group by branch,payment_method
 )
select branch,payment_method as preffered_payment_method 
from cte
where rank=1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
with sales_shift as
(
select
  branch,
  case 
    when DATEPART(HOUR,time) <12 then 'Morning'
	when DATEPART(HOUR,time) BETWEEN 12 and 17 THEN 'Afternoon'
	else 'Evening'
  end as shift
from cleaned_walmart
)
select branch,shift,
    COUNT(*) as num_invoice
from sales_shift
group by branch,shift
order by branch, num_invoice

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

with revenue_2022 as(
  select 
    branch,
	SUM(total) as revenue_2022
  from cleaned_walmart
  where YEAR([date]) =2022
  group by branch
),
revenue_2023 as (
  select 
    branch,
	SUM(total) as revenue_2023
  from cleaned_walmart
  where YEAR([date]) = 2023
  group by branch
)
select TOP 5
   r22.branch,
   r22.revenue_2022 as last_year_revenue,
   r23.revenue_2023 as current_year_revenue,
   round(
       ((r22.revenue_2022-r23.revenue_2023)*100.0)
	   /r22.revenue_2022,2
	   ) as revenue_decrease_ratio
from revenue_2022 r22
join revenue_2023 r23
   on r22.branch = r23.branch
where r22.revenue_2022 > r23.revenue_2023
order by revenue_decrease_ratio desc;








