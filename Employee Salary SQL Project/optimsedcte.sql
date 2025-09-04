WITH cte AS (
    SELECT *,
           RANK() OVER(PARTITION BY employee_id ORDER BY change_date DESC) AS rk_desc,
           RANK() OVER(PARTITION BY employee_id ORDER BY change_date ASC) AS rk_asc,
           LEAD(salary, 1) OVER(PARTITION BY EMPLOYEE_ID ORDER BY CHANGE_DATE DESC) as previous_sal,
           LEAD(change_date, 1) OVER(PARTITION BY EMPLOYEE_ID ORDER BY CHANGE_DATE DESC) as previous_date,
    FROM salary_history
),

growth_rate AS (
    SELECT 
        EMPLOYEE_ID,
        MAX(CASE WHEN rk_desc = 1 THEN salary END) / NULLIF(MAX(CASE WHEN rk_asc = 1 THEN salary END), 0) as GROWTH,
        MIN(change_date) as join_date
    FROM cte
    GROUP BY EMPLOYEE_ID
    ORDER BY EMPLOYEE_ID
)

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
