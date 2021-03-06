/*
Covid-19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
Link to dataset: https://ourworldindata.org/covid-deaths
MySQL 8.0 was used for this exploration.
*/

-- create 'vaccinations' table in the 'covid' database

drop table if exists covid.vaccinations
    
create table covid.vaccinations(
    iso_code text, 
	continent text, 
	location text, 
	date text, 
	new_tests int null, 
	total_tests int null, 
	total_tests_per_thousand text, 
	new_tests_per_thousand text, 
	new_tests_smoothed text,
	new_tests_smoothed_per_thousand text,
	positive_rate double,
	tests_per_case text, 
	tests_units text, 
	total_vaccinations int null,
	people_vaccinated int null, 
	people_fully_vaccinated int null, 
	total_boosters int null, 
	new_vaccinations int null, 
	new_vaccinations_smoothed text, 
	total_vaccinations_per_hundred text, 
	people_vaccinated_per_hundred text, 
	people_fully_vaccinated_per_hundred text, 
	total_boosters_per_hundred text,
    new_vaccinations_smoothed_per_million text, 
	stringency_index double,
	population_density double, 
	median_age double, 
	aged_65_older double, 
	aged_70_older double, 
	gdp_per_capita double, 
	extreme_poverty text, 
	cardiovasc_death_rate double, 
	diabetes_prevalence double,
	female_smokers text, 
	male_smokers text, 
	handwashing_facilities double, 
	hospital_beds_per_thousand double, 
	life_expectancy double,
	human_development_index double, 
	excess_mortality_cumulative_absolute text, 
	excess_mortality_cumulative text, 
	excess_mortality text, 
	excess_mortality_cumulative_per_million text
    );

-- load data into 'vaccinations' table

LOAD DATA INFILE 'C://owid-covid-vaccinations.csv'
INTO TABLE covid.vaccinations
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@iso_code, @continent, @location, @date, @new_tests, @total_tests, @total_tests_per_thousand, @new_tests_per_thousand, @new_tests_smoothed, @new_tests_smoothed_per_thousand, @positive_rate, @tests_per_case, @tests_units, @total_vaccinations, @people_vaccinated, @people_fully_vaccinated, @total_boosters, @new_vaccinations, @new_vaccinations_smoothed, @total_vaccinations_per_hundred, @people_vaccinated_per_hundred, @people_fully_vaccinated_per_hundred, @total_boosters_per_hundred, @new_vaccinations_smoothed_per_million, @stringency_index, @population_density, @median_age, @aged_65_older, @aged_70_older, @gdp_per_capita, @extreme_poverty, @cardiovasc_death_rate, @diabetes_prevalence, @female_smokers, @male_smokers, @handwashing_facilities, @hospital_beds_per_thousand, @life_expectancy, @human_development_index, @excess_mortality_cumulative_absolute, @excess_mortality_cumulative, @excess_mortality, @excess_mortality_cumulative_per_million) 
       SET iso_code = NULLIF(@iso_code,''), 
           continent = NULLIF(@continent,''), 
           location = NULLIF(@location,''), 
           date = NULLIF(@date,''),
           new_tests = NULLIF(@new_tests,''),
           total_tests = NULLIF(@total_tests,''),
           total_tests_per_thousand = NULLIF(@total_tests_per_thousand,''),
           new_tests_per_thousand = NULLIF(@new_tests_per_thousand,''),
           new_tests_smoothed = NULLIF(@new_tests_smoothed,''),
           new_tests_smoothed_per_thousand = NULLIF(@new_tests_smoothed_per_thousand,''),
           positive_rate = NULLIF(@positive_rate,''), 
           tests_per_case  = NULLIF(@tests_per_case ,''), 
           tests_units = NULLIF(@tests_units,''), 
           total_vaccinations = NULLIF(@total_vaccinations,''),
           people_vaccinated = NULLIF(@people_vaccinated,''),
           people_fully_vaccinated = NULLIF(@people_fully_vaccinated,''),
           total_boosters = NULLIF(@total_boosters,''),
           new_vaccinations = NULLIF(@new_vaccinations,''),
           new_vaccinations_smoothed = NULLIF(@new_vaccinations_smoothed,''),
           total_vaccinations_per_hundred  = NULLIF(@total_vaccinations_per_hundred,''),
           people_vaccinated_per_hundred = NULLIF(@people_vaccinated_per_hundred,''),
           people_fully_vaccinated_per_hundred = NULLIF(@people_fully_vaccinated_per_hundred,''),
           total_boosters_per_hundred = NULLIF(@total_boosters_per_hundred,''),
           new_vaccinations_smoothed_per_million = NULLIF(@new_vaccinations_smoothed_per_million,''),
           stringency_index = NULLIF(@stringency_index,''),
           population_density = NULLIF(@population_density,''),
           median_age = NULLIF(@median_age,''),
           aged_65_older = NULLIF(@aged_65_older,''),
           aged_70_older = NULLIF(@aged_70_older,''),
           gdp_per_capita = NULLIF(@gdp_per_capita,''),
           extreme_poverty = NULLIF(@extreme_poverty,''),
           cardiovasc_death_rate = NULLIF(@cardiovasc_death_rate,''),
           diabetes_prevalence = NULLIF(@diabetes_prevalence,''),
           female_smokers = NULLIF(@female_smokers,''),
           male_smokers = NULLIF(@male_smokers,''),
           handwashing_facilities = NULLIF(@handwashing_facilities,''),
           life_expectancy = NULLIF(@life_expectancy,''),
           human_development_index = NULLIF(@human_development_index,''),
           excess_mortality_cumulative_absolute = NULLIF(@excess_mortality_cumulative_absolute,''),
           excess_mortality_cumulative = NULLIF(@excess_mortality_cumulative,''),
           excess_mortality = NULLIF(@excess_mortality,''),
           excess_mortality_cumulative_per_million = NULLIF(@excess_mortality_cumulative_per_million,'')
;

-- data import validation test 

select * from covid.vaccinations
where location = 'Albania' and date = '3/30/2021'

-- join covid.deaths and covid.vaccinations tables 
-- total population vs vaccinations : shows percentage of population that has received at least one covid vaccination shot per country

select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(b.new_vaccinations) over (partition by a.location order by a.location, str_to_date(a.date, '%m/%d/%Y')) as 'vaccination_running_total'
from covid.deaths a 
join covid.vaccinations b 
	on a.location = b.location 
	and a.date = b.date
where a.continent is not null and a.location = 'nigeria'
order by a.location, str_to_date(a.date, '%m/%d/%Y')

-- Using CTE to perform Calculation on Partition By in previous query (running total with Windows Function)

with pop_vs_vac (continent, location, date, population, new_vaccinations, vaccination_running_total) as 
(
select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(b.new_vaccinations) over (partition by a.location order by a.location, str_to_date(a.date, '%m/%d/%Y')) as 'vaccination_running_total'
from covid.deaths a 
join covid.vaccinations b 
	on a.location = b.location 
	and a.date = b.date
where a.continent is not null and a.location = 'nigeria'
order by a.location, str_to_date(a.date, '%m/%d/%Y')
)

select *, (cast(vaccination_running_total as float)/population)*100 as 'percentage_vaccinated' 
from pop_vs_vac

-- Using a Temp Table to perform Calculation on Partition By in previous query (running total with Windows Function)

drop table if exists covid.population_vaxxed_perc

create table covid.population_vaxxed_percentage(
	continent text, 
	location text, 
	date text, 
	population int null, 
	new_vaccinations int null, 
	vaccination_running_total int null
);

insert into covid.population_vaxxed_percentage
select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(b.new_vaccinations) over (partition by a.location order by a.location, str_to_date(a.date, '%m/%d/%Y')) as 'vaccination_running_total'
from covid.deaths a 
join covid.vaccinations b 
	on a.location = b.location 
	and a.date = b.date
where a.continent is not null and a.location = 'nigeria'
order by a.location, str_to_date(a.date, '%m/%d/%Y')

-- view records
select *, (cast(vaccination_running_total as float)/population)*100 as 'percentage_vaccinated'  
from covid.population_vaxxed_percentage

-- Creating View to store data for later visualizations

create view covid.v_population_vaxxed_percentage as
select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(b.new_vaccinations) over (partition by a.location order by a.location, str_to_date(a.date, '%m/%d/%Y')) as 'vaccination_running_total'
from covid.deaths a 
join covid.vaccinations b 
	on a.location = b.location 
	and a.date = b.date
where a.continent is not null and a.location = 'nigeria'
order by a.location, str_to_date(a.date, '%m/%d/%Y')

-- view records 
select *, (cast(vaccination_running_total as float)/population)*100 as 'percentage_vaccinated'  
from covid.v_population_vaxxed_percentage
