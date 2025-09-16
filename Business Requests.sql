-- Business Request – 1: Monthly Circulation Drop Check

select 
City, 
Year, 
Month, 
Net_Circulation, 
prev_Month_Circulation, 
(Net_Circulation - prev_Month_Circulation) as decline_value,
round(((Net_Circulation - prev_Month_Circulation)/prev_Month_Circulation)*100,2) as mom_percent_change,
dense_rank() over (order by (round(((Net_Circulation - prev_Month_Circulation)/prev_Month_Circulation)*100,2)) asc) as ranks
from (
select 
City,
Year,
month(Month) as Month,
Net_Circulation,
lag(Net_Circulation,1) over (partition by City order by Year, Month) as prev_Month_Circulation
from print_sales
JOIN dim_city ON print_sales.City_Id = dim_city.City_Id
) as a
where prev_Month_Circulation is not null
order by ranks
limit 3;

-- Business Request – 2: Yearly Revenue Concentration by Category
 
 with pct_calc as (
	select 
    ad_category.Standard_Ad_Category as category_name, 
    ad_revenue.Year, 
    round(sum(ad_revenue.Ad_Revenue),2) as revenue,
    round(sum(ad_revenue.Ad_Revenue)*100/sum(sum(ad_revenue.Ad_Revenue)) over (partition by ad_revenue.Year),2) as Pct
	from 
    ad_revenue join ad_category 
    on ad_revenue.Ad_Category = ad_category.Ad_Category_ID
    group by ad_category.Standard_Ad_Category, ad_revenue.Year
    )
    select *
    from pct_calc
    having Pct > 50
    order by Year, category_name;
    
    
--  Business Request – 3: 2024 Print Efficiency Leaderboard

-- efficiency ratio and waste ratio are inversely proportional 
select * ,
100 - waste_ratio as efficiency_ratio,
dense_rank() over (order by waste_ratio asc) as ranks
from
(
select 
dim_city.City,
sum(print_sales.Copies_Sold) as sold_copies,
sum(print_sales.Copies_Returned) as return_copies, 
round((sum(print_sales.Copies_Returned)/sum(print_sales.Copies_Sold))*100,2) as waste_ratio
from print_sales join dim_city on 
print_sales.City_Id = dim_city.City_Id
where print_sales.Year = 2024
group by City
) as a
limit 5;


-- Business Request – 4 : Internet Readiness Growth (2021)

with Q1_data as (
select 
dim_city.City, 
round(avg(city_readiness.Internet_Penetration)*100,2) as Q1_internet_penetration, 
city_readiness.Quart_Year
from city_readiness join dim_city
on city_readiness.City_Id = dim_city.City_Id
where city_readiness.Quart_Year = 'Q1-2021'
group by dim_city.City, city_readiness.Quart_Year),

Q4_data as (
select 
dim_city.City, 
avg(city_readiness.Internet_Penetration)*100 as Q4_internet_penetration, 
city_readiness.Quart_Year
from city_readiness join dim_city
on city_readiness.City_Id = dim_city.City_Id
where city_readiness.Quart_Year = 'Q4-2021'
group by dim_city.City, city_readiness.Quart_Year)

select Q1_data.City, 
Q1_data.Q1_internet_penetration, 
Q4_data.Q4_internet_penetration,
round((Q4_data.Q4_internet_penetration - Q1_data.Q1_internet_penetration),2) as Change_in_Internet_Penetration,
dense_rank() over (order by round((Q4_data.Q4_internet_penetration - Q1_data.Q1_internet_penetration),2) desc) as ranks
from Q1_data join Q4_data
on Q1_data.City = Q4_data.City;


-- Business Request – 5: Consistent Multi-Year Decline (2019→2024) 

with circulation_data as(
select 
dim_city.City,
print_sales.Year,
sum(print_sales.Net_Circulation) as yearly_net_circulation,
lag(sum(print_sales.Net_Circulation),1) over (partition by City order by Year) as prev_year_circulation,
case
when sum(print_sales.Net_Circulation) <  lag(sum(print_sales.Net_Circulation),1) over (partition by City order by Year) 
then 'Yes' else 'No'
end as is_declining_print
from print_sales join dim_city
on print_sales.City_Id = dim_city.City_Id
group by City, Year),

Edition_Yr_City as (
select distinct
print_sales.Edition_Id,
print_sales.Year,
print_sales.City_Id
from print_sales),

revenue_agg as (
select 
ad_revenue.Edition_Id,
ad_revenue.Year,
round(sum(ad_revenue.Ad_Revenue),2) as revenue
from ad_revenue
group by Edition_Id, Year),

revenue_data as (
select 
dim_city.City,
revenue_agg.Year,
sum(revenue_agg.revenue) as yearly_revenue,
lag(sum(revenue_agg.revenue),1) over (partition by City order by revenue_agg.Year) as prev_year_revenue,
case 
when sum(revenue_agg.revenue) < lag(sum(revenue_agg.revenue),1) over (partition by City order by revenue_agg.Year) then 
'Yes' else 'No'
end as is_declining_revenue
from revenue_agg join Edition_Yr_City 
on revenue_agg.Edition_Id = Edition_Yr_City.Edition_Id
join dim_city on dim_city.City_Id = Edition_Yr_City.City_Id 
and revenue_agg.Year = Edition_Yr_City.Year
group by City, Year),

consistent_decline as(
select
cd.City, 
count(case when is_declining_print = 'Yes' then 1 end) as print_decline_count,
count(case when is_declining_revenue = 'Yes' then 1 end) as revenue_decline_count
from circulation_data cd join revenue_data rd
on cd.City = rd.City and cd.Year = rd.Year
where cd.Year between 2020 and 2024
group by cd.City)

select cd.City
from consistent_decline cd
where print_decline_count = 5 
and revenue_decline_count = 5
order by cd.City;


-- Business Request – 6 : 2021 Readiness vs Pilot Engagement Outlier
 
with ce as (
select 
print_sales.Edition_Id,
dim_city.City_Id,
dim_city.City
from dim_city join print_sales 
on dim_city.City_Id = print_sales.City_Id
),

ad_r as (
select 
ad_revenue.Edition_Id,
ad_category.Ad_Category_ID,
ad_category.Standard_Ad_Category,
ad_revenue.Ad_Revenue
from ad_category join ad_revenue 
on ad_category.Ad_Category_ID = ad_revenue.Ad_Category
),

city_cat as (
select 
ce.City,
ad_r.Ad_Category_ID,
sum(ad_r.Ad_Revenue) as city_revenue
from ce join ad_r 
on ce.Edition_id = ad_r.Edition_id
group by ce.City, ad_r.Ad_Category_ID
),

city_share as (
select 
cc.City,
cc.Ad_Category_ID,
cc.city_revenue * 1.0 / sum(cc.city_revenue) over(partition by cc.Ad_Category_ID) as city_share
from city_cat cc
),

engagement_metric as (
select 
cs.City,
round(avg((100 - dp.Avg_Bounce_Rate*100) * cs.city_share),2) as engagement_rate
from digital_pilot dp join city_share cs
on dp.Ad_Category_Id = cs.Ad_Category_ID
group by cs.City
order by cs.City),

readiness as(
select 
dim_city.City,
round(((avg(city_readiness.Smartphone_Penetration) + avg(city_readiness.Internet_Penetration) + avg(city_readiness.Literacy_Rate))/3)*100,2) as readiness_score
from city_readiness join dim_city
on city_readiness.City_Id = dim_city.City_Id
where city_readiness.Year = 2021
group by City),

ranks as (
select
r.City,
r.readiness_score,
em.engagement_rate,
dense_rank() over (order by r.readiness_score desc) as readiness_rank,
dense_rank() over (order by em.engagement_rate asc) as engagement_rank
from readiness r join engagement_metric em
on r.City = em.City)

select * ,
case 
when readiness_rank = 1 and engagement_rank <=3 then 'yes'
else 'no'
end as is_outlier
from ranks