-- select *
-- from PortfolioProject.covidvaccinations
-- order by 3, 4;

/*
Changing date format to fit the mysql format:

alter table coviddeaths
add column new_date DATE;

alter table coviddeaths
add index idx_date(date(50));

update coviddeaths
set new_date = str_to_date(date, '%d/%m/%Y')
where date is not null;

alter table coviddeaths
drop column date;

alter table coviddeaths
rename column new_date to date;
*/

-- Select the data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.coviddeaths
where location = 'India'
order by 1, 2; -- Sort by location and date


-- Looking at Total Cases vs Total Deaths 
-- Basically calculates likelihood of death if one gets infected
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from PortfolioProject.coviddeaths
-- where location = 'India' -- checking specific locations
order by 1, 2;


-- Looking at Total Cases vs Population
-- Showing percentage of population that has been infected
select location, date, total_cases, population, (total_cases/population)*100 CasesPercentage
from PortfolioProject.coviddeaths
-- where location = 'India'
order by 1, 2;



-- Looking at countries with highest infection rate compared to population
select location, population, max(cast(total_cases as unsigned)) HighestInfectionCount, max(cast(total_cases as unsigned)/population)*100 PercentPopulationInfected
from PortfolioProject.coviddeaths
where continent <> '' -- basically to exclude the continents and the "world" and the "income groups", so that we can look at countries
group by population, location
order by 4 desc;




-- Showing the countries with highest death count per Population
select location, max(cast(total_deaths as unsigned)) HighestDeathCount
from PortfolioProject.coviddeaths
where continent <> ''
group by population, location
order by 2 desc;


-- Breaking things down by Continent
-- Showing the continents with the highest death count per population
select continent, max(cast(total_deaths as unsigned)) HighestDeathCount
from PortfolioProject.coviddeaths
where continent <> ''
group by continent
order by 2 desc;



-- Global Numbers

-- Total cases vs Total deaths per day
select date, sum(new_cases) TotalCases, sum(new_deaths) TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 DeathPercentage
from PortfolioProject.coviddeaths
where continent <> ''
group by date
order by 1, 2;

-- Total cases vs Total deaths
select sum(new_cases) TotalCases, sum(new_deaths) TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 DeathPercentage
from PortfolioProject.coviddeaths
where continent <> ''
order by 1, 2;


/*Adding Covid Vaccinations Table to what we are working with*/


/*
Changing date format to fit the mysql format:

alter table covidvaccinations
add column new_date DATE;

alter table covidvaccinations
add index idx_date(date(50));

update covidvaccinations
set new_date = str_to_date(date, '%d/%m/%Y')
where date is not null;

alter table covidvaccinations
drop column date;

alter table covidvaccinations
rename column new_date to date;
*/
select location, date, new_vaccinations
from covidvaccinations
order by 1, 2;

-- Looking at total population vs vaccinations

-- Having the number of new vaccinations as a rolling count
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) over (partition by dea.location order by dea.location, dea.date) RollingNumberOfVaccinations
from PortfolioProject.coviddeaths dea
join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> ''
order by 2, 3;


-- Using CTEs and calculating percentage of vaccinations per population on a rolling basis
with pop_vs_vac(continent, location, date, population, new_vaccinations, rolling_number_of_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as unsigned),
sum(cast(vac.new_vaccinations as unsigned)) over (partition by dea.location order by dea.location, dea.date) rolling_number_of_vaccinations
from PortfolioProject.coviddeaths dea
join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> ''
)
select *, (rolling_number_of_vaccinations/population)*100 percentage_of_vaccinations_per_population
from pop_vs_vac;


-- Using Temp table and calculating percentage of vaccinations per population on a rolling basis

drop table if exists percent_vaccinations_per_population;
create temporary table percent_vaccinations_per_population(
continent text,
location text,
date date,
population bigint,
new_vaccinations int,
rolling_number_of_vaccinations int
);

insert into percent_vaccinations_per_population
select dea.continent, dea.location, dea.date, dea.population, cast(coalesce(nullif(vac.new_vaccinations, ''), '0') as unsigned),
sum(cast(coalesce(nullif(vac.new_vaccinations, ''), '0') as unsigned)) over (partition by dea.location order by dea.location, dea.date) rolling_number_of_vaccinations
from PortfolioProject.coviddeaths dea
join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> '';

select *, (rolling_number_of_vaccinations/population)*100 percentage_of_vaccinations_per_population
from percent_vaccinations_per_population;


-- Creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, cast(coalesce(nullif(vac.new_vaccinations, ''), '0') as unsigned),
sum(cast(coalesce(nullif(vac.new_vaccinations, ''), '0') as unsigned)) over (partition by dea.location order by dea.location, dea.date) rolling_number_of_vaccinations
from PortfolioProject.coviddeaths dea
join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> '';


/*Some more exploration*/

-- Exploring ICU patients in countries over the world since 2020:

-- Calculating percentage of ICU patients from total COVID cases in the world every day
-- This should provide insight into when COVID strains were relatively more/less dangerous
select date, sum(new_cases), sum(icu_patients), (sum(icu_patients)/sum(new_cases))*100 percentage_of_icu_patients_for_new_covid_cases
from coviddeaths
where continent <> ''
group by date;

-- Creating a view for later visualization
create view PercentICUForNewCases
as
select date, sum(new_cases), sum(icu_patients), (sum(icu_patients)/sum(new_cases))*100 percentage_of_icu_patients_for_new_covid_cases
from coviddeaths
where continent <> ''
group by date;

-- storing this data in a temp table (just in case I wish to use this data later)
drop table if exists percent_icu_patients_for_new_covid_cases;
create temporary table percent_icu_patients_for_new_covid_cases(
date date,
new_cases_all_countries decimal,
icu_patients_all_countries double,
percentage_of_icu_patients_for_new_covid_cases_all_countries double
);

insert into percent_icu_patients_for_new_covid_cases
select date, sum(new_cases), sum(icu_patients), 
case
	when sum(new_cases) <> '0' then (sum(icu_patients)/sum(new_cases))*100 
end as percentage_of_icu_patients_for_new_covid_cases
from coviddeaths
where continent <> ''
group by date;

select *
from percent_icu_patients_for_new_covid_cases;

-- Getting this same data month-wise and year-wise
-- In my opinion, month-wise should be able to portray results best as we will be able to identify spikes better than for per day, while per year will get too general (but still good to have)
-- Month-Wise
select month(date) month, year(date) year, sum(new_cases) new_cases_per_month, sum(icu_patients) icu_patients_per_month, (sum(icu_patients)/sum(new_cases))*100 percentage_of_icu_patients_for_new_covid_cases_per_month
from coviddeaths
where continent <> ''
group by month(date), year(date);

-- Creating a view for later visualization
create view PercentICUForNewCasesByMonth
as
select date, sum(new_cases), sum(icu_patients), (sum(icu_patients)/sum(new_cases))*100 percentage_of_icu_patients_for_new_covid_cases
from coviddeaths
where continent <> ''
group by date;


-- Year-Wise
select year(date) year, sum(new_cases) new_cases_per_year, sum(icu_patients) icu_patients_per_year, (sum(icu_patients)/sum(new_cases))*100 percentage_of_icu_patients_for_new_covid_cases_per_year
from coviddeaths
where continent <> ''
group by year(date);

-- Creating a view for later visualization
create view PercentICUForNewCasesByYear
as
select date, sum(new_cases), sum(icu_patients), (sum(icu_patients)/sum(new_cases))*100 percentage_of_icu_patients_for_new_covid_cases
from coviddeaths
group by date;










