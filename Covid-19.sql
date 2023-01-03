SELECT * 
FROM CovidDeaths

-- Исправляем формат даты 

ALTER TABLE CovidDeaths
ADD normal_date INTEGER;

UPDATE CovidDeaths
SET normal_date = substr(date, -2) || '-' || substr(date, 4, 2) || '-' || substr(date, 1, 2)


-- Method to make virtual table with calculations
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, total_vaccinated)
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

-- TEMP TABLE to show I can create a new table with calculations
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
--ORDER BY 2, 3

SELECT *, (total_vaccinated/population)*100
FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
DROP Table if exists PercentPopulationVaccinated ;
CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.normal_date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.normal_date) as total_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null and dea.location like "%russia%"
-- ORDER BY 2, 3 ;
