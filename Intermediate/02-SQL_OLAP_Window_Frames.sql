/********************
 * Module Windowed Aggregates: Window Frames
 ********************/

DATABASE employee_sales;

/********************
 * Adding a Frame to the Window
 ********************/

SELECT
   department_number AS dept#
  ,job_code
  ,employee_number   AS emp#
  ,last_name
  ,salary_amount     AS salary

  -- implicit & explicit window
  ,Avg(salary_amount)
   Over () AS by_all
  ,Avg(salary_amount)
   Over (ROWS BETWEEN Unbounded Preceding AND Unbounded Following) AS by_all2
   
   -- implicit & explicit window
  ,Avg(salary_amount)
   Over (PARTITION BY dept#) AS by_dept
  ,Avg(salary_amount)
   Over (PARTITION BY dept#
         ROWS BETWEEN Unbounded Preceding AND Unbounded Following) AS by_dept2

   -- implicit & explicit window
  ,Avg(salary_amount)
   Over (PARTITION BY job_code) AS by_job
  ,Avg(salary_amount)
   Over (PARTITION BY job_code
         ROWS BETWEEN Unbounded Preceding AND Unbounded Following) AS by_job2
FROM employee AS e
WHERE dept# IN (301, 501)
-- no ORDER BY!, but sorted by job_code = last window functions
;


/********************
 * Cumulative Window
 ********************/

SELECT
   department_number AS dept#
  ,employee_number   AS emp#
  ,last_name
  ,Sum(salary_amount)
   Over (ORDER BY emp#
         ROWS BETWEEN Unbounded Preceding AND CURRENT ROW) AS cum_sum
  ,salary_amount AS salary
FROM employee AS e
WHERE dept# IN (301, 501)
-- no ORDER BY!, but sorted by emp#
;


/********************
 * Cumulative Window (continued)
 ********************/

SELECT
   department_number AS dept#
  ,employee_number   AS emp#
  ,last_name
  ,salary_amount     AS salary
  ,Sum(salary_amount) Over (PARTITION BY dept#)                                          AS sum_by_dept
  ,Sum(salary_amount) Over (                ORDER BY emp# DESC ROWS Unbounded Preceding) AS cum_sum_desc
  ,Sum(salary_amount) Over (                ORDER BY emp#      ROWS Unbounded Preceding) AS cum_sum
FROM employee AS e
WHERE dept# IN (301, 501)
-- no ORDER BY!, but sorted by last frame (cum_sum)
;

/********************
 * Frames and ORDER BY
 ********************/


-- No ORDER BY -> optimizer adds an implicit "ORDER BY all columns" in Select list
SELECT
   department_number AS dept#
  ,employee_number   AS emp#
  ,last_name
  ,salary_amount AS salary
  ,Sum(salary_amount)
   Over (ROWS BETWEEN Unbounded Preceding AND CURRENT ROW) AS cum_sum
FROM employee AS e
WHERE dept# IN (301, 501)
-- sorted by dept#, emp#, last_name, salary_amount
;

-- ORDER BY column is not unique -> result may differ with each execution
SELECT
   department_number AS dept#
  ,employee_number   AS emp#
  ,last_name
  ,salary_amount AS salary
  ,Sum(salary_amount)
   Over (ORDER BY dept#
         ROWS BETWEEN Unbounded Preceding AND CURRENT ROW) AS cum_sum
FROM employee AS e
WHERE dept# IN (301, 501)
;


/********************
 * Moving Window
 ********************/

SELECT
   department_number AS dept#
  ,employee_number   AS emp#
  ,last_name
  ,Avg(salary_amount)
   Over (ORDER BY emp#
         ROWS BETWEEN 1 Preceding
                  AND 1 Following) AS mov_avg
  ,salary_amount AS salary
FROM employee AS e
WHERE dept# IN (301, 501)
;


-- ORDER BY column is not unique -> result may differ with each execution
SELECT
   department_number AS dept#
  ,employee_number   AS emp#
  ,last_name
  ,salary_amount AS salary
  ,Sum(salary_amount)
   Over (ORDER BY dept#
         ROWS BETWEEN Unbounded Preceding AND CURRENT ROW) AS cum_sum
FROM employee AS e
WHERE dept# IN (301, 501)
-- sorted by emp#
;


/********************
 * Remaining Window
 ********************/

SELECT
   department_number AS dept#
  ,employee_number   AS emp#
  ,last_name
  ,Sum(salary_amount)
   Over (ORDER BY emp#
         ROWS BETWEEN CURRENT ROW AND Unbounded Following) AS cum_sum
-- rewritten as 
/*
  ,SUM(salary_amount)
   OVER (ORDER BY emp# DESC
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sum
*/
  ,salary_amount     AS salary
FROM employee AS e
WHERE dept# IN (301, 501)
-- without final ORDER BY the order is reversed and sorted by descending emp#
;


/********************
 * Moving Window
 ********************/

SELECT
   department_number AS dept#
  ,employee_number   AS emp#
  ,last_name
  ,salary_amount     AS salary
  ,Avg(salary_amount)
   Over (ORDER BY emp#
         ROWS BETWEEN 1 Preceding
                  AND 1 Following) AS mov_avg
FROM employee AS e
WHERE dept# IN (301, 501)
;




/********************
 * Differences to Standard SQL
 ********************/


-- fails
-- 5486: Window size value is not acceptable. 
SELECT
   department_number AS dept#
  ,employee_number   AS emp#
  ,last_name
  ,salary_amount     AS salary
  ,Avg(salary_amount)
   Over (ORDER BY emp#
         ROWS BETWEEN 4096 Preceding
                  AND 4097 /*max 4096*/ Following) AS mov_avg
FROM employee AS e
WHERE dept# IN (301, 501)
;

SELECT
   department_number AS dept#
  ,employee_number   AS emp#
  ,last_name
  ,salary_amount     AS salary
  ,Sum(salary_amount)
   Over (ORDER BY emp#
         /* defaults to 
         ROWS BETWEEN UNBOUNDED PRECEDING
                  AND UNBOUNDED FOLLOWING*/) AS mov_avg
FROM employee AS e
WHERE dept# IN (301, 501)
;


/********************
 * Moving difference
 ********************/

-- Tables used in the following slides
CREATE VOLATILE TABLE vt_prices( item INT, dt DATE, price DEC(10,2)) 
UNIQUE PRIMARY INDEX(item, dt) 
ON COMMIT PRESERVE ROWS
;

INSERT INTO vt_prices(1, DATE '2021-03-12',  9.90);
INSERT INTO vt_prices(1, DATE '2021-05-02',  8.95);
INSERT INTO vt_prices(1, DATE '2021-05-09',  9.90);
INSERT INTO vt_prices(1, DATE '2021-08-20',  NULL);
INSERT INTO vt_prices(1, DATE '2021-09-04', 10.95);
INSERT INTO vt_prices(1, DATE '2021-12-03', 12.90);
INSERT INTO vt_prices(1, DATE '2022-01-15', 10.90);
INSERT INTO vt_prices(1, DATE '2022-02-12',  8.95);

SELECT 
   item
  ,dt
  ,price
  ,Max(price)
   Over (ORDER BY dt
         ROWS BETWEEN 1 Preceding
                  AND 1 Preceding) AS prev_price
  ,price - prev_price AS diff2prev
FROM vt_prices
WHERE item = 1
;


/********************
 * LAG & LEAD
 ********************/

-- Same moving difference using LAG
SELECT item, dt, price
  ,Lag(price) 
   Over (PARTITION BY item
         ORDER BY dt) AS prev_price
  ,price - prev_price AS diff2prev
  ,Lead(price) 
   Over (PARTITION BY item
         ORDER BY dt) AS next_price
  ,price - next_price AS diff2next
FROM vt_prices
WHERE item = 1
ORDER BY item, dt
;


/********************
 * LAG & LEAD NULL Handling
 ********************/

SELECT item, dt, price
  ,Lag(price)                    Over (ORDER BY dt) AS prev_price
  ,Lag(price, 1, 0)              Over (ORDER BY dt) AS prev_default
  ,Lag(price)       IGNORE NULLS Over (ORDER BY dt) AS prev_ignore
  ,Lag(price, 1, 0) IGNORE NULLS Over (ORDER BY dt) AS prev_def_ign
FROM vt_prices
WHERE item = 1
ORDER BY item, dt
;



/********************
 * Emulating DISTINCT
 ********************/

SELECT
   last_name
  ,dept#
  ,sal
  ,Count(sal_uniq) Over () AS cnt_distinct
  ,Avg  (sal_uniq) Over () AS avg_distinct
FROM 
 (
   SELECT
      last_name
     ,department_number AS dept#
     ,Round(salary_amount, -3) AS sal
     ,CASE WHEN Lag(sal)
                Over (ORDER BY sal) = sal 
           THEN NULL 
           ELSE sal
      END AS sal_uniq
   FROM employee
   WHERE dept# IN (301, 501, 402)
 ) AS dt
;


/********************
 * FIRST_VALUE
 ********************/

SELECT item, dt, price
  ,First_Value(price) 
   Over (ORDER BY dt)  AS first_price
  ,price - first_price AS diff2initial
FROM vt_prices
WHERE item = 1
ORDER BY item, dt
;


/********************
 * LAST_VALUE
 ********************/

SELECT item, dt, price
  ,Last_Value(price) 
   Over (ORDER BY dt
         ROWS BETWEEN Unbounded Preceding 
                  AND Unbounded Following) AS last_price
  ,price - last_price AS diff2current
FROM vt_prices
WHERE item = 1
ORDER BY item, dt
;


/********************
 * Replacing NULLs with the last-known value
 ********************/

SELECT item, dt, price
  ,Last_Value(price IGNORE NULLS)
   Over (ORDER BY dt) AS last_price
  ,Lag(price, 0) IGNORE NULLS
   Over (ORDER BY dt) AS last_price2   
FROM vt_prices
WHERE item = 1
ORDER BY item, dt
;


/********************
 * Replacing NULLs with the last-known value (cont.)
 ********************/

SELECT item, dt, price
  ,First_Value(price IGNORE NULLS)
   Over (ORDER BY dt
         ROWS BETWEEN CURRENT ROW 
                  AND Unbounded Following) AS next_price
  ,Lead(price, 0) IGNORE NULLS
   Over (ORDER BY dt) AS next_price2
FROM vt_prices
WHERE item = 1
ORDER BY item, dt
;


/**** Default database for labs ****/
DATABASE finance_payroll;

/********************
 * Windowed Aggregates: Window Frames Lab 1 - 4
 ********************/

HELP TABLE fin_trans;


/********************
 * Windowed Aggregates: Window Frames Lab 1 Solution
 ********************/

SELECT
   Extract(YEAR From trans_date) AS yy
  ,Extract(MONTH From trans_date) AS mm
  ,Avg(amount) AS avgamt
  ,Sum(amount) AS sumamt
  ,Sum(sumamt) 
   Over (PARTITION BY yy
         ORDER BY mm
         ROWS Unbounded Preceding) AS cumsum
FROM fin_trans
WHERE trans_type = 'C'
  AND Extract(YEAR From trans_date) BETWEEN 2014 AND 2018
GROUP BY 1,2
ORDER BY 1,2
;


/********************
 * Windowed Aggregates: Window Frames Lab 2 Solution
 ********************/

SELECT
   Extract(YEAR From trans_date) AS yy
  ,Extract(MONTH From trans_date) AS mm
  ,Avg(amount) AS avgamt
  ,Sum(amount) AS sumamt
  ,sumamt 
    / Lag(sumamt, 12) 
      Over (ORDER BY yy, mm) AS factor
-- A different way to get the same month previous year 
--   Lag(sumamt) 
--   Over (PARTITION BY mm
--         ORDER BY yy) AS factor
FROM fin_trans
WHERE trans_type = 'C'
  AND Extract(YEAR From trans_date) BETWEEN 2014 AND 2018
GROUP BY 1,2
QUALIFY factor > 1.45
ORDER BY 1,2
;


/********************
 * Windowed Aggregates: Window Frames Lab 3 Solution
 ********************/

SELECT account_id
  ,trans_date
  ,amount
  ,First_Value(balance)
   Over (PARTITION BY account_id
         ORDER BY trans_date) 
   + Sum(amount) 
     Over (PARTITION BY account_id
           ORDER BY trans_date
           ROWS Unbounded Preceding) AS balance
FROM fin_trans
WHERE account_id = 4150
AND trans_date BETWEEN DATE '2018-01-01' AND  DATE '2018-01-31'
ORDER BY trans_date
;


/********************
 * Windowed Aggregates: Window Frames Lab 4 Solution
 ********************/

SELECT
   account_id
  ,Count(*) AS order_count
  ,Cast(Avg(diff) AS INT) AS avg_days
FROM
 (
   SELECT
     account_id
     ,trans_date
     ,NullIf(trans_date
             - Lag(trans_date)
               Over (PARTITION BY account_id
                     ORDER BY trans_date), 0) AS diff
   FROM finance_payroll.fin_trans
   WHERE Extract(YEAR From trans_date) = 2018
   AND trans_type = 'P'
   QUALIFY 
     Count(*)
      Over (PARTITION BY account_id) > 12
 ) dt
GROUP BY 1
ORDER BY 1;

-- Simplified
SELECT
   account_id
  ,Count(*) AS order_count
  ,(Max(trans_date) - Min(trans_date))
    / (Count(DISTINCT trans_date)-1) AS avg_days
FROM fin_trans
WHERE Extract(YEAR From trans_date) = 2018
  AND trans_type = 'P'
GROUP BY 1
HAVING order_count > 12
ORDER BY 1
;
