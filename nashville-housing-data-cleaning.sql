/* 

Cleaning Data in SQL Queries

Activities done: 
1. Standardizing date format 
2. Populate empty colums 
3. Split column contents 
4. Standardizing text colums (change Y and N to Yes and No) 
5. Remove unused columns and duplicates 

*/

create schema housing_data

drop table if exists `nashville housing data`

create table housing_data.`nashville housing data`(
	UniqueID text, 
	ParcelID text, 
	LandUse text, 
	PropertyAddress text, 
	SaleDate text, 
	SalePrice int, 
	LegalReference text, 
	SoldAsVacant text, 
	OwnerName text, 
	OwnerAddress text, 
	Acreage double, 
	TaxDistrict text, 
	LandValue double, 
	BuildingValue double, 
	TotalValue double, 
	YearBuilt bigint, 
	Bedrooms bigint, 
	FullBath bigint, 
	HalfBath int
); 

load data infile 'C://Nashville Housing Data.csv'
into table housing_data.`nashville housing data`
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(@UniqueID, @ParcelID, @LandUse, @PropertyAddress, @SaleDate, @SalePrice, @LegalReference, @SoldAsVacant, @OwnerName, @OwnerAddress, @Acreage, @TaxDistrict, @LandValue, @BuildingValue, @TotalValue, @YearBuilt, @Bedrooms, @FullBath, @HalfBath)
SET UniqueID = NULLIF(@UniqueID,''), ParcelID = NULLIF(@ParcelID,''), LandUse = NULLIF(@LandUse,''), PropertyAddress = NULLIF(@PropertyAddress,''), SaleDate = NULLIF(@SaleDate,''), SalePrice = NULLIF(@SalePrice,''),LegalReference = NULLIF(@LegalReference,''), SoldAsVacant = NULLIF(@SoldAsVacant,''), OwnerName = NULLIF(@OwnerName,''), OwnerAddress = NULLIF(@OwnerAddress,''), Acreage = NULLIF(@Acreage,''), TaxDistrict = NULLIF(@TaxDistrict,''), LandValue = NULLIF(@LandValue,''), BuildingValue = NULLIF(@BuildingValue,''), TotalValue = NULLIF(@TotalValue,''), YearBuilt = NULLIF(@YearBuilt,''), Bedrooms = NULLIF(@Bedrooms,''), FullBath = NULLIF(@FullBath,''), HalfBath = NULLIF(@HalfBath,'');


use housing_data
-- change column name 
-- ALTER TABLE `nashville housing data` CHANGE Uniqueid UniqueID text;

-- standardize SaleDate field
update `nashville housing data`
set saledate = str_to_date(saledate, '%M %d, %Y')

select * from `nashville housing data`
where saledate > '2013-12-31'

-- populate property address data 
select * from `nashville housing data`
where propertyaddress is null
-- order by parcelid

-- self join 
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ifnull(a.propertyaddress, b.propertyaddress)
from `nashville housing data` a
join `nashville housing data` b
 on a.parcelid = b.parcelid 
 and a.uniqueid <> b.uniqueid 
where a.propertyaddress is null

-- replace missing addresses
UPDATE `nashville housing data` a,
	(SELECT parcelid, uniqueid, propertyaddress FROM `nashville housing data`) AS b
    SET a.propertyaddress = ifnull(a.propertyaddress, b.propertyaddress)
    WHERE a.propertyaddress is null
    AND a.uniqueid <> b.uniqueid
    AND a.parcelid = b.parcelid;

-- verify update
select * from `nashville housing data` 
where propertyaddress is null

-- breaking out addresses into individual columns - PropertyAddress
select substring_index(propertyaddress, ',', 1) as Address, substring_index(propertyaddress, ',', -1) as City
from `nashville housing data` 

-- add new colums to table 
alter table `nashville housing data` add Address text
update `nashville housing data`
set Address = substring_index(propertyaddress, ',', 1)

alter table `nashville housing data` add City text
update `nashville housing data`
set City = substring_index(propertyaddress, ',', -1)

-- verify update
select * from `nashville housing data` 

-- split OwnerAddress
select owneraddress, substring_index(owneraddress,',',1) as OwnerAddress_split, substring_index(substring_index(owneraddress,',',2),',',-1) as OwnerCity_split, substring_index(owneraddress,',',-1) as OwnerState_split
from `nashville housing data`

-- add new columns to table 
alter table `nashville housing data` add OwnerAddress_split text
update `nashville housing data` 
set OwnerAddress_split = substring_index(owneraddress,',',1)

alter table `nashville housing data` add OwnerCity_split text
update `nashville housing data` 
set OwnerCity_split = substring_index(substring_index(owneraddress,',',2),',',-1)

alter table `nashville housing data` add OwnerState_split text
update `nashville housing data` 
set OwnerState_split = substring_index(owneraddress,',',-1)

-- verify update
select * from `nashville housing data`

-- standardize SoldAsVacant field (Y/N) 
-- view unique column contents
select distinct(soldasvacant) from `nashville housing data`

-- count unique column contents
select distinct(soldasvacant), count(soldasvacant)
from `nashville housing data`
group by soldasvacant
order by 2

-- standardize 
select soldasvacant, 
(case 
	when soldasvacant = 'N' then 'No'
	when soldasvacant = 'Y' then 'Yes'
    else soldasvacant
end) as soldasvacant_st
from `nashville housing data`

alter table `nashville housing data` add soldasvacant_st text
update `nashville housing data`
set soldasvacant_st = (case 
	when soldasvacant = 'N' then 'No'
	when soldasvacant = 'Y' then 'Yes'
    else soldasvacant
end)

-- verify update
alter table `nashville housing data` change soldasvacant_st SoldAsVacant_st text
select * from `nashville housing data`
where soldasvacant_st = 'Y'

-- remove duplicates and unused columns 
-- create a new table to prevent modifying source data
drop table if exists nashville_housing 

create table nashville_housing( 
	UniqueID text, 
    ParcelID text, 
    LandUse text, 
    Address text, 
    City text, 
    SaleDate date, 
    SalePrice double, 
    LegalReference text, 
    SoldAsVacant_st text, 
    OwnerName text, 
    OwnerAddress_split text, 
    OwnerCity_split text, 
    OwnerState_split text,
    Acreage double, 
    TaxDistrict text, 
    LandValue double, 
    BuildingValue double, 
    TotalValue double, 
    YearBuilt int, 
    Bedrooms int, 
    FullBath int, 
    HalfBath int
);

insert into nashville_housing
select UniqueID, ParcelID, LandUse, Address, City, SaleDate, SalePrice, LegalReference, SoldAsVacant_st, OwnerName, OwnerAddress_split, OwnerCity_split, OwnerState_split, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath 
from `nashville housing data`

select * from nashville_housing

-- delete duplicates
/* 
The following statement uses the ROW_NUMBER() function to assign a sequential integer number to each row. If the selected fields are duplicate, the row number will be greater than one.
*/
select *, 
	row_number() 
		over (
			partition by parcelid, address, saledate, saleprice, legalreference 
			order by UniqueID) as row_num 
from nashville_housing

-- The following statement returns list of the duplicate rows:
select uniqueid, parcelid, address, saledate, saleprice, legalreference, row_num
from ( 
	select *, 
		row_number() over (
		partition by parcelid, address, saledate, saleprice, legalreference 
        order by UniqueID) as row_num 
	from 
		nashville_housing
) t 
where row_num > 1

/* 
delete the duplicate rows from the nashville_housing table using the DELETE statement with a subquery in the WHERE clause:
*/
delete from nashville_housing
where 
	uniqueid in (
    select uniqueid 
	from ( 
		select *, 
		row_number() over (
		partition by parcelid, address, saledate, saleprice, legalreference 
        order by UniqueID) as row_num 
	from 
		nashville_housing
	) t 
where row_num > 1
)

-- validate deletion of duplicate records
select * from nashville_housing
where uniqueid = '27111'

