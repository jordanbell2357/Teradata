/********************
 * Module Data Manipulation - Insert, Update, Delete
 ********************/

DATABASE trainee_1;

/********************
 * Inserting a Single Row
 ********************/

DROP TABLE employee;

CREATE TABLE employee 
AS employee_sales.employee
WITH DATA;

INSERT INTO employee
VALUES (1210, NULL, 401, 412101, 'Smith', 'James', DATE '2009-03-03', DATE '1966-04-21', 41000)
;

INSERT INTO employee
       (last_name, first_name, hire_date,         birthdate,         salary_amount, employee_number)
VALUES ('Garcia' , 'Maria'   , DATE '2006-10-27', DATE '1974-11-10', 76500.00     , 1291)
;


/********************
 * Inserting an Apostrophe within a String
 ********************/

DROP TABLE department;

CREATE TABLE department 
AS employee_sales.department
WITH DATA
;

INSERT INTO Department
VALUES(111, 'President''s Club', 400000.00, 222)
;
SELECT *
FROM department
WHERE department_name = 'President''s Club'
;

/********************
 * Inserting Default Values
 ********************/

-- it would be better to use a VOLATILE TABLE for these examples 
-- but:  *** Failure 3706 Syntax error: DEFAULT option not allowed for a volatile table.

--DROP TABLE test_defaults;

CREATE TABLE test_defaults
 (
   c1 INTEGER
  ,c2 VARCHAR(10)  DEFAULT 'n/a'
  ,c3 CHAR(5)      WITH DEFAULT ---> DEFAULT '     '
  ,c4 INTEGER      DEFAULT 10
  ,c5 INTEGER      WITH DEFAULT ---> DEFAULT 0
  ,c6 VARCHAR(128) DEFAULT USER
  ,c7 DATE         DEFAULT Current_Date
  ,c8 TIME(2)      DEFAULT Current_Time(2)
  ,c9 TIMESTAMP(2) DEFAULT Current_Timestamp(2)
 )
;
SHOW TABLE test_defaults
;

INSERT INTO test_defaults
VALUES(1 , , , , , , , , )
;
INSERT INTO test_defaults
VALUES(2,DEFAULT,DEFAULT,DEFAULT,DEFAULT,
         DEFAULT,DEFAULT,DEFAULT,DEFAULT)
;
INSERT INTO test_defaults
VALUES(3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
;

SELECT *
FROM test_defaults
ORDER BY 1;

DROP TABLE test_defaults
;


/********************
 * Default Values and NOT NULL
 ********************/

-- NULL values and other problems

CREATE MULTISET TABLE test1 
 (
  c1 INTEGER NOT NULL
 )
;

INSERT INTO test1 VALUES();        -- fails 3811 Column 'c1' is NOT NULL.  Give the column a value. 
INSERT INTO test1 VALUES(DEFAULT); -- fails 3811 Column 'c1' is NOT NULL.  Give the column a value. 
INSERT INTO test1 VALUES(NULL);    -- fails 3811 Column 'c1' is NOT NULL.  Give the column a value. 

SELECT *
FROM test1
;
DROP TABLE test1
;


CREATE MULTISET TABLE test2
 (
  c1 INTEGER NOT NULL WITH DEFAULT
 )
;
INSERT INTO test2 VALUES();        -- inserts a zero
INSERT INTO test2 VALUES(DEFAULT); -- inserts a zero
INSERT INTO test2 VALUES(NULL);    -- fails 3811 Column 'c1' is NOT NULL.  Give the column a value. 

SELECT *
FROM test2
;
DROP TABLE test2
;


CREATE MULTISET TABLE test3
 (
  c2 VARCHAR(128) NOT NULL DEFAULT USER
 )
;
INSERT INTO test3 VALUES();        -- inserts the user name
INSERT INTO test3 VALUES(DEFAULT); -- inserts the user name
INSERT INTO test3 VALUES(NULL);    -- fails 3811 Column 'c1' is NOT NULL.  Give the column a value. 

SELECT *
FROM test3
;
DROP TABLE test1
;


/********************
 * INSERT … SELECT
 ********************/

CREATE TABLE emp_copy
AS employee_sales.employee
WITH NO DATA
;

INSERT INTO emp_copy 
SELECT * 
FROM employee_sales.employee
;


-- INSERT ... SELECT ...

-- first, create the "birthdays" table
CREATE VOLATILE TABLE vt_birthdays
(
   empno  INTEGER   NOT NULL
  ,lname  CHAR(20)  NOT NULL
  ,fname  VARCHAR(30)
  ,birth  DATE FORMAT'yyyy-mm-dd'
)
UNIQUE PRIMARY INDEX (empno)
ON COMMIT PRESERVE ROWS;

-- populate the "birthdays"' table from employee:
INSERT INTO vt_birthdays
SELECT
   employee_number
  ,last_name
  ,first_name
  ,birthdate
FROM employee_sales.employee
WHERE department_number = 403
;

SELECT *
FROM vt_birthdays
;
DROP TABLE vt_birthdays
;

/********************
 * CASESPECIFIC and SET Tables
 ********************/

-- better use volatile tables when playing around 
------------------------------
-- SET & NOT CASESPECIFIC
CREATE VOLATILE SET TABLE vt_t1
 (
   c1 INTEGER
  ,c2 VARCHAR(20) NOT CaseSpecific
 )
PRIMARY INDEX (c2)
ON COMMIT PRESERVE ROWS
;
INSERT INTO vt_t1 VALUES(1,'ABC');  -- Insert Statement completed. 1 rows processed.
INSERT INTO vt_t1 VALUES(2,'ABC');  -- Insert Statement completed. 1 rows processed.
INSERT INTO vt_t1 VALUES(2,'abc');  -- Insert Statement failed.  Failed [2802 : 23000] Duplicate row error in trainee_1.vt_t1.

SELECT *
FROM vt_t1
; 
--    1 ABC
--    2 ABC

-- trying to duplicate the content
INSERT INTO vt_t1
SELECT *
FROM vt_t1
; 
-- Insert Statement completed. 0 rows processed. 
-- duplicate rows silently discarded !!!

SELECT *
FROM vt_t1
WHERE c2 = 'abc'
;
--    1 ABC
--    2 ABC

------------------------------
-- SET & CASESPECIFIC
CREATE VOLATILE SET TABLE vt_t2
(
   c1 INTEGER
  ,c2 VARCHAR(20) CaseSpecific
)
PRIMARY INDEX (c2)
ON COMMIT PRESERVE ROWS
;
INSERT INTO vt_t2 VALUES(1,'ABC');  -- Insert Statement completed. 1 rows processed.
INSERT INTO vt_t2 VALUES(2,'ABC');  -- Insert Statement completed. 1 rows processed.
INSERT INTO vt_t2 VALUES(2,'abc');  -- Insert Statement completed. 1 rows processed.
 
SELECT *
FROM vt_t2
;
--    1 ABC
--    2 ABC
--    2 abc

-- trying to duplicate the content
INSERT INTO vt_t2
SELECT *
FROM vt_t2
;
-- Insert Statement completed. 0 rows processed. 
-- duplicate rows silently discarded !!!

SELECT
  *
FROM vt_t2
WHERE c2 = 'abc'
;
--    2 abc


------------------------------
-- MULTISET & NOT CASESPECIFIC
CREATE VOLATILE MULTISET TABLE vt_t3
(
   c1 INTEGER
  ,c2 VARCHAR(20) NOT CaseSpecific
)
PRIMARY INDEX (c2)
ON COMMIT PRESERVE ROWS
;
INSERT INTO vt_t3 VALUES(1,'ABC');  -- Insert Statement completed. 1 rows processed.
INSERT INTO vt_t3 VALUES(2,'ABC');  -- Insert Statement completed. 1 rows processed.
INSERT INTO vt_t3 VALUES(2,'abc');  -- Insert Statement completed. 1 rows processed.

SELECT *
FROM vt_t3
;
--    1 ABC
--    2 ABC
--    2 abc

-- trying to duplicate the content
INSERT INTO vt_t3
SELECT
  *
FROM vt_t3
;
-- Insert Statement completed. 3 rows processed. 

SELECT *
FROM vt_t3
WHERE c2 = 'abc'
;
--    1 ABC
--    2 ABC
--    2 abc
--    1 ABC
--    2 ABC
--    2 abc


------------------------------
-- MULTISET & CASESPECIFIC
CREATE VOLATILE MULTISET TABLE vt_t4
(
   c1 INTEGER
  ,c2 VARCHAR(20) CaseSpecific
)
PRIMARY INDEX (c2)
ON COMMIT PRESERVE ROWS
;

INSERT INTO vt_t4 VALUES(1,'ABC');  -- Insert Statement completed. 1 rows processed.
INSERT INTO vt_t4 VALUES(2,'ABC');  -- Insert Statement completed. 1 rows processed.
INSERT INTO vt_t4 VALUES(2,'abc');  -- Insert Statement completed. 1 rows processed.

SELECT * 
FROM vt_t4
;
--    1 ABC
--    2 ABC
--    2 abc

-- trying to duplicate the data
INSERT INTO vt_t4 
SELECT *
FROM vt_t4
;
-- Insert Statement completed. 3 rows processed. 

SELECT
  *
FROM vt_t4
WHERE c2 = 'abc'
;
--    2 abc
--    2 abc


/********************
 * UPDATE
 ********************/

-- updates

SELECT
   employee_number          AS emp#
  ,last_name                AS lnm
  ,first_name               AS fnm
  ,manager_employee_number  AS mngr#
  ,department_number        AS dept#
  ,job_code
FROM  employee
WHERE employee_number = 1004
;
-- emp# lnm      fnm     mngr# dept# job_code 
-- ---- -------- ------- ----- ----- -------- 
-- 1004 Johnson  Darlene  1003   401   412101

UPDATE employee 
  SET department_number = 403
     ,job_code = 432101
     ,manager_employee_number = 1005
WHERE employee_number = 1004
;

SELECT
   employee_number          AS emp#
  ,last_name                AS lnm
  ,first_name               AS fnm
  ,manager_employee_number  AS mngr#
  ,department_number        AS dept#
  ,job_code
FROM  employee
WHERE employee_number = 1004
;
-- emp# lnm      fnm     mngr# dept# job_code 
-- ---- -------- ------- ----- ----- -------- 
-- 1004 Johnson  Darlene  1005   403   432101



/********************
 * UPDATE Based on Other Tables
 ********************/

-- update using subquery
UPDATE employee
  SET salary_amount = salary_amount * 1.10
WHERE department_number IN
 ( SELECT department_number
   FROM  department
   WHERE department_name LIKE '%support%'
 )
;

--using a correlated subquery
UPDATE employee AS e
  SET salary_amount = salary_amount * 1.10
WHERE EXISTS
 ( SELECT *
   FROM   department AS d
   WHERE  e.department_number = d.department_number
     AND  d.department_name LIKE '%support%'
 )
;

-- using an implicit inner join
-- no explicit JOIN allowed
UPDATE e
FROM employee AS e, department AS d
  SET salary_amount = salary_amount * 1.10
WHERE e.department_number = d.department_number
  AND department_name LIKE '%support%'
;



/********************
 * UPDATE Based on Derived Tables
 ********************/

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


/********************
 * DELETE
 ********************/

-- no employees working in department anymore
DELETE  
FROM  employee
WHERE  department_number = 301
;

-- syntax variations to delete all rows
DELETE 
FROM employee 
ALL
;
DELETE 
FROM employee
;
-- Teradata extension: FROM keyword is optional 
DELETE employee 
;
-- Teradata extension: DELETE can be abbreviated to DEL
DEL employee
;

/********************
 * DELETE Based on Other Tables
 ********************/

-- using a subquery
DELETE 
FROM  employee
WHERE department_number IN
 (
   SELECT department_number
   FROM   department
   WHERE  department_name  = 'temp'
 )
;
    
-- using a join
DELETE 
FROM employee AS e
WHERE e.department_number = department.department_number
  AND department.department_name = 'Temp'
;


-- using a correlated subquery
DELETE 
FROM  employee AS e
WHERE EXISTS
 (
   SELECT *
   FROM department AS d
   WHERE e.department_number = d.department_number
     AND d.department_name = 'Temp'
 )
;





-- Default database for labs

--DATABASE finance_payroll;
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


/********************
 * Data Manipulation Lab 1
 ********************/

HELP TABLE finance_payroll.fin_trans;

/********************
 * Data Manipulation Lab 1 solution
 ********************/

SET QUERY_BAND = 'lab=no;' UPDATE FOR SESSION VOLATILE
;

-- just in case table already exists from a previous run
--DROP TABLE fin_trans_copy;

CREATE MULTISET TABLE fin_trans_copy AS finance_payroll.fin_trans WITH NO DATA
;

SET QUERY_BAND = 'lab=DML;step=ins_empty;index=no;' UPDATE FOR SESSION VOLATILE
;
INSERT INTO fin_trans_copy
SELECT * FROM finance_payroll.fin_trans
;

SET QUERY_BAND = 'lab=DML;step=update;index=no;' UPDATE FOR SESSION VOLATILE
;
UPDATE tgt
FROM finance_payroll.trans_staging_1  AS src, fin_trans_copy  AS tgt

SET amount = src.amount
,balance = tgt.balance + src.amount

WHERE tgt.account_id = src.account_id
  AND tgt.trans_date = src.trans_date
  AND tgt.trans_id = src.trans_id
;

SET QUERY_BAND = 'lab=DML;step=insert;index=no;' UPDATE FOR SESSION VOLATILE
;
INSERT INTO fin_trans_copy 
SELECT * FROM  finance_payroll.trans_staging_1 AS src
WHERE NOT EXISTS
 (
   SELECT 1 
   FROM fin_trans_copy AS tgt
   WHERE tgt.account_id = src.account_id
     AND tgt.trans_date = src.trans_date
     AND tgt.trans_id = src.trans_id
 );

SET QUERY_BAND = 'lab=DML;step=merge;index=no;' UPDATE FOR SESSION VOLATILE
;

-- using a macro to run both UPDATE & INSERT as a single transaction;
REPLACE MACRO trans_merge AS
 (
   UPDATE tgt
   FROM finance_payroll.trans_staging_2  AS src, fin_trans_copy  AS tgt
   
   SET amount = src.amount
   ,balance = tgt.balance + src.amount
   
   WHERE tgt.account_id = src.account_id
     AND tgt.trans_date = src.trans_date
     AND tgt.trans_id = src.trans_id 
   ;
   
   INSERT INTO fin_trans_copy 
   SELECT * FROM  finance_payroll.trans_staging_2 AS src
   WHERE NOT EXISTS
    ( SELECT 1 
      FROM fin_trans_copy AS tgt
      WHERE tgt.account_id = src.account_id
        AND tgt.trans_date = src.trans_date
        AND tgt.trans_id = src.trans_id
    )
   ;
 )
;

EXEC trans_merge
;
 
SET QUERY_BAND = 'lab=DML;step=delete;index=no;' UPDATE FOR SESSION VOLATILE
;
DELETE FROM fin_trans_copy AS tgt
WHERE  EXISTS
 ( SELECT 1 
   FROM finance_payroll.trans_staging_2 AS src
   WHERE tgt.account_id = src.account_id
     AND tgt.trans_date = src.trans_date
     AND tgt.trans_id = src.trans_id
 )
;
 
 
SET QUERY_BAND = 'lab=no;' UPDATE FOR SESSION VOLATILE
;

DROP TABLE fin_trans_copy;
CREATE MULTISET TABLE fin_trans_copy AS finance_payroll.fin_trans WITH NO DATA;
CREATE UNIQUE INDEX usi_trans_date (trans_id, balance) ON fin_trans_copy;

SET QUERY_BAND = 'lab=DML;step=ins_empty;index=USI;' UPDATE FOR SESSION VOLATILE
;
INSERT INTO fin_trans_copy
SELECT * FROM finance_payroll.fin_trans
;

SET QUERY_BAND = 'lab=DML;step=update;index=USI;' UPDATE FOR SESSION VOLATILE
;
UPDATE tgt
FROM finance_payroll.trans_staging_1  AS src, fin_trans_copy  AS tgt

SET amount = src.amount
,balance = tgt.balance + src.amount

WHERE tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id
;

SET QUERY_BAND = 'lab=DML;step=insert;index=USI;' UPDATE FOR SESSION VOLATILE
;
INSERT INTO fin_trans_copy 
SELECT * FROM  finance_payroll.trans_staging_1 AS src
WHERE NOT EXISTS
 ( SELECT 1 
   FROM fin_trans_copy AS tgt
   WHERE tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id
 )
;

SET QUERY_BAND = 'lab=DML;step=merge;index=USI;' UPDATE FOR SESSION VOLATILE
;
EXEC trans_merge
;
 
SET QUERY_BAND = 'lab=DML;step=delete;index=USI;' UPDATE FOR SESSION VOLATILE
;
DELETE FROM fin_trans_copy AS tgt
WHERE  EXISTS
 ( SELECT 1 
   FROM finance_payroll.trans_staging_2 AS src
   WHERE tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id
 )
;
 
  
SET QUERY_BAND = 'lab=no;' UPDATE FOR SESSION VOLATILE
;
DROP TABLE fin_trans_copy;
CREATE MULTISET TABLE fin_trans_copy AS finance_payroll.fin_trans WITH NO DATA;
CREATE  INDEX nusi_trans_date (trans_date, balance) ON fin_trans_copy;
--create  index nusi_trans_date (amount) on fin_trans_copy;

SET QUERY_BAND = 'lab=DML;step=ins_empty;index=NUSI;' UPDATE FOR SESSION VOLATILE
;
INSERT INTO fin_trans_copy 
SELECT * FROM finance_payroll.fin_trans
;

SET QUERY_BAND = 'lab=DML;step=update;index=NUSI;' UPDATE FOR SESSION VOLATILE
;
UPDATE tgt
FROM finance_payroll.trans_staging_1  AS src, fin_trans_copy AS tgt

SET amount = src.amount
,balance = tgt.balance + src.amount

WHERE tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id
;

SET QUERY_BAND = 'lab=DML;step=insert;index=NUSI;' UPDATE FOR SESSION VOLATILE
;
INSERT INTO fin_trans_copy 
SELECT * FROM  finance_payroll.trans_staging_1 AS src
WHERE NOT EXISTS
 ( SELECT 1 
   FROM fin_trans_copy AS tgt
   WHERE tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id
 )
;

SET QUERY_BAND = 'lab=DML;step=merge;index=NUSI;' UPDATE FOR SESSION VOLATILE
;
EXEC trans_merge
;

 
SET QUERY_BAND = 'lab=DML;step=delete;index=NUSI;' UPDATE FOR SESSION VOLATILE
;
DELETE FROM fin_trans_copy AS tgt
WHERE  EXISTS
 ( SELECT 1 
   FROM finance_payroll.trans_staging_2 AS src
   WHERE tgt.account_id = src.account_id
AND tgt.trans_date = src.trans_date
AND tgt.trans_id = src.trans_id
 )
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
  AND GetQuerybandValue(queryband, 0, 'lab') = 'DML'
  AND QueryBand IS NOT NULL
  AND (InsCnt IS NOT NULL OR updcnt IS NOT NULL OR delcnt IS NOT NULL)
  AND StartTime >= Current_Timestamp - INTERVAL '15' MINUTE
ORDER BY StartTime
; 

/********* 24-AMP system with Block Level Compression (BLC)

RunTime IO_logical IO_physical  CPU     SpoolUsage   InsCnt     UpdCnt   DelCnt   step       idx 
------- ---------- -----------  ------  -----------  ---------  -------  -------  ---------  ----
   0.33      4,304       1,228    4.76   50,561,024  1,056,320        0        0  ins_empty  no  
   1.37     10,123       3,415    6.26   50,561,024  1,056,320        0        0  ins_empty  USI 
   0.94     11,465       3,246    7.24   50,561,024  1,056,320        0        0  ins_empty  NUSI
                                                                                                 
   0.31      3,663         375    4.91   11,812,864          0  305,946        0  update     no  
   1.31     18,309       4,237   12.93   14,954,496          0  305,946        0  update     USI 
   1.46     14,397       2,497   15.79   11,812,864          0  305,946        0  update     NUSI
                                                                                                 
   1.37    129,116       2,824   21.01  100,696,064    307,550        0        0  insert     no  
   2.03    134,468       4,174   23.86  100,696,064    307,550        0        0  insert     USI 
   1.91    136,362       4,723   25.96  100,696,064    307,550        0        0  insert     NUSI
                                                                                                 
   1.65    103,079       3,406   23.02  105,365,504    233,247  209,577        0  merge      no  
   2.55    124,833       8,543   33.59  105,365,504    233,247  209,577        0  merge      USI 
   2.48    126,090       6,439   31.65  105,365,504    233,247  209,577        0  merge      NUSI
                                                                                                 
   0.48     10,165       2,133    6.71   13,496,320          0        0  442,824  delete     no  
   0.65     16,023       2,810    9.71   13,496,320          0        0  442,824  delete     USI 
   1.49     19,213       3,588   20.77   13,496,320          0        0  442,824  delete     NUSI
   
*********/

/********* Same 24-AMP system but BLC switched off
 ********* SET QUERY_BAND = 'BLOCKCOMPRESSION=no;' UPDATE FOR SESSION VOLATILE;

RunTime IO_logical IO_physical  CPU     SpoolUsage   InsCnt     UpdCnt   DelCnt   step       idx 
------- ---------- -----------  ------  -----------  ---------  -------  -------  ---------  ----
   0.40      4,383       1,257    2.78   50,561,024  1,056,320        0        0  ins_empty  no  
   1.30      8,681       2,900    3.93   50,561,024  1,056,320        0        0  ins_empty  USI 
   0.81     10,582       2,995    3.99   50,561,024  1,056,320        0        0  ins_empty  NUSI
                                                                                                 
   0.24      3,657         375    2.70   11,812,864          0  305,946        0  update     no  
   1.04     18,666       4,314    7.71   16,957,440          0  305,946        0  update     USI 
   1.13     14,477       2,339   14.22   11,812,864          0  305,946        0  update     NUSI
                                                                                                 
   1.79    167,253       2,873   18.50  100,696,064    307,550        0        0  insert     no  
   2.11    171,519       4,355   20.17  100,696,064    307,550        0        0  insert     USI 
   2.22    189,635       4,870   23.13  100,696,064    307,550        0        0  insert     NUSI
                                                                                                 
   1.74    103,268       3,580   16.14  105,365,504    233,247  209,577        0  merge      no  
   2.27    125,694       8,825   23.20  105,365,504    233,247  209,577        0  merge      USI 
   2.76    127,552       7,797   26.05  105,365,504    233,247  209,577        0  merge      NUSI
                                                                                                 
   0.32      9,926       1,805    3.52   13,496,320          0        0  442,824  delete     no  
   0.70     15,852       2,953    5.88   13,496,320          0        0  442,824  delete     USI 
   1.35     19,010       3,610   17.63   13,496,320          0        0  442,824  delete     NUSI
   
*********/