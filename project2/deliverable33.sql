/* 
INFO 430: Database Design and Management 
Project 2 Deliverable 3: OLAP & Reporting
Students: Evonne La & Megan Chiang
Due Date: Thursday, May 30, 2024
*/

-- CUBE Function (Evonne)
-- Purpose: 
-- Calculates the total emission quantity per sector per country. Also provides the total emission 
-- quantity per country as well as the grand total emission quantity for all countries at the end. 
-- Interpretation: 
-- This query provides us with insight into which countries and practices produce the most emission 
-- quantity, giving policymakers crucial information that could help them implement policies 
-- or laws to reduce the environmental impact of these sectors and countries. 
CREATE TABLE #tempEmissionSummary (
    sectorName NVARCHAR(100),
    countryName NVARCHAR(100),
    totalEmissions DECIMAL(18, 2)
);

INSERT INTO #tempEmissionSummary (sectorName, countryName, totalEmissions)
SELECT 
    COALESCE(ds.sectorName, 'Grand Total') AS sectorName,
    COALESCE(dc.countryName, 'Total') AS countryName,
    SUM(fe.emissionQuantity) AS totalEmissions
FROM fctEmission fe
JOIN dimCountry dc ON fe.countryID = dc.countryID
JOIN dimSubSector dss ON fe.subsectorID = dss.subsectorID
JOIN dimSector ds ON dss.sectorID = ds.sectorID
GROUP BY CUBE (ds.sectorName, dc.countryName);

SELECT sectorName, countryName, totalEmissions
FROM #tempEmissionSummary
ORDER BY 
    CASE WHEN sectorName = 'Grand Total' THEN 1 ELSE 0 END, 
    sectorName, 
    CASE WHEN countryName = 'Total' THEN 1 ELSE 0 END, 
    countryName;

DROP TABLE #tempEmissionSummary;


-- Ranking Window function (Evonne)
-- Purpose: 
-- Identifies and ranks the top 3 sectors by emission quantity for each country.
-- Interpretation: 
-- This query provides insights into the sectors contributing the most to emissions in each country,
-- giving the policymakers of each country a good understanding of which practices are most harmful to 
-- the environment. With this information, they can implement changes for a greener future. 
WITH RankedSectors AS (
    SELECT 
        dc.countryName,
        ds.sectorName,
        SUM(fe.emissionQuantity) AS totalEmissions,
        ROW_NUMBER() OVER (PARTITION BY dc.countryName ORDER BY SUM(fe.emissionQuantity) DESC) AS SectorRank
    FROM fctEmission fe
    JOIN dimCountry dc ON fe.countryID = dc.countryID
    JOIN dimSubSector dss ON fe.subsectorID = dss.subsectorID
    JOIN dimSector ds ON dss.sectorID = ds.sectorID
    GROUP BY dc.countryName, ds.sectorName
)
SELECT countryName, sectorName, totalEmissions, SectorRank
FROM RankedSectors
WHERE SectorRank <= 3
ORDER BY countryName, SectorRank, totalEmissions DESC;




-- Evonne's other 2 queries here




/* CUBE Function (Megan)
Purpose: 
Calculates the percentage of CO2 emissions in relation to the total greenhouse gas emissions for
each year between 2015-2022 to understand how the percentage has changed over time.

Interpretation: 
The results show that proportion of CO2 emissions stayed very similar from 2015 to 2021. However,
in 2022, the percentage increased by 10 percentage points. This might be due to changes in
industrial activities, energy production sources, or transportation patterns.
*/
CREATE TABLE #tempEmissionSummaryYearGas (
    yearName VARCHAR(10),
    gasName VARCHAR(50),
    totalEmissions NUMERIC(22, 10)
);

INSERT INTO #tempEmissionSummaryYearGas (yearName, gasName, totalEmissions)
SELECT 
    COALESCE(y.yearName, 'All Years') AS yearName,
    COALESCE(g.gasName, 'All Gases') AS gasName,
    SUM(e.emissionQuantity) AS totalEmissions
FROM fctEmission e
JOIN dimYear y ON e.yearID = y.yearID
JOIN dimGas g ON e.gasID = g.gasID
GROUP BY CUBE (y.yearName, g.gasName);

WITH total_emissions_per_year AS (
    SELECT yearName, totalEmissions
    FROM #tempEmissionSummaryYearGas
    WHERE gasName = 'All Gases' AND yearName <> 'All Years'
),
co2_percentages AS (
    SELECT *
    FROM #tempEmissionSummaryYearGas
    WHERE gasName = 'co2' AND yearName <> 'All Years'
)
SELECT 
    t.yearName AS 'Year',
    CASE
        WHEN 
            ROUND(100 * c.totalEmissions / t.totalEmissions, 2) % 1 = 0
        THEN
            CAST(FORMAT(ROUND(100 * c.totalEmissions / t.totalEmissions, 0), 'N0') AS VARCHAR(20)) + '%'
        ELSE
            REPLACE(CAST(ROUND(100 * c.totalEmissions / t.totalEmissions, 2) AS VARCHAR(20)), '0', '') + '%'
    END AS 'CO2 Emissions Percentage'
FROM total_emissions_per_year t
JOIN co2_percentages c ON t.yearName = c.yearName;

DROP TABLE #tempEmissionSummaryYearGas;


/* Ranking Window Function (Megan)
Purpose: 
Identifies the top 5 countries by emission quantity for each year between 2015-2022 to see which countries are
the largest contributors to greenhouse gas emissions.

Interpretation: 
The results show that for each year in 2015-2022, China emitted the most greenhouse gases. From 2015-2021, the
second-, third-, and fourth-highest-ranking countries were the United States, Russia, and India, respectively.
It was interesting to see that Japan was the fifth-highest-ranking country in 2015-2017, but from 2018 to 2021,
Indonesia's total emissions exceeded those of Japan. I also found it interesting to see how the ranks changed
in 2022. The United States had consistently been the second-highest-ranking country, but it was not even in
the top five in 2022.
*/
WITH country_emission_ranks AS (
    SELECT 
        y.yearName,
        c.countryName,
        SUM(emissionQuantity) AS totalEmissions,
        DENSE_RANK() OVER (PARTITION BY y.yearName ORDER BY SUM(emissionQuantity) DESC) AS rank
    FROM fctEmission e 
    JOIN dimYear y ON e.yearID = y.yearID
    JOIN dimCountry c ON e.countryID = c.countryID
    GROUP BY y.yearName, c.countryName
)
SELECT
    yearName AS [Year],
    countryName AS Country, 
    FORMAT(totalEmissions, 'N2') AS 'Total Emissions (tonnes)'
FROM country_emission_ranks
WHERE rank <= 5;


/* Value Window Function (Megan)
Purpose: 
For each of the top 3 countries by total emission quantity in 2015-2022, identifies the year in which
they experienced the largest year-on-year percentage increase in emissions.

Interpretation: 
The results show that the top 3 countries by total emissions (in no particular order) is Russia, the
United States, and China. In 2021, Russia's emissions increased by 7.18%, and in 2018, the United States'
emission increased by 5.8% and China's emissions increased by 3.64%. These results suggest that there might
have been changes in their economic or industrial activities during these years.
*/
WITH top_3_countries_by_emission_per_year AS (
    SELECT TOP 3 
        c.countryName
    FROM fctEmission e 
    JOIN dimYear y ON e.yearID = y.yearID
    JOIN dimCountry c ON e.countryID = c.countryID
    GROUP BY c.countryName 
    ORDER BY SUM(emissionQuantity) DESC
),
country_emissions_prev_year AS (
    SELECT 
        y.yearName,
        c.countryName,
        SUM(emissionQuantity) AS currYearEmissions,
        LAG(SUM(emissionQuantity)) OVER (PARTITION BY c.countryName ORDER BY y.yearName) AS prevYearEmissions
    FROM fctEmission e 
    JOIN dimYear y ON e.yearID = y.yearID
    JOIN dimCountry c ON e.countryID = c.countryID
    WHERE c.countryName IN (SELECT * FROM top_3_countries_by_emission_per_year)
    GROUP BY y.yearName, c.countryName 
),
country_emissions_differences AS (
    SELECT 
        yearName,
        countryName,
        (currYearEmissions - prevYearEmissions) / prevYearEmissions * 100 AS percentChange,
        ROW_NUMBER() OVER (
            PARTITION BY countryName
            ORDER BY (currYearEmissions - prevYearEmissions) / prevYearEmissions * 100 DESC) AS rank
    FROM country_emissions_prev_year
)
SELECT
    countryName AS Country,
    yearName AS [Year],
    REPLACE(CAST(ROUND(percentChange, 2) AS VARCHAR(10)), '0', '') + '%'
        AS 'Percent Increase in Emissions From Previous Year'
FROM country_emissions_differences
WHERE rank = 1
ORDER BY 'Percent Increase in Emissions From Previous Year' DESC;


/* Time Series Analytic Function (Megan)
Purpose: 
For each sector, calculates the average emission quantity over the previous two years and determines whether
this average has increased or decreased compared to the previous year's average.

Interpretation: 
The results of this query show the trends of emission quantity averages for each sector. It is useful to compare
emissions between sectors to determine which sectors in particular need more attention to reduce total emissions.
For example, out of the eight sectors, the moving emission averages for the fluorinated_gases, mineral_extraction,
and waste sectors only increased. This suggests that these sectors might need more attention and specific strategies
to lower their emissions.
*/
WITH sector_emissions_per_year AS (
    SELECT y.yearName, sectorName, SUM(emissionQuantity) AS totalEmissions
    FROM fctEmission e 
    JOIN dimSubSector ss ON e.subsectorID = ss.subsectorID 
    JOIN dimSector s ON ss.sectorID = s.sectorID
    JOIN dimYear y ON e.yearID = y.yearID
    GROUP BY y.yearName, sectorName   
),
moving_emission_avg_2_year AS (
    SELECT 
        yearName,
        sectorName,
        AVG(totalEmissions) OVER (
            PARTITION BY sectorName
            ORDER BY yearName
            ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS moving_emission_avg_2_year
    FROM sector_emissions_per_year
),
change_in_avg AS (
    SELECT
        yearName,
        sectorName,
        moving_emission_avg_2_year,
        CASE
            WHEN LAG(moving_emission_avg_2_year)
                OVER (
                    PARTITION BY sectorName
                    ORDER BY yearName)
                < moving_emission_avg_2_year THEN 'increased'
            WHEN LAG(moving_emission_avg_2_year)
                OVER (
                    PARTITION BY sectorName
                    ORDER BY yearName)
                > moving_emission_avg_2_year THEN 'decreased'
            ELSE 'N/A'
        END AS change
    FROM moving_emission_avg_2_year
)
SELECT
    yearName AS [Year],
    sectorName AS Sector,
    FORMAT(moving_emission_avg_2_year, 'N2') AS 'Average Emission Quantity in Previous 2 Years (tonnes)',
    change AS 'Change in Average Emission Quantity from Previous Year'
FROM change_in_avg;