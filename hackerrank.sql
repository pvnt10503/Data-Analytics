create table submissions (
  submission_date date,
  submission_id int,
  hacker_id int,
  score int
  
);

create table hackers (
  hacker_id int,
  name varchar(20)
);

insert into submissions values
('2016-03-01', 8494, 20703, 0),('2016-03-01', 22403, 53473,15),
('2016-03-01',23965,79722,60),('2016-03-01',30173,36396,70),
('2016-03-02',34928,20703,0),('2016-03-02',38740,15758,60),
('2016-03-02',42769,79722,25),('2016-03-02',44364,79722,60),
('2016-03-03',45440,20703,0),('2016-03-03',49050,36396,70),
('2016-03-03',50273,79722,5),('2016-03-04',50344,20703,0),
('2016-03-04',51360,44065,90),('2016-03-04',54404,53473,65),
('2016-03-04',61533,79722,45),('2016-03-05',72852,20703,0),
('2016-03-05',74546,38289,0),('2016-03-05',76487,62529,0),
('2016-03-05',82439,36396,10),('2016-03-05',90006,36396,40),
('2016-03-06',90404,20703,0);

insert into hackers values 
(15758, 'Rose'),(20703, 'Angela'),
(36396,'Frank'),(38289, 'Patrick'),
(44065, 'Lisa'),(53473,'Kimberly'),
(62529, 'Bonnie'),(79722, 'Michael');


--Solving:
with count_sub as
(select submission_date, hacker_id
		from submissions
		),
	id as (select hacker_id,name from hackers)
	select submission_date, id.hacker_id, name
	from count_sub, id
	group by submission_date, id.hacker_id,name
order by submission_date


--Nháp
with count_sub as
(select submission_date, count(hacker_id) as s_count, hacker_id,
	 row_number()
		over( partition by submission_date
		order by submission_date)
		from submissions
		group by submission_date, hacker_id),

--Solution
 
 WITH Submissions_Count AS (
    SELECT hacker_id, submission_date, COUNT(*) as submissions
    FROM Submissions
    GROUP BY hacker_id, submission_date
),
Day_Hacker_Rankings AS (
    SELECT sc.submission_date,
        sc.hacker_id,
        hkr.name,
        ROW_NUMBER() OVER(PARTITION BY sc.submission_date ORDER BY sc.submissions DESC, sc.hacker_id) as day_rank
    FROM Submissions_Count sc
    LEFT JOIN Hackers hkr
    ON sc.hacker_id = hkr.hacker_id
),
Day_Top_Hackers AS (
    SELECT submission_date,
        hacker_id,
        name
    FROM Day_Hacker_Rankings
    WHERE day_rank = 1
),
Day_Ranking AS (
    SELECT submission_date,
        hacker_id,
        DENSE_RANK() OVER(ORDER BY submission_date) as day
    FROM Submissions
),
Hackers_Streak AS (
    SELECT dr.submission_date,
        dr.hacker_id, 
        (   SELECT COUNT(DISTINCT submission_date)
            FROM Submissions s
            WHERE s.hacker_id = dr.hacker_id
            AND s.submission_date <= dr.submission_date
        ) as streak,
        day
    FROM Day_Ranking dr
),
Full_Streak_Hackers AS (
    SELECT submission_date, 
        COUNT(DISTINCT hacker_id) AS users_count
    FROM Hackers_Streak
    WHERE streak = day
    GROUP BY submission_date   
)

SELECT fs.submission_date,
    fs.users_count,
    th.hacker_id,
    th.name
FROM Full_Streak_Hackers fs
JOIN Day_Top_Hackers th
ON fs.submission_date = th.submission_date;

--
create table Occupations(
Name varchar,
Occupation varchar
)
insert into Occupations values
('Samantha','Doctor'),('Julia','Actor'),('Maria','Actor'),('Meera','Singer'),
('Ashley','Professor'),('Ketty','Professor'),('Christeen','Professor'),
('Jane','Actor'),('Jenny','Doctor'),('Priya','Singer')
select*from occupations

select name,occupation, row_number() over(
partition by occupation
order by name)
from occupations
CREATE EXTENSION IF NOT EXISTS tablefunc;

WITH OccupationRanks AS (
    SELECT name,
           occupation,
           ROW_NUMBER() OVER (PARTITION BY occupation ORDER BY name) AS row_num
    FROM OCCUPATIONS
)
SELECT *
FROM crosstab(
    'SELECT occupation, row_num, name 
     FROM OccupationRanks 
     ORDER BY occupation, row_num',
    'VALUES (''Doctor''), (''Professor''), (''Singer''), (''Actor'')'
) AS pivot_table(row_num INT, Doctor TEXT, Professor TEXT, Singer TEXT, Actor TEXT);


WITH Ranked AS ( 
	SELECT Name, Occupation, ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name)
		AS row_num 
	FROM Occupations ) 
	SELECT MIN(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
		MIN(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor, 
		MIN(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer, 
		MIN(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor FROM Ranked 
GROUP BY row_num ORDER BY row_num;

create table company (
	company_code varchar,
	founder varchar);
create table lead_manager(lead_manager_code varchar, company_code varchar);
create table senior_manager (senior_manager_code varchar,lead_manager_code varchar, company_code varchar);
create table manager(manager_code varchar,
	senior_manager_code varchar, 
	lead_manager_code varchar, 
	company_code varchar);
create table employee (employee_code varchar, manager_code varchar,
senior_manager_code varchar,lead_manager_code varchar, company_code varchar);
insert into company values ('C1','Monika'),('C2','Samantha');
insert into lead_manager values ('LM1','C1'),('LM2','C2');
insert into senior_manager values ('SM1','LM1','C1'),('SM2','LM1','C1'),('SM3','LM2','C2');
insert into manager values ('M1','SM1','LM1','C1'),
				('M2','SM3','LM2','C2'),
				('M3','SM3','LM2','C2');
insert into employee values('E1','M1','SM1','LM1','C1'),
	('E2','M1','SM1','LM1','C1'),
	('E3','M2','SM3','LM2','C2'),
	('E4','M3','SM3','LM2','C2');


with lm as (select  company_code, count(lead_manager_code)as total_lm from lead_manager
           group by company_code),
    sm as (select company_code, count(senior_manager_code) as total_sm from                 senior_manager
           group by company_code),
    mg as (select company_code, count(manager_code) as total_mg from manager
          group by company_code),
	em as (select company_code,count(employee_code) as total_em from employee group by company_code)
select distinct company.company_code, founder, total_lm, total_sm,total_mg,total_em from company,
lm,sm,mg,em;


with lm as (select  company_code, count(lead_manager_code)as total_lm from lead_manager
           group by company_code);

----solving (solved)
  select comp.company_code,comp.founder, 
  r_num_lm, 
  r_num_sm, 
 COUNT( mg_num) as num_mg,
 em_num from company as comp
INNER JOIN(
	select lm.company_code, lm.lead_manager_code, 
		dense_rank() over(partition by lm.lead_manager_code
			order by lm.company_code) as r_num_lm,COUNT(sm.r_num) as r_num_sm
	from lead_manager as lm
			INNER JOIN 
				(select company_code,lead_manager_code, substring(senior_manager_code for 3),
			dense_rank() over (partition by senior_manager_code) as r_num
			from senior_manager) as sm
		on lm.lead_manager_code = sm.lead_manager_code
	group by lm.company_code,lm.lead_manager_code	
		) as common
	on comp.company_code = common.company_code
INNER JOIN 
		(SELECT mg0.manager_code, mg0.company_code,
		dense_rank() over (partition by mg0.manager_code) as mg_num
		,COUNT(em.r_em_num) as em_num
			from manager as mg0
	INNER JOIN
		(select *,
		dense_rank() over(partition by manager_code) as r_em_num
		from employee) as em
		on mg0.company_code = em.company_code
		group by mg0.manager_code,mg0.company_code
		) 
			as mg1
			on comp.company_code = mg1.company_code 
group by comp.company_code, comp.founder, common.r_num_sm,mg1.em_num,r_num_lm
order by comp.company_code;



SELECT c.company_code, c.founder, 
    COUNT(DISTINCT e.lead_manager_code),
    COUNT(DISTINCT S.senior_manager_code), 
    COUNT(DISTINCT m.manager_code), 
    COUNT(DISTINCT e.employee_code) 
FROM company c
    JOIN employee as e ON c.company_code = e.company_code 
	JOIN senior_manager as s on c.company_code = s.company_code
	Join manager as m on c.company_code = m.company_code
    GROUP BY c.company_code, c.founder 
    ORDER BY c.company_code;	

