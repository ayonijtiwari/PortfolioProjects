select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Total Deaths vs Total Cases
--Shows likelihood of dying if you contract covid 

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2


--Total Cases vs Population
--Shows percentage of population that got covid

select Location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentageInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
order by 1,2


--Countries with Highest Infection Rate compared to Population

select location,  max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationPercentageInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by PopulationPercentageInfected desc


--Countries with Highest Death Count 

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--CONTINENT WISE
--Continents with the Highest Death Count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Total Population vs Vaccination

select dea.continent, dea.location, dea.date, population, new_vaccinations, sum(cast(new_vaccinations as bigint))over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations dea
join PortfolioProject..CovidDeaths vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, population, new_vaccinations, sum(cast(new_vaccinations as bigint))over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations dea
join PortfolioProject..CovidDeaths vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, new_vaccinations, sum(cast(new_vaccinations as bigint))over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations dea
join PortfolioProject..CovidDeaths vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

use PortfolioProject
go
create view 
PercentPopulationVaccinated
as
select dea.continent, dea.location, dea.date, population, new_vaccinations, sum(cast(new_vaccinations as bigint))over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations dea
join PortfolioProject..CovidDeaths vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated