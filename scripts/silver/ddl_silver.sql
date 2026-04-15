-- Creating DDL for Silver Layer tables with metadata for future use

-- CRM customer information table
drop table if exists silver.crm_cust_info;
create Table silver.crm_cust_info(
	cust_id int, -- Unique customer ID
	cust_key varchar(50), -- Customer business key
	cust_firstname varchar(50), -- First name
	cust_lastname varchar(50), -- Last name
	cust_marital_status varchar(50), -- Marital status
	cust_gndr varchar(50), -- Gender
	cust_create_date date, -- Customer created date
    dwh_create_date datetime default current_timestamp -- Record load timestamp
);

-- CRM product information table
drop table if exists silver.crm_prd_info;
create table silver.crm_prd_info(
prd_id int, -- Product ID
cat_id varchar(50), -- Category ID
prd_key varchar(50), -- Product key
prd_nm varchar(50), -- Product name
prd_cost int, -- Product cost
prd_line varchar(50), -- Product line
prd_start_dt date, -- Product start date
prd_end_dt date, -- Product end date
dwh_create_date datetime default current_timestamp -- Record load timestamp
);

-- CRM sales details table
drop table if exists silver.crm_sales_details;
create table silver.crm_sales_details(
sls_ord_num varchar(50), -- Sales order number
sls_prd_key varchar(50), -- Product key
sls_cust_id int, -- Customer ID
sls_order_dt date, -- Order date
sls_ship_dt date, -- Shipping date
sls_due_dt date, -- Due date
sls_sales int, -- Sales amount
sls_quantity int, -- Quantity sold
sls_price int, -- Price per unit
dwh_create_date datetime default current_timestamp -- Record load timestamp
); 

-- ERP customer details table
drop table if exists silver.erp_cust_az12;
create table silver.erp_cust_az12(
cid varchar(50), -- Customer ID
bdate date, -- Birth date
gen varchar(50), -- Gender
dwh_create_date datetime default current_timestamp -- Record load timestamp
);

-- ERP location details table
drop table if exists silver.erp_loc_a101;
create table silver.erp_loc_a101(
cid varchar(50), -- Customer ID
cntry varchar(50), -- Country
dwh_create_date datetime default current_timestamp -- Record load timestamp
);

-- ERP product category table
drop table if exists silver.erp_px_cat_g1v2;
create table silver.erp_px_cat_g1v2(
id varchar(50), -- Category ID
cat varchar(50), -- Category name
subcat varchar(50), -- Subcategory name
maintenance varchar(50), -- Maintenance type
dwh_create_date datetime default current_timestamp -- Record load timestamp
);
