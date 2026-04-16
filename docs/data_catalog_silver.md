# Data Catalog for Silver Layer

## Overview
The Silver Layer contains **cleaned, standardized, and validated data** transformed
from the raw Bronze layer. Data quality issues from both source systems (CRM and ERP)
were identified and resolved before loading into this layer.

### Data Quality Issues Fixed
| Issue                         | Action Taken                                       |
|-------------------------------|----------------------------------------------------|
| Duplicate records             | Detected and removed using ROW_NUMBER()            |
| NULL / missing values         | Replaced NULLs with 0 or 'n/a' where applicable   |
| Inconsistent text values      | Standardized abbreviations to full readable text   |
| Unwanted spaces / characters  | Trimmed whitespace, removed hyphens and prefixes   |
| Inconsistent date formats     | Validated and cast all dates to DATE format        |

---

## CRM Source Tables

### 1. **silver.crm_cust_info**
- **Purpose:** Cleaned and standardized customer data from the CRM system.
- **Source:** `bronze.crm_cust_info`

| Column Name         | Data Type   | Description                              | Cleaning Applied                                              |
|---------------------|-------------|------------------------------------------|---------------------------------------------------------------|
| cust_id             | INT         | Unique numerical identifier for each customer. | Removed duplicates using ROW_NUMBER(); excluded cust_id = 0. |
| cust_key            | VARCHAR     | Alphanumeric customer reference code.    | No transformation applied.                                    |
| cust_firstname      | VARCHAR     | Customer's first name.                   | Trimmed leading/trailing whitespace using TRIM().             |
| cust_lastname       | VARCHAR     | Customer's last name.                    | Trimmed leading/trailing whitespace using TRIM().             |
| cust_marital_status | VARCHAR     | Customer's marital status.               | Standardized: 'M' → 'Married', 'S' → 'Single', else → 'n/a'.|
| cust_gndr           | VARCHAR     | Customer's gender.                       | Standardized: 'M' → 'Male', 'F' → 'Female', else → 'n/a'.   |
| cust_create_date    | DATE        | Date the customer record was created.    | No transformation applied; loaded as-is.                      |

---

### 2. **silver.crm_prd_info**
- **Purpose:** Cleaned and standardized product data from the CRM system.
- **Source:** `bronze.crm_prd_info`

| Column Name  | Data Type | Description                                              | Cleaning Applied                                                    |
|--------------|-----------|----------------------------------------------------------|---------------------------------------------------------------------|
| prd_id       | INT       | Unique product identifier.                               | No transformation applied.                                          |
| cat_id       | VARCHAR   | Category ID extracted from product key.                  | Extracted first 5 characters of prd_key; hyphens replaced with underscores. |
| prd_key      | VARCHAR   | Product key after removing category prefix.              | Extracted from character 7 onwards of the original prd_key.         |
| prd_nm       | VARCHAR   | Descriptive name of the product.                         | No transformation applied.                                          |
| prd_cost     | INT       | Base cost of the product.                                | NULLs replaced with 0 using IFNULL().                               |
| prd_line     | VARCHAR   | Product line classification.                             | Standardized: 'M' → 'Mountain', 'R' → 'Road', 'S' → 'Other Sales', 'T' → 'Touring', else → 'n/a'. |
| prd_start_dt | DATE      | Date the product became available.                       | Cast to DATE format.                                                |
| prd_end_dt   | DATE      | Derived end date for the product version.                | Derived using LEAD() window function minus 1 day.                   |

---

### 3. **silver.crm_sales_details**
- **Purpose:** Cleaned transactional sales data from the CRM system.
- **Source:** `bronze.crm_sales_details`

| Column Name  | Data Type | Description                                  | Cleaning Applied                                                                 |
|--------------|-----------|----------------------------------------------|----------------------------------------------------------------------------------|
| sls_ord_num  | VARCHAR   | Unique identifier for each sales order.      | No transformation applied.                                                       |
| sls_prd_key  | VARCHAR   | Product key linked to the products table.    | No transformation applied.                                                       |
| sls_cust_id  | INT       | Customer ID linked to the customers table.   | No transformation applied.                                                       |
| sls_order_dt | DATE      | Date the order was placed.                   | Invalid values (0 or length ≠ 8) set to NULL; valid values cast to DATE.         |
| sls_ship_dt  | DATE      | Date the order was shipped.                  | Invalid values (0 or length ≠ 8) set to NULL; valid values cast to DATE.         |
| sls_due_dt   | DATE      | Payment due date for the order.              | Invalid values (0 or length ≠ 8) set to NULL; valid values cast to DATE.         |
| sls_sales    | INT       | Total monetary value of the sale.            | NULLs, negatives, and mismatches recalculated as sls_quantity × sls_price.       |
| sls_quantity | INT       | Number of units ordered.                     | No transformation applied.                                                       |
| sls_price    | INT       | Price per unit of the product.               | NULLs and negatives recalculated as sls_sales ÷ sls_quantity.                    |

---

## ERP Source Tables

### 4. **silver.erp_cust_az12**
- **Purpose:** Cleaned customer demographic data from the ERP system.
- **Source:** `bronze.erp_cust_az12`

| Column Name | Data Type | Description                                          | Cleaning Applied                                               |
|-------------|-----------|------------------------------------------------------|----------------------------------------------------------------|
| cid         | VARCHAR   | ERP customer ID mapped to CRM customer key.          | Removed 'NAS' prefix where present using SUBSTRING().          |
| bdate       | DATE      | Customer date of birth.                              | Future dates (> today) set to NULL.                            |
| gen         | VARCHAR   | Customer gender from ERP system.                     | Standardized: 'M' → 'Male', 'F' → 'Female', blank → 'n/a'.   |

---

### 5. **silver.erp_loc_a101**
- **Purpose:** Cleaned customer location/country data from the ERP system.
- **Source:** `bronze.erp_loc_a101`

| Column Name | Data Type | Description                          | Cleaning Applied                                                              |
|-------------|-----------|--------------------------------------|-------------------------------------------------------------------------------|
| cid         | VARCHAR   | Customer ID linked to erp_cust_az12. | Removed hyphens using REPLACE().                                              |
| cntry       | VARCHAR   | Country of residence.                | Standardized: 'DE' → 'Germany', 'US'/'USA' → 'United States', blank/NULL → 'n/a'. |

---

### 6. **silver.erp_px_cat_g1v2**
- **Purpose:** Product category and subcategory reference data from the ERP system.
- **Source:** `bronze.erp_px_cat_g1v2`

| Column Name | Data Type | Description                                          | Cleaning Applied               |
|-------------|-----------|------------------------------------------------------|--------------------------------|
| id          | VARCHAR   | Unique identifier for the product category.          | No transformation applied.     |
| cat         | VARCHAR   | Broad product category (e.g., Bikes, Components).    | No transformation applied.     |
| subcat      | VARCHAR   | More specific product subcategory classification.    | No transformation applied.     |
| maintenance | VARCHAR   | Indicates if the product requires maintenance.       | No transformation applied.     |

---

## Full Summary of Cleaning Applied

| Cleaning Type                 | Tables Affected                                              |
|-------------------------------|--------------------------------------------------------------|
| Removed duplicates          | silver.crm_cust_info                                         |
| Handled NULLs               | silver.crm_prd_info, silver.crm_sales_details                |
| Standardized text values    | silver.crm_cust_info, silver.erp_cust_az12, silver.erp_loc_a101, silver.crm_prd_info |
| Removed spaces / characters | silver.crm_cust_info, silver.erp_loc_a101, silver.erp_cust_az12 |
| ✅ Standardized date formats   | silver.crm_sales_details, silver.erp_cust_az12               |
