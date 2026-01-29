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


CREATE OR ALTER PROCEDURE bronze.load_bronze as
BEGIN
	DECLARE @start_time DateTime, @end_time Datetime, @batch_start_time Datetime, @batch_end_time Datetime;
	BEGIN TRY 
	    set @batch_start_time = GETDATE();
		print '======================================';
		print 'Loading Bronze Layer';
		print '======================================';

		print '---------------------------------------';
		print 'Loading CRM table' ;
		print '--------------------------------------';

		set @start_time = GETDATE();
		print '>> Truncating Table : bronze_crm_cust_info';
		TRUNCATE TABLE bronze_crm_cust_info;

		print '>> Inserting Data Into : bronze_crm_cust_info';
		BULK INSERT bronze_crm_cust_info
		FROM 'C:\Users\tamit\Desktop\sql-ultimate-course\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';


		set @start_time = GETDATE();
		print '>> Truncating Table : bronze_crm_prd_info';
		TRUNCATE TABLE bronze_crm_prd_info;
		print '>> Inserting Data Into : bronze_crm_prd_info';

		BULK INSERT bronze_crm_prd_info
		FROM 'C:\Users\tamit\Desktop\sql-ultimate-course\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';


		set @start_time = GETDATE();
		print '>> Truncating Table : bronze_crm_sales_details';
		TRUNCATE TABLE bronze_crm_sales_details;

		print '>> Inserting Data Into : bronze_crm_sales_details';
		BULK INSERT bronze_crm_sales_details
		FROM 'C:\Users\tamit\Desktop\sql-ultimate-course\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';


		print '---------------------------------------';
		print 'Loading CRM table' ;
		print '--------------------------------------';
		
		set @start_time = GETDATE();	
		print '>> Truncating Table : bronze_erp_cust_az12';
		TRUNCATE TABLE bronze_erp_cust_az12;
	
		print '>> Inserting Data Into : bronze_erp_cust_az12';
		BULK INSERT bronze_erp_cust_az12
		FROM 'C:\Users\tamit\Desktop\sql-ultimate-course\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';


		set @start_time = GETDATE();
		print '>> Truncating Table : bronze_erp_loc_a101';
		TRUNCATE TABLE bronze_erp_loc_a101;

		print '>> Inserting Data Into : bronze_erp_loc_a101';
		BULK INSERT bronze_erp_loc_a101
		FROM 'C:\Users\tamit\Desktop\sql-ultimate-course\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';


		set @start_time = GETDATE();
		print '>> Truncating Table : bronze_erp_px_cat_g1v2';
		TRUNCATE TABLE bronze_erp_px_cat_g1v2;

		print '>> Inserting Data Into : bronze_erp_px_cat_g1v2';
		BULK INSERT bronze_erp_px_cat_g1v2
		FROM 'C:\Users\tamit\Desktop\sql-ultimate-course\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		set @end_time = GETDATE();
		print'>> Load Duration '+ Cast(DATEDIFF(Second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------------';
		
		set @batch_end_time = GETDATE();
		print'=============================='
		print'Loading Bronze Layer Completed'
		Print'   -> Whole Bronze Batch Duration '+ Cast(DATEDIFF(Second, @batch_start_time, @batch_end_time)as nvarchar)+ ' Seconds';
		print'=============================='
	END TRY
	BEGIN CATCH
	Print '====================================';
	print'Error Message' + Error_Message();
	print'Error Message' + Cast(Error_Number() as nvarchar);
	print'Error Message' + Cast(Error_State() as nvarchar);	
	Print '====================================';
	END CATCH 

END;

EXEC bronze.load_bronze

