SELECT * FROM employees

SELECT * FROM salary_history

--Find the latest salary for each employee

with Latest_salary as (SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY EMPLOYEE_ID ORDER BY CHANGE_DATE DESC) AS RK
FROM
    salary_history )

SELECT EMPLOYEE_ID,CHANGE_DATE,SALARY AS LATEST_SALARY from Latest_salary
WHERE RK=1

--Using Qualify

SELECT
    employee_id,
    salary AS latest_salary
FROM salary_history
QUALIFY ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY change_date DESC) = 1;

--Using JOIN

SELECT sh.employee_id, sh.salary
FROM salary_history sh
JOIN (
    SELECT employee_id, MAX(change_date) AS max_date
    FROM salary_history
    GROUP BY employee_id
) latest
ON sh.employee_id = latest.employee_id
AND sh.change_date = latest.max_date;

--Calculate the total number of promotion each employee has received

WITH cte AS (
    SELECT *,
           RANK() OVER(PARTITION BY employee_id ORDER BY change_date DESC) AS rk_desc,
           RANK() OVER(PARTITION BY employee_id ORDER BY change_date ASC) AS rk_asc,
           LEAD(salary,1) OVER(PARTITION BY EMPLOYEE_ID ORDER BY CHANGE_DATE desc) as previous_sal,
           LEAD(change_date,1) OVER(PARTITION BY EMPLOYEE_ID ORDER BY CHANGE_DATE desc) as previous_date,
    FROM salary_history
),
/*latest_salary_cte AS (
    SELECT employee_id, change_date, salary AS latest_salary
    FROM cte
    WHERE rk_desc = 1
),
/*promotion_cte as (SELECT EMPLOYEE_ID,COUNT(*) as no_of_promotions
FROM cte
WHERE PROMOTION='Yes'
GROUP BY EMPLOYEE_ID)*/

--Determine the max salary hike percentage between any two consecutive salary change for each employee
/*,prev_sal as (SELECT *,
LEAD(salary,1) OVER(PARTITION BY EMPLOYEE_ID ORDER BY CHANGE_DATE desc) as previous_sal,
LEAD(change_date,1) OVER(PARTITION BY EMPLOYEE_ID ORDER BY CHANGE_DATE desc) as previous_date
FROM cte ),

max_sal_growth as (SELECT EMPLOYEE_ID,MAX(cast(100*(salary-previous_sal)/previous_sal as decimal(4,2))) as hike_perct FROM cte
group by EMPLOYEE_ID
order by employee_id),*/

--Identify employees whose salaries have never decreased over time
/*demotion as (SELECT EMPLOYEE_ID,CHANGE_DATE,SALARY AS CURRENT_SAL,LEAD(salary,1) OVER(PARTITION BY EMPLOYEE_ID ORDER BY CHANGE_DATE desc) as previous_sal
FROM CTE
ORDER BY EMPLOYEE_ID),

sal_decreased as(
SELECT distinct employee_id,'N'as never_decreased FROM cte
WHERE  SALARY<previous_sal),*/

--Find the avg time in (months) between salary change for each employee
/*avg_month as (SELECT EMPLOYEE_ID,ROUND(AVG(DATEDIFF(month,previous_date,change_date))) as avg_change_in_months FROM cte
GROUP BY EMPLOYEE_ID
ORDER BY EMPLOYEE_ID)*/


--Rank employees by salary growth rate (from first to last recorded salary),breaking the ties by earliest join date

growth_rate AS (
    SELECT 
        EMPLOYEE_ID,
        MAX(CASE WHEN rk_desc = 1 THEN salary END) / NULLIF(MAX(CASE WHEN rk_asc = 1 THEN salary END), 0) as GROWTH,
        MIN(change_date) as join_date
    FROM cte
    GROUP BY EMPLOYEE_ID
    ORDER BY EMPLOYEE_ID
)


/*sal_growth_rank as(
SELECT employee_id,
RANK() OVER(ORDER BY GROWTH DESC,join_date ) as growth_rank 
FROM
growth_rate),*/


SELECT 
    cte.employee_id,
    MAX(CASE WHEN rk_desc = 1 THEN SALARY END) AS LATEST_SALARY,
    SUM(CASE WHEN PROMOTION = 'Yes' THEN 1 ELSE 0 END) AS NO_OF_PROMOTION,
    MAX(CAST(100 * (salary - previous_sal) / previous_sal AS DECIMAL(4,2))) AS hike_perct,
    CASE WHEN MAX(CASE WHEN salary < previous_sal THEN 1 ELSE 0 END) = 0 THEN 'Y' ELSE 'N' END AS NEVER_DECREASED,
    ROUND(AVG(DATEDIFF(MONTH, previous_date, change_date))) AS avg_change_in_months,
    RANK() OVER (ORDER BY gr.GROWTH DESC, gr.join_date) AS growth_rank 
FROM cte 
LEFT JOIN growth_rate gr ON gr.employee_id = cte.employee_id 
GROUP BY cte.employee_id, gr.GROWTH, gr.join_date;

/*
SELECT e.EMPLOYEE_ID,e.NAME,l.latest_salary,IFNULL(p.no_of_promotions,0) as PROMOTION_CNT,msg.hike_perct,IFNULL(sd.never_decreased,'Y') AS never_decreased,am.avg_change_in_months,sg.growth_rank
FROM employees e
LEFT JOIN latest_salary_cte l ON e.employee_id=l.employee_id
LEFT JOIN promotion_cte p ON e.employee_id=p.employee_id
LEFT JOIN max_sal_growth msg ON e.employee_id=msg.employee_id
LEFT JOIN sal_decreased sd ON e.employee_id=sd.employee_id
LEFT JOIN avg_month am ON e.employee_id=am.employee_id
LEFT JOIN sal_growth_rank sg ON e.employee_id=sg.employee_id
order by employee_id */
