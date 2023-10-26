/********************
 * Module CREATE TABLE AS
 ********************/

--DATABASE employee_sales;


/********************
 * CREATE TABLE AS "existing table"
 ********************/

DATABASE trainee_1;

CREATE TABLE employee
AS employee_sales.employee
WITH NO DATA
;

SHOW TABLE employee
;

DROP TABLE employee
;


/********************
 * CREATE TABLE AS − Cloning Attributes
 ********************/

CREATE MULTISET TABLE dept1
AS employee_sales.department 
WITH NO DATA
;
SHOW TABLE dept1
;
DROP TABLE dept1
;

CREATE TABLE dept1 
AS employee_sales.department 
WITH NO DATA
UNIQUE INDEX (department_name)
;
SHOW TABLE dept1
;
DROP TABLE dept1
;

CREATE TABLE dept1 
AS employee_sales.department 
WITH NO DATA
UNIQUE PRIMARY INDEX (Department_Number)
UNIQUE INDEX (department_name)
;
SHOW TABLE dept1
;
DROP TABLE dept1
;


/********************
 * CREATE TABLE AS SELECT
 ********************/

CREATE TABLE employee AS
 (
   SELECT * 
   FROM employee_sales.employee
 )
WITH DATA
;

SHOW TABLE employee
;

DROP TABLE employee
;


/********************
 * Renaming Columns
 ********************/

-- technique 1
CREATE TABLE trainee_1.emp1 AS 
 (
   SELECT
      employee_number AS emp#           -- Optional
     ,department_number 
     ,salary_amount / 12 AS monthly_sal -- Required 
   FROM employee
 ) 
WITH NO DATA;

SHOW TABLE emp1
;
DROP TABLE emp1
;

-- technique 2
CREATE TABLE emp1
 (
   emp#                      --  Required
  ,department_number         --  Required
  ,monthly_sal               --  Required
 )
AS 
 (
   SELECT
      employee_number AS nnn --  ignored
     ,department_number
     ,salary_amount / 12
   FROM employee_sales.employee
 ) 
WITH NO DATA;

SHOW TABLE emp1
;
DROP TABLE emp1
;



/********************
 * Changing Column Attributes
 ********************/

CREATE TABLE dept1 
AS 
 (
   SELECT 
     department_number              AS dept 
    ,CAST(budget_amount AS INTEGER) AS budget 
   FROM employee_sales.department
 ) 
WITH DATA
;
SHOW TABLE dept1
;
DROP TABLE dept1
;

CREATE TABLE dept1 
 (
   dept DEFAULT 0 UNIQUE NOT NULL
  ,budget CHECK (budget > 0)
 )   
AS  
 (
   SELECT
      department_number
     ,CAST(budget_amount AS INTEGER) 
   FROM employee_sales.department
 ) 
WITH DATA
;
SHOW TABLE dept1
;
DROP TABLE dept1
;

/********************
 * Adding Unique and Primary Key Constraints
 ********************/

CREATE TABLE dept1 
 (
   deptno   UNIQUE      NOT NULL 
  ,deptname PRIMARY KEY NOT NULL 
  ,budget  
  ,manager
 )  
AS employee_sales.department 
WITH DATA
;
SHOW TABLE dept1
;

-- index info
HELP INDEX dept1
;

SELECT 
   IndexNumber
  ,IndexType
  ,UniqueFlag
  ,IndexName
  ,ColumnName
  ,ColumnPosition
FROM dbc.IndicesV
WHERE DatabaseName = DATABASE
  AND TableName = 'dept1'
ORDER BY IndexNumber, ColumnPosition
;

DROP TABLE dept1
;

/********************
 * Copying Statistics
 ********************/

-- data & stats
CREATE TABLE dept1 
AS employee_sales.department 
WITH DATA
AND STATISTICS
;

HELP STATS dept1
;

DROP TABLE dept1
;

-- no data & zeroed stats
CREATE TABLE dept1 
AS employee_sales.department 
WITH NO DATA
AND STATISTICS
;

HELP STATS dept1
;

-- copy stats
COLLECT STATS ON dept1 
FROM employee_sales.department 
;

HELP STATS dept1
;
