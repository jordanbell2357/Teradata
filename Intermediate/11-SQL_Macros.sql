/********************
 * Module Macros
 ********************/

--DATABASE employee_sales;

DATABASE trainee_nn;

-- prepare some tables

--DROP TABLE department;
CREATE TABLE department AS employee_sales.department WITH DATA
;
--DROP TABLE employee;
CREATE TABLE employee AS employee_sales.employee WITH DATA
;
--DROP TABLE job;
CREATE TABLE job AS employee_sales.job WITH DATA
;


/********************
 * CREATE and EXECUTE Macro
 ********************/

CREATE MACRO emp_401
AS   
(
  SELECT 
     employee_number
    ,last_name
    ,salary_amount
  FROM employee
  WHERE department_number = 401
  ;
)
;

EXEC emp_401
;

/********************
 * Modifying a Macro with REPLACE
 ********************/

REPLACE MACRO emp_401
AS   
(
  SELECT 
     department_number AS dept#
    ,employee_number   AS emp#
    ,last_name
    ,salary_amount
  FROM employee
  WHERE department_number IN (401, 403, 403)
  ;
)
;

EXEC emp_401
;

-- cleanup
DROP MACRO emp_401
;


/********************
 * Macros vs. Multi-Statement Requests
 ********************/

CREATE MACRO dept_job
AS 
(
  SELECT 
    department_name
  FROM department
  WHERE department_number = 401
  ;
  SELECT 
    description
  FROM job
  WHERE job_code = 412101
  ;
)
;

EXEC dept_job
;

-- This would be a MSR in a BTEQ script:
-- BTEQ submits a request when no new statement starts on the same line after the final semicolon
-- In Teradata Studio "Execute All" must be used 
EXPLAIN
SELECT 
   department_name
FROM department
WHERE department_number = 401
;SELECT 
   description
FROM job
WHERE job_code = 412101
;

EXPLAIN
EXEC dept_job
;

-- cleanup
DROP MACRO dept_job
;


/********************
 * Parameterized Macros
 ********************/

CREATE MACRO get_sal   
(emp#  INTEGER)
AS  
(
  SELECT 
     employee_number
    ,last_name
    ,salary_amount
  FROM employee
  WHERE employee_number = :emp#
  ;
)
;

EXEC get_sal(1018)
;

EXEC get_sal(1008)
;

-- cleanup
DROP MACRO get_sal
;


/********************
 * Parameterized Macros - Multiple Parameter
 ********************/


REPLACE MACRO new_dept
(
   in_dept   INTEGER
  ,in_budget DECIMAL(10,2) DEFAULT 0
  ,in_name   CHAR(30)
  ,in_mgr    INTEGER
)
AS
( -- check input parameters 
  ROLLBACK 'in_name can''t be NULL' 
  WHERE :in_name IS NULL
  ;
  ROLLBACK 'in_mgr doesn''t exist'
  WHERE :in_mgr IS NOT NULL
    AND NOT EXISTS
   ( SELECT 1 
     FROM employee AS e
     WHERE e.employee_number = :in_mgr
   )
  ;
  -- inserting a new row
  INSERT INTO department
  ( department_number
   ,department_name
   ,budget_amount
   ,manager_employee_number
  )
  VALUES
  ( :in_dept
   ,:in_name
   ,:in_budget
   ,:in_mgr 
  )
  ;
  SELECT -- echoing what was inserted
     department_number       AS dept#
    ,department_name         AS name
    ,budget_amount           AS budget
    ,manager_employee_number AS mngr#
  FROM department
  WHERE department_number = :in_dept
  ;
)
;

EXEC new_dept  
 ( 505
  ,610000.00
  ,'Marketing Research'
  ,1007
 )
;

EXEC new_dept(102,,'Payroll',NULL)
;
EXEC new_dept  
 ( in_name  = 'accounting'
  ,in_budget = 425000.00
  ,in_dept   = 106 
 )
;
EXEC new_dept(,,'new dept',801)
;
EXEC new_dept(230,,'new dept',999)
;

-- cleanup
DROP MACRO new_dept
;

/********************
 * Macros and DDL
 ********************/

CREATE MACRO vt_emp_copy
AS
(
  CREATE VOLATILE TABLE vt_employee 
   (
     employee_number INTEGER
    ,manager_employee_number INTEGER
    ,department_number INTEGER
    ,job_code INTEGER
    ,last_name CHAR(20)
    ,first_name VARCHAR(30)
    ,hire_date DATE FORMAT'yyyy-mm-dd'
    ,birthdate DATE FORMAT'yyyy-mm-dd'
    ,salary_amount DECIMAL(10,2) NOT NULL
   )
  UNIQUE PRIMARY INDEX ( employee_number )
  ON COMMIT PRESERVE ROWS
  ;
)
;   
-- submit whenever you need a copy
EXEC vt_emp_copy
;
-- verify what has been created
SHOW TABLE vt_employee
;



-- cleanup
DROP TABLE department
;
DROP TABLE employee
;
DROP TABLE job
;




-- Default database for labs
DATABASE finance_payroll;

/********************
 * Macros Lab 1
 ********************/

HELP TABLE hr_salary_hist;


/********************
 * Macros Lab 2
 ********************/

HELP TABLE hr_salary_hist;


/********************
 * Macros Lab 1 Solution
 ********************/
  
-- macros must be created in trainee-user

DATABASE trainee_nn;

REPLACE MACRO max_pay_macro 
 (
   sal_yr INT
  ,over_hrs INT DEFAULT 100
 )
AS
 (
   SELECT
      employee_number
     ,first_name
     ,last_name
     ,department_number AS dept#
     ,job_code
     ,total_pay
     ,overtime_pay
     ,overtime_hours
   FROM finance_payroll.hr_salary_hist
   WHERE sal_year = :sal_yr
     AND overtime_hours > :over_hrs
   QUALIFY
      overtime_pay 
        = Max(overtime_pay) 
          OVER (PARTITION BY dept#)
   ORDER BY overtime_pay DESC
   ;
 );
 
EXEC max_pay_macro( sal_yr = 2017 , over_hrs = 200);


/********************
 * Macros Lab 2 Solution
 ********************/
  
REPLACE MACRO max_pay_macro 
 (
   sal_yr INT
  ,over_hrs INT DEFAULT 100
 )
AS
 (

 -- check the correct range of values for parameters 
   ABORT 'sal_yr must be between 2008 and 2017' 
   WHERE :sal_yr NOT BETWEEN 2008 AND 2017;

   ABORT 'over_hrs must be at least 100' 
   WHERE NOT :over_hrs >= 100;
 
   SELECT
      employee_number
     ,first_name
     ,last_name
     ,department_number AS dept#
     ,job_code
     ,total_pay
     ,overtime_pay
     ,overtime_hours
   FROM finance_payroll.hr_salary_hist
   WHERE sal_year = :sal_yr
     AND overtime_hours > :over_hrs
   QUALIFY
      overtime_pay 
        = Max(overtime_pay) 
          OVER (PARTITION BY dept#)
   ORDER BY overtime_pay DESC
   ;
 );
 

EXEC max_pay_macro( sal_yr = 2020 , over_hrs = 500);
EXEC max_pay_macro( sal_yr = 2016 , over_hrs = 20);
 
