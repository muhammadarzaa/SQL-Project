select*
from CovidPortofolioProject..CovidDeath$
where continent is not null
order by 3,4

--select*
--from CovidPortofolioProject..CovidVaccin$
--order by 3,4

--Select the data that we are going to use
select location, date, total_cases, new_cases, total_deaths, population
from CovidPortofolioProject..CovidDeath$
where continent is not null
order by 1,2


--Looking at total cases vs total death
--Show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidPortofolioProject..CovidDeath$
where location like '%indonesia%' and continent is not null
order by 1,2

--Looking at total cases vs Population
--show what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from CovidPortofolioProject..CovidDeath$
--where location like '%indonesia%'
where continent is not null
order by 1,2

--Looking countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from CovidPortofolioProject..CovidDeath$
--where location like '%indonesia%'
where continent is not null
group by location, population
order by PercentagePopulationInfected desc

select location, population, date, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from CovidPortofolioProject..CovidDeath$
--where location like '%indonesia%'
where continent is not null
group by location, population, date
order by PercentagePopulationInfected desc

--Showing country with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidPortofolioProject..CovidDeath$
--where location like '%indonesia%'
where continent is not null
group by location
order by TotalDeathCount desc


--Showing continent with highest death per population 
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidPortofolioProject..CovidDeath$
--where location like '%indonesia%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidPortofolioProject..CovidDeath$
--where location like '%indonesia%'
where continent is not null
--group by date
order by 1,2

select location, sum(cast(new_deaths as int)) as TotalDeathCount
from CovidPortofolioProject..CovidDeath$
--where location like '%indonesia%'
where continent is null 
and location not in ('world','international','European Union','Low income','Lower middle income','Upper middle income','High income')
group by location
order by TotalDeathCount desc

--Looking at total population vs total deaths
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidPortofolioProject..CovidDeath$ dea
join CovidPortofolioProject..CovidVaccin$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE
WITH PopvsVacc (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidPortofolioProject..CovidDeath$ dea
join CovidPortofolioProject..CovidVaccin$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100
from PopvsVacc


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population Numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidPortofolioProject..CovidDeath$ dea
join CovidPortofolioProject..CovidVaccin$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidPortofolioProject..CovidDeath$ dea
join CovidPortofolioProject..CovidVaccin$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select*from PercentPopulationVaccinated