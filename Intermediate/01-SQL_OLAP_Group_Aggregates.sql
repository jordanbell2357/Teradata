/********************
 * Module OLAP Functions: Group Aggregates
 ********************/

DATABASE employee_sales;


/********************
 * Combining Detail and Aggregated Values
 ********************/

SELECT 
   department_number  AS dept#
  ,MAX(salary_amount) AS MaxSal 
  ,AVG(salary_amount) AS AvgSal 
FROM employee
WHERE dept# in (301, 501)
GROUP BY department_number
ORDER BY department_number
;

SELECT 
   department_number AS dept#
  ,last_name
  ,salary_amount     AS salary
FROM employee
WHERE dept# in (301, 501)
ORDER BY department_number, salary
;

-- 3504 Selected non-aggregate values must be part of the associated group. 
SELECT 
   department_number AS dept#
  ,last_name
  ,salary_amount     AS salary
  ,salary - AVG(salary) AS diff2avg
  ,salary - MAX(salary) AS diff2max
FROM employee
WHERE dept# in (301, 501)
;


/********************
 * Combining Detail and Aggregated Values (cont.)
 ********************/

SELECT
   e.department_number AS dept#
  ,e.job_code
  ,e.employee_number   AS emp#
  ,e.last_name
  ,e.salary_amount     AS salary
  ,salary - eg.AvgSal  AS diff2avg
  ,salary - eg.MaxSal  AS diff2max
FROM employee AS e
JOIN
 (
   SELECT
      department_number
     ,AVG(salary_amount) AS AvgSal
     ,MAX(salary_amount) AS MaxSal
   FROM employee
   GROUP BY department_number
   WHERE department_number IN (301, 501)
 ) AS eg
  ON dept# = eg.department_number
WHERE e.department_number IN (301, 501)
;

WITH cte AS
 (
   SELECT
      e.department_number AS dept#
     ,e.job_code
     ,e.employee_number   AS emp#
     ,e.last_name
     ,e.salary_amount     AS salary
   FROM employee AS e
   WHERE e.department_number IN (301, 501)
 )
SELECT
   e.*
  ,salary - eg.AvgSal AS diff2avg
  ,salary - eg.MaxSal AS diff2max
FROM cte AS e
JOIN
 (
   SELECT
      dept#
     ,Avg(salary) AS AvgSal
     ,Max(salary) AS MaxSal
   FROM cte
   GROUP BY dept#
 ) AS eg
  ON e.dept# = eg.dept#
;


/********************
 * Group Aggregates to the Rescue
 ********************/

SELECT 
   department_number                            AS dept#
  ,AVG(salary_amount) OVER (PARTITION BY dept#) AS AvgSal 
  ,MAX(salary_amount) OVER (PARTITION BY dept#) AS MaxSal 
  ,COUNT(*)           OVER (PARTITION BY dept#) AS CntStar
FROM employee
WHERE dept# in (301, 501)
-- no ORDER BY!, but sorted by dept#
;


/********************
 * Group Aggregates
 ********************/

SELECT
   department_number          AS dept#
  ,job_code
  ,employee_number            AS emp#
  ,last_name
  ,salary_amount              AS salary
  ,salary - AVG(salary_amount) OVER (PARTITION BY dept#) AS diff2avg
  ,salary - MAX(salary_amount) OVER (PARTITION BY dept#)    AS diff2max
FROM employee
WHERE dept# in (301, 501)
-- no ORDER BY!, but sorted by dept#
;

SELECT
   e.department_number AS dept#
  ,e.job_code
  ,e.employee_number   AS emp#
  ,e.last_name
  ,e.salary_amount     AS salary
  ,salary - eg.AvgSal  AS diff2avg
  ,salary - eg.MaxSal  AS diff2max
FROM employee AS e
JOIN
 (
   SELECT
      department_number
     ,AVG(salary_amount) AS AvgSal
     ,MAX(salary_amount) AS MaxSal
   FROM employee
   GROUP BY department_number
   WHERE department_number IN (301, 501)
 ) AS eg
  ON dept# = eg.department_number
WHERE e.department_number IN (301, 501)
;


/********************
 * Different partitions
 ********************/

SELECT
   department_number AS dept#
  ,job_code
  ,employee_number   AS emp#
  ,last_name
  ,salary_amount     AS salary
  ,AVG(salary_amount)
   OVER ()                      AS by_all
  ,AVG(salary_amount)
   OVER (PARTITION BY dept#)    AS by_dept
  ,AVG(salary_amount)
   OVER (PARTITION BY job_code) AS by_job
FROM employee_sales.employee AS e
WHERE dept# in (301, 501)
-- no ORDER BY!, but sorted by job_code = last window function
;


/********************
 * The QUALIFY Clause
 ********************/

SELECT
   department_number           AS dept#
  ,job_code
  ,employee_number             AS emp#
  ,last_name
  ,salary_amount               AS salary
  ,salary
   - AVG(salary_amount)
     OVER (PARTITION BY dept#) AS diff2avg
FROM employee
WHERE dept# IN (301, 501)
QUALIFY diff2avg > 0
    AND COUNT(*)
        OVER (PARTITION BY dept#) > 3
ORDER BY diff2avg DESC
;

-- same using Derived Table plus WHERE
SELECT -- column list needed because "cnt" is not to be projected 
   dept#
  ,job_code
  ,emp#
  ,last_name
  ,salary
  ,diff2avg
FROM 
 (
   SELECT
      department_number           AS dept#
     ,job_code
     ,employee_number             AS emp#
     ,last_name
     ,salary_amount               AS salary
     ,salary
      - AVG(salary_amount)
        OVER (PARTITION BY dept#) AS diff2avg
     ,COUNT(*)
        OVER (PARTITION BY dept#) AS cnt
   FROM employee
   WHERE dept# in (301, 501)
 ) AS dt
WHERE diff2avg > 0
  AND cnt > 3
ORDER BY diff2avg DESC
;


/********************
 * Nested aggregation
 ********************/

-- base data
SELECT
   department_number          AS dept#
  ,salary_amount              AS salary
FROM employee
WHERE dept# BETWEEN 300 AND 499
  AND salary IS NOT NULL
ORDER BY dept#, salary_amount
;

-- adding GROUP BY/HAVING
SELECT
   department_number    AS dept#
  ,AVG(salary_amount)   AS avgsal
  ,COUNT(*) AS cnt
FROM employee
WHERE dept# BETWEEN 300 AND 499
  AND salary_amount IS NOT NULL
GROUP BY dept#
HAVING COUNT(*) > 1
ORDER BY 1
;

-- adding Group Max & QUALIFY
SELECT
   department_number   AS dept#
  ,AVG(salary_amount)  AS avgsal
  ,COUNT(*)            AS cnt
  ,MAX(avgsal) OVER () AS maxavg
  ,avgsal - maxavg     AS diff2max
FROM employee
WHERE dept# BETWEEN 300 AND 499
  AND salary_amount IS NOT NULL
GROUP BY dept#
HAVING cnt > 1
QUALIFY diff2max < -5000
ORDER BY diff2max
;


/********************
 * Usage Notes
 ********************/

SELECT 
   department_number AS dept#
  ,last_name
  ,salary_amount     AS salary
  ,MAX(salary_amount) OVER (PARTITION BY 1) AS MaxSal 
  ,COUNT(*)           OVER (PARTITION BY 1) AS Cnt
FROM employee
WHERE dept# IN (402, 501, 999)
ORDER BY 1
;


/********************
 * Group Aggregates Lab 1
 ********************/

/**** Default database for labs ****/
DATABASE finance_payroll;

HELP TABLE hr_salary_hist;


/********************
 * Group Aggregates Lab 2
 ********************/

HELP TABLE hr_salary_hist;


/********************
 * Group Aggregates Lab 3
 ********************/

HELP TABLE hr_departments;
HELP TABLE hr_salary_hist;


/********************
 * Group Aggregates Lab 4
 ********************/

HELP TABLE hr_salary_hist;


/********************
 * Group Aggregates Lab 5
 ********************/

HELP TABLE hr_salary_hist;

/********************
 * Group Aggregates Lab 1 Solution
 ********************/


/********************
Write a query to return details of the employee earning the highest annual_salary for each
department_number between 40 and 50. Order by descending salary.
 ********************/

SELECT
   employee_number AS emp#
  ,first_name
  ,last_name
  ,department_number AS dept#
  ,annual_salary
FROM hr_payroll
WHERE dept# BETWEEN 40 AND 50
QUALIFY 
   annual_salary
   = Max(annual_salary)
     Over (PARTITION BY dept#)
ORDER BY annual_salary DESC
;

/********************
Modify the previous query to add a column indicating the percentage this salary represents of all salaries
for the department. Return only rows where the percentage is over 1%. Order by descending percentage.
 ********************/

/********************
 * Group Aggregates Lab 2 Solution
 ********************/

SELECT
   employee_number AS emp#
  ,first_name
  ,last_name
  ,department_number AS dept#
  ,annual_salary
  ,100 * annual_salary / dept_sal AS "% dept sal"
  ,Sum(annual_salary)
   Over (PARTITION BY dept#) AS dept_sal
FROM hr_payroll
WHERE dept# BETWEEN 40 AND 50
QUALIFY 
   annual_salary
   = Max(annual_salary)
     Over (PARTITION BY dept#)
   AND "% dept sal" >= 1
ORDER BY "% dept sal" DESC
;

/********************
Write a query based on employees with a salary (total_pay) > 10000 calculating the average salary
for each job_code <> 999999 and each sal_year between 2014 to 2017.  Add a column showing the difference
of the salary to this average salary and return only rows where the salary is more than twice the average.
Order by descending salary within a year.
 ********************/

/********************
 * Group Aggregates Lab 3 Solution
 ********************/

SELECT
   sal_year
  ,employee_number AS emp#
  ,first_name
  ,last_name
  ,department_number AS dept#
  ,job_code
  ,Avg(total_pay) Over (PARTITION BY job_code, sal_year) AS avg_pay
  ,total_pay
  ,total_pay - avg_pay AS above_avg
  ,overtime_hours
FROM hr_salary_hist AS t
WHERE total_pay > 10000
  AND job_code <> 999999
  AND sal_year BETWEEN 2014 AND 2017
QUALIFY total_pay > 2 * avg_pay
ORDER BY sal_year, total_pay DESC
;

/********************
Modify the previous, to show only employees who earned more than twice the average in at least 3 of the 4 years
between 2014 and 2017.
 ********************/

/********************
 * Group Aggregates Lab 4 Solution
 ********************/

SELECT *
FROM 
 (
   SELECT
      sal_year
     ,employee_number AS emp#
     ,first_name
     ,last_name
     ,department_number AS dept#
     ,job_code
     ,Avg(total_pay)
      Over (PARTITION BY job_code, sal_year) AS avg_pay
     ,total_pay
     ,total_pay - avg_pay AS above_avg
     ,overtime_hours
   FROM hr_salary_hist AS t
   WHERE total_pay > 10000
     AND job_code <> 999999
     AND sal_year BETWEEN 2014 AND 2017
   QUALIFY total_pay > 2 * avg_pay
 ) AS dt
QUALIFY
   Count(*) Over (PARTITION BY emp#) >= 3
ORDER BY sal_year, total_pay DESC
;


/********************
Write a report showing the sum of salaries (total_pay) per department and the percentage these sums represent of
the sum of all salaries. Base the calculation on data from sal_year 2017 only.  Return only rows where the
percentage is over 2%. Order by descending sums.
 ********************/

/********************
 * Group Aggregates Lab 5 Solution
 ********************/

SELECT 
   d.department_name
  ,d.department_number AS dept#
  ,Sum(s.total_pay) AS sum_pay
  ,100 * sum_pay
   / Sum(sum_pay)
     Over () AS "% all sal"
FROM hr_salary_hist AS s
JOIN hr_departments AS d
  ON s.department_number = d.department_number
WHERE s.sal_year = 2017
GROUP BY 1,2 
QUALIFY "% all sal" > 2
ORDER BY sum_pay DESC
;
