SELECT
	LOCATION,
	population,
	MAX(total_cases) AS HighestCaseCount,
	MAX((total_cases / population)) * 100 AS PercentPopulInfected
FROM
	CovidDeaths WHERE location like '%indo%'
GROUP BY
	LOCATION,
	population
ORDER BY
	PercentPopulInfected DESC
	
--Total Death Count each Contry in Continent
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent IN ('Oceania', 'Europe', 'North America', 'South America', 'Africa', 'Asia')
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC

Select location, continent, MAX (cast (Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Group by LOCATION, continent
order by TotalDeathCount desc

--Total Death Count for Each Continent
SELECT location, MAX (cast (Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent = ''
GROUP by location
order by TotalDeathCount desc

--Global Accumulation Each Day
Select date, SUM(new_cases) AS TotalCase, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IN ('Oceania', 'Europe', 'North America', 'South America', 'Africa', 'Asia')
Group By date
order by 1

--Total Popul vs Vax
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY CONVERT(varchar(10), dea.location), dea.date) AS VaxCumSum
FROM CovidDeaths dea JOIN CovidVax vax
ON dea.location = vax.location AND dea.date = vax.date
WHERE dea.continent IN ('Oceania', 'Europe', 'North America', 'South America', 'Africa', 'Asia')
ORDER BY 2,3

--CTE
WITH PopVsVax(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY CONVERT(varchar(10), dea.location), dea.date) AS VaxCumSum
FROM CovidDeaths dea JOIN CovidVax vax
ON dea.location = vax.location AND dea.date = vax.date
WHERE dea.continent IN ('Oceania', 'Europe', 'North America', 'South America', 'Africa', 'Asia')
)
SELECT*, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM PopVsVax

--Temp Table
DROP TABLE IF EXISTS PopVsVaxx
CREATE TABLE PopVsVaxx(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PopVsVaxx
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY CONVERT(varchar(10), dea.location), dea.date) AS VaxCumSum
FROM CovidDeaths dea JOIN CovidVax vax
ON dea.location = vax.location AND dea.date = vax.date
WHERE dea.continent IN ('Oceania', 'Europe', 'North America', 'South America', 'Africa', 'Asia')


SELECT*, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM PopVsVaxx

--Create View
CREATE VIEW PeopleVaccinatedPercentage AS
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY CONVERT(varchar(10), dea.location), dea.date) AS VaxCumSum
FROM CovidDeaths dea JOIN CovidVax vax
ON dea.location = vax.location AND dea.date = vax.date
WHERE dea.continent IN ('Oceania', 'Europe', 'North America', 'South America', 'Africa', 'Asia')
