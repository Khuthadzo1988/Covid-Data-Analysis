select *
from.[dbo].[Covid_Deaths 11]
ORDER BY 2 desc

---------------------------------------------------------------------------------------------------------------------------

--Total Cases vs Total Deaths for South Africa
select location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 as South_Africa_Death_Percentage
from.[dbo].[Covid_Deaths 11]
WHERE location like 'south africa'
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------------------------

--Total_Cases vs Population for South Africa
--percentage of population that got COVID
select location, date, total_cases, population, (total_cases*1.0/population)*100 as South_Africa_Percentage_Infected
from.[dbo].[Covid_Deaths 11]
WHERE location like 'south africa'
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------------------------

--Countries with highest infection rate compared to population

select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases*1.0/population))*100 as Percentage_of_Population_Infected
from.[dbo].[Covid_Deaths 11]
--WHERE location like '%africa'
GROUP BY location, population
ORDER BY 4 DESC

---------------------------------------------------------------------------------------------------------------------------

--South Africa increase in infection rate compared to population and date
select location, population, date, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases*1.0/population))*100 as Percentage_of_Population_Infected
from.[dbo].[Covid_Deaths 11]
WHERE location like '%south africa%'
GROUP BY location, population, date
ORDER BY 5 DESC

--South Africa total Death rate as compared to population 
select location, population, MAX(total_deaths) as Highest_Death_Count, MAX((total_deaths*1.0/population))*100 as Percentage_of_Population_killed
from.[dbo].[Covid_Deaths 11]
WHERE location like '%south africa%'
GROUP BY location, population
ORDER BY 3 DESC


---------------------------------------------------------------------------------------------------------------------------

--Continents with Highest Deaths per Population
select location, population, MAX(total_deaths) as Highest_Death_Count, MAX((total_deaths*1.0/population))*100 as Percentage_of_Population_killed
from.[dbo].[Covid_Deaths 11]
--WHERE location like '%africa'
where continent is NULL
GROUP BY location, population
ORDER BY 3 DESC

---------------------------------------------------------------------------------------------------------------------------

-- global Death rate by income status
select location, population, MAX(total_deaths) as Highest_Death_Count, MAX((total_deaths*1.0/population))*100 as Percentage_of_Population_killed
from.[dbo].[Covid_Deaths 11]
--WHERE location like '%africa'
where continent is NULL
and location not in ('world', 'Europe', 'North America', 'Asia', 'South America', 'European Union', 'Africa', 'Oceania')
GROUP BY location, population
ORDER BY 3 DESC

---------------------------------------------------------------------------------------------------------------------------

--Death rate by income status
select location, population, MAX(total_deaths) as Highest_Death_Count, MAX((total_deaths*1.0/population))*100 as Percentage_of_Population_killed
from.[dbo].[Covid_Deaths 11]
--WHERE location like '%africa'
where continent is NULL
and location not in ('world', 'Europe', 'North America', 'Asia', 'South America', 'European Union', 'Africa', 'Oceania')
GROUP BY location, population
ORDER BY 4 DESC

---------------------------------------------------------------------------------------------------------------------------

--Death rate by continent
select location, population, MAX(total_deaths) as Highest_Death_Count, MAX((total_deaths*1.0/population))*100 as Percentage_of_Population_killed
from.[dbo].[Covid_Deaths 11]
--WHERE location like '%africa'
where continent is NULL
and location in ('world', 'Europe', 'North America', 'Asia', 'South America', 'European Union', 'Africa', 'Oceania')
GROUP BY location, population
ORDER BY 4 DESC

---------------------------------------------------------------------------------------------------------------------------
-- using only the 'world' data from the continent column in the table to determine global fatility rate

select max(population) as Global_population
, max(total_cases) as Total_Global_Cases
, max(total_deaths) as Total_Global_Deaths
, max(total_deaths)*1.0/max(total_cases)*100 as Global_Covid_death_rate
, max(total_deaths)*1.0/max(population) as Percentage_of_global_population_dead
from.[dbo].[Covid_Deaths 11]


--Global Numbers (Total Death vs Total Cases) - Fatality_Rate
--Using cases and deaths by countries to determine global rates
--The rates are the same

SELECT SUM(CAST(Vac.new_cases as int)) as total_cases
, SUM(cast(vac.new_deaths as int)) as total_deaths,(SUM(cast
(vac.new_deaths as int)))*1.0/(SUM(CAST(Vac.new_cases as int)))*100 as Covid_Fatality_Rate
  FROM [master].[dbo].[Covid_Deaths 11] Dea
  JOIN [master].[dbo].[Covid_Vaccinations 11]  Vac
  ON Dea.location = Vac.[location]
  AND Dea.[date] = Vac.[date]
  where vac.continent is not NULL
  --GROUP by Vac.[date],Vac.[location]
  --order by Vac.[date]

---------------------------------------------------------------------------------------------------------------------------

--Population vs Vaccinations using two methods (CTE vs Temp Tables)

-- Method 1 (using CTE)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
   -- ,(Rolling_People_Vaccinated/population)*100
  FROM [master].[dbo].[Covid_Deaths 11] Dea
  JOIN [master].[dbo].[Covid_Vaccinations 11]  Vac
  ON Dea.location = Vac.[location]
  AND Dea.[date] = Vac.[date]
where vac.continent is not NULL
--GROUP by Vac.[date],Vac.[location]
order by 2,3

--CTE
with PopvsVac (continent,location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (
    partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
   -- ,(Rolling_People_Vaccinated/population)*100
  FROM [master].[dbo].[Covid_Deaths 11] Dea
  JOIN [master].[dbo].[Covid_Vaccinations 11]  Vac
  ON Dea.location = Vac.[location]
  AND Dea.[date] = Vac.[date]
where vac.continent is not NULL
--GROUP by Vac.[date],Vac.[location]
--order by 2,3
 )
select *, (Rolling_People_Vaccinated*1.0/population)*100 as Percentage_of_People_Vaccinated --run with CTE
from PopvsVac

--Method 2 (using Temp Table)

drop table if exists #Percentage_of_People_Vaccinated --include if you want to make alterations
create TABLE #Percentage_of_People_Vaccinated
(
continent NVARCHAR(255),
LOCATION NVARCHAR(255),
date datetime,
population NUMERIC,
new_vaccinations NUMERIC,
Rolling_People_Vaccinated NUMERIC
)

INSERT into #Percentage_of_People_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (
    partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
   -- ,(Rolling_People_Vaccinated/population)*100
  FROM [master].[dbo].[Covid_Deaths 11] Dea
  JOIN [master].[dbo].[Covid_Vaccinations 11]  Vac
  ON Dea.location = Vac.[location]
  AND Dea.[date] = Vac.[date]
  where vac.continent is not NULL
--GROUP by Vac.[date],Vac.[location]
--order by 2,3

select *, (Rolling_People_Vaccinated*1.0/population)*100 as Percentage_of_People_Vaccinated 
from #Percentage_of_People_Vaccinated

--Creating View to store data for later visulization

create view Percentage_of_People_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (
    partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
   -- ,(Rolling_People_Vaccinated/population)*100
  FROM [master].[dbo].[Covid_Deaths 11] Dea
  JOIN [master].[dbo].[Covid_Vaccinations 11]  Vac
  ON Dea.location = Vac.[location]
  AND Dea.[date] = Vac.[date]
  where vac.continent is not NULL
--GROUP by Vac.[date],Vac.[location]
--order by 2,3

---------------------------------------------------------------------------------------------------------------------------


