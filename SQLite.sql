--Counting the number of rows--
SELECT COUNT(*)
FROM `chromatic-realm-371921.Covid19.deaths`

--Selecting data we will be using--
--Sorting data by location and date--
SELECT location, date, total_cases, new_cases, new_deaths, total_deaths, population
FROM `chromatic-realm-371921.Covid19.deaths`
ORDER BY 1, 2

--Filtering data to show occurrence in Africa alone--
--Comparing total cases vs population--
--Shows percentage of population infected with covid--
SELECT date, location, total_cases, population, (total_cases/population)*100 AS Percentage_Infected
FROM `chromatic-realm-371921.Covid19.deaths`
WHERE continent like 'Africa'
ORDER BY 1, 2

--Comparing total deaths vs total cases by calculating the percentage of death occurrence--
--This shows the likehood of dying from after getting infected with covid in the Africa--
SELECT date, continent, location, SUM(total_cases) as sum_total_cases, SUM(total_deaths) as sum_total_deaths, (SUM(total_deaths)/SUM(total_cases))*100 as Death_Percentage
FROM `chromatic-realm-371921.Covid19.deaths`
WHERE continent like "Africa"
GROUP BY date, continent, location
ORDER BY 1, 3

SELECT date, continent, location, SUM(new_cases) as sum_new_cases, SUM(new_deaths) as sum_new_deaths, (NULLIF(SUM(new_deaths), 0))/(NULLIF(SUM(new_cases), 0))*100 as Death_Percentage
FROM `chromatic-realm-371921.Covid19.deaths`
WHERE continent like "Africa"
GROUP BY date, continent, location
ORDER BY 1, 3

--Exploring countries with highest infection rates compared to their population--
SELECT date, location, MAX(total_cases) AS highest_infection_count, population, MAX(total_cases/population)*100 AS Percentage_Infected
FROM `chromatic-realm-371921.Covid19.deaths`
WHERE continent like "Africa"
GROUP BY date, location, population
ORDER BY Percentage_Infected DESC

--Looking at countries with the highest death rates--
SELECT location, MAX(total_deaths) AS total_death_count
FROM `chromatic-realm-371921.Covid19.deaths`
WHERE continent like "Africa"
GROUP BY location
ORDER BY total_death_count DESC

--Looking at continents with the highest death rates--
SELECT continent, MAX(total_deaths) AS total_death_count
FROM `chromatic-realm-371921.Covid19.deaths`
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

--Global numbers
SELECT date, SUM(new_cases), SUM(new_deaths), (NULLIF(SUM(new_deaths), 0))/(NULLIF(SUM(new_cases), 0))*100 as Death_Percentage
FROM `chromatic-realm-371921.Covid19.deaths`
where continent is not null
group by date
order by 1, 2

--Looking at total popuation vs vaccinations
--Getting the cumulative of new vaccination first
SELECT deat.date,deat.continent, deat.location, deat.population, vacc.new_vaccinations,
  SUM(vacc.new_vaccinations)
  OVER (partition by deat.location order by deat.location, deat.date) as cumulative_new_vaccinations
FROM `chromatic-realm-371921.Covid19.deaths` deat
JOIN `chromatic-realm-371921.Covid19.vaccinations` vacc
  ON deat.date = vacc.date
  and deat.location = vacc.location
  WHERE deat.continent like "Africa"
  ORDER BY 3,5

  --Using CTE
WITH PopvsVacc AS
(SELECT deat.date,deat.continent, deat.location, deat.population, vacc.new_vaccinations,
  SUM(vacc.new_vaccinations)
  OVER (partition by deat.location order by deat.location, deat.date) as cumulative_new_vaccinations
FROM `chromatic-realm-371921.Covid19.deaths` deat
JOIN `chromatic-realm-371921.Covid19.vaccinations` vacc
  ON deat.date = vacc.date
  and deat.location = vacc.location
  WHERE deat.continent like "Africa"
  ORDER BY 3,5
)
SELECT *, (cumulative_new_vaccinations/population)*100 as percentage_vaccinated
From PopvsVacc

--Creating view to store data for visualisation in Tableau
create view `chromatic-realm-371921.Covid19.popvsvacc` as
SELECT deat.date,deat.continent, deat.location, deat.population, vacc.new_vaccinations,
  SUM(vacc.new_vaccinations)
  OVER (partition by deat.location order by deat.location, deat.date) as cumulative_new_vaccinations
FROM `chromatic-realm-371921.Covid19.deaths` deat
JOIN `chromatic-realm-371921.Covid19.vaccinations` vacc
  ON deat.date = vacc.date
  and deat.location = vacc.location
  WHERE deat.continent like "Africa"
  ORDER BY 3,5