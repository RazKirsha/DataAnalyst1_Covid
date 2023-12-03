/*
SELECT *
FROM CovidDeaths

SELECT *
FROM CovidVaccinations
*/

-- SELECT THE DATA THAT WE ARE GOING TO BE USING

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at total cases VS. total deaths
--Shows likelihood of dying if you contract COVID in Israel

SELECT Location, date, total_cases, total_deaths, ((CAST(total_deaths AS FLOAT)) / (CAST(total_cases AS FLOAT)))*100 AS 'Deaths Precentage'
FROM CovidDeaths
WHERE location like '%Israel%'
ORDER BY 1,2

--Looking at Total Cases VS. Population
-- Shows what precentage of population got COVID

SELECT Location, date, population, total_cases, ((CAST(total_cases AS FLOAT)) / (CAST(population AS FLOAT)))*100 AS 'COVID Precentage'
FROM CovidDeaths
WHERE location like '%Israel%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS FLOAT)) / (CAST(population AS FLOAT)))*100 AS 'Precent Population Infected'
FROM CovidDeaths
GROUP BY location, population
--WHERE location like '%Israel%'
ORDER BY 'Precent Population Infected' DESC

-- Showing countries with highest death count per population

SELECT Location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent is null and location in (SELECT DISTINCT continent
FROM CovidDeaths)
GROUP BY location
ORDER BY HighestDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(CAST(new_cases AS INT)) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, ((SUM(CAST(new_deaths AS FLOAT))) / (SUM(CAST(new_cases AS FLOAT))))*100 AS 'Deaths Precentage'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING (SUM(CAST(new_cases AS FLOAT))) != 0
ORDER BY date

SELECT SUM(CAST(new_cases AS INT)) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, ((SUM(CAST(new_deaths AS FLOAT))) / (SUM(CAST(new_cases AS FLOAT))))*100 AS 'Deaths Precentage'
FROM CovidDeaths
WHERE continent IS NOT NULL


-- Looking at total population VS. vaccinations

SELECT *
FROM CovidDeaths as DEA
JOIN CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, ISNULL(VAC.new_vaccinations,0) AS new_vaccinations,
	SUM(CAST(new_vaccinations AS FLOAT)) OVER (PARTITION BY DEA.location ORDER BY DEA.date) AS RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as DEA
JOIN CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

-- USE VIEW (temp taple)

CREATE VIEW PopVSVac AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, ISNULL(VAC.new_vaccinations,0) AS new_vaccinations,
	SUM(CAST(new_vaccinations AS FLOAT)) OVER (PARTITION BY DEA.location ORDER BY DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths as DEA
JOIN CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS '%Vacc'
FROM PopVSVac
ORDER BY 2,3

