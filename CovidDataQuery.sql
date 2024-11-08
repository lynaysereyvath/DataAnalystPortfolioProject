select top(500) * from PorfolioProject..CovidDeaths
select top(500) * from PorfolioProject..CovidVacinations

-- Total death per total cases daily in each country

select [location], [date], population, total_cases, total_deaths, 
    case 
        when total_cases = 0 then 0 else ((cast(total_deaths as float) / cast(total_cases as float)) * 100)
    end
    as DeathPerCases
from PorfolioProject..CovidDeaths
where continent is not NULL --and location like '%state%'
order by [location], [date]


-- Percentage of infection base on population daily
select [location], [date], population, total_cases, 
    case 
        when population = 0 then 0 else ((cast(total_cases as float) / cast(population as float)) * 100)
    end
    as TotalCasePerPopulation
from PorfolioProject..CovidDeaths
where continent is not NULL --and location like '%state%'
order by [location], [date]


-- Highest infection rate in the world
with 
    cteInfectionRate (location, Population, TotalCase) 
    as 
    (
        SELECT location, max(population), max(total_cases)
        from PorfolioProject..CovidDeaths
        where continent is not null
        group by [location]
    )

select [location], Population, TotalCase, (cast(TotalCase as float) / cast(Population as float)) * 100 as InfectionRate
from cteInfectionRate
order by InfectionRate desc


-- Highest death rate per population
with 
    cteDeathRate (Location, Population, TotalDeath) 
    as 
    (
        SELECT location, max(population), max(total_deaths)
        from PorfolioProject..CovidDeaths
        where continent is not null
        group by [location]
    )

select Location, Population, TotalDeath, (cast(TotalDeath as float) / cast(Population as float)) * 100 as DeathRate
from cteDeathRate
order by DeathRate desc


-- Death rate per infection
with 
    cteDeathRatePerInfection (Location, TotalInfection, TotalDeath) 
    as 
    (
        SELECT location, max(total_cases), max(total_deaths)
        from PorfolioProject..CovidDeaths
        where continent is not null
        group by [location]
    )

select Location, TotalInfection, TotalDeath, 
    case 
        when TotalInfection = 0 then 0 
        else  (cast(TotalDeath as float) / cast(TotalInfection as float)) * 100 
    end
        as DeathRate
from cteDeathRatePerInfection
order by DeathRate desc


-- Total by by continent

drop table if exists #TempTotalNumber
create table #TempTotalNumber (
    Continent varchar(50),
    Location varchar(50),
    Population numeric,
    TotalCases numeric,
    TotalDeath numeric
)

insert 
into #TempTotalNumber
select continent Continent, location, max(population) Population, max(total_cases) TotalCases, max(total_deaths) TotalDeaths
                from PorfolioProject..CovidDeaths
                where continent is not NULL
                group by continent, location
                order by continent;

with 
    cteContinentalStatistics (Continent, Population, TotalDeath, TotalInfection)
    as 
    (
        select Continent, sum(Population) as Population, sum(TotalDeath) as TotalDeath, sum(TotalCases) as TotalInfection
        from #TempTotalNumber
        group by Continent
    )
select Continent, Population, TotalInfection, TotalDeath, 
(TotalDeath / TotalInfection) * 100 as DeathRate,
(TotalInfection / Population) * 100 as InfectionRate
from cteContinentalStatistics
order by DeathRate desc

--Total new cases by date globally
select date, sum(new_cases) as NewCases, sum(new_deaths) as NewDeaths
from PorfolioProject..CovidDeaths
where continent is not NULL
group by [date]
order by [date]


-- Vaccinations
select * 
from PorfolioProject..CovidVacinations;

go
create view [CovidVaccinationData]
as
select Cvac.continent, Cvac.location, Cvac.date, Cod.population, Cvac.total_vaccinations, Cvac.new_vaccinations
from PorfolioProject..CovidVacinations as Cvac full join PorfolioProject..CovidDeaths as Cod     
    on Cvac.location = Cod.[location] and Cvac.date = Cod.[date]

--Total vaccinations in each country per population
go
select 
    location, 
    max(total_vaccinations) as TotalVaccination
from [CovidVaccinationData] 
where continent is not NULL
group by location 
order by location

-- Total vaccination per day
select date, sum(new_vaccinations) as NewVaccination
from [CovidVaccinationData] 
where continent is not NULL
group by [date]
ORDER by [date]
