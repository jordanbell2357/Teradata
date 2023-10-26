/********************
 * Module Windowed Aggregates: Reset When
 ********************/

DATABASE employee_sales;


/********************
 * RESET WHEN Clause
 ********************/

/*
OVER ( [ partition_by_clause ] 
       [ ORDER BY value_specification [,...] [ RESET WHEN condition ]] 
       [ rows_clause ] )
*/

/********************
 * RESET WHEN
 ********************/

SELECT
   birthdate AS dt
  ,salary_amount AS amount
  -- cumulative sum which resets on NULL
  ,Sum(amount)
   Over (ORDER BY dt 
         RESET WHEN amount IS NULL 
         ROWS Unbounded Preceding 
        ) AS cumsum
FROM employee
;


/********************
 * RESET WHEN Rewrite 
 ********************/

WITH cte_dynamic_partition AS
 (
   SELECT 
      birthdate AS dt
     ,salary_amount AS amount
     ,Sum(CASE WHEN amount IS NULL THEN 1 ELSE 0 END)
      Over (ORDER BY dt
           ROWS Unbounded Preceding ) AS sub_part
   FROM employee 
 )
SELECT
   t.*
  ,Sum(amount)
   Over (PARTITION BY sub_part
         ORDER BY dt 
         ROWS Unbounded Preceding 
        ) AS cumsum
FROM cte_dynamic_partition AS t
;


/********************
 * RESET WHEN Nested OLAP Function
 ********************/

SELECT 
   birthdate AS dt
  ,salary_amount AS amount
  ,Row_Number()
   Over (ORDER BY dt
         RESET WHEN amount < Lag(amount)
                             Over (ORDER BY dt)
        )-1  AS increases
FROM employee
WHERE amount IS NOT NULL
;


/********************
 * RESET WHEN Nested OLAP Function Rewrite 
 ********************/

WITH cte_flag AS
 ( 
   SELECT 
      birthdate AS dt
     ,salary_amount AS amount
     ,CASE WHEN amount IS NULL
             OR amount < Lag(amount)
                         Over (ORDER BY dt) 
           THEN 1
           ELSE 0
      END AS flag
   FROM employee
   WHERE amount IS NOT NULL
 )
, cte_dynamic_partition AS
 (
   SELECT 
      t.*
     ,Sum(flag)
      Over (ORDER BY dt
            ROWS Unbounded Preceding) AS sub_part
   FROM cte_flag AS t
 )
SELECT
   t.*
  ,Row_Number()
   Over (PARTITION BY sub_part
         ORDER BY dt 
        )-1  AS increases
FROM cte_dynamic_partition AS t;


/********************
 * Rewrite Recommendations
 ********************/

SELECT
   birthdate AS dt
  ,salary_amount AS amount
  -- cumulative sum which resets on NULL
  ,Sum(amount)
   Over (ORDER BY dt 
         RESET WHEN amount IS NULL 
         ROWS Unbounded Preceding 
        ) AS cumsum
  -- group count which resets on NULL
  ,Count(amount)
   Over (ORDER BY dt
         RESET WHEN amount IS NULL 
        ) AS cumcnt
FROM employee
;

WITH cte_dynamic_partition AS
 (
   SELECT 
      birthdate AS dt
     ,salary_amount AS amount
     ,Sum(CASE WHEN amount IS NULL THEN 1 ELSE 0 END)
      Over (ORDER BY dt
           ROWS Unbounded Preceding ) AS sub_part
   FROM employee 
 )
SELECT
   t.*
  ,Sum(amount)
   Over (PARTITION BY sub_part
         ORDER BY dt 
         ROWS Unbounded Preceding 
        ) AS cumsum
  ,Count(amount)
   Over (PARTITION BY sub_part
        ) AS cumcnt
FROM cte_dynamic_partition AS t
;


/********************
 * Deterministic ORDER BY
 ********************/

WITH cte_dynamic_partition AS
 (
   SELECT 
      birthdate AS dt
     ,salary_amount AS amount
     ,Sum(CASE WHEN amount IS NULL THEN 1 ELSE 0 END)
      Over (ORDER BY dt
           ROWS Unbounded Preceding ) AS sub_part
      -- guarantees deterministic order if ORDER BY is not unique
     ,Row_Number()
      Over (ORDER BY dt) AS sortcol
   FROM employee 
 )
SELECT
   t.*
  ,Sum(amount)
   Over (PARTITION BY sub_part
         ORDER BY sortcol 
         ROWS Unbounded Preceding 
        ) AS cumsum
FROM cte_dynamic_partition AS t
;



-- Default database for labs
DATABASE finance_payroll;

/********************
 * OLAP RESET WHEN Lab 1
 ********************/

HELP TABLE fin_trans;


/********************
 * OLAP RESET WHEN Lab 2
 ********************/

HELP TABLE fin_trans;


/********************
 * OLAP RESET WHEN Lab 3
 ********************/

HELP TABLE fin_trans;



/********************
 * OLAP RESET WHEN Lab 1 Solution
 ********************/

SELECT
   Extract(YEAR From trans_date) * 100
   + Extract(MONTH From trans_date) AS yyyymm
  ,Sum(amount) AS volume
  ,Row_Number()
   Over (ORDER BY yyyymm
         RESET WHEN Lag(volume) 
                    Over (ORDER BY yyyymm) > volume
     ) -1 AS sum_increased
FROM fin_trans
WHERE trans_type = 'C'
AND trans_date BETWEEN DATE '2014-01-01' AND DATE '2016-12-31'
GROUP BY yyyymm
ORDER BY yyyymm
;

/********************
 * OLAP RESET WHEN Lab 2 Solution
 ********************/

WITH cte AS
 (
   SELECT
      account_id
     ,trans_date
     ,balance
     ,Min(trans_date)
      Over (PARTITION BY account_id
            ORDER BY trans_date DESC
            RESET WHEN balance >= 0) AS min_date
   FROM fin_trans
 )
SELECT account_id
  ,min_date AS overdrawn_from
  ,Max(trans_date) AS overdrawn_to
  ,overdrawn_to - overdrawn_from AS num_days
  ,Min(balance) AS min_balance
FROM cte
GROUP BY 1, 2
HAVING num_days >= 100
ORDER BY 1,2
;


/********************
 * OLAP RESET WHEN Lab 3 Solution
 ********************/

WITH cte AS
 (
   SELECT
      account_id
     ,trans_date
     ,balance
     ,Min(trans_date)
      Over (PARTITION BY account_id
            ORDER BY trans_date DESC
            RESET WHEN balance >= 0) AS overdrawn_from
   FROM fin_trans
 )
SELECT account_id
  ,overdrawn_from
  ,Max(trans_date) AS overdrawn_to
  ,overdrawn_to - overdrawn_from AS num_days
  ,Min(balance) AS min_balance
FROM cte
GROUP BY 1, 2
HAVING num_days >= 100
   AND Min(balance) < -1000
QUALIFY Count(*) Over(PARTITION BY account_id) >= 2
ORDER BY 1,2
;


