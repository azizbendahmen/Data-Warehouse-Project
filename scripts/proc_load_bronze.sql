/*
-- To use this procedure :
exec Bronze.load_bronze
*/ 

CREATE OR ALTER PROCEDURE Bronze.load_bronze as
begin
	declare @start_time datetime , @end_time datetime;
	declare @start_time_bronze datetime , @end_time_bronze datetime;
	begin try
		set @start_time_bronze =getdate()
		print('Loading Bronze Layer');
		
		print('Loading CRM Tables');

		set @start_time =getdate()
		truncate table Bronze.crm_cust_info
		bulk insert Bronze.crm_cust_info
		from 'C:\Users\benda\Desktop\sql\DWH_project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with(
			firstrow = 2,
			fieldterminator =',',
			tablock
		);
		set @end_time =getdate()
		print ('load duration = ' + cast(datediff(second, @end_time, @start_time) as varchar)+' seconds')


		set @start_time =getdate()
		truncate table Bronze.crm_prd_info
		bulk insert Bronze.crm_prd_info
		from 'C:\Users\benda\Desktop\sql\DWH_project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with(
			firstrow = 2,
			fieldterminator =',',
			tablock
		);
		set @end_time =getdate()
		print ('load duration = ' + cast(datediff(second, @end_time, @start_time) as varchar)+' seconds')

		set @start_time =getdate()
		truncate table Bronze.crm_sales_details
		bulk insert Bronze.crm_sales_details
		from 'C:\Users\benda\Desktop\sql\DWH_project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with(
			firstrow = 2,
			fieldterminator =',',
			tablock
		);
		set @end_time =getdate()
		print ('load duration = ' + cast(datediff(second, @end_time, @start_time) as varchar)+' seconds')

		
		print('Loading ERP Tables');

		set @start_time =getdate()
		truncate table Bronze.erp_cust_az12
		bulk insert Bronze.erp_cust_az12
		from 'C:\Users\benda\Desktop\sql\DWH_project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		with(
			firstrow = 2,
			fieldterminator =',',
			tablock
		);
		set @end_time =getdate()
		print ('load duration = ' + cast(datediff(second, @end_time, @start_time) as varchar)+' seconds')

		set @start_time =getdate()
		truncate table Bronze.erp_loc_a101
		bulk insert Bronze.erp_loc_a101
		from 'C:\Users\benda\Desktop\sql\DWH_project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with(
			firstrow = 2,
			fieldterminator =',',
			tablock
		);
		set @end_time =getdate()
		print ('load duration = ' + cast(datediff(second, @end_time, @start_time) as varchar)+' seconds')

		set @start_time =getdate()
		truncate table Bronze.erp_px_cat_g1v2
		bulk insert Bronze.erp_px_cat_g1v2
		from 'C:\Users\benda\Desktop\sql\DWH_project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with(
			firstrow = 2,
			fieldterminator =',',
			tablock
		);
		set @end_time =getdate()
		print ('load duration = ' + cast(datediff(second, @end_time, @start_time) as varchar)+' seconds')


		set @end_time_bronze =getdate()
		print ('loading bronze layer duration = ' + cast(datediff(second, @end_time_bronze, @start_time_bronze) as varchar)+' seconds')
	end try

	begin catch 
	print('error happend during loading bronze layer');
	print('error massege'+error_message());
	print('error massege'+ cast (error_number() as nvarchar));
	print('error massege'+ cast (error_state() as nvarchar));
	end catch
end
