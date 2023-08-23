SELECT *
FROM PortfolioProject1..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject1..CovidVaccinations 
--ORDER BY 3,4

--SELECT Data to use 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

--Total Cases vs. Total Deaths and likelihood of death
SELECT Location, date, total_cases, total_deaths, CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

--Total Cases vs. Population and likelihood of death EX. United States 
SELECT Location, date, total_cases, Population, CAST(total_cases AS float)/CAST(population AS float)* 100 AS CovidPercentage
FROM PortfolioProject1..CovidDeaths 
WHERE Location LIKE '%states'
ORDER BY 1,2

--Country with highest infection rate in regards to population
SELECT Location, Population, MAX(total_cases) AS Highest_cases, MAX(total_cases/population)*100 AS Percent_Population_Cases
FROM PortfolioProject1..CovidDeaths
GROUP BY Location, Population
ORDER BY Percent_Population_Cases

--Country with the highest mortality rates per population
SELECT Location, Population, MAX(total_deaths) AS Highest_deaths, MAX(total_deaths/population)*100 AS Percent_Deaths
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY Percent_Deaths DESC

--Country with highest death count per population
SELECT Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Viewing global numbers
SELECT date, SUM(new_cases) AS total_newcases, SUM(CAST(new_deaths as int)) as total_newdeaths
FROM PortfolioProject1..CovidDeaths
GROUP BY date
ORDER BY 1,2 

--Total population vs. Total vaccinations
 SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
 SUM(CAST(vax.new_vaccinations AS float)) OVER (Partition by death.location ORDER BY death.location, death.date) AS Rolling_vaccinations
 FROM PortfolioProject1..CovidDeaths death
 JOIN PortfolioProject1..CovidVaccinations vax
 ON death.location = vax.location
 AND death.date = vax.date
 WHERE death.continent IS NOT NULL
 ORDER BY 2,3

--CTE Population vs. Vaccinations
WITH POPvsVAX (continent, location, date, population, new_vaccinations, Rolling_vaccinations) AS
(
 SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
 SUM(CAST(vax.new_vaccinations AS float)) OVER (Partition by death.location ORDER BY death.location, death.date) AS Rolling_vaccinations
 FROM PortfolioProject1..CovidDeaths death
 JOIN PortfolioProject1..CovidVaccinations vax
 ON death.location = vax.location
 AND death.date = vax.date
 WHERE death.continent IS NOT NULL
 )
 SELECT *, (Rolling_vaccinations/population)*100 as Vaccinated_Population
 FROM POPvsVAX

 --View to store data for visualizations
 CREATE VIEW POPvsVAX as
  SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
 SUM(CAST(vax.new_vaccinations AS float)) OVER (Partition by death.location ORDER BY death.location, death.date) AS Rolling_vaccinations
 FROM PortfolioProject1..CovidDeaths death
 JOIN PortfolioProject1..CovidVaccinations vax
 ON death.location = vax.location
 AND death.date = vax.date
 WHERE death.continent IS NOT NULL

 SELECT * 
 FROM POPvsVAX
 