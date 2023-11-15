/*Exploring the COVID 19 pendamics using Our World in Data*/

/*Understanding the data*/

Select *
From Covidproject.coviddeaths
Where continent is not null
Order by 3,4

/*Exploring the number of cases, deaths and the overall population of countries each day*/

Select location, date, new_cases, total_cases, total_deaths, population
From Covidproject.coviddeaths
Where continent is not null
Order by 1,2

/*Exploring the likelihood of deaths if contracted COVID in each country*/

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rates
From Covidproject.coviddeaths
Where continent is not null
Order by 1,2

/*Exploring the infection rates globally*/

Select location, date, population, total_cases, (total_cases/population)*100 AS infection_rates
From Covidproject.coviddeaths
Order by 1,2

/*Exploring couintries with highest infection rate*/

Select location, population, MAX(total_cases) AS high_infection_count, MAX((total_cases/population))*100 AS infection_rates
From Covidproject.coviddeaths
Group by location, population
Order by infection_rates DESC

/*Exploring countries with highest death counts per population*/

Select location, MAX(CAST(total_deaths AS INT)) AS total_deaths_count
From Covidproject.coviddeaths
Where continent is not null
Group by location
Order by total_deaths_count DESC

/*Exploring the death counts for each continent globally*/

Select continent, MAX(CAST(total_deaths as INT)) AS total_deaths_count
From Covidproject.coviddeaths
Where continent is not null
Group by continent
Order by total_deaths_count DESC

/*Explorimng the global death rate*/

Select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT64))/SUM(new_cases)*100 AS global_death_rate
From Covidproject.coviddeaths
Where continent is not null
Order by 1,2

/*Exploring the part of population that recieved vaccination*/

Select deaths.date, deaths.population, deaths.location, deaths.continent, vaccinations.new_vaccinations, SUM(CAST(vaccinations.new_vaccinations AS INT)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS received_vac
From Covidproject.coviddeaths AS deaths
Join Covidproject.covidvaccinations AS vaccinations
    ON deaths.location = vaccinations.location
    AND deaths.date = vaccinations.date
Where deaths.continent is not null
Order by 2,3

/*Using CTE to perform Calculation on Partition By in previous query*/

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, received_vac)
AS
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations, SUM(CAST(vaccinations.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS received_vac
From Covidproject.coviddeaths AS deaths
Join Covidproject.covidvaccinations AS vaccinations
    ON deaths.location = vaccinations.location
    AND deaths.date = vaccinations.date
Where deaths.continent is not null
)

Select *, (received_vac/population)*100
FROM Popvsvac

/*Using Temp table to perform calculation on partition by in previous query*/

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population
, SUM(CAST(vaccinations.new_vaccinations AS INT)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as received_vac
From Covidproject.coviddeaths AS deaths
Join Covidproject.covidvaccinations AS vaccinations
  On deaths.location = vaccinations.location
  and deaths.date = vaccinations.date
  
Select *, (received_vac/Population)*100
From #Percentpopulationvaccinated

/*Creating View to store data for later visualizations*/

Create View Percentpopulationvacinated AS
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
, SUM(CONVERT(INT64,vaccinations.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as received_vac
From Covidproject.coviddeaths AS deaths
Join Covidproject.covidvaccinations AS vaccinations
	On deaths.location = vacccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null

/*Edouard Mathieu, Hannah Ritchie, Lucas Rodés-Guirao, Cameron Appel, Charlie Giattino, Joe Hasell, Bobbie Macdonald, Saloni Dattani, Diana Beltekian, Esteban Ortiz-Ospina and Max Roser (2020) - "Coronavirus Pandemic (COVID-19)". Published online at OurWorldInData.org. Retrieved from: 'https://ourworldindata.org/coronavirus' [Online Resource]*/
