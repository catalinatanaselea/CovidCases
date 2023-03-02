/*CovidDeaths TABLE*/

--Total cases vs Total deaths 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%romania%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Total cases vs the Population
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulation
FROM CovidDeaths
WHERE location like '%romania%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Which country has the highest Infection rate vs Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC


--Which country has the highest Death count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--The continents with the highest death count
SELECT continent, MAX(CAST(total_deaths AS INT)) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

--GLOBAL numbers
SELECT date, SUM(CAST(total_cases as INT)) AS TotalCases, SUM(CAST(total_deaths AS INT)) as TotalDeaths
FROM CovidDeaths
WHERE location like '%romania%'
AND continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(CAST(new_cases as INT)) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) as TotalNewDeaths, (SUM(CAST(new_deaths as INT)) / SUM(new_cases)) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%romania%'
AND continent IS NOT NULL
AND new_cases <> 0
ORDER BY 1, 2


/*CovidDeaths TABLE JOINING CovidVaccinations TABLE*/

--Total Population vs Vaccination
--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(CAST(v.new_vaccinations as BIGINT)) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
    ON d.location = v.location and d.date = v.date
WHERE d.continent IS NOT NULL
) 

SELECT *, (RollingPeopleVaccinated/population) * 100 as PrecentageVaccinated
FROM PopvsVac

--USE TempTable
SELECT *
INTO #TempT
FROM 
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(CAST(v.new_vaccinations as BIGINT)) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
    ON d.location = v.location and d.date = v.date
WHERE d.continent IS NOT NULL
) T

SELECT *, (RollingPeopleVaccinated/population) * 100 as PrecentagePopulationVaccinated
FROM #TempT

DROP TABLE #TempT

--VIEW
CREATE OR ALTER VIEW PrecentagePopulationVaccinated

AS

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(CAST(v.new_vaccinations as BIGINT)) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location and d.date = v.date
WHERE d.continent IS NOT NULL

SELECT TOP 10 *
FROM PrecentagePopulationVaccinated