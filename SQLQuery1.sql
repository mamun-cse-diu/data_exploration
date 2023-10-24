
Select *
From ProtfolioProject.. CovidDeaths
Where continent is not null
order by 3,4


-- Select data that we are going to be using


Select Location, date, total_cases, new_cases, total_deaths, population
From ProtfolioProject..CovidDeaths
Where continent is not null
order by 3,4


-- Looking at Total cases vs total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProtfolioProject..CovidDeaths
Where location like '%Bangladesh%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs population

Select Location, date, Population, total_cases, (total_cases/population)*100 as CasesPercentage
From ProtfolioProject..CovidDeaths
Where location like '%Bangladesh%'
and continent is not null
order by 1,2

-- looking at Coubtries with Highest Infection Rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasesPercentage
From ProtfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by CasesPercentage desc

-- showing countrise with Highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProtfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break things down by continent
-- showing continent with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProtfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProtfolioProject..CovidDeaths
Where continent is not null
--Group by date 
order by 1,2


-- Looking at total population vs vaccination

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- temp Table

DROP Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPeopleVaccinated


-- Creating view to store data for later visualization

USE ProtfolioProject
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated