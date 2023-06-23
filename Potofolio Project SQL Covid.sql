Select *
from PortofolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--from PortofolioProject..CovidVaccinations
--order by 3,4

--Pilih data yang akan digunakan

Select Location, date, total_cases, New_cases, total_deaths, population
from PortofolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Total Cases Vs Total Deaths (Kemungkinan Mati jika terlutar)

Select Location, date, total_cases as int, total_deaths, (total_deaths/cast(total_cases as int))*100 
from PortofolioProject..CovidDeaths
Where Location like '%indo%'
and continent is not null
order by 1,2

-- Total Cases Vs Pupulation

Select Location, date, Population, total_cases, (total_cases/Population)*100 as InfectionRate
from PortofolioProject..CovidDeaths
--Where Location like '%indo%'
Where continent is not null
order by 1,2

--Mencari yang tertinggi InfectionRate nya

Select Location, Population, MAX(cast(total_cases as int)) as HighestInfectionCount, Max((cast(total_cases as int)/Population)) as PercentPopulationInfected
from PortofolioProject..CovidDeaths
--Where Location like '%indo%'
Group by Location, Population
order by PercentPopulationInfected desc

--Negara berdasarkan total kematian tertinggi

Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
--Where Location like '%indo%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Kategori berdasarkan Continent (benua)
--Benua dengan highest death count per population

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
--Where Location like '%indo%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
--Where Location like '%indo%'
Where continent is not null 
--Group by date
order by 1,2


--Mengetahui total populasi vs vaccinastion

With PopvsVac (Contitent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated