--List of tables used in the analysis

select *
from transactions

select *
from customer_demographic

select *
from customer_address

select *
from new_customer_list

--DATA PROFILING

--Transaction table
select
    max(transaction_date) as maxdate,
	min(transaction_date) as mindate
from transactions

--Customer Address table
select distinct state
from customer_address

--Customer table
select count(distinct customer_id) as customer_count
from customer_demographic

--New Customer List table
select count(*) as new_customer_count
from new_customer_list



----CALCULATION RFM ANALYSIS

drop table if exists #rfm;
with rfm as
(
select 
       customer_id,
	   (select max(transaction_date) from transactions) as max_transaction_date,
       max(transaction_date) as last_order_date,
       datediff(dd,max(transaction_date),(select max(transaction_date) from transactions)) as recency,
	   count(transaction_id) as frequency,
	   round(sum(list_price),2) as monetary_value
from transactions
group by customer_id
), 
rfm_calc as
(
select *,   
       ntile(4) over(order by recency desc) rfm_recency,
	   ntile(4) over(order by frequency) rfm_frequency,
	   ntile(4) over(order by monetary_value) rfm_monetary
from rfm
)
select *,
       rfm_recency+rfm_frequency+rfm_monetary as rfm_cell,
	   cast(rfm_recency as varchar)+cast(rfm_frequency as varchar)+cast(rfm_monetary as varchar) as rfm_score
into #rfm
from rfm_calc

select *
from #rfm


----CUSTOMER SEGMENTATION USING RFM ANALYSIS-----------------

drop table if exists customer_segmentation;
select 
  customer_id, 
  rfm_recency,
  rfm_frequency,
  rfm_monetary,
  case
      when rfm_score in (144,143,134,133) then 'churned best customer'
	  when rfm_score in (121,122,123,124,134,132,133,131) then 'lost customer'
	  when rfm_score in (242,232,241,231) then 'declining customer'
	  when rfm_score in (244,243,234,233) then 'slipping best customer'
	  when rfm_score in (442,441,443,431,432,433,342,341,343,331,332,333) then 'active loyal customer'
	  when rfm_score in (412,411,413,414,311,313,314,312) then 'new customer'
	  when rfm_score in (444) then 'best customer'
	  when rfm_score in (111,112,113,114,213,212,214,211) then 'one-time customer'
	  when rfm_score in (322,321,323,324) then 'potential customer'
	  else 'customer'
  end as rfm_segment 
into customer_segmentation
from #rfm
-----

select *
from customer_segmentation
-----

select distinct
    rfm_segment, 
	rfm_recency,
	rfm_frequency,
	rfm_monetary
from customer_segmentation


--UNDERSTNDING CUSTOMER TARGET SEGMNETS-----------------

--total sales to the target customers
select 
      round(sum(t.list_price),2) as total_order_value
from customer_segmentation as cs
left join transactions as t 
on cs.customer_id = t.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')

--percentage of total sales to target customer
select 
      cast(sum(t.list_price) as float)*100/(select sum(list_price) from transactions) as pct_total_order_value
from customer_segmentation as cs
left join transactions as t 
on cs.customer_id = t.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')

--total order value per cutomer type; pie chart 
select 
      'target customers' as customer_type,
	  cs.rfm_segment,
      round(sum(t.list_price),2) as total_order_value
from customer_segmentation as cs
left join transactions as t 
on cs.customer_id = t.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')
group by cs.rfm_segment
union
select 
      'other customers' as cutomer_type,
	  cs.rfm_segment,
      round(sum(t.list_price),2) as total_order_value
from customer_segmentation as cs
left join transactions as t 
on cs.customer_id = t.customer_id
where cs.rfm_segment not in ('best customer','active loyal customer','customer')
group by cs.rfm_segment


----DISTRIBUTION OF CUSTOMER SEGMENTS IN CUSTOMER POPULATION-----------------

select 
   rfm_segment, 
	 count(customer_id) as customer_count
from customer_segmentation
group by rfm_segment
order by customer_count desc


--SEGMENT ANALYSIS-----------------

--#selected segemnets 1. best customers 2. active loyal customers 3. customers

--Calculating age and age group for customer_demographic table

create or alter view customer_demographics as
select cd.*,
       case 
	       when cd.age between 15 and 24 then '15-24'
		   when cd.age between 25 and 34 then '25-34'
		   when cd.age between 35 and 44 then '35-44'
		   when cd.age between 45 and 54 then '45-54'
		   else '55+'
	  end as age_group
from
(
select *,
      datediff(yy,DOB, (select max(transaction_date) from transactions)) as age 
from customer_demographic
) as cd
where cd.age is not null

--1. Analysing characteristics 
select *
from customer_demographics

select *
from customer_segmentation

select *
from customer_address

--1.1. Age group 
select 
     d.age_group, 
	 count(cs.customer_id) as customer_count
from customer_segmentation as cs
left join customer_demographics as d
on cs.customer_id = d.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')
group by d.age_group
order by d.age_group asc, customer_count desc

--1.2. Location 
select 
     a.state, 
	 count(cs.customer_id) as customer_count
from customer_segmentation as cs
left join customer_address as a
on cs.customer_id = a.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')
and state is not null
group by a.state
order by a.state asc, customer_count desc

--1.3. Job industry
select 
     d.job_industry_category, 
	 count(cs.customer_id) as customer_count
from customer_segmentation as cs
left join customer_demographics as d
on cs.customer_id = d.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')
and d.job_industry_category != 'n/a' 
group by d.job_industry_category 
order by customer_count desc, d.job_industry_category

--1.4. Wealth segment 
select 
     d.wealth_segment, 
	 count(cs.customer_id) as customer_count
from customer_segmentation as cs
left join customer_demographics as d
on cs.customer_id = d.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')
group by d.wealth_segment 
order by customer_count desc, d.wealth_segment

--1.5. Car owership
select 
     d.owns_car as varchar, 
	 count(cs.customer_id) as customer_count
from customer_segmentation as cs
left join customer_demographics as d
on cs.customer_id = d.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')
group by d.owns_car
order by customer_count desc, d.owns_car


--2. Analysing purchasing behaviour 

select * 
from transactions

select *
from customer_segmentation


--2.1. Brand preference 
select 
      t.brand,
	  count(cs.customer_id) as customer_count
from customer_segmentation as cs
left join transactions as t 
on cs.customer_id = t.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')
group by t.brand
order by customer_count desc, t.brand

--2.2. Product line preference 
select 
      t.product_line,
	  count(cs.customer_id) as customer_count
from customer_segmentation as cs
left join transactions as t 
on cs.customer_id = t.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')
group by t.product_line
order by customer_count desc, t.product_line

--2.3. Average order value 
select 
      round(avg(t.list_price),2) as avg_order_value
from customer_segmentation as cs
left join transactions as t 
on cs.customer_id = t.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')

--2.4. Season preference
with monthly_trend as 
(
select 
     t.transaction_id,
     t.customer_id,
	 month(t.transaction_date) as order_month,
     cs.rfm_segment
from customer_segmentation as cs
left join transactions as t 
on cs.customer_id = t.customer_id
where cs.rfm_segment in ('best customer','active loyal customer','customer')
group by t.transaction_id, t.customer_id, cs.rfm_segment, t.transaction_date
)
select 
     order_month,
	 case 
	     when order_month= 1 then 'January'
		 when order_month= 2 then 'February'
		 when order_month= 3 then 'March'
		 when order_month= 4 then 'April'
		 when order_month= 5 then 'May'
		 when order_month= 6 then 'June'
		 when order_month= 7 then 'July'
		 when order_month= 8 then 'August'
		 when order_month= 9 then 'September'
		 when order_month= 10 then 'October'
		 when order_month= 11 then 'November'
		 when order_month= 12 then 'December'
		 else ''
	end as 'month',
	count(transaction_id) as order_volume
from monthly_trend
group by order_month
order by order_month
 

--PROBABLE CUSTOMERS----------------- 

select *
from new_customer_list

--Calculating age and age group for new_customer_list
create or alter view new_customers as
select nc.*,
       case 
	       when nc.age between 15 and 24 then '15-24'
		   when nc.age between 25 and 34 then '25-34'
		   when nc.age between 35 and 44 then '35-44'
		   when nc.age between 45 and 54 then '45-54'
		   else '55+'
	  end as age_group
from 
(
select *,
      datediff(yy,DOB, (select max(transaction_date) from transactions)) as age 
from new_customer_list
where DOB is not null
) as nc
-----

select *
from new_customers





--List of probable customers to target 
create or alter view probable_customers as
select 
     first_name, 
	 last_name,
	 gender,
	 address,
	 postcode,
	 age
from new_customers
where age_group = '35-44'
and state = 'New South Wales'
and job_industry_category in ('Financial Services', 'Manufacturing', 'Health')
and wealth_segment = 'Mass Customer'
-----

select * 
from probable_customers