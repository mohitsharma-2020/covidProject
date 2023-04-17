select d.location, d.date, d.total_cases, d.new_cases, d.total_deaths, d.population
from data_deaths d


select *
from data_vaccination
order by 3,4



--looking at % of total deaths
select d.location, d.date, d.total_cases,d.total_deaths, 
	cast(
		cast(d.total_deaths as float)/cast (d.total_cases as float)*100 
		as decimal(10,2)
		) [Death Percentage]
from data_deaths d
where d.location like '%states%'
order by 1,2


-- looking at total cases vs population
select d.location, d.date, d.total_cases,d.population, 
	cast(
		cast(d.total_cases as float)/cast (d.population as float)*100 
		as decimal(10,2)
		) [Death Percentage]
from data_deaths d
where d.location like '%india%'
order by 1,2

-- looking at countries with highest infection rate compared to population
select d.location, max(d.total_cases) [Highest Infection],d.population, 
	max(cast(
		(d.total_cases/d.population)*100
		as decimal(10,2)
		)) [Highest Death Rate]
from data_deaths d
--where d.location like '%india%'
group by d.location, d.population
order by [Highest Death Rate] desc

SELECT LOCATION,TOTAL_CASES, POPULATION, (TOTAL_CASES/POPULATION)*100
FROM DATA_DEATHS
WHERE LOCATION = 'CYPRUS'
--GROUP BY LOCATION, POPULATION
ORDER BY 4 DESC

--countries with highest death count per population
select d.location, max(cast(d.total_deaths as int)) total_Death_Count
from data_deaths d
where continent is not null
--where d.location like '%india%'
group by d.location
order by total_Death_Count desc


--Continent with highest death count per population
select d.location, max(cast(d.total_deaths as int)) total_Death_Count
from data_deaths d
where continent is null
--where d.location like '%india%'
group by d.location
--having continent is not null
order by total_Death_Count desc

-- showing continent with highest death count
select d.location, max(cast(d.total_deaths as int)) total_Death_Count
from data_deaths d
where continent is null
--where d.location like '%india%'
group by d.location
--having continent is not null
order by total_Death_Count desc

-- global numbers
select sum(d.new_cases) total_cases, sum(d.new_deaths) total_deaths, 
	sum(cast(d.new_deaths as float))/sum(cast(d.new_cases as float))*100 [Death Percentage]
from data_deaths d
where continent is not null
--where d.location like '%states%'
--group by date
order by 1


--looking at total population vs vaccinantion
select d.continent,d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location,d.date) [Rolling vaccincations]
from data_deaths d
join data_vaccination v
on d.location = v.location and d.date = v.date
where d.continent is not null and v.location = 'India'
order by 1,2,3


-- USE CTE +++++++++++++++++++++++++++++++++
with Cummulative_Vaccination(continent, location, date, population, new_vaccinations, [Rolling vaccincations])
as
(
select d.continent,d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location,d.date) [Rolling vaccincations]
from data_deaths d
join data_vaccination v
on d.location = v.location and d.date = v.date
where d.continent is not null and v.location = 'albania'
--order by 1,2,3
)

select *, (cv.[Rolling vaccincations]/cv.population)*100
from Cummulative_Vaccination cv

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
	continent varchar(255), 
	location varchar(255), 
	date datetime, 
	population numeric, 
	new_vaccinations numeric, 
	[Rolling vaccincations] numeric		
)

insert into #PercentPopulationVaccinated 
select d.continent,d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location,d.date) [Rolling vaccincations]
from data_deaths d
join data_vaccination v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 1,2,3

select *, (cv.[Rolling vaccincations]/cv.population)*100 [Rolling %]
from #PercentPopulationVaccinated cv


-- Creating view for visualisation
create view PercentPopulationVaccinated as
select d.continent,d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location,d.date) [Rolling vaccincations]
from data_deaths d
join data_vaccination v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 1,2,3

select *
from PercentPopulationVaccinated