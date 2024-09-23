--recommened solution
SELECT s.user_id,

COALESCE(ROUND(COUNT(CASE WHEN c.action = 'confirmed' THEN 1 ELSE null END)::NUMERIC / NULLIF
(COUNT(*),0),2),0) AS confirmation_rate 

FROM Signups s 
LEFT JOIN Confirmations  c ON s.user_id = c.user_id
GROUP BY  s.user_id
--my query
with confirm as (
	select s.user_id, count(action) as rate 
		from signups as s
			left join  confirmations
       		 on s.user_id = confirmations.user_id
     where action = 'confirmed'    
        group by s.user_Id, action, confirmations.user_id),
		
	total as (
    	select s.user_id, 
			case when s.user_id = cm.user_id 
				then count(*) 
      		 	 else null end
         	as total
   		from  signups as s
    		left join confirmations as cm
    			on s.user_id = cm.user_id
    	group by cm.user_id, s.user_id)
	select s.user_id, case when rate <>0 
		then round(rate/total::decimal,2)
 			else 0 
			 end
    	as confirmation_rate
	from signups as s
		left join total 
			on s.user_id = total.user_id
		left join confirm
			on s.user_id = confirm.user_id 

--1211 leetcode
with q as (
        select query_name, result, rating,
      rating/position::numeric as rate from queries
      group by query_name, result, rating, position
      )
  
    select distinct q.query_name,
  round(
     sum(rate)
        /
        count(q.query_name)
        ,2) as quality,
  round(
        count(case when rating < 3 then 1 else null end)
    *100  /
     count(q.query_name)::decimal
     ,2) as poor_query_percentage
    from q
    where q.query_name is not null
     group by  q.query_name 
--1193. my solution
select to_char(trans_date,'yyyy-mm') as month, country,
    count(id) as trans_count, 
    count(state) filter (where state ='approved') as approved_count ,
    sum(amount) as trans_total_amount, 
    sum(case when state ='approved' then amount else 0 end) as approved_total_amount
from transactions
group by month,country
--1731. recommended solution
WITH managers AS(
    SELECT reports_to AS employee_id,
            COUNT(reports_to) AS reports_count,
            ROUND(AVG(age)) AS average_age
    FROM Employees
    WHERE reports_to IS NOT NULL
    GROUP BY reports_to
)

SELECT employee_id,
        name,
        reports_count,
        average_age
FROM managers AS m
INNER JOIN Employees AS e
USING(employee_id)
ORDER BY employee_id;
--1164. recommended solution: using first_value(expression) in window functions
-- first_value will returns the first value of expression partition by columnX and order by column Y
select product_id, coalesce(price, 10) as price
from (
    select distinct product_id from products
) as unique_products
left join (
    select distinct product_id,
    first_value(new_price) over (partition by product_id order by change_date desc) as price
    from 
    products
    where change_date <= '2019-08-16'
) as last_price
using(product_id)
--1204. my solution using first_value
  with bus as (
    select person_id, person_name, sum(weight) over(
    order by turn
        ) as total_weight
from queue
      )
    select distinct first_value(person_name) over(
        order by total_weight desc) as person_name from bus where total_weight <= 1000 


--1907. recommended solution
SELECT 'Low Salary' AS category, --display a string 'Low Salary' in all rows of accounts table alias Category column 
       COUNT(income) FILTER (WHERE income < 20000) AS accounts_count
FROM accounts

UNION ALL

SELECT 'Average Salary' AS category, 
       COUNT(income) FILTER (WHERE income BETWEEN 20000 AND 50000) AS accounts_count
FROM accounts

UNION ALL

SELECT 'High Salary' AS category, 
       COUNT(income) FILTER (WHERE income > 50000) AS accounts_count
FROM accounts;
--626. my solution
with cte as(
	select id, student, 
		lag(id,1) over( order by id) as odd
    from seat),
   o as(
     select case when 
	 	mod(max(id),2) = 1 then max(id) 
          else null 
         end as last,student
      from seat
    group by id,student
    order by id desc limit 1),
    e as(
        select id,student, lead(id,1) over(order by id) as even from seat)
    select distinct id, student from (
        select distinct odd as id,student from cte
            where  mod(odd,2) = 1
                union
        select distinct even as id, student from e
            where mod(even,2) = 0
                union
        select last as id, student from o)
        where id is not null
    order by id
--RECOMMENDED SOLUTION (2 WAYS)
SELECT
    CASE
        WHEN id % 2 = 1 AND id < (SELECT MAX(id) FROM Seat) 
        THEN id + 1
        WHEN id % 2 = 0 THEN id - 1
       ELSE id
    END AS id,
    student
FROM
    Seat
ORDER BY
    id ASC;
/* */
with max_id as (select max(id) as max_id from Seat) 

select id, case when id % 2 = 1 and id in (select max_id from max_id) then student
                when  id % 2 = 1 then lead(student,1) over (order by id) 
                when id % 2 = 0 then lag(student) over (order by id)
           end as student
from Seat  	
--1321. recommended solution
/*Over ( Partition by
		Order by 
		[Rows between X/Unbounded Preceding and Current Row] 
		[Rows Between Current and Y Rows Following] 
	can just be used in window functions
	Unbounded = from the start to the current row / from the current row to the end*/
WITH amount_by_date AS (
    SELECT
        visited_on,
        SUM(amount) AS amount
    FROM
        Customer
    GROUP BY
        visited_on
    ORDER BY
        visited_on ASC
), moving_avg AS (
    SELECT
    visited_on,
    (CASE WHEN ROW_NUMBER() OVER(ORDER BY visited_on) >= 7 
	THEN SUM(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) ELSE NULL END) AS amount,
    (CASE WHEN ROW_NUMBER() OVER(ORDER BY visited_on) >= 7 
	THEN AVG(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) ELSE NULL END) AS average_amount,
    (CASE WHEN ROW_NUMBER() OVER(ORDER BY visited_on) >= 7 
	THEN COUNT(*) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) ELSE NULL END) AS window_size
FROM
    amount_by_date
)


SELECT
    visited_on,
    amount,
    ROUND(average_amount, 2) AS average_amount
FROM
    moving_avg
WHERE
    window_size >= 7
--585. my solution

select round(sum(tiv_2016)::decimal,2) as tiv_2016 
    from (
      select pid,  tiv_2015, tiv_2016, 
        count(tiv_2015) over(
            partition by tiv_2015
        ) as num_2015,
       count((lat,lon)) over( partition by (lat,lon)
            order by (lat,lon)
        ) as lat_lon
       from insurance
       order by num_2015
        )  
     where num_2015 > 1
    and lat_lon =1
     