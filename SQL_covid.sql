SELECT * 
FROM [Project Portfolio]..CovidDeaths
ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Project Portfolio].dbo.CovidDeaths --FROM [Project Portfolio]..CovidDeaths --NẾU SỬ DỤNG .. THÌ KHÔNG CẦN THÊM TÊN CỦA CSDL
ORDER BY 1,2
--LOOKING AT TOTAL CASE VS TOTAL DEATHS
--Show likelyhood of dying if you look contract covid in your country: 
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
FROM [Project Portfolio].dbo.CovidDeaths 
WHERE [location] LIKE '%State%'
order by 1,2

--LOOKING AT TOTAL CASE VS POPULATION
--show what percentage of population got Covid
SELECT Location, date, population, total_cases, round((total_cases/population)*100,2) as PercentPopulationInfected
FROM [Project Portfolio].dbo.CovidDeaths 
WHERE [location] LIKE '%State%'
order by 1,2

--Looking at the country with the highest infection compared to poputlation
SELECT Location, population, MAX(total_cases) AS highest_infection_count, MAX(round((total_cases/population)*100,2)) as PercentPopulationInfected
FROM [Project Portfolio].dbo.CovidDeaths 
--WHERE [location] LIKE '%State%'
GROUP BY Location, population
order by PercentPopulationInfected desc

--Showing the country with the hightest the death_count: 
SELECT Location, MAX(CAST(total_deaths as int)) AS highest_death_count
FROM [Project Portfolio].dbo.CovidDeaths 
--WHERE [location] LIKE '%State%'
where [continent] is NOT NULL
GROUP BY Location
order by highest_death_count desc

--Lets break thing down by continent
--showing continent with the highest death_count
SELECT continent, MAX(CAST(total_deaths as int)) AS highest_death_count
FROM [Project Portfolio].dbo.CovidDeaths 
--WHERE [location] LIKE '%State%'
where [continent] is NOT NULL
GROUP BY continent
order by highest_death_count desc

--Global Numbers
SELECT Location, date, population, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
FROM [Project Portfolio].dbo.CovidDeaths 
--WHERE [location] LIKE '%State%'
where continent is not null
order by 1,2

--1. 
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as INT)) as total_deaths, 
        round(sum(cast(new_deaths as INT))/sum(new_cases)*100,2) as DeathPercentage
FROM [Project Portfolio].dbo.CovidDeaths 
--WHERE [location] LIKE '%State%'
where continent is not null
order by 1,2

--2. Total cases: 
SELECT location, SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM [Project Portfolio].dbo.CovidDeaths 
--WHERE [location] LIKE '%State%'
where continent is null
and location not in ('World', 'European Union', 'International')
GROUP BY location
order by TotalDeathCount
--group by date 


--3. 
--Looking at the country with the highest infection compared to poputlation
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(round((total_cases/population)*100,2)) as PercentPopulationInfected
FROM [Project Portfolio].dbo.CovidDeaths 
--WHERE [location] LIKE '%State%'
GROUP BY Location, population
order by PercentPopulationInfected desc

--4
SELECT Location, population,date, MAX(total_cases) AS HighestInfectionCount, MAX(round((total_cases/population)*100,2)) as PercentPopulationInfected
FROM [Project Portfolio].dbo.CovidDeaths 
--WHERE [location] LIKE '%State%'
GROUP BY Location, population, date
order by PercentPopulationInfected desc

-- Join two tables
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
FROM [Project Portfolio].dbo.CovidDeaths dea
JOIN [Project Portfolio]..CovidVaccinations vac
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.date 
WHERE dea.continent is not null 
    and vac.new_vaccinations is not null
order by 1,2,3

--looking for sum of new vaccinations by location
WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS
(
    SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
    ,sum(convert(int,vac.new_vaccinations)) 
    OVER (PARTITION BY dea.LOCATION ORDER BY dea.Location, dea.date) as rollingpeoplevaccinated
FROM [Project Portfolio].dbo.CovidDeaths dea
JOIN [Project Portfolio]..CovidVaccinations vac
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.date 
WHERE dea.continent is not null 
    and vac.new_vaccinations is not null
--order by 1,2,3
)

SELECT *, (rollingpeoplevaccinated/population)
FROM PopvsVac

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    DATE DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingpeoplevaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated    
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
    ,sum(convert(int,vac.new_vaccinations)) 
    OVER (PARTITION BY dea.LOCATION ORDER BY dea.Location, dea.date) as rollingpeoplevaccinated
FROM [Project Portfolio].dbo.CovidDeaths dea
JOIN [Project Portfolio]..CovidVaccinations vac
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.date 
WHERE dea.continent is not null 
    and vac.new_vaccinations is not null
--order by 1,2,3

--Creating view to store data for data visualization

CREATE VIEW PercentofPopulationVaccinated  as
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
    ,sum(convert(int,vac.new_vaccinations)) 
    OVER (PARTITION BY dea.LOCATION ORDER BY dea.Location, dea.date) as rollingpeoplevaccinated
FROM [Project Portfolio].dbo.CovidDeaths dea
JOIN [Project Portfolio]..CovidVaccinations vac
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.date 
WHERE dea.continent is not null 
--order by 1,2,3