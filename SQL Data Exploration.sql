select*
from [PortfolioProject-2]..coviddeaths
where continent is not null
order by 3,4

--select*
--from [PortfolioProject-2]..covidvaccinations
--order by 3,4

-- retrieiving data that which is beiong used

Select Location, date, total_cases, new_cases, total_deaths, population
from [PortfolioProject-2]..coviddeaths
where continent is not null
order by 1,2

-- percentage of total cases v/s total deaths 
-- Shows likelihood of dying if you contract Covid in our country CANADA

Select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [PortfolioProject-2]..coviddeaths
where location='Canada'
order by 1,2

-- percentage of total cases and population
--Showing percentage of people affected by Covid

Select location, date,population, total_cases,(total_cases/population)*100 as PercentagePopulationInfected
from [PortfolioProject-2]..coviddeaths
where location='Canada'
order by 1,2

--Countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from [PortfolioProject-2]..coviddeaths
--where location='Canada'
where continent is not null
group by location, population
order by PercentagePopulationInfected desc

--COuntries with the highest Death Count per Population


Select location, max(cast(total_deaths as int)) as TotalDeathCount
from [PortfolioProject-2]..coviddeaths
--where location='Canada'
where continent is not null
group by location
order by TotalDeathCount desc
--Selecting Continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [PortfolioProject-2]..coviddeaths
--where location='Canada'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM (cast(new_deaths as int))/ SUM(new_cases) )*100 as DeathPercentage
From [PortfolioProject-2]..coviddeaths
--where location='Canada'
where continent is not null
group by date
order by 1,2

-- Global number of new cases, death cases and death percentage all over the world
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM (cast(new_deaths as int))/ SUM(new_cases) )*100 as DeathPercentage
From [PortfolioProject-2]..coviddeaths
--where location='Canada'
where continent is not null
order by 1,2

--Joining the Death and Vaccination Tables

select*
from [PortfolioProject-2]..coviddeaths  dea
join [PortfolioProject-2]..covidvaccinations vac
on dea.location=vac.location

--Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [PortfolioProject-2]..coviddeaths  dea
join [PortfolioProject-2]..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- New Vaccinations per day
-- either u can use cast(vac.new_vaccinations as int) or Convert(int,vac.new_vaccinations) both would convert varchar to integer values

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject-2]..coviddeaths  dea
join [PortfolioProject-2]..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 2,3

-- Since you can't used a column just made for providing the data in that column as an input you either use CTE or Temp table

--Use CTE
--If the number of columns in the CTE is different then number of columns used under the paranthesis after as
With PopvsVac(Continent,Location,Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject-2]..coviddeaths  dea
join [PortfolioProject-2]..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
SET ANSI_WARNINGS OFF
GO
Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject-2]..coviddeaths  dea
join [PortfolioProject-2]..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null 
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizationa

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject-2]..coviddeaths  dea
join [PortfolioProject-2]..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

select*
From PercentPopulationVaccinated