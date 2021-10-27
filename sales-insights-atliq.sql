/*
Data Cleaning and Analysis using SQL
Activities done: 
- Creating temp tables 
- standardizing numeric and character columns 
- altering tables

Tableau Profile: https://public.tableau.com/app/profile/ikenna4609
*/

use sales 

select * from transactions

-- create temp transactions table for analysis

drop table if exists transactions_details

create table transactions_details (
product_code varchar(45), 
customer_code varchar(45), 
market_code varchar(45), 
order_date date,
sales_qty int, 
sales_amount double, 
currency varchar(45),
profit_margin_percentage double, 
profit_margin double, 
cost_price double,
product_type varchar(45),
customer_name varchar(45),
customer_type varchar(45),
markets_name varchar(45),
zone varchar(45),
cy_date date,
month_name varchar(45),
year int
)

insert into transactions_details
select a.*, b.product_type, c.custmer_name as 'customer_name', c.customer_type, d.markets_name, d.zone, e.cy_date, e.month_name, e.year
from transactions a 
left join products b
on a.product_code = b.product_code
join customers c 
on a.customer_code = c.customer_code 
join markets d 
on a.market_code = d.markets_code
join date e 
on a.order_date = e.date
where a.sales_amount >= 1 -- data cleaning 

-- standardize sales_amount and currency columns 
alter table transactions_details add sales_amount_st double 
alter table transactions_details add currency_st varchar(55) 

update transactions_details
set sales_amount_st = 
(case
	when currency in ('USD') then sales_amount * 75 
    else sales_amount
end) 

update transactions_details
set currency_st = 
(case
	when currency in ('USD') then 'INR'
    else currency
end) 

-- delete unneeded columns, rename needed columns

alter table transactions_details drop column sales_amount
alter table transactions_details drop column currency 

alter table transactions_details change sales_amount_st sales_amount double 
alter table transactions_details change currency_st currency varchar(55)
alter table transactions_details change profit_margin profit double
alter table transactions_details change profit_margin_percentage profit_margin double

alter table transactions_details add profit_margin_percentage double 

update transactions_details
set profit_margin_percentage = ((sales_amount - cost_price)/sales_amount) * 100.00

select * from transactions_details

/*
Tableau Dashboards : https://public.tableau.com/app/profile/ikenna4609/viz/AtliQSalesInsights_16353275193680/AtliQ-RevenueAnalysis
*/
