/********************
 * Module MERGE INTO
 ********************/

--DATABASE employee_sales;


/********************
 * MERGE Single Row
 ********************/

-- prepare local table copy
DATABASE trainee_1;

--DROP TABLE department;
CREATE TABLE department AS employee_sales.department WITH DATA;

-- department table BEFORE merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;

MERGE INTO department AS tgt
USING VALUES (700, 'Shipping', 800000.00) 
   AS src (dept#, NAME, budget)
ON src.dept# = tgt.department_number

WHEN MATCHED THEN UPDATE
SET department_name   = src.NAME
   ,budget_amount     = src.budget
   
WHEN NOT MATCHED THEN INSERT
VALUES
 ( src.dept#
  ,src.NAME
  ,src.budget
  ,NULL -- no manager_employee_number
 )
;

-- department table AFTER merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;


/********************
 * MERGE Multiple Rows
 ********************/

-- drop table department_staging;
CREATE TABLE department_staging AS department WITH NO DATA;

INSERT INTO department_staging VALUES(  1, 'new department'          ,       .00,  801); -- new row
INSERT INTO department_staging VALUES(301, 'research and development', 512160.00, 1019); -- updated budget and manager
INSERT INTO department_staging VALUES(302, 'product planning'        , 248600.00, 1016); -- updated budget
INSERT INTO department_staging VALUES(501, 'marketing sales'         , 308000.00, 1017); -- no updates
INSERT INTO department_staging VALUES(600, 'none'                    ,      NULL, 1099); -- updated name

-- department table BEFORE merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;

-- EXPLAIN
MERGE INTO department AS tgt
USING department_staging AS src
ON src.department_number = tgt.department_number

WHEN MATCHED THEN UPDATE
SET department_name         = src.department_name
   ,budget_amount           = src.budget_amount
   ,manager_employee_number = src.manager_employee_number
   
WHEN NOT MATCHED THEN INSERT
VALUES
 ( src.department_number
  ,src.department_name
  ,src.budget_amount
  ,src.manager_employee_number
 )
;

-- department table AFTER merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;


/********************
 * MERGE Update Only
 ********************/

-- reset department table
DELETE FROM department;
INSERT INTO department SELECT * FROM employee_sales.department;

-- department table BEFORE merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;

-- EXPLAIN
MERGE INTO department AS tgt
USING 
 (
   SELECT department_number AS dept#
     ,Sum(salary_amount) AS sum_sal
   FROM employee_sales.employee
   GROUP BY 1
 ) AS src
ON tgt.department_number = src.dept#

WHEN MATCHED THEN UPDATE
SET budget_amount = budget_amount + src.sum_sal
;

-- department table AFTER merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;


-- same logic using UPDATE

-- reset department table
DELETE FROM department;
INSERT INTO department SELECT * FROM employee_sales.department;

--EXPLAIN
UPDATE department
FROM
 (
   SELECT department_number AS dept#
     ,Sum(salary_amount) AS sum_sal
   FROM employee_sales.employee
   GROUP BY 1
 ) AS src
SET budget_amount = budget_amount + src.sum_sal
WHERE department_number = src.dept#
;
-- syntax variation
--EXPLAIN
UPDATE d
FROM department AS d,
 (
   SELECT department_number AS dept#
     ,Sum(salary_amount) AS sum_sal
   FROM employee_sales.employee
   GROUP BY 1
 ) AS src
SET budget_amount = d.budget_amount + src.sum_sal
WHERE d.department_number = src.dept#
;


-- department table AFTER merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;


/********************
 * MERGE Insert Only
 ********************/

-- empty department table
DELETE FROM department;

MERGE INTO department AS tgt
USING department_staging AS src
ON src.department_number = tgt.department_number
AND 1=0

WHEN NOT MATCHED THEN INSERT
VALUES
 ( src.department_number
  ,src.department_name
  ,src.budget_amount
  ,src.manager_employee_number
 )
;

-- department table AFTER merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;


-- same logic using INSERT

-- reset department table
DELETE FROM department;

INSERT INTO department
SELECT 
   department_number
  ,department_name
  ,budget_amount
  ,manager_employee_number
FROM department_staging
;


-- department table AFTER merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;


/********************
 * MERGE Delete
 ********************/

-- reset department table
DELETE FROM department;
INSERT INTO department SELECT * FROM employee_sales.department;

-- department table BEFORE merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;

-- EXPLAIN
MERGE INTO department AS tgt
USING department_staging AS src
ON src.department_number = tgt.department_number

WHEN MATCHED THEN DELETE
;

-- department table AFTER merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;


-- same logic using DELETE

-- reset department table
DELETE FROM department;
INSERT INTO department SELECT * FROM employee_sales.department;

--EXPLAIN
DELETE FROM department AS tgt
WHERE EXISTS
 (
   SELECT 1
   FROM department_staging AS src
   WHERE src.department_number = tgt.department_number
 ) 
;

-- department table AFTER merge
SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount
  ,manager_employee_number AS mgr#
FROM department
ORDER BY 1
;


/********************
 * Error Handling
 ********************/

-- reset department table
DELETE FROM department;
INSERT INTO department SELECT * FROM employee_sales.department;

ALTER TABLE department
ADD CHECK (budget_amount > 0)
;

-- fails due to 5317 Check constraint violation: Check error in field department.budget_amount
MERGE INTO department AS tgt
USING department_staging AS src
ON src.department_number = tgt.department_number

WHEN MATCHED THEN UPDATE
SET department_name         = src.department_name
   ,budget_amount           = src.budget_amount
   ,manager_employee_number = src.manager_employee_number
   
WHEN NOT MATCHED THEN INSERT
VALUES
 ( src.department_number
  ,src.department_name
  ,src.budget_amount
  ,src.manager_employee_number
 )
;


/********************
 * Error Tables
 ********************/

CREATE ERROR TABLE FOR department;

SHOW ERROR TABLE FOR department;


/********************
 * MERGE Using an Error Table
 ********************/

MERGE INTO department AS tgt
USING department_staging AS src
ON src.department_number = tgt.department_number

WHEN MATCHED THEN UPDATE
SET department_name         = src.department_name
   ,budget_amount           = src.budget_amount
   ,manager_employee_number = src.manager_employee_number
   
WHEN NOT MATCHED THEN INSERT
VALUES
 ( src.department_number
  ,src.department_name
  ,src.budget_amount
  ,src.manager_employee_number
 )
LOGGING ALL ERRORS
;

SELECT 
   department_number AS dept#
  ,department_name
  ,budget_amount AS budget
  ,manager_employee_number  AS mgr#
  ,ETC_DBQL_QID
  ,ETC_DMLType
  ,ETC_ErrorCode
  ,ETC_ErrSeq
  ,ETC_FieldId 
  ,ETC_TimeStamp
FROM ET_department 
WHERE ETC_dbql_qid = 307190995672810431 -- Copied from Studio History Result Message
ORDER BY ETC_ErrSeq, ETC_ErrorCode DESC
;



-- Default database for labs
--DATABASE financial_payroll;

/********************
 * Lab MERGE 1
 ********************/

DATABASE trainee_1;

/*
-- Stage tables were already created:
CREATE TABLE finance_payroll.trans_staging_1 AS finance_payroll.fin_trans WITH NO DATA
;

INSERT INTO finance_payroll.trans_staging_1
SELECT -- new rows -> insert
   Trans_Id + 4000000 AS trans_id,
   Account_Id,
   Add_Months(Trans_Date, 36) AS trans_date,
   Amount,
   Balance,
   Trans_Type,
   Category,
   Other_Bank_Id,
   Other_Account_Id
FROM finance_payroll.fin_trans
WHERE trans_id < 500000
;INSERT INTO finance_payroll.trans_staging_1
SELECT -- existing rows -> update
   Trans_Id,
   Account_Id,
   Trans_Date,
   Amount * 1.5 AS amount,
   Balance,
   Trans_Type,
   Operation,
   Category,
   Other_Bank_Id,
   Other_Account_Id
FROM finance_payroll.fin_trans
WHERE trans_id BETWEEN 500000 AND 1000000
;

CREATE TABLE finance_payroll.trans_staging_2 AS finance_payroll.fin_trans WITH NO DATA
;

INSERT finance_payroll.trans_staging_2
SELECT -- new rows -> insert
   Trans_Id + 4000000 AS trans_id,
   Account_Id,
   Add_Months(Trans_Date, 36) AS trans_date,
   Amount,
   Balance,
   Trans_Type,
   Operation,
   Category,
   Other_Bank_Id,
   Other_Account_Id
FROM finance_payroll.fin_trans
WHERE trans_id BETWEEN 1000000 AND 3000000
;INSERT INTO trans_staging_2
SELECT -- existing rows -> update
   Trans_Id,
   Account_Id,
   Trans_Date,
   Amount * 1.5 AS amount,
   Balance,
   Trans_Type,
   Operation,
   Category,
   Other_Bank_Id,
   Other_Account_Id
FROM finance_payroll.fin_trans
WHERE trans_id > 3000000
;
*/

SET QUERY_BAND = 'lab=no;' UPDATE FOR SESSION VOLATILE
;
--DROP TABLE fin_trans_copy;

-- Create an exact copy of the finance_payroll.fin_trans table without data in your trainee_n user.
CREATE MULTISET TABLE fin_trans_copy AS finance_payroll.fin_trans WITH NO DATA
;
-- Write a merge to unconditionally insert all rows from the finance_payroll.fin_trans table.
SET QUERY_BAND = 'lab=merge;step=ins_empty;index=no;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING FINANCE_PAYROLL.FIN_Trans AS src
ON tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id
AND 1=0

WHEN NOT MATCHED THEN INSERT 
VALUES
 (
   src.Trans_Id,
   src.Account_Id,
   src.Trans_Date,
   src.Amount,
   src.Balance,
   src.Trans_Type,
   src.Operation,
   src.Category,
   src.Other_Bank_Id,
   src.Other_Account_Id
 )
 ;
 
-- Write an update only merge based on the finance_payroll.trans_staging_1 table.
-- Add the source table amount to the target table balance.
SET QUERY_BAND = 'lab=merge;step=update;index=no;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_1 AS src
   ON src.account_id = tgt.account_id
   AND src.trans_date = tgt.trans_date
   AND src.trans_id = tgt.trans_id

WHEN MATCHED THEN UPDATE
SET amount = src.amount
   ,balance = tgt.balance + src.amount
;

-- Write an insert only merge based on the finance_payroll.trans_staging_1 table.
SET QUERY_BAND = 'lab=merge;step=insert;index=no;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
--using trans_sample as src
USING finance_payroll.trans_staging_1 AS src
ON tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id

WHEN NOT MATCHED THEN INSERT 
VALUES
 (
   src.Trans_Id,
   src.Account_Id,
   src.Trans_Date,
   src.Amount,
   src.Balance,
   src.Trans_Type,
   src.Operation,
   src.Category,
   src.Other_Bank_Id,
   src.Other_Account_Id
 )
;
 
-- Write a merge to insert and update based on the finance_payroll.trans_staging_2 table.
-- Add the source table amount to the target table balance.
SET QUERY_BAND = 'lab=merge;step=merge;index=no;' UPDATE FOR SESSION VOLATILE
; 
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_2 AS src
ON tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id

WHEN NOT MATCHED THEN INSERT 
VALUES
 (
   src.Trans_Id,
   src.Account_Id,
   src.Trans_Date,
   src.Amount,
   src.Balance,
   src.Trans_Type,
   src.Operation,
   src.Category,
   src.Other_Bank_Id,
   src.Other_Account_Id
 )

WHEN MATCHED THEN UPDATE
SET amount = src.amount
   ,balance = tgt.balance + src.amount
;

-- Write a merge to delete based on the finance_payroll.trans_staging_2 table.
SET QUERY_BAND = 'lab=merge;step=delete;index=no;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_2 AS src
   ON src.account_id = tgt.account_id
   AND src.trans_date = tgt.trans_date
   AND src.trans_id = tgt.trans_id

WHEN MATCHED THEN DELETE
;

-- Drop the table.
SET QUERY_BAND = 'lab=no;' UPDATE FOR SESSION VOLATILE
;
DROP TABLE fin_trans_copy
;

-------------------------------------------------------------------------------
-- Repeat all steps, but add a USI on (trans_id, balance) and compare runtimes.
CREATE MULTISET TABLE fin_trans_copy AS finance_payroll.fin_trans WITH NO DATA
;
CREATE UNIQUE INDEX  (trans_id, balance) ON fin_trans_copy
;

SET QUERY_BAND = 'lab=merge;step=ins_empty;index=USI;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING FINANCE_PAYROLL.FIN_Trans AS src
ON tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id
AND 1=0

WHEN NOT MATCHED THEN INSERT 
VALUES
 (
   src.Trans_Id,
   src.Account_Id,
   src.Trans_Date,
   src.Amount,
   src.Balance,
   src.Trans_Type,
   src.Operation,
   src.Category,
   src.Other_Bank_Id,
   src.Other_Account_Id
 )
;
 

SET QUERY_BAND = 'lab=merge;step=update;index=USI;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_1 AS src
   ON src.account_id = tgt.account_id
   AND src.trans_date = tgt.trans_date
   AND src.trans_id = tgt.trans_id

WHEN MATCHED THEN UPDATE
SET amount = src.amount
   ,balance = tgt.balance + src.amount
;

SET QUERY_BAND = 'lab=merge;step=insert;index=USI;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
--using trans_sample as src
USING finance_payroll.trans_staging_1 AS src
ON tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id

WHEN NOT MATCHED THEN INSERT 
VALUES
 (
   src.Trans_Id,
   src.Account_Id,
   src.Trans_Date,
   src.Amount,
   src.Balance,
   src.Trans_Type,
   src.Operation,
   src.Category,
   src.Other_Bank_Id,
   src.Other_Account_Id
 )
 ;
 
SET QUERY_BAND = 'lab=merge;step=merge;index=USI;' UPDATE FOR SESSION VOLATILE
; 
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_2 AS src
ON tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id

WHEN NOT MATCHED THEN INSERT 
VALUES
 (
   src.Trans_Id,
   src.Account_Id,
   src.Trans_Date,
   src.Amount,
   src.Balance,
   src.Trans_Type,
   src.Operation,
   src.Category,
   src.Other_Bank_Id,
   src.Other_Account_Id
 )

WHEN MATCHED THEN UPDATE
SET amount = src.amount
   ,balance = tgt.balance + src.amount
;

SET QUERY_BAND = 'lab=merge;step=delete;index=USI;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_2 AS src
   ON src.account_id = tgt.account_id
   AND src.trans_date = tgt.trans_date
   AND src.trans_id = tgt.trans_id

WHEN MATCHED THEN DELETE
;

SET QUERY_BAND = 'lab=no;' UPDATE FOR SESSION VOLATILE
;
DROP TABLE fin_trans_copy
;

----------------------------------------------------------------------------------
-- Repeat all steps, but add a NUSI on (trans_date, balance) and compare runtimes.
CREATE MULTISET TABLE fin_trans_copy AS finance_payroll.fin_trans WITH NO DATA
;
CREATE INDEX(trans_date, balance) ON fin_trans_copy
;

SET QUERY_BAND = 'lab=merge;step=ins_empty;index=NUSI;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING FINANCE_PAYROLL.FIN_Trans AS src
ON tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id
AND 1=0

WHEN NOT MATCHED THEN INSERT 
VALUES
 (
   src.Trans_Id,
   src.Account_Id,
   src.Trans_Date,
   src.Amount,
   src.Balance,
   src.Trans_Type,
   src.Operation,
   src.Category,
   src.Other_Bank_Id,
   src.Other_Account_Id
 )
;
 
SET QUERY_BAND = 'lab=merge;step=update;index=NUSI;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_1 AS src
   ON src.account_id = tgt.account_id
   AND src.trans_date = tgt.trans_date
   AND src.trans_id = tgt.trans_id

WHEN MATCHED THEN UPDATE
SET amount = src.amount
   ,balance = tgt.balance + src.amount
;

SET QUERY_BAND = 'lab=merge;step=insert;index=NUSI;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_1 AS src
ON tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id

WHEN NOT MATCHED THEN INSERT 
VALUES
 (
   src.Trans_Id,
   src.Account_Id,
   src.Trans_Date,
   src.Amount,
   src.Balance,
   src.Trans_Type,
   src.Operation,
   src.Category,
   src.Other_Bank_Id,
   src.Other_Account_Id
 )
;
 
SET QUERY_BAND = 'lab=merge;step=merge;index=NUSI;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_2 AS src
ON tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id

WHEN NOT MATCHED THEN INSERT 
VALUES
 (
   src.Trans_Id,
   src.Account_Id,
   src.Trans_Date,
   src.Amount,
   src.Balance,
   src.Trans_Type,
   src.Operation,
   src.Category,
   src.Other_Bank_Id,
   src.Other_Account_Id
 )

WHEN MATCHED THEN UPDATE
SET amount = src.amount
   ,balance = tgt.balance + src.amount
;

SET QUERY_BAND = 'lab=merge;step=delete;index=NUSI;' UPDATE FOR SESSION VOLATILE
;
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_2 AS src
   ON src.account_id = tgt.account_id
   AND src.trans_date = tgt.trans_date
   AND src.trans_id = tgt.trans_id

WHEN MATCHED THEN DELETE
;
 
SET QUERY_BAND = 'lab=no;' UPDATE FOR SESSION VOLATILE
;
DROP TABLE fin_trans_copy
;

-- Get info from DBQL
FLUSH QUERY LOGGING WITH DEFAULT
;
SELECT
   StartTime
  ,TotalFirstRespTime      AS RunTime
  ,TotalIOCount            AS IO_logical
  ,ReqPhysIO               AS IO_physical
  ,AMPCPUTime              AS CPU
  ,Coalesce(SpoolUsage, 0) AS SpoolUsage
--  ,StatementType
  ,Coalesce(Cast(StmtDMLRowCount."Insert" AS INT), 0) AS InsCnt
  ,Coalesce(Cast(StmtDMLRowCount."Update" AS INT), 0) AS UpdCnt
  ,Coalesce(Cast(StmtDMLRowCount."Delete" AS INT), 0) AS DelCnt
  ,GetQuerybandValue(queryband, 0, 'step')            AS step
  ,GetQuerybandValue(queryband, 0, 'index')           AS idx
FROM dbc.QryLogV
WHERE UserName = USER 
  AND StartTime = Current_Date
  AND GetQuerybandValue(queryband, 0, 'lab') = 'merge'
  AND QueryBand IS NOT NULL
  AND (InsCnt IS NOT NULL OR updcnt IS NOT NULL OR delcnt IS NOT NULL)
  AND StartTime >= Current_Timestamp - INTERVAL '15' MINUTE
ORDER BY StartTime
; 

/********* 24-AMP system with Block Level Compression (BLC)

RunTime IO_logical IO_physical  CPU     SpoolUsage  InsCnt     UpdCnt   DelCnt   step       idx  
------- ---------- -----------  ------  ----------  ---------  -------  -------  ---------  ---- 
   0.52      3,143       1,015    4.28           0  1,056,320        0        0  ins_empty  no  
  10.71  1,236,257       3,359  113.30           0  1,056,320        0        0  ins_empty  USI 
   1.01      9,100       2,682    6.05           0  1,056,320        0        0  ins_empty  NUSI
                                                                                            
   0.43      6,405         606    5.18           0          0  305,946        0  update     no  
   1.13     14,636       2,957    8.70           0          0  305,946        0  update     USI 
   1.50     17,950       3,041   17.00           0          0  305,946        0  update     NUSI
                                                                                            
   0.43      7,549       1,605    5.39           0    307,550        0        0  insert     no  
   0.93     12,305       3,688    7.76           0    307,550        0        0  insert     USI 
   0.81     14,603       3,107   10.35           0    307,550        0        0  insert     NUSI
                                                                                            
   0.65     10,016       2,250    7.89           0    233,247  209,577        0  merge      no  
   1.20     19,369       4,868   12.45           0    233,247  209,577        0  merge      USI 
   1.37     26,557       5,526   17.42           0    233,247  209,577        0  merge      NUSI
                                                                                            
   0.42     10,340       1,712    6.72           0          0        0  442,824  delete     no  
   0.74     15,731       2,975    9.30           0          0        0  442,824  delete     USI 
   1.47     19,399       3,615   21.50           0          0        0  442,824  delete     NUSI

**********/

/********* Same 24-AMP system but BLC switched off
 ********* SET QUERY_BAND = 'BLOCKCOMPRESSION=no;' UPDATE FOR SESSION VOLATILE;
 
RunTime IO_logical IO_physical  CPU     SpoolUsage  InsCnt     UpdCnt   DelCnt   step       idx  
------- ---------- -----------  ------  ----------  ---------  -------  -------  ---------  ---- 
   0.60      3,169       1,030    2.41           0  1,056,320        0        0  ins_empty  no  
   1.65  1,234,899       2,594   19.21           0  1,056,320        0        0  ins_empty  USI 
   1.34      9,282       2,717    3.77           0  1,056,320        0        0  ins_empty  NUSI
                                                                                            
   0.48     11,845         714    3.38           0          0  305,946        0  update     no  
   1.51     14,064       2,947    6.67           0          0  305,946        0  update     USI 
   1.33     16,837       2,789   14.44           0          0  305,946        0  update     NUSI
                                                                                            
   0.61      7,824       2,079    3.26           0    307,550        0        0  insert     no  
   1.07     12,681       4,234    5.53           0    307,550        0        0  insert     USI 
   1.13     14,991       3,638    7.31           0    307,550        0        0  insert     NUSI
                                                                                            
   0.99     10,001       2,639    4.10           0    233,247  209,577        0  merge      no  
   2.08     20,783       5,550    8.03           0    233,247  209,577        0  merge      USI 
   2.02     27,772       6,115   11.93           0    233,247  209,577        0  merge      NUSI
                                                                                            
   0.34     10,244       1,704    4.16           0          0        0  442,824  delete     no  
   1.27     15,346       2,694    6.25           0          0        0  442,824  delete     USI 
   1.61     19,257       3,436   17.49           0          0        0  442,824  delete     NUSI

**********/



/********************
 * Lab MERGE 2
 ********************/
-- just in case the table exists from a previous run
--DROP ERROR TABLE FOR fin_trans_copy
;
DROP TABLE fin_trans_copy
;

-- Create an exact copy of the finance_payroll.fin_trans table without data in your trainee_n user.
SET QUERY_BAND = 'lab=no;' UPDATE FOR SESSION VOLATILE
;
CREATE MULTISET TABLE fin_trans_copy AS finance_payroll.fin_trans WITH NO DATA
;
--Add a check constraint and an error table:
ALTER TABLE fin_trans_copy ADD CHECK(balance <= 15000)
;
CREATE ERROR TABLE FOR fin_trans_copy
;
SHOW ERROR TABLE FOR fin_trans_copy
;

-- Write an Insert/Select to insert all rows from the finance_payroll.fin_trans table and run it three times:
-- 1. without LOGGING ERRORS
INSERT INTO fin_trans_copy 
SELECT * FROM finance_payroll.fin_trans
;

-- 2. using LOGGING ERRORS
INSERT INTO fin_trans_copy 
SELECT * FROM finance_payroll.fin_trans
LOGGING ERRORS
;

-- 3. using LOGGING ERRORS WITH NO LIMIT
INSERT INTO fin_trans_copy 
SELECT * FROM finance_payroll.fin_trans
LOGGING ERRORS WITH NO LIMIT
;

-- Write a merge to insert and update based on the finance_payroll.trans_staging_2 table.
-- Add the source table amount to the target table balance.
-- Run it using LOGGING ERRORS WITH NO LIMIT.
MERGE INTO fin_trans_copy AS tgt
USING finance_payroll.trans_staging_2 AS src
ON tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id

WHEN NOT MATCHED THEN 
INSERT 
VALUES(
   src.Trans_Id,
   src.Account_Id,
   src.Trans_Date,
   src.Amount,
   src.Balance,
   src.Trans_Type,
   src.Operation,
   src.Category,
   src.Other_Bank_Id,
   src.Other_Account_Id
 )

WHEN MATCHED THEN UPDATE
SET amount = src.amount
   ,balance = tgt.balance + src.amount

LOGGING ERRORS WITH NO LIMIT
;


-- Check the Result column in Studio's SQL History and analyze the errors. 

SELECT TOP 15
   ETC_DMLType
  ,ETC_ErrorCode
  ,ETC_ErrSeq
  ,ETC_TimeStamp
FROM ET_fin_trans_copy 
WHERE ETC_dbql_qid = nnnnnnnnnnnnnn -- Result column copied from SQL History Result column 
ORDER BY ETC_ErrSeq DESC, ETC_ErrorCode
;

SELECT 
   ETC_DBQL_QID
  ,ETC_DMLType
  ,Count(*)
FROM ET_fin_trans_copy 
WHERE ETC_dbql_qid = nnnnnnnnnnnnnn -- Result column copied from SQL History Result column 
GROUP BY 1,2
ORDER BY 1,2
;

-- Drop the table.
-- Error table must be dropped first
DROP ERROR TABLE FOR fin_trans_copy
;
DROP TABLE fin_trans_copy
;