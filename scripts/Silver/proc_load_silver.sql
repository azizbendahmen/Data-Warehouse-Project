create or alter procedure Silver.load_silver as
Begin
	
		print'====================='
		print'Loading Silver Layer'
		print'====================='


		print'====================='
		print'Loading CRM'
		print'====================='

   		truncate table Silver.crm_cust_info
		insert into Silver.crm_cust_info(	
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		select
			cst_id, cst_key, 
			trim(cst_firstname), 
			trim(cst_lastname),
	
			case when upper(trim(cst_marital_status)) = 'M' then 'Maried'
				when upper(trim(cst_marital_status)) = 'S' then 'Single'
				else 'n/a'
			end cst_marital_status,

			case when upper(trim(cst_gndr)) = 'M' then 'Male'
				when upper(trim(cst_gndr)) = 'F' then 'Female'
				else 'n/a'
			end cst_gndr,

			cst_create_date
		from(
			select 
				*,
				ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) firstr
			from Bronze.crm_cust_info 
			where cst_id is not null) t
		where firstr = 1 

		truncate table Silver.crm_prd_info
		insert into Silver.crm_prd_info(
			prd_id,
			prd_key ,
			prd_nm ,
			prd_cost ,
			prd_line,
			prd_start_dt,
			prd_end_dt 
		)
		select	
			prd_id,
			replace(substring(trim(prd_key), 1 ,5), '-', '_') prd_key,
			trim(prd_nm) as prd_nm,
			coalesce(prd_cost , 0) as prd_cost,
			case when upper(trim(prd_line)) ='M' then 'Mountain'
				when upper(trim(prd_line)) ='R' then 'Road'
				when upper(trim(prd_line)) ='S' then 'Other Sales'
				when upper(trim(prd_line)) ='T' then 'Touring'
				else 'n/a'
			 end prd_line,
			cast(prd_start_dt as date) as prd_start_dt,
			cast( 
				cast(lead(prd_start_dt) over( partition by prd_key order by prd_start_dt) as datetime) - 1 as date) as prd_end_dt
		from Bronze.crm_prd_info
		
		truncate table Silver.crm_sales_details
		insert into Silver.crm_sales_details(
			sls_ord_num ,
			sls_prd_key,
			sls_cust_id ,
			sls_order_dt ,
			sls_ship_dt,
			sls_due_dt  ,
			sls_sales ,
			sls_quantity ,
			sls_price 
		)
		select 
			trim(sls_ord_num)  as sls_ord_num,
			trim(sls_prd_key) as sls_prd_key,
			sls_cust_id,

			case when len(sls_order_dt)!= 8 or sls_order_dt = 0 then null
				else cast(cast(sls_order_dt as nvarchar) as date) 
			end sls_order_dt,

			case when len(sls_ship_dt)!= 8 or sls_ship_dt = 0 then null
				else cast(cast(sls_ship_dt as nvarchar) as date) 
			end sls_ship_dt,

			case when len(sls_due_dt)!= 8 or sls_due_dt = 0 then null
				else cast(cast(sls_due_dt as nvarchar) as date) 
			end sls_due_dt,

			case when sls_sales <0 or sls_sales is null or sls_sales!= sls_quantity * abs(sls_price) then  sls_quantity * abs(sls_price)
				else sls_sales
			end sls_sales,

			sls_quantity,

			case when sls_price <0 or sls_price is null or sls_price != sls_sales / coalesce(sls_quantity , 0) then sls_sales / coalesce(sls_quantity , 0)
				else sls_price
			end sls_price
		from Bronze.crm_sales_details



	
		print'====================='
		print'Loading ERP'
		print'====================='
		
		truncate table Silver.erp_loc_a101
		insert into Silver.erp_loc_a101(
			cid ,
			cntry
		)
		select 
			replace(cid, '-', ''),
			case when trim(cntry) ='DE' then 'Germany'
				 when trim(cntry) in ('USA','US') then 'United States'
				 when trim(cntry)='' or cntry is null then 'n/a'
				 else trim(cntry)
			end cntry
		from Bronze.erp_loc_a101
		
		
		truncate table Silver.erp_cust_az12
		insert into Silver.erp_cust_az12(
			cid,
			bdate,
			gen 
		)
		select 
			substring(cid, 4,len (cid)) cid,
			case when bdate> GETDATE() then null
				else bdate
			end dbate,
			case when trim(gen) in ('Female', 'F') then 'Female'
				 when trim(gen) in ('Male','M') then 'Male'
				 when trim(gen)='' or gen is null then 'n/a'
			end gen
		from Bronze.erp_cust_az12
		
		
		
		truncate table Silver.erp_px_cat_g1v2
		insert into Silver.erp_px_cat_g1v2(
			id,
			cat ,
			subcat ,
			maintenance 
		)
		select * 
		from Bronze.erp_px_cat_g1v2


		

END

EXEC Silver.load_silver


