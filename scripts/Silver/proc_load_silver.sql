/*
====================================================================
Stored procedure : Load Bronze Layer (source -> bronze)
=====================================================================
script purpose :
		This stored procedure load data into the 'bronze' schema from external csv file .
		it performs the following actions
	-- Truncate the bronze table before loading data 
	-- Uses the ' Bulk Insert 'command to load data from csv files to bronze table 
*/

CREATE OR ALTER PROCEDURE silver.load_silver as
BEGIN 
	  DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME ;
	  BEGIN TRY 
	  set @batch_start_time = GETDATE()
	    print '======================================';
		print 'Loading Silver Layer';
		print '======================================';

		print '---------------------------------------';
		print 'Loading CRM table' ;
		print '--------------------------------------';
	
	set @start_time = GETDATE();
	PRINT'Truncating table: silver.crm_cust_info ';
	TRUNCATE table silver.crm_cust_info;
	PRINT'>> Inserting Data into silver.crm_cust_info ';

	
INSERT INTO silver.crm_cust_info 
	(
	cst_id, 
	cst_key, 
	cst_firstname,
	cst_lastname, 
	cst_marital_status, 
	cst_gndr, 
	cst_create_date
	)
	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname),
		TRIM(cst_lastname),
	CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'n/a'
	END,
	CASE
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		ELSE 'n/a'
	END,
		cst_create_date
	FROM (
		SELECT *,
			   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		FROM bronze.crm_cust_info
	) t
	WHERE flag_last = 1
	  AND cst_id IS NOT NULL
	  AND cst_key IS NOT NULL;

	set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';


 
	set @start_time = GETDATE();
	PRINT'Truncating table: silver.crm_prd_info ';
	TRUNCATE table silver.crm_prd_info;
	PRINT'>> Inserting Data into silver.crm_prd_info '
	INSERT INTO silver.crm_prd_info
	(
			prd_id ,
			cat_id ,
			prd_key ,	
			prd_nm ,
			prd_cost ,
			prd_line ,
			prd_start_dt ,
			prd_end_dt
	)

	select 
	prd_id,
	Replace (substring (prd_key,1,5), '-','_' ) as cat_id,
	substring(prd_key, 7, len(prd_key))         as prd_key,
	
	prd_nm,

	ISNULL (prd_cost, 0 ) as prd_cost,

	Case upper(trim(prd_line))
		when 'R' then 'Road'
		when 'M'then 'Mountain'
		when 'O' then 'Other Sales'
		when 'T' then 'Touring'
		Else 'n/a'
	end as prd_line,
		Cast(prd_start_dt as date) as prd_start_dt,
		cast(
		lead(prd_start_dt) over  (partition by prd_key order by prd_start_dt )-1 
		as date
		) as prd_end_dt -- calculate end date as one day before the next day start
		from bronze.crm_prd_info;
	
	set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';
	

	set @start_time = GETDATE();
	PRINT'Truncating table: silver.crm_sales_details ';
	TRUNCATE table silver.crm_sales_details;
	PRINT'>> Inserting Data into silver.crm_sales_details '

	INSERT INTO silver.crm_sales_details
	(
	sls_ord_num ,
			sls_prd_key,
			sls_cust_id	,
			sls_order_dt ,
			sls_ship_dt ,
			sls_due_dt ,
			sls_sales ,
			sls_quantity ,
			sls_price)



	Select 
	sls_ord_num,
	sls_prd_key	,
	sls_cust_id	,

	CASE 
		WHEN sls_order_dt = 0 or len(sls_order_dt) !=8 then null 
		ELSE CAST(Cast(sls_order_dt as NVARCHAR) as Date )
	END sls_order_dt,

	CASE
		WHEN sls_ship_dt = 0 or len (sls_ship_dt) !=8 then null
		ELSE CAST(Cast(sls_ship_dt as NVARCHAR) as Date ) 
	END sls_ship_dt ,

	CASE
		WHEN sls_due_dt = 0 or len (sls_due_dt) !=8 then null
		ELSE CAST(Cast(sls_due_dt as NVARCHAR) as Date ) 
	END sls_due_dt ,

	Case 
		when sls_sales IS NULL or sls_sales < = 0 or sls_sales != sls_quantity * abs(sls_price) 
		then sls_quantity * abs(sls_price)
		Else sls_sales 
	end as sls_sales,
	sls_quantity,
	Case 
		when sls_price IS NULL or sls_price <=0 
		then sls_sales / NULLIF(sls_quantity,0)
		else sls_price
	end as sls_price
	from bronze.crm_Sales_details
	set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';

	set @start_time = GETDATE();
	PRINT'Truncating table: silver.erp_cust_az12 ';
	TRUNCATE table silver.erp_cust_az12;
	PRINT'>> Inserting Data into silver.erp_cust_az12 '

	INSERT INTO silver.erp_cust_az12
	(
	cid,
	bdate,
	gen
	)
	select 
	case 
		when cid like 'NASA%' then SUBSTRING(cid, 4 , len(cid))
		else cid
	end as cid ,
	case 
		when bdate > getdate() then null 
		else bdate
	end as bdate,
	case 
		 when upper(trim(gen)) IN ('F', 'FEMALE')then  'Female'
		 when upper(trim(gen)) IN ('M', 'MALE') then 'Male'
		 else 'n/a' 
	end as gen 
	from bronze.erp_cust_az12;

	set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';




	set @start_time = GETDATE();
	PRINT'Truncating table: silver.erp_loc_a101 ';
	TRUNCATE table silver.erp_loc_a101;
	PRINT'>> Inserting Data into silver.erp_loc_a101 '


	INSERT INTO silver.erp_loc_a101
	(
	cid,
	cntry
	)
	select 
		replace (cid, '-', '' ) as cid,
	case 
		when upper(trim(cntry)) in ('USA','US','United States') then 'United States'
		when upper(trim(cntry))in ('DE', 'Germany') then 'Germany'
		when upper(trim(cntry)) is null or cntry =  ''  then 'n/a'
		else trim(cntry) 
	end as cntry
	from bronze.erp_loc_a101;

	set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';



	set @start_time = GETDATE();

	PRINT'Truncating table: silver.erp_px_cat_g1v2 ';
	TRUNCATE table silver.crm_cust_info;
	PRINT'>> Inserting Data into silver.erp_px_cat_g1v2 '
	INSERT INTO silver.erp_px_cat_g1v2
	(id,
	cat,
	subcat,
	maintenance)

	select id,
	cat,
	subcat,
	maintenance
	from bronze.erp_px_cat_g1v2 

	set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';
	END TRY
	BEGIN CATCH
	Print '====================================';
	print'Error Message' + Error_Message();
	print'Error Message' + Cast(Error_Number() as nvarchar);
	print'Error Message' + Cast(Error_State() as nvarchar);	
	Print '====================================';
	END CATCH 

END

EXEC silver.load_silver
