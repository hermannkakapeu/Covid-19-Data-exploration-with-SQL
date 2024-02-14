/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from CovidDeath
where continent is not null
order by 3,4

select location, date, new_cases, total_cases, total_deaths, population
from CovidDeath
order by 1,2

-- Total deaths vs total Cases in Cote d'Ivoire

Select Location, 
       date, 
	   total_cases,
	   total_deaths, 
	   (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeath
Where location like '%oire%'
               and continent is not null 
order by 1,2

-- Total Cases vs Population in Cote d'Ivoire

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeath
--Where location like '%oire%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeath
--Where location like '%voire%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
--Where location like '%voire%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
--where location like '%voire%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeath
Where location like '%voire%'
and continent is not null and New_Cases<>0
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select*
from CovidDeath
--from Covid Vaccinations

select cd.continent, cd.location, cd.population, cv.new_vaccinations,
	   sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as VaccinatedByLocations
from CovidDeath as cd join CovidVaccinations as cv
	 on cd.location = cv.location and 
	    cd.date = cv.date
where cd.location like'%voire%'
order by 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

with VaccByLoc as 
(
select cd.continent, cd.location, cd.population, cv.new_vaccinations,
	   sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as VaccinatedByLocations
from CovidDeath as cd join CovidVaccinations as cv
	 on cd.location = cv.location and 
	    cd.date = cv.date
where cd.location like'%%' and  cd.continent is not null
--order by 2, 3
)

select *, (VaccinatedByLocations/VaccByLoc.population)*100 as percentageVacc
from VaccByLoc
order by 2, 3


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #VaccByLoc
create table #VaccByLoc(
continent varchar(50),
location varchar(50),
population int,
new_vaccinations int,
vaccByLocation int
)

insert into #VaccByLoc
select cd.continent, cd.location, cd.population, cv.new_vaccinations,
	   sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as VaccinatedByLocations
from CovidDeath as cd join CovidVaccinations as cv
	 on cd.location = cv.location and 
	    cd.date = cv.date
where cd.location like'%%' and  cd.continent is not null
--order by 2, 3

select* from #VaccByLoc

select *, (vaccByLocation/#VaccByLoc.population)*100 as percentageVacc
from #VaccByLoc
order by 2, 3


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 





