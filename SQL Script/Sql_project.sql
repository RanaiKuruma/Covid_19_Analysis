-- Exploring the data 

SELECT * FROM project.coviddeaths ORDER BY 3, 4;
-- SELECT * FROM project.covidvaccinations ORDER BY 3,4  
-- Select data that we will be using 
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population 
FROM project.coviddeaths
ORDER BY 
	location,
    date;

-- 1 Looking at the total cases vs total deaths and calculating its percentage 
-- Shows the likelihood of dying of COVID-19 in your country
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths,
	ROUND(100 * (total_deaths / total_cases),2) AS percentage
FROM project.coviddeaths
-- To search for a specific part of the string and using it for filtering purposes 
WHERE location like '%an%'
ORDER BY 
	location,
    date;

-- 2 Looking at the total cases vs population and calculating its percentage
SELECT 
	location, 
	date, 
	total_cases, 
	population,
	ROUND(100 * (total_cases / population),2) AS percentage
FROM project.coviddeaths
-- To search for a specific part of the string and using it for filtering purposes 
WHERE location like '%an%'
ORDER BY 
	location,
    date,
    percentage DESC;

-- 3 Looking at countries with Highest Infection Rate Compared to population 
SELECT 
	location,
    population,
    MAX(total_cases) AS highest_infection_count,
    100 * MAX((total_cases / population)) AS infection_percentage
FROM project.coviddeaths
GROUP BY location, population
ORDER BY infection_percentage DESC;

-- 4 Showing countries with Highest Death count per population 
SELECT 
	location,
    MAX(total_deaths) AS total_death_count  
FROM project.coviddeaths
GROUP BY location 
ORDER BY total_death_count DESC;

-- Breaking things down by continent
SELECT 
	continent,
    MAX(total_deaths) AS total_death_count
FROM project.coviddeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY total_death_count DESC;

-- 5 Showing the continent with the highest death count per population
SELECT 
	continent,
    MAX(total_deaths) AS total_death_count
FROM project.coviddeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY total_death_count DESC;

-- GLOBAL NUMBERS 
SELECT 
	date, 
	SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    ROUND(100 * SUM(new_deaths) / SUM(new_cases),2) AS death_percentage
FROM project.coviddeaths
-- To search for a specific part of the string and using it for filtering purposes 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 
	date,
    total_cases ;

-- Looking at Total Population vs Vaccinations 
WITH popvsvac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    -- CAST(vac.new_vaccinations AS DECIMAL) AS new_vaccinations,
    CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations, 
    SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM project.CovidDeaths AS dea 
INNER JOIN project.CovidVaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- ORDER BY 2,3
)
SELECT *
FROM popvsvac;

-- Creating view for later visualizations 
CREATE VIEW percent_population_vaccinated AS 
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(vac.new_vaccinations AS UNSIGNED) AS new_vaccinations, 
    SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM project.CovidDeaths AS dea 
INNER JOIN project.CovidVaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * 
FROM percent_population_vaccinated;