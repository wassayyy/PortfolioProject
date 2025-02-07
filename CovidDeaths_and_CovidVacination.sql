select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by location, date


-- Total cases vs total deaths location wise

select location,count(total_cases) as Total_Cases_reported, count(total_Deaths) as Total_Deaths_reported, (count(total_cases)-count(total_Deaths)) as people_survived
from CovidDeaths 
group by location
order by location


-- shows what percent of population got covid

select location,date,total_cases,population, ROUND((total_cases/population)*100,2) as Population_Percentage
from CovidDeaths
where location = 'Pakistan'


-- which country has highest infection case

select location, population, max(total_cases) as hightest_infected_count, 
max((total_cases/population))*100 as percentage_highest_infected
from CovidDeaths
group by location, population
order by percentage_highest_infected desc


-- showing country with highest count of death

select location, max(cast(total_deaths as int)) as total_deathcount
from CovidDeaths
where continent is not null
group by location
order by total_deathcount desc

-- showing continent with highest count of death

select continent, max(cast(total_deaths as int)) as total_deathcount
from CovidDeaths
where continent is not null
group by continent
order by total_deathcount desc



-- looking for total population and vacination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over(partition by dea.location order by dea.location , dea.date)
as rolling_people_vacinated
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3






-- looking for total population and vacination with percentage

with popvsvac (continent,location, date, population, new_vaccinations,rolling_people_vacinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over(partition by dea.location order by dea.location , dea.date)
as rolling_people_vacinated
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * , (rolling_people_vacinated/population)*100 as percentage_rolling_people_vacinated
from popvsvac