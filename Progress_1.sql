use [Portfolio project];

select * 
from CovidDeaths$
order by 3,4
select *
from CovidVaccinations$
order by 3,4; 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
as DeathsPercentage
from CovidDeaths$
order by 1,2;

--Looking at total cases and total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage
from CovidDeaths$
order by 1,2;

-- Select data that we are going to use;

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2;

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage
from [Portfolio project].dbo.CovidDeaths$
where location like '%state%'
order by 1,2;

-- looking at total cases vs total deaths
--- shows what percentage of population got Covid

select location, date, population, total_cases, total_deaths, 
 (total_cases/population)*100 as PercentPopulationInffected
from [Portfolio project].dbo.CovidDeaths$
where location like '%state%'
order by 1,2;

-- looking at countries with highest infection rate compared to population
select location, population, Max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInffected
from CovidDeaths$
group by location, population
order by PercentPopulationInffected desc;

-- showing countries with highest death count per population;
select location, max(total_deaths) as TotalDeathCount
from CovidDeaths$
group by location
order by TotalDeathCount desc;

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
group by location
order by TotalDeathCount desc;

-- BREAK THINGS DOWN BY CON TINENT
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc;


--GLOBAL NUMBERS

select date, total_cases, total_deaths, 
 (total_deaths/total_cases)*100 as PercentPopulationInffected
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
order by 1,2;

select date, total_cases,total_cases, total_deaths, 
 (total_deaths/total_cases)*100 as PercentPopulationInffected
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2;

with multiple tables then can not group by something. 
Then use aggregate function on everything else

select date, sum(max(total_cases))
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2;

cannot do that either;

select date, sum(new_cases) as NewCases --total_cases,total_cases, total_deaths, 
 --(total_deaths/total_cases)*100 as PercentPopulationInffected
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2;

select date, sum(new_cases) as NewCases, 
sum(cast(new_deaths as int)) as NewDeaths
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2;

-- deaths percentage across the world
 select date, sum(new_cases) as NewCases, 
sum(cast(new_deaths as int)) as NewDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2;

-- looking at;

select * from [Portfolio project].dbo.CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
order by 1,2,3;

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Portfolio project].dbo.CovidDeaths$  dea
join [Portfolio project]..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3;

-- rolling count

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location
order by dea.location, dea.date ) RollingPeopleVaccinated
from [Portfolio project].dbo.CovidDeaths$  dea
join [Portfolio project]..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3;

-- compared with the population
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location
order by dea.location, dea.date ) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from [Portfolio project].dbo.CovidDeaths$  dea
join [Portfolio project]..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3;

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location
order by dea.location, dea.date )  RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [Portfolio project].dbo.CovidDeaths$  dea
join [Portfolio project]..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp table

drop table if exists #PercentPopulationVaccinated;

Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into  #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date )  RollingPeopleVaccinated
--(RollingPe opleVaccinated/population)*100
from [Portfolio project].dbo.CovidDeaths$  dea
join [Portfolio project]..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated






-- create views


create view dbo.PercenPopulationVaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date )  RollingPeopleVaccinated
--(RollingPe opleVaccinated/population)*100
from [Portfolio project].dbo.CovidDeaths$  dea
join [Portfolio project]..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null

drop view PercenPopulationVaccinated