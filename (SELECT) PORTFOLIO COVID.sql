SELECT * FROM PortfolioCovid..CovidDeaths
ORDER BY 3,4

--SELECT * FROM PortfolioCovid..CovidVaccinations
--ORDER BY 3,4

--Select the data the we are going to be using

SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM PortfolioCovid..CovidDeaths
ORDER BY 1,2


--Looking Total Cases VS Total Deaths

--Shows prospect of Dying if you contract Covid in United State

SELECT Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 DeathsPercentage
FROM PortfolioCovid..CovidDeaths
WHERE Location Like '%state%'
ORDER BY 1,2

--Shows prospect of Dying if you contract Covid in Venezuela

SELECT Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 DeathsPercentage
FROM PortfolioCovid..CovidDeaths
WHERE Location Like '%Venezuela%'
ORDER BY 1,2

--Lookin the Total Cases Vs The Population

--Shows prospect of Infected Population for Covid in United State

SELECT Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 InfectedPopulation
FROM PortfolioCovid..CovidDeaths
WHERE Location Like '%state%'
ORDER BY 1,2

--Shows prospect of Infected Population for Covid in Venezuela

SELECT Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 InfectedPopulation
FROM PortfolioCovid..CovidDeaths
WHERE Location Like '%Venez%'
ORDER BY 1,2

--Looking at Countries with the Higthest Infection Rate Compared to Population


SELECT Location, Population, MAX(Total_Cases) HigthInfections, Max(Total_Cases/Population)*100 PercentageHigthestinfectionCount
FROM PortfolioCovid..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentageHigthestinfectionCount DESC

--Showing Countries with the higthest Death Count per Population


SELECT Location, MAX(Cast(Total_Deaths as int)) As TotalDeathscount
FROM PortfolioCovid..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathsCount DESC

--Showing Continents Death Count

SELECT Continent, MAX(Cast(Total_Deaths as int)) As TotalDeathscount
FROM PortfolioCovid..CovidDeaths
WHERE continent is not NULL
GROUP BY Continent
ORDER BY TotalDeathsCount DESC
-- this in not accurated

-- this is more accurate because the real number are in location
SELECT Location, MAX(Cast(Total_Deaths as int)) As TotalDeathscount
FROM PortfolioCovid..CovidDeaths
WHERE continent is NULL
GROUP BY Location
ORDER BY TotalDeathsCount DESC


--Global numbers

SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, 
SUM(total_deaths/total_cases)*100 As GlobalNumbers
FROM PortfolioCovid..CovidDeaths
WHERE continent is not NULL
GROUP BY Date
ORDER BY 1,2

--Looking Total Populations Vs Vacinations

SELECT Death.continent, death.location, death.date, death.population, Vacc.new_vaccinations,
SUM(CONVERT(Int, Vacc.new_vaccinations)) OVER (Partition By death.location ORDER BY death.location, 
death.date) As RollingPeopleVacinade 
--,(RollingPeopleVacinade/Vacc.population)*100 as porcentage
FROM PortfolioCovid..CovidDeaths as Death
Join PortfolioCovid..CovidVaccinations as Vacc
on Death.location = Vacc.location and
   Death.date = Vacc.date
WHERE Death.continent is not null
ORDER BY 1,2,3


--USE CTE
With PopVsVac (Continent, location, date, Population, new_vaccinations, RollingpeopleVaccinated) as (

SELECT Death.continent, death.location, death.date, death.population, Vacc.new_vaccinations,
SUM(CONVERT(Int, Vacc.new_vaccinations)) OVER (Partition By death.location ORDER BY death.location, 
death.date) As RollingPeopleVacinade 
--,(RollingPeopleVacinade/Vacc.population)*100 as porcentage
FROM PortfolioCovid..CovidDeaths as Death
Join PortfolioCovid..CovidVaccinations as Vacc
on Death.location = Vacc.location and
   Death.date = Vacc.date
WHERE Death.continent is not null
--ORDER BY 1,2,3
)

SELECT *, (RollingpeopleVaccinated/population)*100 as porcentage FROM PopVsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent VARCHAR (255),
Location VARCHAR (255),
Date DATETIME,
Population numeric,
New_Vaccionations numeric,
RollingPeopleVaccinated numeric

)

INSERT INTO #PercentPopulationVaccinated

SELECT Death.continent, death.location, death.date, death.population, Vacc.new_vaccinations,
SUM(CONVERT(Int, Vacc.new_vaccinations)) OVER (Partition By death.location ORDER BY death.location, 
death.date) As RollingPeopleVacinade 
--,(RollingPeopleVacinade/Vacc.population)*100 as porcentage
FROM PortfolioCovid..CovidDeaths as Death
Join PortfolioCovid..CovidVaccinations as Vacc
on Death.location = Vacc.location and
   Death.date = Vacc.date
--WHERE Death.continent is not null
--ORDER BY 1,2,3

SELECT *, (RollingpeopleVaccinated/population)*100 as porcentage FROM #PercentPopulationVaccinated

--Creating a view for store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as

SELECT Death.continent, death.location, death.date, death.population, Vacc.new_vaccinations,
SUM(CONVERT(Int, Vacc.new_vaccinations)) OVER (Partition By death.location ORDER BY death.location, 
death.date) As RollingPeopleVacinade 
--,(RollingPeopleVacinade/Vacc.population)*100 as porcentage
FROM PortfolioCovid..CovidDeaths as Death
Join PortfolioCovid..CovidVaccinations as Vacc
on Death.location = Vacc.location and
   Death.date = Vacc.date
WHERE Death.continent is not null
--ORDER BY 1,2,3

SELECT * FROM PercentPopulationVaccinated