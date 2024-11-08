select top(500) * from PorfolioProject..CovidDeaths
select top(500) * from PorfolioProject..CovidVacinations

-- Total death per total cases daily in each country

select [location], [date], population, total_cases, total_deaths, 
    case 
        when total_cases = 0 then 0 else ((cast(total_deaths as float) / cast(total_cases as float)) * 100)
    end
    as DeathPerCases
from PorfolioProject..CovidDeaths
--where continent is not NULL and location like '%state%'
order by [location], [date]


-- Percentage of infection base on population daily
select [location], [date], population, total_cases, 
    case 
        when population = 0 then 0 else ((cast(total_cases as float) / cast(population as float)) * 100)
    end
    as TotalCasePerPopulation
from PorfolioProject..CovidDeaths
where continent is not NULL and location like '%state%'
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