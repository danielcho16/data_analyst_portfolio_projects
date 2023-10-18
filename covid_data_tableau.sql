-- 1) total global death percentage
-- CREATE VIEW TotalGlobalDeathPercentage AS
SELECT MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths, MAX(total_deaths)/MAX(total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

-- 2) continents with the highest death count per population
-- CREATE VIEW DeathPercentageByContinent AS
SELECT continent, MAX(total_deaths) AS total_death_count, MAX(total_deaths/population)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
-- ORDER BY total_death_count DESC

-- 3) countries with highest infection rate compared to population
-- CREATE VIEW InfectionRateByPopulation AS
SELECT location, population, ISNULL(MAX(total_cases),0) AS highest_infection_count, ISNULL((MAX(total_cases/population)*100),0) AS population_percentage_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
-- ORDER BY population_percentage_infected DESC

-- 4) countries with highest infection rate compared to population by date
-- CREATE VIEW InfectionRateByDate AS
SELECT location, population, date, ISNULL(MAX(total_cases),0) AS highest_infection_count, ISNULL((MAX(total_cases/population)*100),0) AS population_percentage_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY population_percentage_infected DESC
