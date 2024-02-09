SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Show likelihood of dying if you conract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths * 100.0 / total_cases) death_rate
FROM PortfolioProject..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows wha percenage of population got covid

SELECT location, date, total_cases, population, (total_deaths * 100.0 / population) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, population, max(total_cases) as HighestInfectionCount, max(total_cases * 100.0 / population) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
--WHERE location like '%state%'
ORDER BY PercentPopulationInfected desc

--Showing Countries wih Highest Death Count per Population

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
--WHERE location like '%state%'
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS BY CONTINENT

--SHOWING continent with the highest death count  per population

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
--WHERE location like '%state%'
ORDER BY TotalDeathCount desc



--Global number
SELECT	--date,
		sum(new_cases) as total_cases,
		sum(cast(new_deaths as int)) total_deaths,
		sum(cast(new_deaths as int)) * 100.0 /sum(new_cases) as DeadPercentage
FROM	PortfolioProject..CovidDeaths
WHERE	continent is not null AND
		new_deaths is not null AND
		new_deaths != 0
--GROUP BY date
ORDER BY 1,2





--Vaccination
-- use CTE
WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinaions, RollingPeopleVaccinated)
AS(
	SELECT		dea.continent, dea.location, dea.date, dea.population,
				vac.new_vaccinations,
				sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
				--RollingPeopleVaccinated * 100.0 / dea.population
	FROM		PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
	ON			dea.location = vac.location AND	
				dea.date = vac.date
	WHERE		dea.continent is not null AND
				vac.new_vaccinations is not null
	--ORDER BY	2,3
)
SELECT	*,
		RollingPeopleVaccinated * 100.0 / Population
FROM	PopvsVac





--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated(
	Continent					NVARCHAR(255),
	Location					NVARCHAR(255),
	Date						DATETIME,
	Population					NUMERIC,
	New_Vaccinations			NUMERIC,
	RollingPeopleVaccinated		NUMERIC
)

INSERT INTO #PercentPopulationVaccinated

SELECT		dea.continent, dea.location, dea.date, dea.population,
			vac.new_vaccinations,
			sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
			--RollingPeopleVaccinated * 100.0 / dea.population

FROM		PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac

ON			dea.location = vac.location AND	
			dea.date = vac.date

--WHERE		dea.continent is not null AND
--			vac.new_vaccinations is not null

--ORDER BY	2,3

SELECT	*,
		RollingPeopleVaccinated * 100.0 / Population
FROM	#PercentPopulationVaccinated




use PortfolioProject
--Create View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as

SELECT		dea.continent, dea.location, dea.date, dea.population,
			vac.new_vaccinations,
			sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
			--RollingPeopleVaccinated * 100.0 / dea.population

FROM		PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac

ON			dea.location = vac.location AND	
			dea.date = vac.date

WHERE		dea.continent is not null AND
			vac.new_vaccinations is not null

--ORDER BY	2,3

SELECT	*
FROM	PercentPopulationVaccinated