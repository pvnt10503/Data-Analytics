select*from customer where city in ('Philadelphia','Seattle')
/*like*/select*from customer 
where customer_name like 'J%';
select*from customer 
where customer_name like '%Nelson%';
select*from customer
where customer_name like '____ %';
select distinct city from customer where city not like 'S%';
select distinct city from customer where region in ('North','East');
select*from sales where sales between 100 and 500;
select*from customer where customer_name like '% ____';
--order by
select*from sales where discount > 0 
order by discount desc;
select*from sales where discount > 0 
order by discount desc limit 10;
--as
select customer_id as "Serial Number", customer_name 
as Name, age as Customer_age from customer;
--count function
select count(*) from sales;
/*put a quote when new names get space between character
put a comma when want to continue a previous statement*/
select count(order_line) as "Number of Products Ordered",
count (distinct order_id) as "Number of orders"
From sales where customer_id ='CG-12520';
--Sum function
select sum (profit) as "Total Profit" 
from sales;
select sum (quantity) as "Total Quantity"
from SALEs where product_id = 'FUR-TA-10000577';
--average function
select avg(age) as "Average Customer Age" from customer;
Select avg(sales*0.10) as "Average Commission Value" from sales;
--min and max
select min(sales) as "Minimum sales June 15th" from sales 
where order_date between '2015-06-01' and'2015-06-30'
select max(sales) as "Maximum sales June 15th" from sales 
where order_date between '2015-06-01' and'2015-06-30';
--exercise 8
select sum(sales) from sales
select count(*) from customer
where age between 20 and 30;
select avg(age) from customer
where region = 'East';
select min(age), max(age) from customer where city = 'Philadelphia';
--GROUP BY 
/*select and group by must be the same columns, both numbers and names */select region, count(customer_id) as "Customer Count"
from customer group by region;
select region, state, avg(age) as Age, count(customer_id)as "Customer Count" 
from customer group by region,state;
select product_id, sum(quantity) as "Quantity Sold" from sales group by product_id 
order by "Quantity Sold" desc;
--HAVING is a condition to the group by clause after the function type has been done.
select region, count(customer_id) as "Customer Count" from customer
group by region having count(customer_id)>200 ;
--EXERCISE 9
select product_id, sum(sales) as "Total Sales",
sum(quantity) as "Total Quantity",
count(order_id) as "Total orders", min(sales) as "Minimum Sales",
max(sales) as "Maximum Sales", avg(sales) as "Average Sales" from sales 
group by product_id order by "Total Sales" desc;
/*order of statement: 
select (unique data) - function type - from table_name -(where clause)-group by clause -(having clause) - order by clause*/
select product_id, sum(quantity) as "Quantity of product sold" 
from sales group by product_id having sum(quantity)>10;
--CASE WHEN, quote marks are for alias
select *, case when age<30 then 'Young'
When age>60 then 'Senior Citizen'
Else 'Middle Aged'
End as "Age Category"
from customer;
--Creating sales table of 2015
create table sales_2015 as 
select * from sales where ship_date between '2015-01-01' and '2015-12-31';
select count(*) from sales_2015; --2131
--Customer with age between 20 and 60
create table customer_20_60 as select * from customer where age between 20 and 60;
select count(*) from customer_20_60; --597
--INNER JOIN
/*select: choose what columns to present, give aliases for convenience*/
select a.order_line,a.product_id,a.customer_id,a.sales, b.customer_name,b.age
from sales_2015 as a
inner join customer_20_60 as b
on a.customer_id = b.customer_id
order by customer_id;
--LEFT JOIN
/*if select a.column
data from table A doesn't have corresponding values in table B is presented NULL
data from table B doesn't match with data from table A is removed*/
select a.order_line, a.product_id,a.customer_id,a.sales,b.customer_name,b.age
from sales_2015 as a
left join customer_20_60 as b
on a.customer_id=b.customer_id order by customer_id;
--RIGHT JOIN
/*if select b.column
data from table A which doesn't match table B is not represented
data from table B which doesn't have corresponding values in table B will be presented as NULL
if select a.column
data from table B doesn't match table A will be presented at the bottom and will have NULL valueS in missing column*/
select a.order_line, a.product_id,b.customer_id,a.sales,b.customer_name,b.age
from sales_2015 as a
right join customer_20_60 as b
on a.customer_id = b.customer_id order by customer_id;
--FULL OUTER JOIN
select a.order_line,a.product_id,a.customer_id,a.sales,b.customer_name,b.age,b.customer_id from sales_2015 as a
full join customer_20_60 as b 
on a.customer_id = b.customer_id
order by a.customer_id, b.customer_id;
--CROSS JOIN
create table month_values (MM int)
create table year_values (YYYY int)
insert into month_values values (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)
insert into year_values values (2011),(2012),(2013),(2014),(2015),(2016),(2017),(2018),(2019)
select*from month_values;
select*from year_values;
select a.YYYY,b.MM
from year_values as a cross join month_values as b
order by a.YYYY, b.MM;
--INTERSECT
select customer_id from sales_2015
intersect 
select customer_id from customer_20_60;
--EXCEPT
select customer_id from sales_2015
except
select customer_id from customer_20_60
order by customer_id;
--UNION
select customer_id from sales_2015 
union
select customer_id from customer_20_60
order by customer_id;
--EXERCISE 10
select b.state, sum(sales) as "Total Sales in 2015"
from sales_2015 as a
left join customer_20_60 as b
on a.customer_id = b.customer_id
group by b.state;
--Self-solution
/*FUR-BO-10001798 does not have sales and quantity in product table, therefore when use inner join command,
it will remove this product ID from the returned table*/
select c.*,sum(sales) as "Total Sales",sum(quantity)as "Total Quantity Sold" from product as c
inner join sales as a
on a.product_id = c.product_id
group by c.product_id
order by "Total Sales" asc;
--Proposed Solution
/*FUR-BO-10001798 is present in product table without sales and quantity, 
therefore when using the left join command and group by a.product_id, it will return null in total_sales and total_quantity*/
select a.product_name, sum(b.sales) as total_sales, sum(b.quantity) as total_quantity from product as a
left join sales as b
on b.product_id = a.product_id
group by a.product_id
order by sum(b.sales),sum(b.quantity);
---SUBQUERY
/*subquery in where clause*/
SELECT*from sales where customer_id in 
(select distinct customer_id from customer where age>60 );
/*subquery in from clause = CREATE A TEMPORARY TABLE IN THE STATEMENT*/
select a.product_id,
		a.product_name,
		a.category,
		b.quantity 
	from product as a
left join (select product_id, sum(quantity)as Quantity from sales group by product_id )as b
--this statement will return a table consisting product_id, Quantity as table b
	on a.product_id = b.product_id
	order by b.quantity desc;
/*subquery in select clause*/
select customer_id,order_line,(select customer_name from customer
where sales.customer_id = customer.customer_id)
--shorter than using the join command
from sales
order by customer_id;
--Exercise 11
select a.*, b.customer_name,b.age,c.product_name, c.category
from sales as a
left join (select customer_id,customer_name,age from customer) as b
on a.customer_id=b.customer_id
left join (select product_id, product_name,category from product) as c
on a.product_id = c.product_id
/*sales without customers will still appear.*/
--Recommended solution
select c.customer_name,c.age, sp.*
from customer as c
right join(select s.*, p.product_name,p.category from sales as s
left join product as p
on s.product_id = p.product_id) as sp
on c.customer_id = sp.customer_id;
/* prioritizes the customer
customers who don’t have sales won't appear */
--VIEW
create view logistics as
select a.order_line, a.order_id,b.customer_name,b.city,b.state,b.country
from sales as a
left join customer as b
on a.customer_id = b.customer_id
order by a.order_line;
select*from logistics;
--INDEX
create index mon_idx
on month_values(MM);
--EXERCISE 12
create view Daily_Billing as
select order_line,product_id,sales,discount from sales
order by order_date desc;
drop view Daily_billing
--Length
select customer_name, Length(customer_name) as characters_num
from customer
where age > 30
--REPLACE
select customer_name, country, replace(country,'United States','US')
from customer;
--TRIM
SELECT TRIM(LEADING' ' FROM '  START-TECH ACADEMY         ');
--CONCAT
SELECT CUSTOMER_NAME, CITY||', '||STATE||', '||COUNTRY AS ADDRESS
FROM CUSTOMER;
--substring
select customer_id, customer_name,
substring (customer_id for 2) as cust_group
from customer
where substring(customer_id for 2)='AB';
/*create cust_number,cust_group according to substring
create a segment for analytics*/
select customer_id, customer_name,
substring (customer_id, 4 , 5) as cust_number;

from customer
where substring(customer_id for 2)='AB';
--STRING AGGREGATOR
select order_id, string_agg(product_id,',')
from sales
group by order_id;
/*find out product_id,product name that the order_id carries
1 order_id may order multiple products*/
--EXERCISE 13
select max(length(product_name)) from product;
select product_name,sub_category, category,
(product_name||', '||sub_category||', '||category) as "Product details" from product;
select product_id, substring(product_id for 3)as category_short, 
substring(product_id,5, 2) as sub_short,
substring(product_id,from 8) as id
from product;
select string_agg(product_name,'; ') 
from product
where sub_category in ('Chairs','Tables');
--CEIL&FLOOR
select order_line, sales, ceil(sales), floor(sales) from sales
where discount>0;
select order_line,sales, round(sales) from sales
order by sales desc;
--EXERCISE 14
select customer_id, customer_name, random() as rand_n from customer
order by rand_n limit 5;
/*order by rand_n and limit to 5 to choose random 5 customers*/
select sum(ceil(sales)) as higher_int_sales, sum(floor(sales)) as lower_int_sales,
sum(round(sales)) as round_int_sales from sales;
--DATE,AGE AND EXTRACT FUNCTIONS
select current_date, current_time, current_time(1), current_time(3), current_timestamp
select order_line,order_date,ship_date, age(ship_date,order_date) as time_taken from sales
order by time_taken desc;
select order_date,ship_date,
(extract(epoch from ship_date)- extract(epoch from order_date))as sec_taken
from sales;
--EXERCISE 15
select age(current_date,'April 6 1939');
--My solution
select round(sum(sales)) as "Total Sales", 
extract(month from order_date) as Seasonality 
from sales 
		where product_id in
		(select product_id from product where sub_category = 'Chairs')
	group by seasonality
	order by seasonality
/*product in the Chairs subcategory has the highest sales in September, November and December,
which means that consumers tend to buy chairs in Autumn and Winter to decorate their houses for holidays 
such as Haloween on October 31st, Chrismast, New year...*/
--Recommended Solution
select extract(month from order_date) as month_n,
sum(sales) as total_sales from sales
	where product_id in(select product_id from product where sub_category ='Chairs')
group by month_n
order by month_n;
--Regular Expression
select*from customer 
where customer_name ~*'^a+[a-z\s]+$';
/*insensitive case(~*), a string starts with a and(+) set characters ([]) a to z or (\s)space in the middle,
replicates same rule (+) for others and end the string = $*/
select*from customer
where customer_name ~*'^(a|b|c|d)+[a-z\s]+$';
/*insensitive case(~*), start with 'a,b,c,or d', a-z or space following and 
replicate the same rule for others (+) end the string with any charcters($)*/
select*from customer
where customer_name ~*'^(a|b|c|d)[a-z]{3}\s[a-z]{4}$';
/*insensitive case(~*), start a string with a,b,c or d,
next character in a-z(3times) and space,following is a-z(4times) and end the string $*/
select*from users
where name ~*'[a-z0-9\.\-\_\+@[a-z0-0\-]+\.[a-z][2,5]';
--EXERCISE 16
select*from customer
where customer_name ~*'^[a-z]{5}\s(a|b|c|d)[a-z]{4}$';
create table Zipcode	
(PIN_codes int);
insert into zipcode (pin_codes) 
values	(234432),
		(23345),
		('sdfe4'),
		('123%3'),
		(67424),
		(7895432),
		(12312)
alter table zipcode rename column pin_codes to zipcode
select*from zipcode where zipcode ~'^[0-9]{5,6}$';
--WINDOWS FUNCTION + ROW NUMBER + RANK + DENSERANK + NTILE
select a.*, b.order_num,b.sales_tot,b.quantity_tot,b.profit_tot
	from customer as a
	left join (select customer_id, 
	count( distinct order_id) as order_num, 
	sum(sales) as sales_tot, 
	sum(quantity) as quantity_tot,
	sum(profit) as profit_tot
	from sales
	group by customer_id) 
	as b 
	on a.customer_id = b.customer_id;
	/*combine 2 tables sales and customer, and then count distinct order id (it may be duplicated due to order_date and ship_date)
	sum sales, profit, quantity for future tasks*/
create table customer_order as select a.*, b.order_num,b.sales_tot,b.quantity_tot,b.profit_tot
from customer as a
	left join (select customer_id, 
	count( distinct order_id) as order_num, 
	sum(sales) as sales_tot, 
	sum(quantity) as quantity_tot,
	sum(profit) as profit_tot
	from sales
	group by customer_id) 
	as b
on a.customer_id = b.customer_id;
/*create the table from those data*/
select*from customer_order;
select customer_id,customer_name,state,order_num, row_number() 
	over (partition by state 
			order by order_num desc) as row_n
	from customer_order;
select*from (select customer_id,customer_name,state,order_num, row_number() 
	over (partition by state 
			order by order_num desc) as row_n
	from customer_order) as a
	where a.row_n <=3;
	/*row_n is not available when it is created in over clause 
	-> cannot create and provide the info with a where clause in the same statement
	, there are 2 ways to fix
	1: save the info into other table and use condition
	2: use subquery in from clause*/
SELECT CUSTOMER_ID, CUSTOMER_NAME, STATE,ORDER_NUM,
	row_number() 
		over (partition by state 
			order by order_num desc) as row_n,
	RANK() 
		OVER(PARTITION BY STATE
			ORDER BY ORDER_NUM DESC) AS RANK_N, 
	DENSE_RANK() 
		OVER(PARTITION BY STATE
			ORDER BY ORDER_NUM DESC) AS D_RANK_N,
	NTILE(5) 
		OVER(PARTITION BY STATE
			ORDER BY ORDER_NUM DESC) AS D_RANK_N
FROM CUSTOMER_ORDER;

SELECT CUSTOMER_ID, CUSTOMER_NAME, STATE,ORDER_NUM,
	row_number() 
		over (partition by state 
			order by order_num desc) as row_n,
	RANK() 
		OVER(PARTITION BY STATE
			ORDER BY ORDER_NUM DESC) AS RANK_N, 
	DENSE_RANK() 
		OVER(PARTITION BY STATE
			ORDER BY ORDER_NUM DESC) AS D_RANK_N,
	NTILE(5) 
		OVER(PARTITION BY STATE
			ORDER BY ORDER_NUM DESC) AS TILE_N
FROM CUSTOMER_ORDER;

SELECT* FROM(SELECT CUSTOMER_ID, CUSTOMER_NAME, STATE,ORDER_NUM,
	row_number() 
		over (partition by state 
			order by order_num desc) as row_n,
	RANK() 
		OVER(PARTITION BY STATE
			ORDER BY ORDER_NUM DESC) AS RANK_N, 
	DENSE_RANK() 
		OVER(PARTITION BY STATE
			ORDER BY ORDER_NUM DESC) AS D_RANK_N,
	NTILE(5) 
		OVER(PARTITION BY STATE
			ORDER BY ORDER_NUM DESC) AS TILE_N
FROM CUSTOMER_ORDER) 
WHERE TILE_N = 1

select ship_date, order_date,ship_date - order_date as date_taken from sales
