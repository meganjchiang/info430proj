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