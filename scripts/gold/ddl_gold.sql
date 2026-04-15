/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =====================================================
-- Gold Layer Views
-- Purpose: Create dimension and fact views for reporting
-- =====================================================


-- Create customer dimension view
-- Combines customer data from CRM and ERP systems
drop view if exists gold.dim_customers;

create view gold.dim_customers as
select
	row_number() over(order by cust_id) as customer_key, -- Surrogate key
	ci.cust_id as customer_id,
	ci.cust_key as customer_number,
	ci.cust_firstname as firstname,
	ci.cust_lastname as lastname,
    la.cntry as country,
	ci.cust_marital_status as marital_status,

	case 
		when ci.cust_gndr != 'n/a' then ci.cust_gndr -- Use CRM gender if available
		else coalesce(ca.gen,'n/a') -- Else use ERP gender
    end as gender, 

    ca.bdate as birthdate,
	ci.cust_create_date as create_date

from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
	on ci.cust_key = ca.cid
left join silver.erp_loc_a101 la
	on ci.cust_key = la.cid;


-- Create product dimension view
-- Includes only active/current products
drop view if exists gold.dim_products;

create view gold.dim_products as
select 
row_number() over(order by pi.prd_start_dt, pi.prd_key) as product_key, -- Surrogate key
pi.prd_id as product_id,
pi.prd_key as product_number,
pi.prd_nm as product_name,
pi.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance,
pi.prd_cost as cost,
pi.prd_line as product_line,
pi.prd_start_dt as start_date

from silver.crm_prd_info pi
left join silver.erp_px_cat_g1v2 pc
	on pi.cat_id = pc.id

where pi.prd_end_dt is null; -- Exclude historical records


-- Create sales fact view
-- Links sales transactions with customer and product dimensions
drop view if exists gold.fact_sales;

create view gold.fact_sales as 
select 
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price

from silver.crm_sales_details sd
left join gold.dim_products pr
	on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu
	on sd.sls_cust_id = cu.customer_id;
