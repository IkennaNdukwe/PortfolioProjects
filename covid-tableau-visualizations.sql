/*
Queries used for Covid-19 Data Exploration Tableau Project
*/

-- total cases vs total deaths 
-- death_rate shows likelihood of dying if covid is contracted
select sum(new_cases) as 'total_cases', sum(new_deaths) as 'total_deaths', (cast(sum(new_deaths) as float)/sum(new_cases))*100.00 as 'death_rate' from covid.deaths
where continent is not null

-- total deaths per continent 
select continent, location, sum(new_deaths) as 'total_deaths'
from covid.deaths 
where continent is null and location not in ('World', 'European Union', 'International')
group by location 
order by total_deaths desc

select * from covid.deaths
-- population infection rate per country 
select location, population, max(total_cases) as 'total_infections', (cast(max(total_cases) as float)/population)*100 as 'population_infection_rate'  from covid.deaths
where continent is not null 
group by location, population  
order by population_infection_rate desc

-- population infection rate per country - daily trend (timescale) 
select location, date, population, max(total_cases) as 'total_infections', (cast(max(total_cases) as float)/population)*100 as 'population_infection_rate'  from covid.deaths
where continent is not null -- and location = 'nigeria'
group by location, population, date  

/*
Link to the visualization:
https://public.tableau.com/app/profile/ikenna4609/viz/Covid-19DataExploration_16331981337110/Dashboard1?publish=yes
*/
