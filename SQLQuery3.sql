SELECT *
--location, date, total_cases, total_deaths, population
FROM ['CovidDeaths']
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM ['CovidDeaths']
WHERE LOCATION LIKE '%states%'
ORDER BY 1,2 

--looking at Total Cases vs Population
--percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS cases_percentage
FROM ['CovidDeaths']
WHERE LOCATION LIKE '%states%'
ORDER BY 1,2

--looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM ['CovidDeaths']
--WHERE LOCATION LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc 

--showing countries with highest death counts per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
--WHERE LOCATION LIKE '%states%'
FROM ['CovidDeaths']
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_death_count desc

--showing continent with highest death counts
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
--WHERE LOCATION LIKE '%states%'
FROM ['CovidDeaths']
WHERE continent IS NOT NULL
GROUP BY continent	
ORDER BY total_death_count desc 


--global numbers
SELECT SUM(total_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_new_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deathpercentage
FROM ['CovidDeaths']
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2




--VACCINATIONS
--total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM ['CovidVaccinations$'] vac
JOIN ['CovidDeaths'] dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2


WITH PopVsVAc (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM ['CovidVaccinations$'] vac
JOIN ['CovidDeaths'] dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 AS percentage_people_vaccinated
FROM PopVsVAc




--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ['CovidVaccinations$'] vac
JOIN ['CovidDeaths'] dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM #PercentPopulationVaccinated

--SELECT *, (RollingPeopleVaccinated/population)*100 AS percentage_people_vaccinated
--FROM #PercentPopulationVaccinated




-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ['CovidVaccinations$'] vac
JOIN ['CovidDeaths'] dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3