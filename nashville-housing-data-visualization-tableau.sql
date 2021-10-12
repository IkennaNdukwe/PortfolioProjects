/* 
Nashville data tableau visualization (2013 - 2016)
*/ 

use housing_data

-- data exploration 
select min(saledate), max(saledate) 
from nashville_housing

select distinct(landuse), count(landuse)
from  nashville_housing
group by landuse
order by count(landuse)

select distinct(city), count(city)
from  nashville_housing
group by city
order by count(city)

-- 1. sales per season 
alter table nashville_housing add SaleSeason text
update nashville_housing
set  SaleSeason = 
(case
	when month(saledate) between 3 and 5 then 'Spring'
	when month(saledate) between 6 and 8 then 'Summer'
    when month(saledate) between 9 and 11 then 'Fall'
    else 'Winter'
end)

alter table nashville_housing add SaleYear int
update nashville_housing
set SaleYear = year(saledate) 

select saleseason, saleyear, count(saleseason) as 'HousesSoldCount'
from nashville_housing
group by saleseason, saleyear
order by saleyear, saleseason

-- calculate net profit margin 
alter table nashville_housing add ProfitMargin double
update nashville_housing

set ProfitMargin = ((saleprice - totalvalue)/saleprice) * 100
select *
from nashville_housing

-- 2. net profit margin per year 
select saleyear, sum(saleprice), sum(totalvalue), ((sum(saleprice) - sum(totalvalue))/sum(saleprice))*100 as AnnualProfitMargin, count(saleyear) 
from nashville_housing
group by saleyear
order by saleyear

-- 3. net profit margin per landuse (2013 - 2016)
with npm_per_landuse as 
(
	select landuse, sum(saleprice), sum(totalvalue), ((sum(saleprice) - sum(totalvalue))/sum(saleprice))*100 as AnnualProfitMargin, count(saleyear) 
	from nashville_housing
    group by landuse
	order by AnnualProfitMargin
) 

select * from npm_per_landuse
where AnnualProfitMargin is not null -- and landuse = 'church'

-- 4. Global summary 
select count(uniqueid) as 'SalesCount', sum(saleprice),  sum(totalvalue), ((sum(saleprice) - sum(totalvalue))/sum(saleprice))*100 as AnnualProfitMargin
from nashville_housing

-- 5. correlation between number of bedrooms and building value 
select @bedrooms := avg(bedrooms) as c_bedrooms, 
	   @buildingvalue := avg(buildingvalue) as c_bulidingvalue, 
       @division := (stddev_samp(bedrooms) * stddev_samp(buildingvalue)) as corr
from nashville_housing

select (sum((bedrooms - @bedrooms) * (buildingvalue - @buildingvalue)) / ((count(bedrooms) -1) * @division)) as corr_bedroom_value
from nashville_housing

-- 6. correlation between number of bathroom and building value 
select @fullbath := avg(fullbath) as c_fullbath, 
	   @buildingvalue := avg(buildingvalue) as c_bulidingvalue, 
       @division := (stddev_samp(fullbath) * stddev_samp(buildingvalue)) as corr
from nashville_housing

select (sum((fullbath - @fullbath) * (buildingvalue - @buildingvalue)) / ((count(fullbath) -1) * @division)) as corr_fullbath_value
from nashville_housing

-- 7. correlation between year built and building value 
select @yearbuilt := avg(yearbuilt) as yearbuilt, 
	   @buildingvalue := avg(buildingvalue) as c_bulidingvalue, 
       @division := (stddev_samp(yearbuilt) * stddev_samp(buildingvalue)) as corr
from nashville_housing

select (sum((yearbuilt - @yearbuilt) * (buildingvalue - @buildingvalue)) / ((count(yearbuilt) -1) * @division)) as corr_yearbuilt_value
from nashville_housing

-- 8. top 10 owners
select ownername, count(ownername), sum(totalvalue)
from nashville_housing 
where ownername is not null
group by ownername
order by sum(totalvalue) desc, count(ownername) desc
limit 10

select max(saledate)
from nashville_housing

-- Dashboard link: https://public.tableau.com/app/profile/ikenna4609/viz/NashvilleHousingData_16338294980240/Dashboard1?publish=yes
