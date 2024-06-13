SELECT *
FROM PortfolioProject1.dbo.CovidDeaths;


--SELECT *
--FROM PortfolioProject1..CovidVaccinations;

--Select data we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) * 100 as DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 1,2; 

--Looking at Total Cases Vs. Total Deaths
--Shows likelihood of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) * 100 as DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2; 

--Looking at Total Cases Vs. Population
--Shows what percentage of population got covid
SELECT location, date, population, total_cases, (cast(total_cases as float)/cast(population as float)) * 100 as PercentPopulationInfected
FROM PortfolioProject1.dbo.CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2; 

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float))) * 100 as PercentPopulationInfected
FROM PortfolioProject1.dbo.CovidDeaths
--WHERE location LIKE '%India%'
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC; 

--Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount DESC; 

--Global numbers(error)
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ISNULL(SUM (cast(new_deaths as int)), '') / ISNULL(SUM(new_cases), '') * 100 as DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is not NULL 
--GROUP BY date
ORDER BY 1,2; 


--Joining the two tables
SELECT *
FROM PortfolioProject1.dbo.CovidDeaths dea
  JOIN PortfolioProject1.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date


--Looking at total population vs vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
(SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths dea
  JOIN PortfolioProject1.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not NULL
  ORDER BY 2,3;

--Using convert
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths dea
  JOIN PortfolioProject1.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not NULL
  ORDER BY 2,3;

--Number of people vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations))  OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/ population) *100 
 FROM PortfolioProject1.dbo.CovidDeaths dea
  JOIN PortfolioProject1.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not NULL
  ORDER BY 2,3;

--Using CTEs
WITH PopVsVac (Continent, Location, Date, Population,new_vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric))  OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/ population) *100 
 FROM PortfolioProject1.dbo.CovidDeaths dea
  JOIN PortfolioProject1.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not NULL
  --ORDER BY 2,3
  )

  SELECT *
  FROM PopVsVac;




WITH PopVsVac (Continent, Location, Date, Population,new_vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric))  OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/ population) *100 
 FROM PortfolioProject1.dbo.CovidDeaths dea
  JOIN PortfolioProject1.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not NULL
  --ORDER BY 2,3
  )

  SELECT *, (RollingPeopleVaccinated / Population) * 100
  FROM PopVsVac;


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into   #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric))  OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/ population) *100 
 FROM PortfolioProject1.dbo.CovidDeaths dea
  JOIN PortfolioProject1.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  --WHERE dea.continent is not NULL
  --ORDER BY 2,3

    SELECT *, (RollingPeopleVaccinated / Population) * 100
  FROM #PercentPopulationVaccinated;


--Creating view to store data for later visualizations
CREATE VIEW 
Vaccinated_Population  as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/ population) *100 
 FROM PortfolioProject1.dbo.CovidDeaths dea
  JOIN PortfolioProject1.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not NULL
  --ORDER BY 2,3
  )
  SELECT * 
  FROM PercentPopulationVaccinated;


