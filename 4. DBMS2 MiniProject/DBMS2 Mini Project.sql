 /*
Composite data of a business organisation, confined to ‘sales and delivery’ domain is given for the period of last decade. From the given data retrieve solutions for the given scenario.*/
select * from cust_dimen;
select * from market_fact;
select * from orders_dimen;
select * from prod_dimen;
select * from shipping_dimen;






-- 1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)
##select * from cust_dimen a join market_fact b on a.cust_id=b.Cust_id join prod_dimen c

create table combined_table as (
select * from market_fact where cust_id in 
(select cust_id from cust_dimen where ord_id in
(select ord_id from orders_dimen where prod_id in
(select prod_id from prod_dimen where ship_id in 
(select ship_id from shipping_dimen)

))));
select * from combined_table;
drop table combined_table;



-- 2. Find the top 3 customers who have the maximum number of orders

##select b.customer_name,a.ord_id,a.cust_id, a.order_quantity from market_fact as a join cust_dimen as b using(cust_id) order by Order_Quantity desc limit 3;
select customer_name,cust_id,sum1 from
(select cust_id,sum(order_quantity) as sum1 from market_fact group by Cust_id ) as df join cust_dimen as pp using(cust_id) order by sum1 desc limit 3;
-- 3. Create a new column DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
(select order_id ,str_to_date(ship_date,'%d-%m-%YYYY')-str_to_date(order_date,'%d-%m-%YYYY') as difference from orders_dimen as a
join shipping_dimen as b using (order_id)); 

-- 4. Find the customer whose order took the maximum time to get delivered.
select order_id,max(difference) from 
(select order_id ,str_to_date(ship_date,'%d-%m-%YYYY')-str_to_date(order_date,'%d-%m-%YYYY') as difference from orders_dimen as a
join shipping_dimen as b using (order_id) ) as rrt ;

-- 5. Retrieve total sales made by each product from the data (use Windows function)

select ord_id,prod_id,round(sum(sales) over( order by sales desc),2) as total_sales from market_fact group by Prod_id;

-- 6. Retrieve total profit made from each product from the data (use windows function)
select a.prod_id,a.product_category,a.product_sub_category,sum(profit) over(order by profit) as sum_of_profit from market_fact as b join
prod_dimen as a using(prod_id) group by Prod_id;


-- 7. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011


(select distinct cust_id  from market_fact as a join orders_dimen b using(ord_id)  where month(str_to_date(order_date,'%d-%m-%YYYY') )=1  and year( str_to_date(order_date,'%d-%m-%YYYY')=2011) );

select count(distinct cust_id) from orders_dimen b join market_fact a on a.ord_id=b.ord_id where month(str_to_date(order_date,'%d-%m-%YYYY'))!=1 and year(str_to_date(order_date,'%d-%m-%YYYY'))=2011 and cust_id in (select a.cust_id from orders_dimen b join market_fact a on a.ord_id=b.ord_id where month(str_to_date(order_date,'%d-%m-%YYYY'))=1 group by cust_id);


-- 8. Retrieve month-by-month customer retention rate since the start of the business.(using views)
/* Tips:
#1: Create a view where each user’s visits are logged by month, allowing for 
the possibility that these will have occurred over multiple # years since 
whenever business started operations
# 2: Identify the time lapse between each visit. So, for each person and for each 
month, we see when the next visit is.
# 3: Calculate the time gaps between visits
# 4: categorise the customer with time gap 1 as retained, >1 as irregular and 
NULL as churned
# 5: calculate the retention month wise */



