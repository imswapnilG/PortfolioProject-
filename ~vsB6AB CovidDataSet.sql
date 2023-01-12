Select * 
From PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using 

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2 

--Looking at Total cases vs population
-- Shows % of population infected 
Select Location, date, Population, total_cases,(total_cases/Population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2 


-- Lookung at Counties with highest infection rate compared to ppulation 
Select Location, Population, MAX(total_cases ) as HighestInfectionCount, MAX((total_cases/Population))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
Group by Location, Population
order by InfectionPercentage desc

-- Showing countries with Highest death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by Location 
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BUY CONTINENT 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent 
order by TotalDeathCount desc

--Showing Continents with highest death count per population 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by Location 
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by date 
order by 1,2 

-- Global Data 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--Group by date 
order by 1,2 
--Looking at Total Population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
--,   (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--WE used CONVERT this does same function as Cast to change varchar 



--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
--,   (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollinngPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.Location Order by dea.location,
	dea.Date) as RollinngPeopleVaccinated
--,   (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollinngPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualisation

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.Location Order by dea.location,
	dea.Date) as RollinngPeopleVaccinated
--,   (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated