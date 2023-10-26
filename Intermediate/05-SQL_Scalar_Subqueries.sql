/********************
 * Module Scalar Subqueries
 ********************/

DATABASE employee_sales;


/********************
 * Types of Subqueries
 ********************/

-- Who earns above average
--EXPLAIN
SELECT 
   e.employee_number AS emp#
  ,e.last_name
  ,e.salary_amount
FROM employee AS e
WHERE salary_amount > 
 (
   SELECT Avg(salary_amount) 
   FROM employee
 );
 
-- rewrite using Group Aggregate
--EXPLAIN
SELECT 
   e.employee_number AS emp#
  ,e.last_name
  ,e.salary_amount
FROM employee AS e
QUALIFY salary_amount
  > Avg(salary_amount) 
    Over ()
;


/********************
 * Correlated Scalar Subqueries
 ********************/

--EXPLAIN
SELECT
   e.employee_number AS emp#
  ,e.department_number AS dept#
  ,e.last_name
  ,salary_amount AS sal
  ,(
     SELECT budget_amount
     FROM department AS d
     WHERE e.department_number = d.department_number
   ) AS budget
  ,100 * sal / budget AS "% of budget"
FROM employee AS e
ORDER BY 1
;

-- rewrite using outer join
--EXPLAIN
SELECT
   e.employee_number AS emp#
  ,e.department_number AS dept#
  ,e.last_name
  ,d.budget_amount AS budget
  ,100 * e.salary_amount / budget
FROM employee AS e
LEFT JOIN department AS d
ON e.department_number = d.department_number
;

/********************
 * Correlated Scalar Subqueries (cont.)
 ********************/

--EXPLAIN
SELECT 
   d.department_name AS dept_name
  ,d.budget_amount AS budget
  ,(
     SELECT Sum(salary_amount)
     FROM employee AS e
     WHERE e.department_number =  d.department_number
   ) AS sumsal
  ,100 * sumsal / budget AS "% of budget"
FROM department AS d
ORDER BY budget
;

-- rewrite using an Outer Join
--EXPLAIN
SELECT 
   d.department_name AS dept_name
  ,d.budget_amount AS budget
  ,e.sumsal
  ,100 * e.sumsal / budget AS "% of budget"
FROM department AS d
LEFT JOIN
 (
   SELECT
      department_number
     ,Sum(salary_amount) AS sumsal
   FROM employee
   GROUP BY 1
 ) AS e
ON e.department_number =  d.department_number
ORDER BY budget;

-- Another rewrite, but above Derived Table/CTE should be more efficient
--EXPLAIN
SELECT 
   d.department_name AS dept_name
  ,d.budget_amount AS budget
  ,Sum(e.salary_amount) AS sumsal
  ,100 * sumsal / budget AS "% of budget"
FROM department AS d
LEFT JOIN employee AS e
ON e.department_number =  d.department_number
GROUP BY 1,2
ORDER BY budget;


/********************
 * Performance Considerations
 ********************/

-- same table twice
--EXPLAIN
SELECT 
   d.department_name AS dept_name
  ,d.budget_amount AS budget
  ,(
     SELECT Sum(salary_amount)
     FROM employee AS e
     WHERE e.department_number =  d.department_number  -- same table/condition
   ) AS sumsal
  ,100 * sumsal / budget AS "% of budget"
  ,(
     SELECT Count(salary_amount)
     FROM employee AS e
     WHERE e.department_number =  d.department_number  -- same table/condition
   ) AS cntsal
FROM department AS d
ORDER BY budget
;

-- rewrite using an Outer Join
--EXPLAIN
SELECT 
   d.department_name AS dept_name
  ,d.budget_amount AS budget
  ,e.sumsal
  ,100 * e.sumsal / budget AS "% of budget"
  ,e.cntsal
FROM department AS d
LEFT JOIN
 (
   SELECT
      department_number
     ,Sum(salary_amount) AS sumsal
     ,Count(*) AS cntsal
   FROM employee
   GROUP BY 1
 ) AS e
ON e.department_number =  d.department_number
ORDER BY budget
;


-- Default database for labs
DATABASE finance_payroll;

/********************
 * Scalar Subqueries Lab 1 & 4
 ********************/

HELP TABLE fin_trans;


/********************
 * Scalar Subqueries Lab 2 & 3
 ********************/

HELP TABLE fin_trans;
HELP TABLE fin_account;


/********************
 * Scalar Subqueries Lab 1 Solution
 ********************/

SET QUERY_BAND = 'lab=SSQ;LabNo=1-SSQ;' UPDATE FOR SESSION VOLATILE
;
SELECT
   account_id
  ,trans_date
  ,amount
  ,(
     SELECT Sum(amount)
     FROM fin_trans AS t2
     WHERE t2.account_id = t.account_id
       AND t2.trans_date BETWEEN t.trans_date - 27
                             AND t.trans_date
   ) AS sum_prev_28_days
FROM fin_trans AS t
WHERE account_id = 386
  AND trans_date BETWEEN DATE '2017-01-01'
                     AND DATE '2018-12-31'
ORDER BY trans_date
;


/********************
 * Scalar Subqueries Lab 2 Solution
 ********************/

SET QUERY_BAND = 'lab=SSQ;LabNo=2-SSQ;' UPDATE FOR SESSION VOLATILE
;
SELECT
   t.account_id
  ,t.trans_date
  ,t.amount
  ,(
     SELECT Sum(amount)
     FROM fin_trans AS t2
     WHERE t2.account_id = t.account_id
       AND t2.trans_date BETWEEN t.trans_date - 27
                             AND t.trans_date
   ) AS sum_prev_28_days
FROM fin_account AS a 
JOIN fin_trans AS t
  ON a.account_id = t.account_id
WHERE a.district_id = 1
ORDER BY t.account_id, t.trans_date
;


/********************
 * Scalar Subqueries Lab 3 Solution
 ********************/

SET QUERY_BAND = 'lab=SSQ;LabNo=3-SSQ*2;' UPDATE FOR SESSION VOLATILE
;
SELECT
   t.account_id
  ,t.trans_date
  ,t.amount
  ,(
     SELECT Sum(amount)
     FROM fin_trans AS t2
     WHERE t2.account_id = t.account_id
       AND t2.trans_date BETWEEN t.trans_date - 27
                             AND t.trans_date
   ) AS sum_prev_28_days
  ,(
     SELECT Count(*)
     FROM fin_trans AS t2
     WHERE t2.account_id = t.account_id
       AND t2.trans_date BETWEEN t.trans_date - 27
                             AND t.trans_date
   ) AS count_prev_28_days
FROM  fin_account AS a 
JOIN fin_trans AS t
  ON a.account_id = t.account_id
WHERE a.district_id = 1
ORDER BY t.account_id, t.trans_date
;


/********************
 * Scalar Subqueries Lab 4 Solution
 ********************/

SET QUERY_BAND = 'lab=no;' UPDATE FOR SESSION VOLATILE
;
-- CAUTION!
-- Does not return the correct result!
SELECT
   t.account_id
  ,t.trans_date
  ,t.amount
  ,Sum(t2.amount) AS sum_prev_28_days
FROM fin_trans AS t
JOIN fin_trans AS t2
  ON t2.account_id = t.account_id
 AND t2.trans_date BETWEEN t.trans_date - 27 
                       AND t.trans_date
WHERE t.account_id = 386
  AND t.trans_date BETWEEN DATE '2017-01-01' 
                       AND DATE '2018-12-31'
GROUP BY 1,2,3
ORDER BY
   t.account_id
  ,t.trans_date
;

/*
Returns only 86 instead of 87 rows and not the same numbers.

On 2018-01-01 the same amount was transferred twice:        
        386 2018-01-01  -264.00           912.71
        386 2018-01-01  -264.00           912.71
Aggregation combines these two rows into one:
        386 2018-01-01  -264.00          1825.42
 */


SET QUERY_BAND = 'lab=SSQ;LabNo=4-Join;' UPDATE FOR SESSION VOLATILE
;
-- Adding the PK column(s) to make the GROUP BY unique resolves the issue
SELECT
   t.account_id
  ,t.trans_date
  ,t.amount
  ,Sum(t2.amount) AS sum_prev_28_days
FROM fin_trans AS t
JOIN fin_trans AS t2
  ON t2.account_id = t.account_id
 AND t2.trans_date BETWEEN t.trans_date - 27
                       AND t.trans_date
WHERE t.account_id = 386
  AND t.trans_date BETWEEN DATE '2017-01-01'
                       AND DATE '2018-12-31'
GROUP BY 1,2,3, t.trans_id
ORDER BY
   t.account_id
  ,t.trans_date
;


/********************
 * Rewrite of Lab 2 & 3
 ********************/

-- Join solution Lab 2
SET QUERY_BAND = 'lab=SSQ;LabNo=2-Join;' UPDATE FOR SESSION VOLATILE
;
SELECT
   t.account_id
  ,t.trans_date
  ,t.amount
  ,Sum(t2.amount) AS sum_prev_28_days
FROM fin_account AS a 
JOIN fin_trans AS t
  ON a.account_id = t.account_id
JOIN fin_trans AS t2
  ON t2.account_id = t.account_id
 AND t2.trans_date BETWEEN t.trans_date - 27
                       AND t.trans_date
WHERE a.district_id = 1
GROUP BY 1,2,3, t.trans_id
ORDER BY
   t.account_id
  ,t.trans_date
;


-- Join solution Lab 3
SET QUERY_BAND = 'lab=SSQ;LabNo=3-Join*2;' UPDATE FOR SESSION VOLATILE
;
SELECT
   t.account_id
  ,t.trans_date
  ,t.amount
  ,Sum(t2.amount) AS sum_prev_28_days
  ,Count(*) AS count_prev_28_days
FROM fin_account AS a 
JOIN fin_trans AS t
  ON a.account_id = t.account_id
JOIN fin_trans AS t2
  ON t2.account_id = t.account_id
 AND t2.trans_date BETWEEN t.trans_date - 27
                       AND t.trans_date
WHERE a.district_id = 1
GROUP BY 1,2,3, t.trans_id
ORDER BY
   t.account_id
  ,t.trans_date
;

SET QUERY_BAND = 'lab=no;' UPDATE FOR SESSION VOLATILE
;




-- Get info from DBQL
FLUSH QUERY LOGGING WITH DEFAULT
;

SELECT
   TotalFirstRespTime AS RunTime
  ,TotalIOCount AS IO_logical
  ,ReqPhysIO    AS IO_physical
  ,AMPCPUTime   AS CPU
  ,Coalesce(SpoolUsage, 0) AS SpoolUsage
  ,GetQuerybandValue(queryband, 0, 'LabNo') AS lab
FROM dbc.QryLogV
WHERE UserName = USER 
  AND StartTime >= Current_Timestamp - INTERVAL '10' MINUTE
  AND GetQuerybandValue(queryband, 0, 'lab') = 'SSQ'
  AND CPU > 0.1
ORDER BY StartTime;


/************
-- 24 AMP system, QryLogV (new lab system)

 RunTime IO_logical    CPU  SpoolUsage lab      
 ------- ---------- ------ ----------- -------- 
    1.35     24,739  22.93 300,883,968 -- Lab 2-SSQ   
    4.33     46,356  80.16 404,602,880 -- Lab 3-SSQ*2 
    0.60      6,653   9.92  46,268,416 -- Lab 2-Join  
    0.62      6,742   9.60  47,333,376 -- Lab 3-Join*2

*************/
