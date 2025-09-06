/*
==================================================================
Quality Checks
==================================================================
Script Purpose:
	This script performs various quality checks to validate 
	integrity, consistency and accuracy of the Gold Layer.
	These checks ensure:
	- uniqueness of surrogate keys in the dimension tables.
	- Referential integrity between fact and dimension tables.
	- validation of relationships in the data model for 
	  analytical purposesl.
	
Useage Notes:
	- Run these checks after executing the Gold layer DDL script.
	- Investigate and resolve any discrepancies found during 
	  the checks.
===================================================================
*/


--================================================
-- Checking 'gold.dim_customers'
--================================================
-- Check for uniqueness of Customer Key in gold.dim_customers
-- Expectation: No Results

SELECT
	customer_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


--================================================
-- Checking 'gold.dim_products'
--================================================
-- Check for uniqueness of Product Key in gold.dim_products
-- Expectation: No Results

SELECT
	product_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


--================================================
-- Checking 'gold.fact_sales'
--================================================
-- Check the data model connectivity between fact and dimensions

SELECT *
FROM gold.fact_sales fact f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE c.customer_key IS NULL 
OR p.product_key IS NULL;
