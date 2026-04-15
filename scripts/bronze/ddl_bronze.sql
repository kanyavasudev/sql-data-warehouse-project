/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

SELECT '======================================';
SELECT 'LOADING BRONZE LAYER';
SELECT '======================================';

-- -----------------------------------------------------
-- LOADING CRM TABLES
-- -----------------------------------------------------
SELECT '--------------------------------------';
SELECT 'LOADING CRM TABLES';
SELECT '--------------------------------------';

-- Truncate and load customer information table
SELECT '>> Truncating Table: bronze.crm_cust_info';
TRUNCATE TABLE bronze.crm_cust_info;

SELECT '>> Inserting Data into: bronze.crm_cust_info';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
IGNORE
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Truncate and load product information table
SELECT '>> Truncating Table: bronze.crm_prd_info';
TRUNCATE TABLE bronze.crm_prd_info;

SELECT '>> Inserting Data into: bronze.crm_prd_info';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
IGNORE
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Truncate and load sales details table
SELECT '>> Truncating Table: bronze.crm_sales_details';
TRUNCATE TABLE bronze.crm_sales_details;

SELECT '>> Inserting Data into: bronze.crm_sales_details';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
IGNORE
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- -----------------------------------------------------
-- LOADING ERP TABLES
-- -----------------------------------------------------
SELECT '--------------------------------------';
SELECT 'LOADING ERP LAYERS';
SELECT '--------------------------------------';

-- Truncate and load ERP customer table
SELECT '>> Truncating Table: bronze.erp_cust_az12';
TRUNCATE TABLE bronze.erp_cust_az12;

SELECT '>> Inserting Data into: bronze.erp_cust_az12';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
IGNORE
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Truncate and load ERP location table
SELECT '>> Truncating Table: bronze.erp_loc_a101 ';
TRUNCATE TABLE bronze.erp_loc_a101;

SELECT '>> Inserting Data into: bronze.erp_loc_a101';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
IGNORE
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Truncate and load ERP product category table
SELECT '>> Truncating Table: bronze.erp_px_cat_g1v2';
TRUNCATE TABLE bronze.erp_px_cat_g1v2;

SELECT '>> Inserting Data into: bronze.erp_px_cat_g1v2';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
IGNORE
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
