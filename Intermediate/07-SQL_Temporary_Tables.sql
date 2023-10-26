/********************
 * Module CREATE TABLE AS
 ********************/

DATABASE employee_sales;


/********************
 * Permanent Tables as Interim Tables
 ********************/

CREATE TABLE daily_net_trans 
 (
   account_number INTEGER
  ,total_trans_amount DECIMAL(14,2)
 )
UNIQUE PRIMARY INDEX (Account_Number)
;

INSERT INTO daily_net_trans
SELECT  
   account_number
  ,SUM(trans_amount)
FROM  trans
GROUP BY account_number
;

SELECT *
FROM  daily_net_trans
WHERE account_number IN
  (  20035223
     ,20024048
     ,20045853
  )
;

DROP TABLE daily_net_trans 
;


/********************
 * Volatile Table Syntax
 ********************/

-- create volatile table in spool space
CREATE VOLATILE TABLE vt_deptsal
 (
   deptno   SMALLINT
  ,avgsal   DECIMAL(9,2)
  ,maxsal   DECIMAL(9,2)
  ,minsal   DECIMAL(9,2)
  ,sumsal   DECIMAL(9,2)
  ,empcnt   SMALLINT
 )
;

-- verify what has been created 
-- watch out for defaults
SHOW TABLE vt_deptsal
;

INSERT INTO vt_deptsal 
SELECT  
   department_number
  ,AVG(salary_amount) 
  ,MAX(salary_amount) 
  ,MIN(salary_amount)
  ,SUM(salary_amount)
  ,COUNT(employee_number)
FROM  employee
GROUP BY 1
;

SELECT
  *
FROM vt_deptsal
ORDER BY 1
;
 
/********************
 * Volatile Table Traps
 ********************/

-- create volatile table in spool space
CREATE VOLATILE TABLE vt_deptsal
 (
   deptno   SMALLINT
  ,avgsal   DECIMAL(9,2)
  ,maxsal   DECIMAL(9,2)
  ,minsal   DECIMAL(9,2)
  ,sumsal   DECIMAL(9,2)
  ,empcnt   SMALLINT
 )
;

-- verify what has been created 
-- watch out for defaults
SHOW TABLE vt_deptsal
;

INSERT INTO vt_deptsal 
SELECT  
   department_number
  ,AVG(salary_amount) 
  ,MAX(salary_amount) 
  ,MIN(salary_amount)
  ,SUM(salary_amount)
  ,COUNT(employee_number)
FROM  employee
GROUP BY 1
;

SELECT *
FROM vt_deptsal
ORDER BY maxsal DESC
;


/********************
 * Volatile Table Trap Avoided
 ********************/

-- you cannot use ALTER TABLE
DROP TABLE vt_deptsal
;
-- create a new table 
CREATE VOLATILE TABLE vt_deptsal
 (
   deptno   SMALLINT
  ,avgsal   DECIMAL(9,2)
  ,maxsal   DECIMAL(9,2)
  ,minsal   DECIMAL(9,2)
  ,sumsal   DECIMAL(9,2)
  ,empcnt   SMALLINT
 )
ON COMMIT PRESERVE ROWS
;

INSERT INTO vt_deptsal
SELECT  
   department_number
  ,AVG(salary_amount) 
  ,MAX(salary_amount) 
  ,MIN(salary_amount)
  ,SUM(salary_amount)
  ,COUNT(employee_number)
FROM  employee
GROUP BY 1
;  

SELECT *
FROM vt_deptsal
ORDER BY maxsal DESC
;

-- returns a list of all volatile tables in the current session.
HELP VOLATILE TABLE
;
 
/********************
 * Global Temporary Tables Syntax
 ********************/

CREATE GLOBAL TEMPORARY TABLE gt_deptsal
 (
   deptno   SMALLINT
  ,avgsal   DECIMAL(9,2)
  ,maxsal   DECIMAL(9,2)
  ,minsal   DECIMAL(9,2)
  ,sumsal   DECIMAL(9,2)
  ,empcnt   SMALLINT
 )
UNIQUE PRIMARY INDEX (deptno)
;
SHOW TABLE gt_deptsal
;

/********************
 * Global Temporary Tables Syntax (cont.)
 ********************/

EXPLAIN
SELECT *
FROM gt_deptsal
;

EXPLAIN
INSERT INTO gt_deptsal 
SELECT  
   department_number
  ,AVG(salary_amount)
  ,MAX(salary_amount)
  ,MIN(salary_amount)
  ,SUM(salary_amount)
  ,COUNT(employee_number)
FROM employee
GROUP BY 1
;

INSERT INTO gt_deptsal 
SELECT  
   department_number
  ,AVG(salary_amount)
  ,MAX(salary_amount)
  ,MIN(salary_amount)
  ,SUM(salary_amount)
  ,COUNT(employee_number)
FROM employee
GROUP BY 1
;

EXPLAIN
SELECT *
FROM gt_deptsal
;

SELECT *
FROM gt_deptsal
;


/********************
 * Global Temporary Tables - Space Allocation
 ********************/

SELECT
   TempSpace
  ,SpoolSpace
FROM dbc.UsersV
;

SELECT
   SUM(MaxTemp)     AS temp_available
  ,SUM(CurrentTemp) AS temp_used
FROM dbc.DiskSpacev
WHERE databasename = USER
;

SELECT
  *
FROM dbc.AllTempTablesV
;





-- Default database for labs

DATABASE finance_payroll;


/********************
 * Volatile Tables Lab 1
 ********************/

HELP TABLE fin_trans;
HELP TABLE fin_account;

-- Scalar Subquery Lab 2 Solution
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
FROM  fin_account AS a 
JOIN fin_trans AS t
  ON a.account_id = t.account_id
WHERE a.district_id = 1
ORDER BY t.account_id, t.trans_date
;

-- Scalar Subquery Lab 2 Solution (Join)
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


/********************
 * Volatile Tables Lab 2
 ********************/

-- Scalar Subquery Lab 3 Solution
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

-- Scalar Subquery Lab 3 Solution (Join)
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







/********************
 * Volatile Tables Lab 1 Solution
 ********************/

--DROP  TABLE vt_amounts;
-- SET QUERY_BAND = 'lab=volatile;LabNo=1-CVT;' UPDATE FOR SESSION VOLATILE;
CREATE MULTISET VOLATILE TABLE vt_amounts AS
 (
   SELECT 
      t.account_id
     ,t.trans_date
     ,t.amount
     ,t.trans_id -- Join version needs to add the PK column trans_id
   FROM fin_account AS a 
   JOIN fin_trans AS t
     ON a.account_id = t.account_id
   WHERE a.district_id = 1
 ) WITH DATA
PRIMARY INDEX(account_id)
ON COMMIT PRESERVE ROWS
;

-- SSQ
-- SET QUERY_BAND = 'lab=volatile;LabNo=1-SSQ;' UPDATE FOR SESSION VOLATILE;
SELECT
   t.account_id
  ,t.trans_date
  ,t.amount
  ,(
     SELECT Sum(amount)
     FROM vt_amounts AS t2
     WHERE t2.account_id = t.account_id
       AND t2.trans_date BETWEEN t.trans_date - 27
                             AND t.trans_date
   ) AS sum_prev_28_days
FROM vt_amounts AS t
ORDER BY t.account_id, t.trans_date
;

-- Join, needs to add the PK column trans_id
-- SET QUERY_BAND = 'lab=volatile;LabNo=1-Join;' UPDATE FOR SESSION VOLATILE;

SELECT 
   t.account_id
  ,t.trans_date
  ,t.amount
  ,Sum(t2.amount) AS sum_prev_28_days
FROM vt_amounts AS t 
JOIN vt_amounts AS t2
  ON t2.account_id = t.account_id
 AND t2.trans_date BETWEEN t.trans_date - 27
                       AND t.trans_date
GROUP BY 1,2,3,t.trans_id
ORDER BY t.account_id, t.trans_date
;  


/********************
 * Volatile Tables Lab 2 Solution
 ********************/

-- SSQ 
-- SET QUERY_BAND = 'lab=volatile;LabNo=2-SSQ*2;' UPDATE FOR SESSION VOLATILE;
SELECT
   t.account_id
  ,t.trans_date
  ,t.amount
  ,(
     SELECT Sum(amount)
     FROM vt_amounts AS t2
     WHERE t2.account_id = t.account_id
       AND t2.trans_date BETWEEN t.trans_date - 27
                             AND t.trans_date
   ) AS sum_prev_28_days
  ,(
     SELECT Count(*)
     FROM vt_amounts AS t2
     WHERE t2.account_id = t.account_id
       AND t2.trans_date BETWEEN t.trans_date - 27
                             AND t.trans_date
   ) AS count_prev_28_days
FROM vt_amounts AS t
ORDER BY t.account_id, t.trans_date
;

-- Join, needs to add the PK column trans_id
-- SET QUERY_BAND = 'lab=volatile;LabNo=2-Join*2;' UPDATE FOR SESSION VOLATILE;
SELECT 
   t.account_id
  ,t.trans_date
  ,t.amount
  ,Sum(t2.amount) AS sum_prev_28_days
  ,Count(*) AS count_prev_28_days
FROM vt_amounts AS t 
JOIN vt_amounts AS t2   
  ON t2.account_id = t.account_id
 AND t2.trans_date BETWEEN t.trans_date - 27 AND t.trans_date
GROUP BY 1,2,3,t.trans_id
ORDER BY t.account_id, t.trans_date
;  


-- SET QUERY_BAND = 'lab=volatile;LabNo=2-SSQ*3;' UPDATE FOR SESSION VOLATILE;
SELECT
   t.account_id
  ,t.trans_date
  ,t.amount
  ,(
     SELECT Sum(amount)
     FROM vt_amounts AS t2
     WHERE t2.account_id = t.account_id
       AND t2.trans_date BETWEEN t.trans_date - 27
                             AND t.trans_date
   ) AS sum_prev_28_days
  ,(
     SELECT avg(amount)
     FROM vt_amounts AS t2
     WHERE t2.account_id = t.account_id
       AND t2.trans_date BETWEEN t.trans_date - 27
                             AND t.trans_date
   ) AS avg_prev_28_days
  ,(
     SELECT Count(*)
     FROM vt_amounts AS t2
     WHERE t2.account_id = t.account_id
       AND t2.trans_date BETWEEN t.trans_date - 27
                             AND t.trans_date
   ) AS count_prev_28_days
FROM vt_amounts AS t
ORDER BY t.account_id, t.trans_date
;

-- Join, needs to add the PK column trans_id
-- SET QUERY_BAND = 'lab=volatile;LabNo=2-Join*3;' UPDATE FOR SESSION VOLATILE;
SELECT 
   t.account_id
  ,t.trans_date
  ,t.amount
  ,Sum(t2.amount) AS sum_prev_28_days
  ,Avg(t2.amount) AS sum_prev_28_days
  ,Count(*) AS count_prev_28_days
FROM vt_amounts AS t 
JOIN vt_amounts AS t2   
  ON t2.account_id = t.account_id
 AND t2.trans_date BETWEEN t.trans_date - 27 AND t.trans_date
GROUP BY 1,2,3,t.trans_id
ORDER BY t.account_id, t.trans_date
;  

-- Get info from DBQL
FLUSH QUERY LOGGING WITH DEFAULT
;
SELECT
   TotalFirstRespTime AS RunTime
  ,TotalIOCount AS IO_logical
  ,ReqPhysIO   AS IO_physical
  ,AMPCPUTime  AS CPU
  ,SpoolUsage
  ,GetQueryBandValue(queryband, 0, 'LabNo') as lab
FROM dbc.QryLogV
WHERE UserName = USER 
  AND StartTime >= Current_Timestamp - INTERVAL '10' MINUTE
  AND GetQueryBandValue(queryband, 0, 'lab') = 'volatile'
  AND CPU > 1
ORDER BY StartTime
;

/*************
-- 24 AMP system, dbc.QryLogV

-- Using base tables                                      -- Using Volatile tables 
RunTime IO_logical    CPU   SpoolUsage                    RunTime IO_logical    CPU   SpoolUsage
------- ---------- ------  -----------                    ------- ---------- ------  -----------
                                            Create VT        0.19      2,159   2.22   13,910,016    
   1.35     24,739  22.93  300,883,968      SSQ              0.61      4,365   9.00   38,363,136
   4.33     46,356  80.16  404,602,880      SSQ*2            1.16      8,398  18.23   48,476,160
                                            SSQ*3            1.50     11,322  22.98   55,255,040
   0.60      6,653   9.92   46,268,416      Join             0.36      2,648   5.28   46,268,416
   0.62      6,742   9.60   47,333,376      Join*2           0.33      2,737   5.31   47,333,376
                                            Join*3           0.33      2,860   5.24   48,402,432

 ************/

