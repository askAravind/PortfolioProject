select *
from PortfolioProject..covidDeaths
order by 3,4

--select *
--from PortfolioProject..covidvaccinations
--order by 3,4

-- Select data 
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeaths
order by 1,2

--Total cases v Total deaths -> showing the likelihood of dying if you are infected with the virus in India

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where location = 'India'
order by 1,2

-- Total cases v population -> what percentage of population are infected

select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..covidDeaths
where location = 'India'
order by 1,2

select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..covidDeaths
where location like '%states%'
order by 1,2

-- countries with highest infection rate 

select Location, population, MAX(total_cases) as HighestCases, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
group by Location, population
--where location = 'India'
order by PercentPopulationInfected desc

-- countries with highest deaths 

select Location, MAX(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..covidDeaths
where continent is not null
group by Location
order by TotalDeaths desc

-- continent deaths
select continent, SUM(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by TotalDeaths desc

-- joining death and vaccination tables
-- total vaccinated people in the world
-- rolling count

select d.continent,d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(BIGINT,v.new_vaccinations)) OVER (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths d Join 
PortfolioProject..covidvaccinations v 
on d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 2,3


-- USE CTE

With PopVsVac (Continent, location, Date, Population, New_vaccination, RollingPeopleVaccinated) 
as
(
select d.continent,d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(BIGINT,v.new_vaccinations)) OVER (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths d Join 
PortfolioProject..covidvaccinations v 
on d.location = v.location 
and d.date = v.date
where d.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

-- TEMP TABLE
Create table #PercentPeopleVaccinated 
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)


insert into #PercentPeopleVaccinated
select d.continent,d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(BIGINT,v.new_vaccinations)) OVER (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths d Join 
PortfolioProject..covidvaccinations v 
on d.location = v.location 
and d.date = v.date
where d.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPeopleVaccinated


--create VIEW to store data

Create View PercentPopulationVacc as 
select d.continent,d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(BIGINT,v.new_vaccinations)) OVER (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths d Join 
PortfolioProject..covidvaccinations v 
on d.location = v.location 
and d.date = v.date
where d.continent is not null

