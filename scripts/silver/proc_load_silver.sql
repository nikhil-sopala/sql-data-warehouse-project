/*
======================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
======================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.
Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
======================================================
*/
create or alter procedure silver.load_silver as
begin 
BEGIN TRY 
declare @start_time datetime,@end_time datetime,@batch_start_time datetime,@batch_end_time datetime
    set @batch_start_time=getdate()
	set @start_time=getdate()
	 print '================================================='
	 print '::::::::::::::LOADING SILVER LAYER::::::::::'
	 print'================================================='


	 PRINT '-------------------------------------------------'
	 PRINT ':::::::LOADING CRM TABLES ::::::::::::::::::'
	 PRINT '-------------------------------------------------'

		print '>>>truncatng table:silver.crm_cust_info'
		truncate table silver.crm_cust_info;
		print '>>>inserting into table:silver.crm_cust_info'
		insert into silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)
		select cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname,
		trim(cst_lastname) as cst_lastname,
		case
		when upper(cst_marital_status)='M' then 'Married' 
		when upper(cst_marital_status)='S' then 'Single' 
		else 'n/a' end as cst_marital_status,
		case
		when upper(cst_gndr)='M' then 'Male' 
		when upper(cst_gndr)='F' then 'Female' 
		else 'n/a' end as cst_gndr,
		cst_create_date
		from(
		select *,row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info ) t where flag_last=1 and cst_id is not null
     set @end_time=getdate()
	 print '------------------------'
	 print 'LOAD DURATION : '+cast(datediff(second,@start_time,@end_time) as varchar)+'seconds'
	 print '------------------------'

	 set @start_time=getdate()
		print '>>>truncatng table:silver.crm_prd_info'
		truncate table silver.crm_prd_info;
		print '>>>inserting into table:silver.crm_prd_info'

		insert into silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt)

		select prd_id,
		replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
		substring(prd_key,7,len(prd_key)) as  prd_key,
		prd_nm,
		isnull(prd_cost,0) as prd_cost,
		case  upper(trim(prd_line))
		when 'M' then 'Mountain'
		when 'R' then 'Road'
		when 'S' then 'Other Sales'
		when 'T' then 'Touring'
		else 'n/a' end as prd_line,
		prd_start_dt,
		dateadd(day,-1,lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)) prd_end_dt
		from bronze.crm_prd_info
		set @end_time=getdate()
		 print '------------------------'
		 print 'LOAD DURATION : '+cast(datediff(second,@start_time,@end_time) as varchar)+'seconds'
		 print '------------------------'

		 set @start_time=getdate()

		print '>>>truncatng table:silver.crm_sales_details'
		truncate table silver.crm_sales_details;
		print '>>>inserting into table:silver.crm_sales_details'
		insert into silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price)
		select 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		case 
			when sls_order_dt <=0 or  len(sls_order_dt) <> 8 then null 
			else cast(cast (sls_order_dt as varchar) as date)
			End as sls_order_dt,
			case 
			when sls_ship_dt <=0 or  len(sls_ship_dt) <> 8 then null 
			else cast(cast (sls_ship_dt as varchar) as date)
			End as sls_ship_dt,
		case 
			when sls_due_dt <=0 or  len(sls_due_dt) <> 8 then null 
			else cast(cast (sls_due_dt as varchar) as date)
			End as sls_due_dt,
		case	
			when sls_sales is null or sls_Sales <=0
			or sls_sales <> sls_quantity * abs(sls_price) 
			then sls_quantity*abs(sls_price) 
			else sls_sales 
				end as sls_sales,         
				sls_quantity,
		case
			when sls_price is null or sls_price<=0
			then sls_sales/nullif(sls_quantity,0) 
			else sls_sales 
			end as sls_price  
		from bronze.crm_sales_details
		set @end_time=getdate()
	 print '------------------------'
	 print 'LOAD DURATION: '+cast(datediff(second,@start_time,@end_time) as varchar)+'seconds'
	 print '------------------------'


	 PRINT'----------------------------------------------'
	 PRINT ':::::::::::LOADING ERP TABLES::::::::::::::::'
	 PRINT '----------------------------------------------'
	 set @start_time=getdate()
		print '>>>truncatng table:silver.erp_cust_az12'
		truncate table silver.erp_cust_az12;
		 print '>>>inserting into table:silver.erp_cust_az12'
		insert into silver.erp_cust_az12(
		cid,
		bdate,gen)
		select 
		case 
		when cid like 'NAS%' then substring(trim(cid),4,len(cid)) 
		else cid end as cid,
		case 
		when bdate>getdate() then null
		else bdate
		end as bdate,
		case  
		when upper(trim(gen)) in ('M','MALE') then 'MALE' 
		when upper(trim(gen)) in ('F','FEMALE') then 'FEMALE'
		else 'n/a'
		end as gen 
		from bronze.erp_cust_az12;
		set @end_time=getdate()
	 print '------------------------'
	 print 'LOAD DURATION : '+cast(datediff(second,@start_time,@end_time) as varchar)+'seconds'
	 print '------------------------'

	 set @start_time=GETDATE()
		print '>>>truncatng table:silver.erp_loc_a101'
		truncate table silver.erp_loc_a101;
		print '>>>inserting into table:silver.erp_loc_a101'
		insert into silver.erp_loc_a101(
		cid,
		cntry
		)
		select 
		replace(cid,'-','') as cid,
		case 
		when trim(cntry)  in ('USA','US') then 'UNITED STATES '
		when Trim(cntry) ='DE' THEN 'GERMANY'
		when Trim(cntry)='' or trim(cntry) is null THEN 'n/a'
		ELSE trim(cntry)
		end as cntry
		from bronze.erp_loc_a101
		set @end_time=getdate()
	 print '------------------------'
	 print 'LOAD DURAAION : '+cast(datediff(second,@start_time,@end_time) as varchar)+'seconds'
	 print '------------------------'

	 set @start_time=getdate()
		print '>>>truncatng table:silver.erp_px_cat_g1v2'
		truncate table silver.erp_px_cat_g1v2;
		print '>>>inserting into table:silver.erp_px_cat_g1v2'
		insert into silver.erp_px_cat_g1v2(
		id,cat,SUBCAT,MAINTENANCE)
		select id,
		cat,
		subcat,
		MAINTENANCE
		from bronze.erp_px_cat_g1v2
		set @end_time=getdate()
	 print '------------------------'
	 print 'LOAD DURATION: '+cast(datediff(second,@start_time,@end_time) as varchar)+'seconds'
	 print '------------------------'

	 set @batch_end_time=getdate()
	 print '------------------------'
	 print 'batch_loading duration	 : '+cast(datediff(second,@batch_start_time,@batch_end_time) as varchar)+'seconds'
	 print '------------------------'

end TRY
BEGIN CATCH
      print'=============================================='
		  print'ERRROR OCCURED DURING THE LOADING SILVER LAYER'
      PRINT 'ERROR MESSAGE'+ERROR_MESSAGE();
		  PRINT 'ERROR MESSAGE'+CAST(ERROR_NUMBER() AS VARCHAR);
      PRINT 'ERROR MESSAGE'+CAST(ERROR_STATE() AS VARCHAR);
		 PRINT'================================================='

END CATCH
END



