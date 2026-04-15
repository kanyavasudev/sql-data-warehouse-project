/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

drop procedure if exists silver.load_silver;
DELIMITER //

-- Create procedure to load Silver layer tables
CREATE PROCEDURE silver.load_silver()
BEGIN

-- Load customer information
select '>> Truncating Table: silver.crm_cust_info';
truncate table silver.crm_cust_info;

select '>>Inserting data into:silver.crm_cust_info';
insert into silver.crm_cust_info(
cust_id,
cust_key,
cust_firstname,
cust_lastname,
cust_marital_status,
cust_gndr,
cust_create_date)

select 
cust_id,
cust_key,
trim(cust_firstname) as cust_firstname, -- Remove spaces
trim(cust_lastname) as cust_lastname, -- Remove spaces

case when upper(trim(cust_marital_status)) = 'M' Then 'Married'
	when upper(trim(cust_marital_status)) = 'S' Then 'Single'
	else 'n/a'
end cust_marital_status, -- Standardize marital status

case when upper(trim(cust_gndr)) = 'F' Then 'Female'
	when upper(trim(cust_gndr)) = 'M' Then 'Male'
	else 'n/a'
end cust_gndr, -- Standardize gender

cust_create_date
from
(
select 
*, 
row_number() over(partition by cust_id order by cust_create_date desc) flag_last -- Identify latest record
from bronze.crm_cust_info
where cust_id!=0
)t
where flag_last = 1; -- Keep latest customer record


-- Load product information
select '>> Truncating Table: silver.crm_prd_info';
truncate table silver.crm_prd_info;

select '>>Inserting data into:silver.crm_prd_info';
insert into silver.crm_prd_info
(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
select
prd_id,
replace(substring(prd_key,1,5),'-','_') as cat_id, -- Extract category id
substring(prd_key, 7, length(prd_key)) as prd_key, -- Extract product key
prd_nm,
ifnull(prd_cost, 0) as prd_cost, -- Replace null cost

case upper(trim(prd_line))
	when 'M' Then 'Mountain'
	when 'R' Then 'Road'
	when 'S' Then 'Other Sales'
	when 'T' Then 'Touring'
else 'n/a'
end as prd_line, -- Standardize product line

cast(prd_start_dt as date) as prd_start_dt,
cast(lead(prd_start_dt) over(partition by prd_key order by prd_start_dt asc) - INTERVAL 1 DAY as date) as prd_end_dt -- Derive end date
from bronze.crm_prd_info;


-- Load sales details
select '>> Truncating Table: silver.crm_sales_details';
truncate table silver.crm_sales_details;

select '>>Inserting data into:silver.crm_sales_details';
insert into silver.crm_sales_details
(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)

select 
sls_ord_num,
sls_prd_key,
sls_cust_id,

case when sls_order_dt = 0 or length(sls_order_dt) != 8 Then null
	else cast(sls_order_dt as date)
end sls_order_dt, -- Validate order date

case when sls_ship_dt= 0 or length(sls_ship_dt) != 8 Then null
	else cast(sls_ship_dt as date)
end sls_ship_dt, -- Validate ship date

case when sls_due_dt= 0 or length(sls_due_dt) != 8 Then null
	else cast(sls_due_dt as date)
end sls_due_dt, -- Validate due date

CASE
    WHEN sls_sales IS NULL or sls_sales < 0 or sls_sales = 0 or sls_sales != sls_quantity * sls_price
	THEN sls_quantity * coalesce(nullif(abs(sls_price), 0), sls_sales / NULLIF(sls_quantity, 0))
	ELSE sls_sales
END sls_sales, -- Correct sales amount

sls_quantity,

CASE
    WHEN sls_price IS NULL OR sls_price <= 0 THEN
        CASE
            WHEN sls_sales > 0 AND sls_quantity > 0
            THEN sls_sales / sls_quantity
            ELSE NULL
        END
    ELSE sls_price
END sls_price -- Correct price
from bronze.crm_sales_details;


-- Load ERP customer data
select '>> Truncating Table: silver.erp_cust_az12';
truncate table silver.erp_cust_az12;

select '>>Inserting data into:silver.erp_cust_az12';
insert into silver.erp_cust_az12(
cid,
bdate,
gen 
)
select
case when cid like 'NAS%' then substring(cid,4,length(cid))
     else cid
end as cid, -- Remove prefix

case when bdate > now()
	then null
    else bdate
end as bdate, -- Remove future dates

case upper(trim(gen))
	when 'M' then 'Male'
    when 'F' then 'Female'
    when '' then 'n/a'
    else gen
end as gen -- Standardize gender

FROM bronze.erp_cust_az12;


-- Load ERP location data
select '>> Truncating Table: silver.erp_loc_a101';
truncate table silver.erp_loc_a101;

select '>>Inserting data into:silver.erp_loc_a101';
insert into silver.erp_loc_a101(cid, cntry)

SELECT 
replace(cid,'-','') as cid, -- Remove hyphen

case when trim(cntry) = 'DE' then 'Germany'
	when trim(cntry) in ('US','USA') then 'United States'
    when trim(cntry) = '' or cntry is null then 'n/a'
    else trim(cntry)
end cntry -- Standardize country

FROM bronze.erp_loc_a101;


-- Load product category data
select '>> Truncating Table: silver.erp_px_cat_g1v2';
truncate table silver.erp_px_cat_g1v2;

select '>>Inserting data into:silver.erp_px_cat_g1v2';
insert into silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
select
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;

END //

DELIMITER ;
