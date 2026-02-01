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

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO


------- Creating Gold.dim_customers table----------

CREATE VIEW gold.dim_customers as 
SELECT 
ROW_NUMBER() over (order by cst_id) as customer_key,
ct.cst_id as customer_id,
ct.cst_key as customer_number,
ct.cst_firstname as first_name,
ct.cst_lastname as last_name,
el.cntry as country,
ca.bdate as birth_date,
case 
	when ct.cst_gndr != 'n/a' then ct.cst_gndr
	else coalesce (ca.gen, 'n/a')
end as gender,
ct.cst_marital_status as marital_status,
ct.cst_create_date

from silver.crm_cust_info as ct


LEFT JOIN silver.erp_cust_az12 as ca
ON ct.cst_Key = ca.cid

LEFT JOIN silver.erp_loc_a101 as el
ON ct.cst_key = el.cid


-------Creating gold.dim_products table ---------
CREATE VIEW gold.dim_products as 
select
ROW_NUMBER () over (ORDER BY pr.prd_start_dt, pr.prd_key) as product_key,
pr.prd_id as product_id,
pr.prd_key as product_number,
pr.prd_nm as product_name,
pr.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance as maintenance,
pr.prd_cost as cost,
pr.prd_line as line,
pr.prd_start_dt as start_date

from silver.crm_prd_info as pr
LEFT JOIN silver.erp_px_cat_g1v2 as pc
ON pr.cat_id = pc.id
where prd_end_dt is null 




----------Creating gold.fact_sales table--------------
create view gold.fact_sales as
select 
sd.sls_ord_num as order_number ,
pr.product_key,
dc.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date ,
sd.sls_due_dt as due_date,
sd.sls_sales as sales,
sd.sls_quantity as quantity ,
sd.sls_price as price
from silver.crm_sales_details as sd

LEFT JOIN gold.dim_products pr
on sd.sls_prd_key = pr.product_number

LEFT JOIN gold.dim_customers dc
on sd.sls_cust_id = dc.customer_id

select * from gold.dim_products


