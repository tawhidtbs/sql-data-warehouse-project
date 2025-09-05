/*
===========================================================
Quality Checks
===========================================================
Script Purpose:
	This script performs various quality checks for data 
	consistency, accuracy and standardization across the
	'silver' schemas. It includes checks for:
	- Null or duplicate primary keys.
	- Unwanted spaces in string fields.
	- Data standardization and consistency.
	- Invalid date ranges and orders.
	- Data consistency between related fields.
	
Useage Notes:
	- Run these checks after data loading silver layer.
	- Investigate and resolve any discrepancies found during 
	  the checks.
============================================================
*/

-- Exploring the data
-- =====================================================
-- Checking for related fields.
-- =====================================================

  SELECT TOP 5 * FROM silver.crm_cust_info;
  SELECT TOP 5 * FROM silver.crm_prd_info;
  SELECT TOP 5 * FROM silver.crm_sales_details;
  SELECT TOP 5 * FROM silver.erp_cust_az12;
  SELECT TOP 5 * FROM silver.erp_loc_a101;
  SELECT TOP 5 * FROM silver.erp_px_cat_g1v2;


-- =====================================================
-- Checking silver.crm_cust_info.
-- =====================================================

 -- Check for Nulls or Duplicates in the Primary Key
 -- Expectation: No Result

 SELECT 
	cst_id,
	COUNT(*)
 FROM silver.crm_cust_info
 GROUP BY cst_id
 HAVING COUNT(*) > 1 OR cst_id IS NULL;
 
-- Check for unwanted spaces on each column
-- Expectation: No Results

SELECT 
	cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Data Standardization & Consistency

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

-- =====================================================
-- Checking silver.crm_prd_info.
-- =====================================================

-- Check for Nulls or Duplicates in the Primary Key
-- Expectation: No Result

SELECT 
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Nulls or Negative numbers in the Product cost
-- Expectation: No Result

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization & Consistency

SELECT
	DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders
-- Expectation: No Results

SELECT 
	*
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- =====================================================
-- Checking silver.crm_sales_details.
-- =====================================================

-- Checking for unwanted spaces in all the columns
-- Expectation: No Result

SELECT 
	 sls_ord_num,
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check for Nulls or Duplicates in the Primary Key
-- Expectation: No Result

SELECT 
	sls_ord_num,
	COUNT(*)
FROM silver.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1 OR sls_ord_num IS NULL

 
-- Checking for missing keys in other connecting tables
-- Expectation: No Result

SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id
FROM silver.crm_sales_details
--WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- Checking for Invalid Dates

SELECT
	NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0 
	OR LEN(sls_ship_dt) != 8 
	OR sls_ship_dt > 20501231	-- Outliers
	OR sls_ship_dt < 19001231	-- Outliers

SELECT 
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
FROM silver.crm_sales_details
WHERE  sls_order_dt > sls_ship_dt
	OR sls_order_dt > sls_due_dt

-- Check the quality of data
-- Check Data Consistency: Between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, Zero or Negative
-- Expectation: No Result

SELECT 
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL;

-- =====================================================
-- Checking silver.erp_cust_az12.
-- =====================================================

-- Checking for missing keys in other connecting tables
-- Expectation: No Result

SELECT
	cid,
	bdate,
	gen
FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info);

-- Check for out of range date

SELECT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1900-12-31' OR bdate > GETDATE();

-- Data Standardization & Consistency

SELECT DISTINCT
	gen
FROM silver.erp_cust_az12;

-- =====================================================
-- Checking silver.erp_loc_a101.
-- =====================================================

-- Checking for unwanted spaces in all the columns
-- Expectation: No Result

SELECT
	cid,
	cntry
FROM silver.erp_loc_a101
WHERE cntry != TRIM(cntry)
	OR cntry IS NULL;


-- =====================================================
-- Checking silver.erp_px_cat_g1v2.
-- =====================================================

-- check missing values & Unwanted space

SELECT DISTINCT
	id,
	cat,
	subcat,
	maintenance
FROM silver.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance)
	OR maintenance IS NULL;
