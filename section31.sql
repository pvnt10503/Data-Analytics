SELECT*FROM CUSTOMER_ORDER
--CUSTOMER WITH AVG_REVENUE
SELECT CUSTOMER_ID, CUSTOMER_NAME, STATE, SALES_TOT AS REVENUE,
	AVG(SALES_TOT) OVER(
			PARTITION BY STATE) AS AVG_REVENUE	 
	FROM CUSTOMER_ORDER;
--CUSTOMER WITH REVENUE < AVG_REVENUE
SELECT*FROM(SELECT CUSTOMER_ID, CUSTOMER_NAME, STATE, SALES_TOT AS REVENUE,
	AVG(SALES_TOT) OVER(
			PARTITION BY STATE) AS AVG_REVENUE	 
	FROM CUSTOMER_ORDER)
WHERE REVENUE < AVG_REVENUE;
--Create order_rollup_state
CREATE TABLE ORDER_ROLLUP AS SELECT ORDER_ID, MAX(ORDER_DATE) AS ORDER_DATE,
	MAX(CUSTOMER_ID) AS CUSTOMER_ID, SUM(SALES) AS SALES FROM SALES
	GROUP BY ORDER_ID;
CREATE TABLE ORDER_ROLLUP_STATE AS SELECT a.*,b.state from order_rollup as a
	left join customer as b
	on a.customer_id = b.customer_id;
SELECT*FROM ORDER_ROLLUP_state;
select *, sum(sales) 
	over(partition by state) as sales_sate_total
from order_rollup_state;


SELECT*,
	SUM(SALES) 
		OVER (PARTITION BY STATE) AS SALSE_STATE_TOTAL,
	SUM(SALES) 
		OVER (PARTITION BY STATE ORDER BY ORDER_DATE) AS RUNNING_TOTAL
	FROM ORDER_ROLLUP_STATE;
--LAG/LEAD FUNCTION
select customer_id, order_date,order_id,sales,
	lead(sales,2) over(partition by customer_id order by order_date) as previous_sales,
	lead(order_id,2) over(partition by customer_id order by order_date) as previous_order_id
from order_rollup_state;
--To_char: convert number/date into a string
select sales,'Total sales value for this order is ' ||to_char(sales,'$9,999.99') as message
from sales;
select order_date, to_char(order_date,'MonthDD, YYYY'),
	to_char(order_date,'YY-MM-DD')
	from sales;
Select to_date('26122018','ddmmyyyy');
select cast(order_date as date) from sales