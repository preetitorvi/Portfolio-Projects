-- SQL Queries to understand the data

-- Check the count of records to match the data source text file 
select count(*) 
from coviddeaths

-- Query to see the records and the data are displayed correctly
select * 
from coviddeaths
limit 100

-- Check the count of records to match the data source text file 
select count(*) 
from CovidVaccinations

-- Query to see the records and the data are displayed correctly
select * 
from CovidVaccinations
limit 100

select location, total_cases , total_deaths 
from CovidDeaths


-- Total cases vs Total deaths by location
select location, sum(total_cases)Total_Cases , sum(total_deaths) Total_Deaths
from CovidDeaths
group by location
order by 1

-- Total cases vs Total Deaths : Percentage of cases resulted in death
select location, total_cases , total_deaths, 
		cast(total_deaths as real)/total_cases *100 as DeathPercentage
from CovidDeaths

-- Total cases vs Population
-- percentage of people who got covid 
-- sampling for US 
select location, date,total_cases , population, 
		cast(total_cases as real)/population *100 as peopleinfectedPercentage
from CovidDeaths
where location like 'United %States'

-- Countries/Location with highest infection rate
select location,population, 
		max(total_cases) as Highest_infection_count,
		max(cast(total_cases as real)/population *100) as peopleinfectedPercentage
from CovidDeaths
group by location, population
order by 4 desc

-- which country has the deaths
select location, 
		max(total_deaths) as Total_Death_count
		--max(cast(total_cases as real)/population *100) as peopleinfectedPercentage
from CovidDeaths
where continent is not null
	  and total_deaths is not null
group by location
order by 2 desc

-- Total cases ny continent
select location, 
		max(total_deaths) as Total_Death_count
from CovidDeaths
where continent is null
	  and total_deaths is not null
group by location
order by 2 desc

-- Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(cast(new_deaths as real) )/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
Group By date
order by 1,2


-- checking the integrity of data 
-- number of records after join 
select * --count(*) 
from 
	 coviddeaths dea 
join covidvaccinations vac
on dea.location = vac.location
and cast(dea.date as date) = cast(vac.date as date)

-- total Population vs Vacciantions 
select dea.continent, dea.location, dea.population, vac.new_vaccinations
from 
	 coviddeaths dea 
join covidvaccinations vac
on dea.location = vac.location
and cast(dea.date as date) = cast(vac.date as date)
where dea.continent is not null
order by 2,3


-- Total vaccinations by location
select dea.continent, dea.location, dea.population, vac.new_vaccinations,
	   sum(vac.new_vaccinations) over (partition by dea.location order by 
		dea.location, dea.date) as countpeoplevaccinated
from 
	 coviddeaths dea 
join covidvaccinations vac
on dea.location = vac.location
and cast(dea.date as date) = cast(vac.date as date)
where dea.continent is not null
order by 2,3

-- CTE
with PopulationvsVac (Continent, location, population, new_vaccinations,
					 countpeoplevaccinated)
as(
select dea.continent, dea.location, dea.population, vac.new_vaccinations,
	   sum(vac.new_vaccinations) over (partition by dea.location order by 
		dea.location, dea.date) as countpeoplevaccinated
from 
	 coviddeaths dea 
join covidvaccinations vac
on dea.location = vac.location
and cast(dea.date as date) = cast(vac.date as date)
where dea.continent is not null
order by 2,3)
select *,(countpeoplevaccinated /cast(population as real)) * 100 Percentagepeoplevaccinated
from PopulationvsVac 


-- Temp Table 

create table percentpopulationvaccinated
(
continent varchar(250),
location varchar(250),
population integer,
new_vaccinations integer,
countpeoplevaccinated integer
)

insert into percentpopulationvaccinated
(
select dea.continent, dea.location, dea.population, vac.new_vaccinations,
	   sum(vac.new_vaccinations) over (partition by dea.location order by 
		dea.location, dea.date) as countpeoplevaccinated
from 
	 coviddeaths dea 
join covidvaccinations vac
on dea.location = vac.location
and cast(dea.date as date) = cast(vac.date as date)
where dea.continent is not null
order by 2,3)

select *,(countpeoplevaccinated /cast(population as real)) * 100 Percentagepeoplevaccinated
from percentpopulationvaccinated
