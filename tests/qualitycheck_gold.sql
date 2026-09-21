--checking if any dupplicates are there after join logic
select cst_id,count(*) from
(	select 
	  ci.cst_id,
	  ci.cst_key,
	  ci.cst_firstname,
	  ci.cst_lastname,
	  ci.cst_marital_status,
	  ci.cst_gndr,
	  ci.cst_create_date,
	  ca.BDATE,
	  ca.gen,
	  la.cntry
	from silver.crm_cust_info ci left join silver.erp_cust_az12 as ca
	on ci.cst_key=ca.CID
	left join silver.erp_loc_a101 as la
	on ci.cst_key=la.cid )t 
group by cst_id having count(*)>1

--checking data integration issue

select distinct
	  ci.cst_gndr,
	  ca.gen
	from silver.crm_cust_info ci left join silver.erp_cust_az12 as ca
	on ci.cst_key=ca.CID
	left join silver.erp_loc_a101 as la
	on ci.cst_key=la.cid
	order by 1,2 


	
select distinct
	  ci.cst_gndr,
	  ca.gen,
	  case when ci.cst_gndr<>'n/a' then ci.cst_gndr
	else coalesce(ca.gen,'n/a') 
	  end as new_gen
	  
	from silver.crm_cust_info ci left join silver.erp_cust_az12 as ca
	on ci.cst_key=ca.CID
	left join silver.erp_loc_a101 as la
	on ci.cst_key=la.cid
	order by 1,2 


	--checking duplictes for crm_prd and erp_px_cat
	select prd_key,count(*)  from	
	(
	select 
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt,
pc.CAT,	
pc.SUBCAT,
pc.MAINTENANCE
from silver.crm_prd_info pn left join silver.erp_px_cat_g1v2 pc on pn.cat_id =pc.id
where prd_end_dt is null        ---filtritng out alll historic data
)
t group by prd_key having count(*)>1


--FOREIGN KEY INTEGRITY

select * from gold.fact_sales f left join gold.dim_customers c on 
c.customer_key=f.customer_key 
left join gold.dim_products p on f.product_key=p.product_key 
where p.product_key is null
