-- 

Select normal_date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
(SUM(cast(new_deaths as real))/SUM(new_cases))*100 as DeathPersantage
From CovidDeaths
Where continent is not NULL
--Group by normal_date
Order by 1,2


-- 

Select continent, SUM(new_deaths) as total_deaths
From CovidDeaths
Where continent is not NULL
and location not in ('World', 'European Union', 'International')
Group by continent
Order by total_deaths desc


-- 

Select location, population, max(total_cases) as MaximumTotalCases,
Max((total_cases/population))*100 as PercentageInfected
From CovidDeaths
-- Where continent is not NULL
Group by location, population
Order by  PercentageInfected desc


-- 

Select location, population, date, normal_date, max(total_cases) as MaximumTotalCases,
Max((total_cases/population))*100 as PercentageInfected
From CovidDeaths
-- Where continent is not NULL
Group by location, population, normal_date
Order by  PercentageInfected  desc
