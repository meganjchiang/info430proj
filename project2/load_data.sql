-- create database
CREATE DATABASE emissions_db_el_mc

-- create tables
CREATE TABLE dimSector (
   sectorID INT PRIMARY KEY identity(1, 1) NOT NULL,
   sectorName VARCHAR(50) NOT NULL
)

CREATE TABLE dimSubSector (
   subsectorID INT PRIMARY KEY identity(1, 1) NOT NULL,
   sectorID INT NOT NULL,
   subsectorName VARCHAR(100) NOT NULL,
   FOREIGN KEY(sectorID) REFERENCES dimSector(sectorID)
)

CREATE TABLE dimCountry (
   countryID INT PRIMARY KEY identity(1, 1) NOT NULL,
   countryCode CHAR(3) NOT NULL,
   countryName VARCHAR(100) NOT NULL
)

CREATE TABLE dimGas (
   gasID INT PRIMARY KEY identity(1, 1) NOT NULL,
   gasName VARCHAR(50) NOT NULL
)

CREATE TABLE dimYear (
   yearID INT PRIMARY KEY identity(1, 1) NOT NULL,
   yearName CHAR(4) NOT NULL
)

CREATE TABLE fctEmission (
   emissionID INT PRIMARY KEY identity(1, 1) NOT NULL,
   countryID INT NOT NULL,
   subsectorID INT NOT NULL,
   yearID INT NOT NULL,
   gasID INT NOT NULL,
   emissionQuantity FLOAT
   FOREIGN KEY(countryID) REFERENCES dimCountry(countryID),
   FOREIGN KEY(subsectorID) REFERENCES dimSubSector(subsectorID),
   FOREIGN KEY(yearID) REFERENCES dimYear(yearID),
   FOREIGN KEY(gasID) REFERENCES dimGas(gasID)
)

-- bulk insert data
-- BULK INSERT dimYear
-- FROM '/Users/meganchiang/Documents/info430/info430proj/project2/transformed_data/dimYear.csv'
-- WITH (
--     FIELDTERMINATOR = ',',  
--     ROWTERMINATOR = '\n',    
--     FIRSTROW = 2             
-- );
-- error: 'You do not have permission to use the bulk load statement.'