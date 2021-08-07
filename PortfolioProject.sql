
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Vietnam

SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Vietnam'
ORDER BY 1,2

-- Looking at the Total Cases vs Population
-- Show what percentage of population got covid

SELECT Location,date,total_cases,population, (total_cases/population) * 100 as PercentGotCovid
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Vietnam'
ORDER BY 1,2

-- Looking at country with highest infection rate compared to Population

SELECT Location,population,MAX(total_cases) as Highest_Infection,population, MAX(total_cases/population) * 100 as PercentGotCovid
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Vietnam'
GROUP BY location,population
ORDER BY PercentGotCovid desc

-- Showing countries highest Death Count per Population

SELECT Location,max(cast(total_deaths as int)) as NumberDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY NumberDeathCount desc

-- Let's break things down by continent

---- Showing continents with the highest death count per population


SELECT location as continent,max(cast(total_deaths as int)) as NumberDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY NumberDeathCount desc

-- GLOBAL NUMBER

SELECT sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
-- Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Total_People_Vaccinated)
as
(
SELECT t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations
, SUM(cast(t2.new_vaccinations as int)) OVER (Partition by t1.location Order By t1.location,t1.date) as Total_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ t1
JOIN PortfolioProject..CovidVaccinations$ t2
	On t1.location = t2.location
	and t1.date = t2.date
WHERE t1.continent is not null
--ORDER BY 2,3
)
SELECT
*, (Total_People_Vaccinated/Population)*100
FROM PopvsVac


-- Temp Table

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations
, SUM(cast(t2.new_vaccinations as int)) OVER (Partition by t1.location Order By t1.location,t1.date) as Total_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ t1
JOIN PortfolioProject..CovidVaccinations$ t2
	On t1.location = t2.location
	and t1.date = t2.date
WHERE t1.continent is not null

SELECT *,(Total_People_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Create view for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations
, SUM(cast(t2.new_vaccinations as int)) OVER (Partition by t1.location Order By t1.location,t1.date) as Total_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ t1
JOIN PortfolioProject..CovidVaccinations$ t2
	On t1.location = t2.location
	and t1.date = t2.date
WHERE t1.continent is not null

select *
from PercentPopulationVaccinated