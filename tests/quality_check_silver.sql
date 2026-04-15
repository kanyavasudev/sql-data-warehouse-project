/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- Check for nulls or duplicates in customer primary key
-- Expectation: No results
select
cust_id,
count(*)
from silver.crm_cust_info
group by cust_id
having count(*) > 1 or cust_id is null;


-- Check for unwanted spaces in customer first name
-- Expectation: No Results
select 
cust_firstname
from silver.crm_cust_info
where cust_firstname != trim(cust_firstname);


-- Check data standardization for gender values
select distinct
cust_gndr
from silver.crm_cust_info;


-- View customer table data
select * 
from silver.crm_cust_info;


-- Check for nulls or duplicates in product primary key
-- Expectation: No Results
select
prd_id,
count(*)
from silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null;


-- Check for unwanted spaces in product name
-- Expectation: No Results
select 
prd_nm
from silver.crm_prd_info
where prd_nm != trim(prd_nm);


-- Check for null, zero, or negative product cost
-- Expectation: No Results
select 
prd_cost
from silver.crm_prd_info
where prd_cost = 0 or prd_cost < 0;


-- Check data consistency for product line values
select distinct prd_line
from silver.crm_prd_info;


-- Check for invalid product date ranges
-- End date should not be before start date
select * 
from silver.crm_prd_info
where prd_end_dt < prd_start_dt;


-- View product table data
select * 
from silver.crm_prd_info;


-- Check invalid sales order dates
select 
*
from silver.crm_sales_details
where sls_order_dt <= 0 
or length(sls_order_dt) != 8;


-- Check sales date sequence
-- Order date should not be after ship or due date
select 
* 
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt 
or sls_order_dt > sls_due_dt;


-- Check sales calculations and null values
-- Expectation: No invalid records
select distinct
sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price 
or sls_sales is null 
or sls_quantity is null 
or sls_price is null
or sls_sales <=0 
or sls_quantity <=0 
or sls_price <=0;


-- View sales details table
select * 
from silver.crm_sales_details;


-- Check invalid birth dates
-- Expectation: Reasonable date range only
select distinct 
bdate
from silver.erp_cust_az12
where bdate < '1924-01-01' 
or bdate > now();


-- Check gender consistency in ERP customer table
select distinct gen
from silver.erp_cust_az12;


-- View ERP customer table
select * 
from silver.erp_cust_az12;


-- Check country value consistency
select distinct
cntry 
from silver.erp_loc_a101;


-- View ERP location table
select *  
from silver.erp_loc_a101;


-- Check unwanted spaces in bronze category table
select * 
from bronze.erp_px_cat_g1v2
where cat != trim(cat) 
or subcat != trim(subcat) 
or maintenance != trim(maintenance);


-- Check maintenance value consistency
select distinct
maintenance
from bronze.erp_px_cat_g1v2;


-- View Silver product category table
select * 
from silver.erp_px_cat_g1v2;
