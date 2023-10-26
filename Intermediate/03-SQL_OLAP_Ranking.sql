/********************
 * Module Windowed Aggregates: Ranking
 ********************/

DATABASE employee_sales;


/********************
 * ROW_NUMBER
 ********************/

SELECT
   last_name
  ,department_number AS dept#
  ,Round(salary_amount, -3) AS sal
  ,Count(*) 
   Over (ORDER BY sal DESC 
         ROWS Unbounded Preceding) AS cum_cnt
  ,Row_Number()
   Over (ORDER BY sal DESC) AS row_num
FROM employee
WHERE dept# IN (301, 401, 403)
;


/********************
 * Ranking Functions: RANK & DENSE_RANK
 ********************/

SELECT
   last_name
  ,department_number AS dept#
  ,Row_Number() Over (ORDER BY dept#)                AS rownum
  ,Rank()       Over (ORDER BY dept#)                AS rnk
  ,Rank()       Over (ORDER BY dept# WITH TIES High) AS r_high
  ,Rank()       Over (ORDER BY dept# WITH TIES Avg)  AS r_avg
  ,Dense_Rank() Over (ORDER BY dept#)                AS r_dense
FROM employee
WHERE dept# IN (301,402,501,999)
;


/********************
 * Relative Ranking Functions: PERCENT_RANK & CUME_DIST
 ********************/

SELECT
   last_name
  ,department_number AS dept#
  ,salary_amount AS sal
  ,Rank()
   Over (ORDER BY sal DESC) AS rnk
  ,Percent_Rank()
   Over (ORDER BY sal DESC) AS pct_rnk
  ,Cume_Dist()
   Over (ORDER BY sal DESC) AS cum_dist
FROM employee
WHERE dept# IN (301, 401, 403)
  AND sal IS NOT NULL
;


/********************
 * NULL Handling
 ********************/

-- ignoring NULLs in calculation -> add two partitions: NULL/NOT NULL
SELECT
   last_name
  ,department_number AS dept#
  ,salary_amount AS sal
  ,CASE
     WHEN sal IS NOT NULL
     THEN Row_Number() 
          Over (ORDER BY sal NULLS LAST)
   END AS rn_null
  ,CASE WHEN sal IS NOT NULL 
        THEN Percent_Rank()
             Over (PARTITION BY CASE WHEN sal IS NOT NULL THEN 0 ELSE 1 END
                   ORDER BY sal)
   END AS pct_rnk
FROM employee
WHERE dept# IN (301, 501, 402)
;


/********************
 * QUANTILE
 ********************/

SELECT
   last_name
  ,department_number AS dept#
  ,salary_amount AS sal
  ,Quantile(4, sal) AS qnt
  ,4 * (Rank()  Over (ORDER BY sal) - 1) 
     / Count(*) Over () AS "QUANTILE"  
FROM employee
WHERE dept# IN (301, 401, 403)
  AND sal IS NOT NULL
; 

-- rewrite NTILE (almost)
SELECT
   last_name
  ,department_number AS dept#
  ,salary_amount AS sal
  ,Quantile(4, sal) AS qnt
  ,4 * (Rank()  Over (ORDER BY sal) - 1) 
     / Count(*) Over () AS "QUANTILE"  
  ,4 * (Row_Number()  Over (ORDER BY sal) - 1) 
     / Count(*) Over () AS "Almost NTILE"  
FROM employee
WHERE dept# IN (301, 401, 403)
  AND sal IS NOT NULL
; 

-- rewrite NTILE (exactly)
SELECT
   last_name
  ,department_number AS dept#
  ,salary_amount AS sal
  ,Quantile(4, sal) AS qnt
  ,4 * (Rank()  Over (ORDER BY sal) - 1) 
     / Count(*) Over () AS "QUANTILE"  
--  ,NTILE(4) OVER (ORDER BY sal) 
  ,4 AS B
  ,COUNT(*)     OVER () AS N
  ,ROW_NUMBER() OVER (ORDER BY sal) AS rowno
  ,CASE
     WHEN  rowno   <= ((N/B)+1) * (N MOD B)
     THEN (rowno-1) / ((N/B)+1)
     ELSE (rowno-1 - (N MOD B)) / (N/B)
   END + 1 AS "NTILE"
FROM employee
WHERE dept# IN (301, 401, 403)
  AND sal IS NOT NULL
; 


/********************
 * Inverse Distribution Functions: PERCENTILE_DISC
 ********************/
  
SELECT
   salary_amount AS sal
  ,Cume_Dist()
   Over (ORDER BY sal DESC) AS cum_dist
FROM employee
WHERE department_number IN (301, 401, 403)
  AND sal IS NOT NULL
;

SELECT
   Percentile_Disc(0.2)
   Within Group (ORDER BY salary_amount DESC) 
  ,Percentile_Disc(0.8)
   Within Group (ORDER BY salary_amount DESC) 
FROM employee
WHERE department_number IN (301, 401, 403)
  AND salary_amount IS NOT NULL
;


/********************
 * Inverse Distribution Functions: PERCENTILE_CONT
 ********************/

SELECT
   salary_amount AS sal
  ,Percent_Rank()
   Over (ORDER BY sal DESC) AS cum_dist
FROM employee
WHERE department_number IN (301, 401, 403)
  AND sal IS NOT NULL
;

SELECT 
   Percentile_Cont(0.2)
   Within Group (ORDER BY salary_amount DESC ) 
  ,Percentile_Cont(0.8)
   Within Group (ORDER BY salary_amount DESC) 
FROM employee
WHERE department_number IN (301, 401, 403)
  AND salary_amount IS NOT NULL
;



-- Default database for labs
DATABASE finance_payroll;

/********************
 * OLAP Ranking Lab 1
 ********************/

HELP TABLE hr_payroll;


/********************
 * OLAP Ranking Lab 2
 ********************/

HELP TABLE hr_salary_hist;


/********************
 * OLAP Ranking Lab 3
 ********************/

HELP TABLE hr_salary_hist;


/********************
 * OLAP Ranking Lab 4
 ********************/

HELP TABLE fin_account;
HELP TABLE fin_trans;


/********************
 * OLAP Quantile Lab
 ********************/

HELP TABLE fin_trans;


/********************
 * OLAP Ranking Lab 1 Solution
 ********************/

SELECT
   employee_number AS emp#
  ,first_name
  ,last_name
  ,department_number AS dept#
  ,Dense_Rank()
   Over (PARTITION BY dept#
         ORDER BY annual_salary DESC) AS rnk
  ,annual_salary
FROM hr_payroll
WHERE dept# BETWEEN 40 AND 50
QUALIFY 
   rnk <= 2
ORDER BY annual_salary DESC
;


/********************
 * OLAP Ranking Lab 2 Solution
 ********************/

SELECT
   employee_number AS emp#
  ,first_name
  ,last_name
  ,department_number AS dept#
  ,total_pay
  ,overtime_pay
  ,overtime_hours
  ,Rank() 
   Over (ORDER BY overtime_pay DESC) AS overtime_rank
  ,Rank() 
   Over (PARTITION BY department_number
         ORDER BY overtime_pay DESC) AS dept_rank
FROM hr_salary_hist
WHERE sal_year = 2017
  AND overtime_hours >= 100
QUALIFY overtime_rank <= 30
ORDER BY overtime_rank
;


/********************
 * OLAP Ranking Lab 3 Solution
 ********************/

SELECT
   employee_number AS emp#
  ,first_name
  ,last_name
  ,department_number AS dept#
  ,total_pay
  ,overtime_pay
  ,overtime_hours
  ,Rank() 
   Over (ORDER BY overtime_pay DESC) AS overtime_rank
  ,Rank() 
   Over (ORDER BY total_pay DESC) AS total_rank
FROM hr_salary_hist
WHERE sal_year = 2017
QUALIFY total_rank <= 30
    AND overtime_hours >= 100
ORDER BY total_rank
;


/********************
 * OLAP Ranking Lab 4 Solution
 ********************/

SELECT
   a.district_id
  ,a.account_id
  ,RANK()
   OVER (PARTITION BY district_id
        ORDER BY volume) AS rnk
  ,SUM(amount) AS volume
FROM fin_account AS a 
JOIN fin_trans AS t
  ON a.account_id = t.account_id
WHERE trans_type = 'P' -- cash withdrawal
GROUP BY 1, 2
HAVING volume < -50000
QUALIFY rnk <= 3
ORDER BY volume
;


/********************
 * OLAP Quantile Lab Solution (equal height buckets)
 ********************/

WITH cte AS
 (
   SELECT
      --QUANTILE(10,amount) AS q
      10 * (Rank() Over (ORDER BY amount) -1)
         / Count(*) Over () AS q
     ,amount
   FROM fin_trans
   WHERE trans_type = 'C' -- credit
     AND trans_date BETWEEN DATE '2017-01-01'
                        AND DATE '2017-12-31'
 )
SELECT
   q
  ,Count(*) AS Cnt
  ,Min(amount) AS min_amt
  ,Avg(amount) AS avg_amt
  ,Median(amount) AS med_amt
  ,Max(amount) AS max_amt
  ,Sum(amount) AS sum_amt
FROM cte
GROUP BY q
ORDER BY q
;


/********************
 * OLAP Quantile Lab Solution (equal sum buckets)
 ********************/

WITH cte AS
 (
   SELECT -- similar to RANK/COUNT = Cumulative Sum / Group Sum
        Sum(amount) Over (ORDER BY amount ROWS Unbounded Preceding) AS cumsum
       ,Sum(amount) Over (ORDER BY amount) AS grpsum
       ,Cast(10 * Cast(cumsum AS NUMBER) / (grpsum + 0.01) AS INT) AS q
       ,amount
   FROM fin_trans
   WHERE trans_type = 'C' -- credit
     AND trans_date BETWEEN DATE '2017-01-01'
                        AND DATE '2017-12-31'
 )
SELECT
   q
  ,Count(*) AS Cnt
  ,Min(amount) AS min_amt
  ,Avg(amount) AS avg_amt
  ,Median(amount) AS med_amt
  ,Max(amount) AS max_amt
  ,Sum(amount) AS sum_amt
FROM cte
GROUP BY q
ORDER BY q
;


/********************
 * OLAP WIDTH_BUCKET Lab Solution (equal width buckets)
 ********************/

SELECT
   Width_Bucket(amount, 0, 5000, 10) AS wb
  ,Count(*) AS Cnt
  ,Min(amount) AS min_amt
  ,Avg(amount) AS avg_amt
  ,Median(amount) AS med_amt
  ,Max(amount) AS max_amt
  ,Sum(amount) AS sum_amt
FROM fin_trans
WHERE trans_type = 'C' -- credit
  AND trans_date BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
GROUP BY wb
ORDER BY wb
;

