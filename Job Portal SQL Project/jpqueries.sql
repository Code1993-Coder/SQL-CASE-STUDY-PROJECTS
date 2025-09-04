SELECT * from portal
SELECT * from user_registration
SELECT * from resume_doc

---1 What is the count of registration every month on the 'Resume Now' portal for 2024 
---O/P-Month,Registration(12 rows total)

SELECT 
    Month(REGISTRATION_DATETIME) as Month,COUNT(*) as REG_CNT
FROM portal p
INNER JOIN
user_registration u on u.portal_id=p.portal_id
WHERE 
    p.portal_name='Resume Now' and YEAR(registration_datetime)='2024'
GROUP BY Month(REGISTRATION_DATETIME)

--Which portal has the highest subscription rate for users regsistered in last 30 days ?
--Subscription rate=Total subscription/Total registration
--output:portal_name,subscription rate
SELECT 
  TOP 1  portal_name,
   100*SUM(CASE WHEN SUBSCRIPTION_FLAG='Y' THEN 1 ELSE 0 END) /COUNT(*) as subscription_rate
FROM
    portal p
INNER JOIN 
    user_registration u on p.portal_id=u.portal_id
---WHERE 
---- registration_datetime>=dateadd(day,-30,getdate())
GROUP BY
    portal_name
ORDER by subscription_rate desc

--How many regsitered users create less than 3 resumes
--output:less_than_3_resume_created_users(A sinle number)


SELECT u.user_id as user,count(resume_id) as less_than_3_resumes
FROM
    user_registration u
left join
    resume_doc r
ON 
    r.user_id=u.user_id
GROUP BY
    u.user_id
having count(resume_id)<3

--Create a list of user who subscribed in 2024 on 'Zety' portal and get the experience_years on their first resume
--output:user_id,experince_years

SELECT 
    t.user_id,experience_years
FROM(SELECT u.user_id,experience_years,row_number() over(partition by u.user_id order by date_created ) as r
FROM user_registration u
LEFT JOIN resume_doc r on r.user_id=u.user_id
WHERE portal_id=3 and year(subscription_datetime)=2024
ORDER BY resume_id) as t
where r=1 and experience_years>0
