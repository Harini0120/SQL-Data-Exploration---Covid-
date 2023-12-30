Select *
From SQL_Exploration..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From SQL_Exploration..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, 
CASE
        WHEN total_cases = 0 THEN NULL
        ELSE (CAST(total_deaths AS float) / NULLIF(CAST(total_cases AS float), 0)) * 100
    END as DeathPercentage
From SQL_Exploration..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases, 
CASE
        WHEN total_cases = 0 THEN NULL
        ELSE (CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0)) * 100
    END as PercentPopulationInfected
From SQL_Exploration..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,
    CASE
        WHEN MAX(total_cases) = 0 THEN NULL
        ELSE MAX(CAST(total_cases AS float) / NULLIF(CAST(Population AS float), 0)) * 100
    END AS PercentPopulationInfected
FROM SQL_Exploration..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;



-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From SQL_Exploration..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From SQL_Exploration..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT
    SUM(CAST(new_cases AS int)) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    CASE
        WHEN SUM(CAST(new_cases AS int)) = 0 THEN NULL
        ELSE (SUM(CAST(new_deaths AS int)) / SUM(CAST(new_cases AS int))) * 100
    END AS DeathPercentage
FROM
    SQL_Exploration..CovidDeaths
WHERE
    continent IS NOT NULL
--GROUP BY
--    date  -- If you want to group by date, uncomment this line
ORDER BY
    1, 2;




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQL_Exploration..CovidDeaths dea
Join SQL_Exploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
    FROM
        SQL_Exploration..CovidDeaths dea
    JOIN
        SQL_Exploration..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100
FROM
    PopvsVac;






Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQL_Exploration..CovidDeaths dea
Join SQL_Exploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

