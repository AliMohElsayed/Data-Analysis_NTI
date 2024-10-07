-- create database bikeStore;
use bikestore;
		##to show all data 
select * from brands ;
select * from customers ;
select * from categories ;
select * from stores ;
select * from stocks ;
select * from staffs ;
select * from products ;
select * from orders ;
select * from order_items ;

			##1- Which bike is most expensive? What could be the motive behind pricing this bike at the high price?
select product_name,max(list_price) as max from products
group by product_name
ORDER BY max DESC
limit 1; 
			##2- How many total customers does BikeStore have? Would you consider people with order status 3 as customers substantiate your answer?
SELECT 
    COUNT(customer_id) AS total_customer
FROM
    customers;
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers
FROM
    orders
WHERE
    order_status != 3;
    
			##3- How many stores does BikeStore have?
select count(store_id) as numbers_of_stores from stores;

			##4- What is the total price spent per order? total price = [list_price] *[quantity]*(1-[discount])
SELECT 
    order_id,
    (list_price * quantity * (1 - discount)) AS total_price
FROM
    order_items;
    
			##5- What’s the sales/revenue per store? Sales revenue = ([list_price] *[quantity]*(1-[discount]))
SELECT 
    st.store_name,
    ROUND(SUM(list_price * quantity * (1 - discount)),
            3) AS Sales_revenue
FROM
    order_items AS order_items
        INNER JOIN
    orders AS od ON order_items.order_id = od.order_id
        INNER JOIN
    stores AS st ON st.store_id = od.store_id
GROUP BY st.store_name;

			##6- Which category is most sold?
SELECT 
    cate.category_name,
    SUM(order_items.quantity) AS total_quantity
FROM
    order_items
        INNER JOIN
    products AS pd ON order_items.product_id = pd.product_id
        INNER JOIN
    categories AS cate ON cate.category_id = pd.category_id
GROUP BY cate.category_name
ORDER BY total_quantity DESC
LIMIT 1;

			##7- Which category rejected more orders?
SELECT 
    cate.category_name,
    COUNT(od.order_id) AS rejected_orders,
    od.order_status
FROM
    categories AS cate
        INNER JOIN
    products AS pd ON cate.category_id = pd.category_id
        INNER JOIN
    order_items AS it ON pd.product_id = it.product_id
        INNER JOIN
    orders AS od ON it.order_id = od.order_id
WHERE
    od.order_status = 3
GROUP BY cate.category_name
ORDER BY rejected_orders DESC
LIMIT 1; ##most category rejected 

			##8- Which bike is the least sold?
SELECT 
    pd.product_name, od.order_date
FROM
    products AS pd
        INNER JOIN
    order_items AS it ON it.product_id = pd.product_id
        INNER JOIN
    orders AS od ON od.order_id = it.order_id
ORDER BY od.order_date 
LIMIT 1;

				##9- What’s the full name of a customer with ID 259?
SELECT 
    customer_id, CONCAT(first_name, ' ', last_name) AS Full_name
FROM
    customers
WHERE
    customer_id = 259;

			##10- What did the customer on question 9 buy and when? What’s the status of this order?
SELECT 
    CONCAT(first_name, ' ', last_name) AS FULL_NAME,
    od.order_date,
    od.order_status,
    pd.product_name
FROM
    customers AS cs
        INNER JOIN
    orders AS od ON cs.customer_id = od.customer_id
        INNER JOIN
    order_items AS it ON od.order_id = it.order_id
        INNER JOIN
    products AS pd ON it.product_id = pd.product_id
WHERE
    cs.customer_id = 259;
    
			##11- Which staff processed the order of customer 259? And from which store?
SELECT 
    od.customer_id,
    od.order_id,
    CONCAT(st.first_name, ' ', st.last_name) AS Staff_name,
    store.store_name
FROM
    staffs AS st
        INNER JOIN
    orders AS od ON st.staff_id = od.staff_id
        INNER JOIN
    stores AS store ON st.store_id = store.store_id
WHERE
    od.customer_id = 259;
    
			##12- How many staff does BikeStore have? Who seems to be the lead Staff at BikeStore?
SELECT 
    COUNT(staff_id) AS total_Staff
FROM
    staffs;
    
			##13- Which brand is the most liked? equal to more sales
SELECT 
    bd.brand_name, SUM(o.quantity) AS more_sales
FROM
    brands AS bd
        INNER JOIN
    products p ON bd.brand_id = p.brand_id
        INNER JOIN
    order_items o ON p.product_id = o.product_id
GROUP BY bd.brand_name
ORDER BY more_sales DESC
LIMIT 1;           
            
			##14- How many categories does BikeStore have, and which one is the least liked?
SELECT 
    COUNT(*) AS total_categories
FROM
    categories;
SELECT 
    c.category_name, SUM(o.quantity) AS more_sales
FROM
    categories c
        INNER JOIN
    products p ON c.category_id = p.category_id
        INNER JOIN
    order_items o ON p.product_id = o.product_id
GROUP BY c.category_name
ORDER BY more_sales
LIMIT 1;

			##15- Which store still have more products of the most liked brand?
-- Step 1: Get the most liked brand into view (v_brand)
CREATE VIEW v_brand AS
    SELECT 
        bd.brand_name
    FROM
        brands AS bd
            INNER JOIN
        products p ON bd.brand_id = p.brand_id
            INNER JOIN
        order_items o ON p.product_id = o.product_id
    GROUP BY bd.brand_name
    ORDER BY SUM(o.quantity) DESC
    LIMIT 1;
-- Step 2: Find the store with the most stock of the view
SELECT 
    st.store_name,
    st.phone,
    st.city,
    SUM(si.quantity) AS total_product
FROM
    stores AS st
        INNER JOIN
    stocks si ON st.store_id = si.store_id
        INNER JOIN
    products p ON si.product_id = p.product_id
        INNER JOIN
    brands bd ON p.brand_id = bd.brand_id
WHERE
    bd.brand_name = (SELECT 
            brand_name
        FROM
            v_brand)
GROUP BY st.store_name , st.phone , st.city
ORDER BY total_product DESC
LIMIT 1;

			##16- Which state is doing better in terms of sales?
SELECT 
    st.state,
    st.city,
    SUM(it.quantity) AS total_quantity,
    COUNT(od.order_id) AS total_sales,
    ROUND(SUM(it.list_price * it.quantity), 3) AS total_money
FROM
    stores AS st
        INNER JOIN
    orders AS od ON st.store_id = od.store_id
        INNER JOIN
    order_items AS it ON od.order_id = it.order_id
GROUP BY st.state , st.city
ORDER BY total_sales DESC
LIMIT 1;

			##17- What’s the discounted price of product id 259?
SELECT 
    pd.product_name,
    pd.list_price,
    it.discount,
    ROUND(pd.list_price - (pd.list_price * it.discount / 100),
            2) AS discounted_price
FROM
    products AS pd
        INNER JOIN
    order_items AS it ON pd.product_id = it.product_id
WHERE
    pd.product_id = 259;
    
			##18- What’s the product name, quantity, price, category, model year and brand name of product number 44?           
select pd.product_id as product_number,pd.product_name, sum(sc.quantity) as Total_quantity, pd.list_price,ct.category_name,pd.model_year,bd.brand_name 
from products as pd inner join brands as bd on pd.brand_id = bd.brand_id 
inner join categories as ct on pd.category_id = ct.category_id 
inner join stocks as sc on pd.product_id = sc.product_id
where pd.product_id = 44
group by pd.product_name,pd.list_price,ct.category_name,pd.model_year,bd.brand_name;

			##19- What’s the zip code of CA?
SELECT DISTINCT
    state, zip_code
FROM
    customers
WHERE
    state = 'CA';
    
			##20- How many states does BikeStore operate in?
SELECT 
    COUNT(DISTINCT state) AS Total_states
FROM
    customers;

			##21- How many bikes under the children category were sold in the last 8 months?
--             WHERE ct.category_name LIKE 'children%' AND od.order_date >= DATE_SUB(CURDATE(), INTERVAL 8 MONTH);
select distinct ct.category_name,  od.order_date, sum(it.quantity) as total_bike_sold
from categories as ct inner join products as pd on ct.category_id = pd.category_id
inner join order_items as it on pd.product_id = it.product_id 
inner join orders as od on od.order_id = it.order_id
where ct.category_name  like "children%" and order_date between '2018-05-01' and '2018-12-30' 
group by ct.category_name, od.order_date ;

			##22- What’s the shipped date for the order from customer 523?
select CONCAT(cs.first_name, ' ', cs.last_name) AS Full_name, od.shipped_date
from orders as od inner join customers as cs on cs.customer_id=od.customer_id
where od.customer_id = 523;

			##23- How many orders are still pending? where order status = 1 is pending
select order_status,count(order_id) as total_orders_pending from orders where order_status = 1 group by order_status;


			##24- What’s the names of category and brand does "Electra white water 3i - 2018" fall under?
select cs.category_name,bd.brand_name,pd.product_name,pd.model_year from products as pd
inner join categories as cs on cs.category_id= pd.category_id
inner join brands as bd on pd.brand_id=bd.brand_id
where pd.product_name = "Electra white water 3i - 2018";