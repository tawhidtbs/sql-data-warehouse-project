/*
================================================================================
DDL Script: Create Gold Views
================================================================================
Script Purpose:
	The script creates views for the Gold Layer in the data warehouse.
	The Gold Layer represents the final dimension and fact tables (Star Schema)
	
	Each view performs transformations and combines data from the
	Silver Layer to produce a clean, enriched and business-ready dataset.
	
Usage:
	- These views can be queried directly for analytics and reporting.
================================================================================
*/

--=================================================
-- Create Dimension:gold.dim_customers 
--=================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
	 ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	 ci.cst_id AS customer_id,
	 ci.cst_key AS customer_number,
	 ci.cst_firstname AS firstname,
	 ci.cst_lastname AS lastname,
	 cl.cntry AS country,
	 ci.cst_marital_status AS marital_status,
	 CASE
		WHEN ci.cst_gndr = 'Unknown' THEN COALESCE(cb.gen, 'Unknown')
		ELSE ci.cst_gndr
	 END AS gender,
	 cb.bdate AS birthdate,
	 ci.cst_create_date AS create_date		 
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 cb
ON ci.cst_key = cb.cid
LEFT JOIN silver.erp_loc_a101 cl
ON ci.cst_key = cl.cid;
	
	
	
--=================================================
-- Create Dimension: gold.dim_products View
--=================================================	
	
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY prd_start_dt, prd_key) AS product_key,
	pr.prd_id AS product_id,
	pr.prd_key AS product_number,
	pr.prd_nm AS product_name,
	pr.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pr.prd_line AS product_line,
	pr.prd_cost AS cost,
	pc.maintenance,
	pr.prd_start_dt AS start_date
FROM silver.crm_prd_info pr
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pr.cat_id = pc.id
WHERE prd_end_dt IS NULL;


--=================================================
-- Create Fact: gold.fact_sales View
--=================================================


IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
	cs.sls_ord_num AS order_number,
	gp.product_key,
	gc.customer_key,
	cs.sls_order_dt AS order_date,
	cs.sls_ship_dt AS shipping_date,
	cs.sls_due_dt AS due_date,
	cs.sls_sales AS sales_amount,
	cs.sls_quantity AS quantity,
	cs.sls_price AS price
FROM silver.crm_sales_details cs
LEFT JOIN gold.dim_products gp
ON cs.sls_prd_key = gp.product_number
LEFT JOIN gold.dim_customers gc
ON cs.sls_cust_id = gc.customer_id;
