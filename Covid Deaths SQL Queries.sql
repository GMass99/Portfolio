
Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total cases vs Total deaths
-- Likelihood of dying if you contract Covid in America
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%United Kingdom%'
order by 1,2

Create View UKDeathPercentage as
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%United Kingdom%'

-- Total cases v Population
-- Percentage of Population that got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
Where location like '%United Kingdom%' and continent is not null
order by 1,2

Create View UKCovidPercentage as
Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
Where location like '%United Kingdom%' and continent is not null

-- Countries with the highest infection rate v population

Select Location, Population, MAX(cast(total_cases as int)) as TotalInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
group by Location, Population
order by PercentPopulationInfected desc

-- Countries with the Highest Death Count

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

-- Continents with the Highest Death Counts

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where not location like '%income%' and continent is null
group by Location
order by TotalDeathCount desc

-- Countries with the Highest Death Count per Population

Select Location, Population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((total_deaths/population))*100 as PercentPopulationDied
From PortfolioProject..CovidDeaths
where continent is not null
group by Location, Population
order by PercentPopulationDied desc

Create View DeathCountPerPopulation as
Select Location, Population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((total_deaths/population))*100 as PercentPopulationDied
From PortfolioProject..CovidDeaths
where continent is not null
group by Location, Population

-- Global Death Numbers 

Select SUM(new_cases) as TotalCaseCount, SUM(cast(new_deaths as int)) as TotalDeathCount, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Joining Death and Vaccination Tables

Select *
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date

-- Total Population vs Vaccinations (using CTE)

with PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinationNumber)
as (
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(convert(numeric, vac.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as RollingVaccinationNumber
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null
)

Select *, (RollingVaccinationNumber/population)*100
From PopvsVac 

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinationNumber numeric
)
Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(convert(numeric, vac.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as RollingVaccinationNumber
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null

Select *, (RollingVaccinationNumber/population)*100
From #PercentPopulationVaccinated 

-- Creating View to store data for later viz 

Create view PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(convert(numeric, vac.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as RollingVaccinationNumber
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null

Select * 
From PercentPopulationVaccinated