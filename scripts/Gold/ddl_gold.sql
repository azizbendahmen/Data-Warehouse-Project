-- Create Dimension: gold.dim_customers

if object_id('Gold.dim_customer' , 'V') is not null
	drop view Gold.dim_customer;
go

create view Gold.dim_customer as
select
	row_number() over(order by ci.cst_id) as customer_key,
	ci.cst_id as customer_id ,
	ci.cst_key as customer_number,
	ci.cst_firstname as firstname,
	ci.cst_lastname as lastname,
	el.cntry as country,
	ci.cst_marital_status as marital_status,
	ec.bdate as birthdate,
	case when ci.cst_gndr != 'n/a'  then ci.cst_gndr
		else coalesce( ec.gen, 'n/a')
	end gender,
	ci.cst_create_date as create_date
from Silver.crm_cust_info as ci
left join Silver.erp_cust_az12  as ec
on ci.cst_key = ec.cid
left join Silver.erp_loc_a101 as el
on ci.cst_key = el.cid;
go


-- Create Dimension: gold.dim_products
if object_id('Gold.dim_product' , 'V') is not null
	drop view Gold.dim_product;
go

create view Gold.dim_product as 
select
    row_number() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) as product_key, -- Surrogate key
    pn.prd_id       as product_id,
    pn.prd_key      as product_number,
    pn.prd_nm       as product_name,
    pn.cat_id       as category_id,
    pc.cat          as category,
    pc.subcat       as subcategory,
    pc.maintenance  as maintenance,
    pn.prd_cost     as cost,
    pn.prd_line     as product_line,
    pn.prd_start_dt as start_date
from Silver.crm_prd_info pn
left join Silver.erp_px_cat_g1v2 pc
    on pn.cat_id = pc.id
where pn.prd_end_dt IS NULL; 
go

-- Create Fact Table: gold.fact_sales
if object_id('Gold.fact_sales' , 'V') is not null
	drop view Gold.fact_sales
go

create view Gold.fact_sales as 
select 
	cs.sls_ord_num as order_number,
	cp.product_key,
	cc.customer_key,
	cs.sls_order_dt as order_date,
	cs.sls_ship_dt shipping_date,
	cs.sls_due_dt due_date,
	cs.sls_sales total_sales,
	cs.sls_quantity quantity ,
	cs.sls_price price
from Silver.crm_sales_details as cs
left join Gold.dim_customer cc
on cs.sls_cust_id = cc.customer_id
left join Gold.dim_product as cp
on cs.sls_prd_key = cp.product_number
go
