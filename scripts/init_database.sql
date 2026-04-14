/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/
-- Display all available databases in MySQL
SHOW DATABASES;

-- Create the main database for the project
CREATE DATABASE DataWarehouse;

-- Select the DataWarehouse database
USE DataWarehouse;

-- Create Bronze schema (same as database in MySQL) for raw data storage
CREATE SCHEMA bronze;

-- Create Silver schema for cleaned and transformed data
CREATE SCHEMA silver;

-- Create Gold schema for final business-ready analytics data
CREATE SCHEMA gold;
