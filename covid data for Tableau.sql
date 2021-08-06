
--1/ new cases, new deaths, percent deaths

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_percentage 
FROM ['CovidDeaths']
WHERE continent IS NOT NULL
ORDER BY 1,2


--2/ 

SELECT continent, location, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM ['CovidDeaths']
WHERE continent IS NOT NULL
AND location not in ('World', 'European Union', 'International')
GROUP BY continent, location
ORDER BY total_death_count desc


--3/
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
		MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM ['CovidDeaths']
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--4/
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, 
		MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM ['CovidDeaths']
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc


--5/
SELECT Location, date, population, total_cases, total_deaths
FROM ['CovidDeaths']
WHERE continent is not null 
ORDER BY 1,2


--6/ 
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date,dea.location) AS RollingPeopleVaccinated
FROM ['CovidDeaths'] dea
JOIN ['CovidVaccinations$'] vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM PopvsVac


--7/
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM ['CovidDeaths']
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc


