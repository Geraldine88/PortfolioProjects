SELECT *
FROM PortfolioProjects..CovidDeaths
---ORDER BY THE 3RD AND FORTH COLUMN OF THE DATASET
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--ORDER BY 3, 4

--------------------------- SELECTING DATA TO BE USED -------------------------------------------

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
---ORDER BY THE FIRST AND SECOND SELECTED COLUMNS
ORDER BY 1, 2



----Looking at the total cases vs total deaths
---Getting the percentage of people who are dying who actually get infected
----Shows the likelyhood of dying if you contract COVID in Africa
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%Africa%'
---ORDER BY THE FIRST AND SECOND SELECTED COLUMNS
ORDER BY 1, 2


---------------Looking at the Total cases vs the population
-------Shows what percentage of population got COVID 
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPopulation
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
---ORDER BY THE FIRST AND SECOND SELECTED COLUMNS
ORDER BY 1, 2


---What country(ies) has the highest infection rate compared to the population
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as InfectedPopulation
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
---Descending gets the highest number first
ORDER BY InfectedPopulation DESC

--- Coutries with highest death count population from COVID
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
---Descending gets the highest number first
ORDER BY TotalDeathCount DESC

-- Since total_death from the CovidDeath set is an nvarchar, it won't give the accurate result. As such, we need to cast
-- it as an interger so it's read as a numeric
--- Coutries with highest death count population from COVID
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
---Descending gets the highest number first
ORDER BY TotalDeathCount DESC


--- BREAKING DOWN BY CONTINENT

--- Displaying countries with highest death counts
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--- Displaying continents with highest death counts
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS  NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


					/************** TOTAL POPULATION VS TOTAL VACCINATION ************/
--JOINING BOTH TABLES; COVID DEATHS AND COVID VACCINATION
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VACC.new_vaccinations
FROM PortfolioProjects..CovidDeaths DEA
JOIN PortfolioProjects..CovidVaccinations VACC
	ON DEA.location = VACC.location
	AND DEA.date = VACC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3


								/****************** USING CTE ******************/

WITH PopVSVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VACC.new_vaccinations,
SUM(CONVERT(INT, VACC.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths DEA
JOIN PortfolioProjects..CovidVaccinations VACC
	ON DEA.location = VACC.location
	AND DEA.date = VACC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
FROM PopVSVacc


								/********************** USING A TEMP TABLE ****************************/

---- DROP TABEL IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VACC.new_vaccinations,
SUM(CONVERT(INT, VACC.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths DEA
JOIN PortfolioProjects..CovidVaccinations VACC
	ON DEA.location = VACC.location
	AND DEA.date = VACC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated



									/**************** USING VIEW ************/
--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VACC.new_vaccinations,
SUM(CONVERT(INT, VACC.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths DEA
JOIN PortfolioProjects..CovidVaccinations VACC
	ON DEA.location = VACC.location
	AND DEA.date = VACC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3


----- Querying off of the PercentPopulationVaccinated view
SELECT * 
FROM PercentPopulationVaccinated


