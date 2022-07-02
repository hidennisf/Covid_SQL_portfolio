USE new_schema;

-- Total cases Vs total deaths for each country
SELECT location, population, MAX(total_cases), MAX(total_cases/population) AS death_percentage
FROM covid_deaths
GROUP BY location, population;

-- Countries with the highest case rate
SELECT location, population, MAX(total_cases), MAX(total_case/population) AS case_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
-- HAVING COUNT(location)>1
ORDER BY case_percentage DESC;

-- Countries with the highest death rate
SELECT location, population, MAX(total_cases), MAX(total_deaths/population) AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING COUNT(location)>1
ORDER BY death_percentage DESC;

-- New cases per day and death percentages per day.
SELECT date, SUM(new_cases) AS new_case, MAX(total_deaths/population) AS death_percentages
FROM covid_deaths
GROUP BY date
ORDER BY new_case DESC;

-- Join tables based on location and date
SELECT * 
FROM covid_deaths AS d1
JOIN covid_vaccinations AS d2
ON d1.location=d2.location
AND d1.date= d2.date;

-- What is the amount of people who are vaccinated?
SELECT d1.continent, d1.location, d1.date, d1.population, d2.new_vaccinations,
 d2.new_vaccinations/d1.population AS vax_rate, 
 SUM(d2.new_vaccinations) OVER (PARTITION BY d1.location ORDER BY d1.location, d2.date)
FROM covid_deaths as d1
INNER JOIN covid_vaccinations AS d2
	ON d1.date =d2.date 
	AND d1.location =d2.location
WHERE d1.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE
WITH popvsvac (continent, location, date, population, new_vaccinations, vax_rate, rollingpeoplevaccinated)
AS ( SELECT d1.continent, d1.location, d1.date, d1.population, d2.new_vaccinations,
 d2.new_vaccinations/d1.population AS vax_rate, 
 SUM(d2.new_vaccinations) OVER (PARTITION BY d1.location ORDER BY d1.location, d2.date) AS rollingpeoplevaccinated
FROM covid_deaths as d1
INNER JOIN covid_vaccinations AS d2
	ON d1.date =d2.date 
	AND d1.location =d2.location
WHERE d1.continent IS NOT NULL
)
SELECT * , (rollingpeoplevaccinated/population)
FROM popvsvac;

SELECT d1.continent, d1.location, d1.date, d1.population, d2.new_vaccinations,
 d2.new_vaccinations/d1.population AS vax_rate, 
 SUM(d2.new_vaccinations) OVER (PARTITION BY d1.location ORDER BY d1.location, d2.date)
FROM covid_deaths as d1
INNER JOIN covid_vaccinations AS d2
	ON d1.date =d2.date 
	AND d1.location =d2.location
WHERE d1.continent IS NOT NULL
ORDER BY 2,3;

-- Death tolls vs Vax rates
SELECT d1.date, d1.population, d1.location, d1.new_deaths, 
d2.new_vaccinations,SUM(d2.new_vaccinations) OVER (PARTITION BY d1.location ORDER BY d1.location, d2.date) AS rolling_vax ,
SUM(d1.new_deaths) OVER (PARTITION BY d1.location ORDER BY d1.location, d2.date) AS rolling_death, 
FROM covid_deaths AS d1
JOIN covid_vaccinations AS d2
	ON d1.date=d2.date
	AND d1.location=d2.location
ORDER BY d1.location, d1.date;

-- Deaths vs cases
SELECT location, population, MAX(total_cases), MAX(total_deaths/population) AS death_percentage
FROM covid_deaths
GROUP BY location, population;

-- Death percentage vs vax percentage
SELECT d1.date, d1.location, d1.population, MAX(d1.total_deaths), MAX(d2.total_vaccinations), MAX(d1.total_deaths)/MAX(d2.total_vaccinations) AS death_and_vaxed
FROM covid_deaths AS d1
JOIN covid_vaccinations AS d2
ON d1.location=d2.location
AND d1.date = d2.date
GROUP BY 1,2,3;



