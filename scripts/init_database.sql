/*
--------------------------------------------
Create Database and Schemas
--------------------------------------------
Script Purpose :
	The script creates anew database named 'DataWarehouse' after checking if it already exist.
	If the database exists, It is deopped and  recreated. Additionally, the script sets up three 
	Schemas within the database: 'bronze', 'Silver', 'Gold'

Warning:
	Running the script will drop the entire 'Datewarehouse' Datavase if it exists,
	All data in the database will be permanently deleted. proceed with caution
	and ensure you have proper nackups beofre running the script 
*/

USE master;
GO

-- Drop and recreate the 'Datawarehouse' datbase
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	  ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	  DROP DATABASE DataWarehouse
END;
GO 

-- Creating the database 'DataWarehouse'

CREATE DATABASE DataWarehouse;

USE  DataWarehouse;
GO

-- Creating the 3 layer Schemas 

CREATE SCHEMA Bronze;
GO

CREATE SCHEMA Sliver;
GO

CREATE SCHEMA Gold;
GO
