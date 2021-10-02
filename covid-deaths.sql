/*
Covid-19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
Link to dataset: https://ourworldindata.org/covid-deaths

MySQL 8.0 was used for this exploration.
*/

-- create 'deaths' table in the 'covid' database

drop table if exists covid.deaths;

create table covid.deaths(
	iso_code text, 
	continent text, 
	location text, 
	date text, 
	population int, 
	total_cases int null, 
	new_cases int, 
	new_cases_smoothed text, 
	total_deaths int NULL, 
	new_deaths int null, 
	new_deaths_smoothed text, 
	total_cases_per_million double, 
	new_cases_per_million double, 
	new_cases_smoothed_per_million text, 
	total_deaths_per_million text, 
	new_deaths_per_million text, 
	new_deaths_smoothed_per_million text, 
	reproduction_rate text, 
	icu_patients text, 
	icu_patients_per_million text, 
	hosp_patients text, 
	hosp_patients_per_million text, 
	weekly_icu_admissions text, 
	weekly_icu_admissions_per_million text, 
	weekly_hosp_admissions text, 
	weekly_hosp_admissions_per_million text
    );
  
-- load data into 'deaths' table 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/owid-covid-deaths.csv'
INTO TABLE covid.deaths
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@iso_code, @continent, @location, @date, @population, @total_cases, @new_cases, @new_cases_smoothed, @total_deaths, @new_deaths, @new_deaths_smoothed, @total_cases_per_million, @new_cases_per_million, @new_cases_smoothed_per_million, @total_deaths_per_million, @new_deaths_per_million, @new_deaths_smoothed_per_million, @reproduction_rate, @icu_patients, @icu_patients_per_million, @hosp_patients, @hosp_patients_per_million, @weekly_icu_admissions, @weekly_icu_admissions_per_million, @weekly_hosp_admissions, @weekly_hosp_admissions_per_million) 
       SET iso_code = NULLIF(@iso_code,''), 
           continent = NULLIF(@continent,''), 
           location = NULLIF(@location,''), 
           date = NULLIF(@date,''),
           population = NULLIF(@population,''),
           total_cases = NULLIF(@total_cases,''),
           new_cases = NULLIF(@new_cases,''),
           new_cases_smoothed = NULLIF(@new_cases_smoothed,''),
           total_deaths = NULLIF(@total_deaths,''),
           new_deaths = NULLIF(@new_deaths,''),
           new_deaths_smoothed = NULLIF(@new_deaths_smoothed,''), 
           total_cases_per_million = NULLIF(@total_cases_per_million,''), 
           new_cases_per_million = NULLIF(@new_cases_per_million,''), 
           new_cases_smoothed_per_million = NULLIF(@new_cases_smoothed_per_million,''),
           total_deaths_per_million = NULLIF(@total_deaths_per_million,''),
           new_deaths_per_million = NULLIF(@new_deaths_per_million,''),
           new_deaths_smoothed_per_million = NULLIF(@new_deaths_smoothed_per_million,''),
           reproduction_rate = NULLIF(@reproduction_rate,''),
           icu_patients = NULLIF(@icu_patients,''),
           icu_patients_per_million = NULLIF(@icu_patients_per_million,''),
           hosp_patients = NULLIF(@hosp_patients,''),
           hosp_patients_per_million = NULLIF(@hosp_patients_per_million,''),
           weekly_icu_admissions = NULLIF(@weekly_icu_admissions,''),
           weekly_icu_admissions_per_million = NULLIF(@weekly_icu_admissions_per_million,''),
           weekly_hosp_admissions = NULLIF(@weekly_hosp_admissions,''),
           weekly_hosp_admissions_per_million = NULLIF(@weekly_hosp_admissions_per_million,'')
;


-- validate record count 

select count(*) from covid.deaths

-- view records 

select * from covid.deaths

-- Select fields for exploration 

select location, date, total_cases, new_cases, total_deaths, population 
from covid.deaths
order by location, str_to_date(date, '%m/%d/%Y')

-- total cases vs total deaths 
-- death_rate shows likelihood of a person dying if covid is contracted per country - Nigeria, in this context

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'death_rate'
from covid.deaths
where location = "Nigeria" -- can be changed as desired

-- total cases vs population 
-- infection_rate shows percentage of population infected with covid in your country

select location, date, population, total_cases, (cast(total_cases as float)/population)*100 as 'infection_rate'
from covid.deaths
where location = "Nigeria"
-- where location like '%states%'

-- countries with highest infection rate compared to population

select location, population, max(total_cases) as 'max_total_cases', max((cast(total_cases as float)/population))*100 as 'percentage_population_infected'
from covid.deaths
group by location, population 
order by percentage_population_infected desc 

-- countries with highest death count per to population

select location, population, max(total_deaths) as 'total_death_count'
from covid.deaths
where iso_code not like '%owid%' -- or where continent is not null 
group by location 
order by total_death_count desc 

-- breaking things down by continent
-- categorizing death count per continent 

select continent, sum(new_deaths) as 'total_death_count'
from covid.deaths
where continent is not  null 
group by continent 
order by total_death_count desc 

-- global numbers by date 

select date, sum(new_cases) as 'daily_case_count_world', sum(new_deaths) as 'daily_death_count_world', (cast(sum(new_deaths) as float)/sum(new_cases))*100.00 as 'death_rate'
from covid.deaths
where continent is not null 
group by str_to_date(date, '%m/%d/%Y')
order by str_to_date(date, '%m/%d/%Y'), daily_case_count_world

-- global death rate summary

select sum(new_cases) as 'total_cases', sum(new_deaths) as 'total_deaths', (cast(sum(new_deaths) as float)/sum(new_cases))*100.00 as 'death_rate'
from covid.deaths
where continent is not null 

