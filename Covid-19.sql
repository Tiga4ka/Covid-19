SELECT * 
FROM CovidDeaths
WHERE continent is not null 
order by 3, normal_date


-- Add a new column with fixed date format

ALTER TABLE CovidDeaths
ADD normal_date INTEGER;

UPDATE CovidDeaths
SET normal_date = substr(date, -2) || '-' || substr(date, 4, 2) || '-' || substr(date, 1, 2)


-- Select Data that we are going to be using 

Select Location, normal_date, total_cases, total_deaths, population
From CovidDeaths
Where continent is not NULL
order by 1,2


-- Case-fatality risk of Covid-19 

Select Location, normal_date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
Where continent is not NULL
order by 1,2


-- Total Confirmed Cases vs Population
-- Shows what percentage of population in Russia got Covid-19

Select Location, normal_date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From CovidDeaths
Where continent is not NULL
And location like "%russia%"
Order by 1,2


-- STATS BY COUNTRY
-- Looking at Countries with Highest Case Count per Population 

Select Location, normal_date, max(total_cases) as MaximumTotalCases, population, Max((total_cases/population))*100 as InfectedPercentage
From CovidDeaths
Where continent is not NULL
Group by Location
Order by 5 desc


-- Showing Countries with Highest Death Count per Population 

Select Location, normal_date, max(total_deaths) as MaximumTotalDeaths, population, Max((total_deaths/population))*100 as PercentageDied
From CovidDeaths
Where continent is not NULL
Group by Location
Order by 5 desc


-- STATS BY CONTINENT 

-- Showing continents with highest death count per population

Select Continent, normal_date, max(total_deaths) as MaximumTotalDeaths, population, Max((total_deaths/population))*100 as PercentageDied
From CovidDeaths
Where continent is not NULL
Group by Continent
Order by 5 desc


-- GLOBAL NUMBERS 
-- Using aggregate functions for calculations

Select normal_date, new_cases, SUM(new_cases) as total_cases, total_cases, SUM(new_deaths) as total_deaths, (SUM(cast(new_deaths as real))/SUM(new_cases))*100
From CovidDeaths
Where continent is not NULL
Group by normal_date
Order by 1


-- Looking at Total Population and Total Vaccinations

Select dea.location, dea.normal_date, dea.population, vac.total_vaccinations
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date 
Where dea.continent is not NULL


-- Calculating the percentage of people vaccinated in Russia using CTE

WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, total_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.normal_date, dea.population,
vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.normal_date) as total_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null and dea.location like "%russia%"
--ORDER BY 2, 3
)
SELECT *, (total_vaccinated/population)*100
FROM PopvsVac


-- Calculating the percentage of people vaccinated in Russia and adding it to a new table

DROP Table if exists PercentPopulationVaccinated ;
CREATE TABLE PercentPopulationVaccinated

(
Continent TEXT,
Location TEXT,
Date INTEGER,
Population REAL,
new_vaccinations REAL,
total_vaccinated REAL
) ;

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.normal_date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.normal_date) as total_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null and dea.location like "%russia%";


SELECT *, (total_vaccinated/population)*100
FROM PercentPopulationVaccinated
ORDER BY 3 ;


-- Creating a View to store data for later visualizations

DROP Table if exists PercentPopulationVaccinated ;

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.normal_date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.normal_date) as total_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null and dea.location like "%russia%";
