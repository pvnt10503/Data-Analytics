
create table sales (
    "customer_id" varchar(1),
    "order_date" date,
    "product_id" int
);
insert into sales values
    ('A', '2021-01-01', '1'),
    ('A', '2021-01-01', '2'),
    ('A', '2021-01-07', '2'),
    ('A', '2021-01-10', '3'),
    ('A', '2021-01-11', '3'),
    ('A', '2021-01-11', '3'),
    ('B', '2021-01-01', '2'),
    ('B', '2021-01-02', '2'),
    ('B', '2021-01-04', '1'),
    ('B', '2021-01-11', '1'),
    ('B', '2021-01-16', '3'),
    ('B', '2021-02-01', '3'),
    ('C', '2021-01-01', '3'),
    ('C', '2021-01-01', '3'),
    ('C', '2021-01-07', '3');
create table menu (
    "product_id" int, 
    "product_name" varchar(5), 
    "price" int
    );
insert into menu values 
    (1,'sushi',10),
    (2,'curry',15),
    (3,'ramen',12);

create table members (
    "customer_id" varchar(1),
    "join_date" date
    );
 insert into members values
        ('A','2021-01-07'),
        ('B','2021-01-09');
select * from menu
select * from sales


/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
select customer_id, sum(price) as total_spent from sales
    left join menu
        on sales.product_id = menu.product_id
    group by customer_id;
-- 2. How many days has each customer visited the restaurant?
    select distinct sales.customer_id, count(distinct order_date) as visit_day 
    from sales
    group by sales.customer_id

-- 3. What was the first item from the menu purchased by each customer?
select distinct customer_id, product_name from 
    (
        select *, dense_rank() over(partition by customer_id order by order_date) as rnk from sales
        ) as s
    left join menu as m
        on s.product_id = m.product_id
    where rnk = 1


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 product_name, count(s.product_id) as most_purchased from menu
    left join sales as s
        on menu.product_id = s.product_id
    group by product_name
    order by count(s.product_id) desc;

-- 5. Which item was the most popular for each customer?
with cte as (
    select customer_id, product_id, count(product_id) as total from sales 
    group by customer_id,product_id
    ),
    cte1 as (
    select customer_id, product_id, dense_rank() over(partition by customer_id order by total) as rnk
    from cte
    )
select cte1.customer_id, product_name from cte1
    left join menu as m
        on m.product_id = cte1.product_id
    where rnk = 1

-- 6. Which item was purchased first by the customer after they became a member?
select distinct s.customer_id, 
    first_value(product_name) over(partition by s.customer_id order by order_date) as after_join
    from sales as s
        left join menu
        on menu.product_id = s.product_id
        left join members
        on members.customer_id = s.customer_id
where order_date > join_date



-- 7. Which item was purchased just before the customer became a member?
select distinct s.customer_id, product_name from( 
    select s.customer_id, product_id, order_date,dense_rank()
    over(partition by s.customer_id order by order_date desc) as rn from sales as s
        left join members
        on members.customer_id = s.customer_id
where order_date < join_date 
        ) as s
        left join menu
        on menu.product_id = s.product_id
        where rn = 1
    

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(s.product_id) as quantity, concat('$ ',sum(price)) as total_spent 
    from (
        select s1.* from sales as s1
        left join members
        on members.customer_id = s1.customer_id
        where order_date < join_date 
    ) as s
        left join menu
            on menu.product_id = s.product_id
group by s.customer_id
order by customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte3 as (
    select customer_id, product_name,
       case when product_name ='sushi' then sum(price)*20
        else sum(price)*10
        end as points
    from sales as s
    left join menu
        on s.product_id = menu.product_id
    group by customer_id, product_name
    )

    select cte3.customer_id, sum(points) as total_points from cte3
    group by cte3.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
with cte4 as(
    select s.customer_id, price*count(s.product_id)*20 as bonus from (
        select s1.* from sales as s1
            left join members
                on members.customer_id = s1.customer_id
            where order_date >= join_date
            and month(order_date) = 1
    ) as s
    left join menu
        on s.product_id = menu.product_id
    group by s.customer_id, price
    )
select cte4.customer_id, sum(bonus) as bonus_points from cte4
    group by cte4.customer_id

--BONUS QUESTION:
select s.customer_id, order_date, product_name, price, case 
    when s.customer_id = members.customer_id and order_date >= join_date then 'Y'
    else 'N' 
    end as member
    from sales as s
    left join menu on menu.product_id = s.product_id
    left join members on members.customer_id = s.customer_id
--RANKING ALL THE THINGS:
with cte5 as (
    select s.customer_id, order_date, product_name, price, case 
        when s.customer_id = members.customer_id and order_date >= join_date then 'Y'
        else 'N' 
        end as member
    from sales as s
        left join menu on menu.product_id = s.product_id
        left join members on members.customer_id = s.customer_id
    )
    select customer_id, order_date, product_name, price, case when 
            member = 'Y' then dense_rank() over(partition by customer_id,member order by order_date) 
            else null 
            end as ranking
        from cte5
