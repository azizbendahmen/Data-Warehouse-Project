-- Check the data model connectivity between fact and dimensions
select * 
from Gold.fact_sales f
left join Gold.dim_customer c
on c.customer_key = f.customer_key
left join Gold.dim_product p
on p.product_key = f.product_key
where p.product_key is null or c.customer_key is null  
