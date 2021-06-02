# Creation of the table covid_deaths where insert data with Wizard. As well creation of covid_vaccinations schema.

CREATE TABLE covid_deaths (iso_code CHAR(3) PRIMARY KEY,
                           continent VARCHAR(20),
                           location VARCHAR(20),
                           date DATE,
                           population INT,
                           total_cases INT,
                           new_cases INT,
                           total_deaths INT,
                           new_deaths INT);
                           

# The 10 countries with more Covid19 victims

SELECT location, MAX(total_deaths) AS victims
FROM covid_deaths
WHERE continent NOT LIKE ''
GROUP BY location
ORDER BY victims DESC
LIMIT 10;


# The 10 countries with highest percent of victims related to population

SELECT location, (MAX(total_deaths) / population) * 100 AS victims_percent
FROM covid_deaths
WHERE continent NOT LIKE ""
GROUP BY location
ORDER BY victims_percent DESC
LIMIT 10;


# The 10 countries with highest percent of victims related to Covid cases

SELECT location, (MAX(total_deaths) / MAX(total_cases)) AS death_rate
FROM covid_deaths
WHERE continent NOT LIKE ""
GROUP BY location
ORDER BY death_rate DESC
LIMIT 10;


# Italy total cases, deaths and vaccinations

SELECT A.location, MAX(A.total_cases) AS covid_cases, Max(total_deaths) AS covid_deaths, MAX(total_vaccinations) AS covid_vaccination
FROM covid_deaths AS A
INNER JOIN covid_vaccinations AS B
ON A.location = B.location
WHERE A.location = "Italy";


# The 10 days with more covid's deaths partioned by Countries

SELECT location, date, new_deaths
FROM covid_deaths
WHERE continent NOT LIKE ""
GROUP BY location, date
ORDER BY new_deaths DESC
LIMIT 10;


# Vaccination program around countries

SELECT location, population, MAX(total_vaccinations) AS vaccinations, MAX(people_fully_vaccinated) AS people_safe,
CASE 
    WHEN (people_fully_vaccinated/population*100) < 0.1 THEN "No protection"
	WHEN (people_fully_vaccinated/population*100) < 0.4 THEN "Poor protection"
	WHEN (people_fully_vaccinated/population*100) < 0.6 THEN "Almost protected"
    ELSE "Protected" END AS Covid_protection
FROM covid_vaccinations
WHERE continent NOT LIKE "" AND people_fully_vaccinated <> 0 
GROUP BY location
ORDER BY vaccinations DESC;


# Nations with covid victims but no vaccinations program

SELECT A.location, MAX(total_deaths) AS covid_death, MAX(total_vaccinations) AS vaccinations
FROM covid_deaths AS A
INNER JOIN covid_vaccinations AS B 
USING (location)
GROUP BY location
HAVING  vaccinations = 0 AND covid_deaths <> 0
ORDER BY 1;


# Day with more covid_deaths in each country

WITH CTE_covid AS (
SELECT location, date, population, new_cases, MAX(new_cases) OVER (PARTITION BY location) AS max_new_cases
FROM covid_deaths
WHERE continent NOT LIKE ""
GROUP BY date, location
ORDER BY location
)
SELECT A.location, A.population, A.date, A.max_new_cases
FROM CTE_covid AS A
INNER JOIN CTE_covid AS B
USING (location, date)
WHERE A.max_new_cases = B.new_cases AND A.max_new_cases != 0 
ORDER BY A.max_new_cases DESC;





