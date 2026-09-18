
/*
===========================================================
stored procedure: load bronze layer  [source-->bronze]
==============================================================

script purpose:
   This stored procedure loads data into the 'bronze' schema from external csv files.
   It Performs the following :
   - truncates the bronze tables before loading the data 
   -uses bulk insert command to load from csv files 

parameters:
none
this stored procedure doesnot accept any parameter or return any value

usage example:
EXEC bronze.load_bronze;

=====================================
*/

create or alter procedure bronze.load_bronze as
begin 
    declare @start_time datetime,@end_time datetime,@batch_start_time datetime,@batch_end_time datetime;
           begin try
           set @batch_start_time=getdate();
                print'======================================='
                print 'loading bronze layer'
                print '======================================='


                print '----------------------------------------'
                print 'LOADING CRM TABLES'
                PRINT '----------------------------------------'

                set @start_time=getdate();
                print '>>> truncating the table: bronze.crm_cust_info'
                TRUNCATE table bronze.crm_cust_info
                print '>>> inserting data into the table: bronze.crm_cust_info'
                BULK INSERT bronze.crm_cust_info 
                from 'C:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
                with( 
                       FIRSTROW=2,
                       FIELDTERMINATOR=',',
                       TABLOCK
                                    )
                set @end_time=getdate();
                print '.....load duration :: '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds' ;
                print '----------------------'

                set @start_time=getdate();
                 print '>>> truncating the table: bronze.crm_prd_info'
                 TRUNCATE table bronze.crm_prd_info
                 print '>>> inserting data into the table: bronze.crm_prd_info'
                 BULK INSERT bronze.crm_prd_info
                 from 'C:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
                 with( 
                       FIRSTROW=2,
                       FIELDTERMINATOR=',',
                       TABLOCK
                       )
                    set @end_time=GETDATE();
                    print '...loading time:: '+cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds' ;
                    print '----------------'
                 set @start_time=GETDATE();
                 print '>>> truncating the table: bronze.crm_sales_details'
                 TRUNCATE table bronze.crm_sales_details
                 print '>>> inserting data into  the table: bronze.crm_sales_details'
                 BULK INSERT bronze.crm_sales_details
                 from 'C:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
                 with( 
                            FIRSTROW=2,
                            FIELDTERMINATOR=',',
                            TABLOCK
                              )
                  set @end_time=GETDATE();
                  print '...loading time:: '+cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds' ;
                  print '----------------'
                 print '----------------------------------------'
                 print 'LOADING ERP TABLES'
                 PRINT '----------------------------------------'
                 set @start_time=GETDATE();
                 print '>>> truncating the table: bronze.erp_cust_az12'
                 TRUNCATE table bronze.erp_cust_az12
                 print '>>> inserting data into the table: bronze.erp_cust_az12'
                 BULK INSERT bronze.erp_cust_az12
                 from 'C:\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
                 with( 
                        FIRSTROW=2,
                        FIELDTERMINATOR=',',
                        TABLOCK
                                    )
                  set @end_time=GETDATE();
                  print '...loading time:: '+cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds' ;
                  print '----------------'

                  set @start_time=GETDATE();
                  print '>>> truncating the table: bronze.erp_loc_a101'
                  TRUNCATE table bronze.erp_loc_a101
                  print '>>> inserting data into table: bronze.erp_loc_a101'
                  BULK INSERT bronze.erp_loc_a101
                  from 'C:\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
                  with( 
                       FIRSTROW=2,
                       FIELDTERMINATOR=',',
                        TABLOCK
                                    )
                   set @end_time=GETDATE();
                   print '...loading time:: '+cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds' ;
                   print '----------------'
                   print '>>> truncating the table: bronze.erp_px_cat_g1v2'


                   set @start_time=GETDATE();
                   TRUNCATE table bronze.erp_px_cat_g1v2

                   print '>>> inserting data into the table: bronze.erp_px_cat_g1v'
                    BULK INSERT bronze.erp_px_cat_g1v2
                    from 'C:\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
                    with( 
                            FIRSTROW=2,
                            FIELDTERMINATOR=',',
                            TABLOCK
                                    )
                    set @end_time=GETDATE();
                    print '...loading time:: '+cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds' ;
                    print '----------------'
                    print  '----------========---------------'
                    set @batch_end_time=GETDATE();
                    print '-loading bronze layer is completed-'
                    print '...load tot duration:: '+cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + ' seconds' ;
                    print '---------==========-------'
       end try
       begin catch
                  print'======================================='
                  print 'error message ocured'
                  print 'error message'+error_message();
                  print 'error message '+cast(error_number() as nvarchar)
                  print 'error message'+cast(error_state() as nvarchar)
                   print '======================================='
       end catch
end 








            
