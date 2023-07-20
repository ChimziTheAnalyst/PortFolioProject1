
Select *
FROM PortfolioProject1..CovidDeaths$
order by 3,4

--Select *
--FROM PortfolioProject1..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths$
order by 1,2

----Considering the Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (Total_deaths/Total_cases) *100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths$
Where location like '%nigeria%'
and continent is not null
order by 1,2    

--Considering The Total cases vs population
--Shows what percentage of population got covid
Select location, date, Population, total_cases, (Total_cases/population) *100 as PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths$
Where location like '%nigeria%'
order by 1,2


-- Considering countries with highest infection rate compared to population
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population)) *100 as PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths$
--Where location like '%nigeria%'
Group by location, population
order by PercentPopulationInfected DESC


--Considering the countries with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
--Where location like '%nigeria%'
where continent is not null
Group by continent
order by  TotalDeathCount DESC


--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as deathpercentage
From PortfolioProject1..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2


--Looking at Total Population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated 
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

With PopsVsVac (Continent, Location, Date, Population,New_vaccinations ,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopsVsVac
 

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated


 