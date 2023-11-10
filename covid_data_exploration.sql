-- initial look at the data
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- select data to start with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- total cases vs total deaths
-- likelihood of dying if you contract covid in the US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 2

-- total cases vs population
-- the percentage of population infected with covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS population_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 2

-- countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS population_percentage_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY population_percentage_infected DESC

-- countries with highest death count per population
SELECT location, population, MAX(total_deaths) AS total_death_count, MAX(total_deaths/population)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_death_count DESC

-- breaking things down by continent
-- continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS total_death_count, MAX(total_deaths/population)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

-- global numbers
-- death percentage by date
SELECT date, total_cases, total_deaths, total_deaths/total_cases*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
-- total death percentage
SELECT MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths, MAX(total_deaths)/MAX(total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths

-- join CovidDeaths and CovidVaccinations tables
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date

-- total population vs vaccinations
-- the percentage of population that has received at least one covid vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- creating a cte
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100 AS percentage_vaccinated
FROM pop_vs_vac

-- creating a temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_people_vaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated

-- create view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

