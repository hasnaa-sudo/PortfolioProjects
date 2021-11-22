--View both tables
select *
from PortfolioProject..CovidDeath
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

--select our data we're going to be using
select location, date, population, total_cases, new_cases,total_deaths, new_deaths
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2

--looking at death percentage
select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percent
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2

--shows the probability of dying if you contract covid in Bahrain

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percent
from PortfolioProject..CovidDeath
where location = 'Bahrain'
order by 2 desc

--looking at recent covid cases percentage in Bahrain

select location, date, population, total_cases, (total_cases/population)*100 as total_cases_percent
from PortfolioProject..CovidDeath
where location = 'Bahrain'
order by 2 desc

--looking at country with highest infection rate compare to population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as total_cases_percent
from PortfolioProject..CovidDeath
where continent is not null
group by location, population
order by 4 desc


--looking at country with highest death count compare to population
select location,max(cast (total_deaths as bigint)) as total_death_count
from PortfolioProject..CovidDeath
where continent is not null
group by location
order by 2 desc

--lets beak things down by continent
select location,max(cast (total_deaths as bigint)) as total_death_count
from PortfolioProject..CovidDeath
where continent is null
group by location
order by 2 desc

--global numbers
select sum(new_cases) as total_cases_globally, sum(cast(new_deaths as bigint)) as total_death_glubally, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as Death_percent
from PortfolioProject..CovidDeath
where continent is not null
--group by date
--order by 


-- looking at total population vs vaccinations
select deaths.continent,deaths.location,deaths.date,deaths.population,
 vaccinations.people_fully_vaccinated
from PortfolioProject..CovidDeath deaths
inner join PortfolioProject..CovidVaccinations vaccinations 
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
order by 1,2,3 desc

--looking at total population vs vaccinations
select deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,
 sum(cast(vaccinations.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeath deaths
inner join PortfolioProject..CovidVaccinations vaccinations 
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
order by 2,3



--use CTE

with pop_vs_vac (continent,location,data,population,new_vaccinations,rolling_people_vaccinated )
as
(select deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,
 sum(cast(vaccinations.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeath deaths
inner join PortfolioProject..CovidVaccinations vaccinations 
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null)
--order by 2,3),
select *,(rolling_people_vaccinated/population)*100 as people_vaccinated_percent
from pop_vs_vac



--temp table
drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated (continent nvarchar(255),
location nvarchar(255),
data datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric) 
insert into #percent_population_vaccinated
select deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,
 sum(cast(vaccinations.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeath deaths
inner join PortfolioProject..CovidVaccinations vaccinations 
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
--where deaths.continent is not null
--order by 2,3),
select *,(rolling_people_vaccinated/population)*100 as people_vaccinated_percent
from #percent_population_vaccinated

--creat view to store data for later viz
create View percent_population_vaccinated as select deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,
 sum(cast(vaccinations.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeath deaths
inner join PortfolioProject..CovidVaccinations vaccinations 
on deaths.location = vaccinations.location
and deaths.date = vaccinations.date
where deaths.continent is not null
--order by 2,3)

select * 
from percent_population_vaccinated











