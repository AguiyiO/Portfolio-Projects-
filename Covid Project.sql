SELECT location,[date],[total_cases],[new_cases],[total_deaths],[population]
FROM CovidDeaths
Order BY 1,2

--Total Cases vs Total Deaths

SELECT location,[date],[total_cases],[total_deaths],(total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%States%'
Order BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX([total_cases]) AS 'Highest Infection Count',MAX(total_cases/population)*100 '% of Population'
FROM CovidDeaths
GROUP BY location, population 
Order BY 4 desc;
GO

--Countries with Highest Death Count per Population

SELECT location, MAX(CAST([total_deaths]AS int)) AS 'Total Death Count'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
Order By 2 desc
GO


-- Continents with the highest death count per population

SELECT location, MAX(CAST([total_deaths]AS int)) AS 'Total Death Count'
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
Order By 2 desc
GO

--GLOBAL NUMBERS 

SELECT SUM([total_cases])as 'Total cases',SUM(CAST(new_deaths AS int)) as 'Total deaths',SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 'Death Percentage'
FROM CovidDeaths
WHERE continent is not null
Order BY 1,2

--Total Population vs Vaccinations 

SELECT c.continent, c.location, c.date, c.population,v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS int)) OVER (Partition by c.location Order by c.location, c.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as c
JOIN CovidVaccinations as v
ON c.location = v.location
AND c.date = v.date
WHERE c.continent is not null
Order by 2,3


-- CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT c.continent, c.location, c.date, c.population,v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS int)) OVER (Partition by c.location Order by c.location, c.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as c
JOIN CovidVaccinations as v
ON c.location = v.location
AND c.date = v.date
WHERE c.continent is not null
) 

SELECT*,RollingPeopleVaccinated
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent NVARCHAR (200),
Location NVARCHAR (200),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC)

INSERT INTO #PercentPopulationVaccinated
SELECT c.continent, c.location, c.date, c.population,v.new_vaccinations,
SUM(CONVERT(INT, v.new_vaccinations)) OVER (Partition by c.location Order by c.location, c.date) as RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] as c
JOIN [dbo].[CovidVaccinations] as v
ON c.location = v.location
AND c.date = v.date

SELECT*,(RollingPeopleVaccinated/Population)*100 AS '% of Population Vaccinated'
FROM #PercentPopulationVaccinated


--View
Create View PercentPopulationVaccinated AS
SELECT c.continent, c.location, c.date, c.population,v.new_vaccinations,
SUM(CONVERT(INT, v.new_vaccinations)) OVER (Partition by c.location Order by c.location, c.date) as RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] as c
JOIN [dbo].[CovidVaccinations] as v
ON c.location = v.location
AND c.date = v.date
WHERE c.continent IS NOT NULL


--Querying from created view
SELECT*
FROM PercentPopulationVaccinated






