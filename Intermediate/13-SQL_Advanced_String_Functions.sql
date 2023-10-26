/********************
 * Module Advanced String Functions
 ********************/

DATABASE employee_sales;


/********************
 * Creating Comma-Separated Values
 ********************/

SELECT
             employee_number
   || ',' || manager_employee_number
   || ',' || last_name
   || ',' || first_name
   || ',' || hire_date
   || ',' || salary_amount
FROM employee
WHERE department_number = 403
ORDER BY employee_number
;


-- NULLs propagate --> COALESCE on Nullable column 
-- Implicit type cast for numeric columns: right aligned with leading spaces --> TRIM
-- Trailing spaces in CHARs --> TRIM
SELECT 
             Trim(employee_number)
   || ',' || Coalesce(Trim(manager_employee_number), '')
   || ',' || Trim(last_name)
   || ',' || Trim(first_name)
   || ',' || hire_date
   || ',' || Coalesce(Trim(salary_amount), '')
FROM employee_sales.employee
WHERE department_number = 403
ORDER BY employee_number
;     
     
-- optionally: quoted strings
SELECT
             Trim(employee_number)
   || ',' || Coalesce(Trim(manager_employee_number), '')
   || ',' || '''' || Trim(last_name) || ''''
   || ',' || '''' || Trim(first_name) || ''''
   || ',' || hire_date
   || ',' || Coalesce(Trim(salary_amount), '')
FROM employee_sales.employee
WHERE department_number = 403
ORDER BY employee_number
;     
     
/********************
 * CSV Table Function
 ********************/

WITH cte AS 
 (  -- base select here
   SELECT * 
   FROM employee_sales.employee AS  e
   WHERE department_number = 403
 )
SELECT * 
FROM TABLE
 ( CSV
    ( NEW VARIANT_TYPE
       ( -- you need to list each column of your table
         cte.employee_number
        ,cte.manager_employee_number
        ,trim(cte.last_name) AS last_name
        ,cte.first_name
        ,cte.hire_date
        ,cte.salary_amount
       )
     , ','    -- delimiter character
     , '''')  -- quote character
   RETURNS (op VARCHAR(32000) CHARACTER SET UNICODE)
 ) AS dt
 ORDER BY Cast(StrTok(op, ',', 1) AS INT)
 ;

 /********************
 * Pack Table Operator (16.20 FU2)
 ********************/

 -- Syntax
/* 
  SELECT * FROM Pack (
  ON { table | view | (query) }
  USING
  [ TargetColumns ({ 'target_column' | target_column_range }[,...]) ]
  [ Delimiter ('delimiter') ]
  [ IncludeColumnName ({'true'|'t'|'yes'|'y'|'1'|'false'|'f'|'no'|'n'|'0'}) ]
  OutputColumn ('output_column')
  [ Accumulate ({ 'accumulate_column' | accumulate_column_range }[,...]) ]
  [ ColCast ({'true'|'t'|'yes'|'y'|'1'|'false'|'f'|'no'|'n'|'0'}) ]
) AS alias;
*/
WITH cte AS 
 (  -- base select here
   SELECT 
       employee_number
      ,manager_employee_number
      ,'''' || Trim(last_name) || '''' AS last_name
      ,'''' || first_name || '''' AS first_name
      ,birthdate
      ,salary_amount
 
   FROM employee_sales.employee
 )
SELECT * FROM Pack (
  ON cte
  USING
  Delimiter (',')
  OutputColumn ('packed_data')
  IncludeColumnName('no')
) AS dt;  
 
 
 
 /********************
 * CSVLD Table Function
 ********************/

-- create some example data
CREATE VOLATILE TABLE vt_csv AS
 (
   SELECT
                Trim(employee_number)
      || ',' || Coalesce(Trim(manager_employee_number), '')
      || ',' || '''' || Trim(last_name) || ''''
      || ',' || '''' || Trim(first_name) || ''''
      || ',' || hire_date
      || ',' || Coalesce(Trim(salary_amount), '') AS col
   FROM employee_sales.employee
   WHERE department_number = 403
 )
WITH DATA
NO PRIMARY INDEX
ON COMMIT PRESERVE ROWS
;     

SHOW TABLE vt_csv
;

WITH cte AS 
 (  -- base select here
   SELECT col
   FROM vt_csv
 )
SELECT * 
FROM TABLE
 ( CSVLD
    (cte.col
    ,','
    ,''''
    )
   RETURNS
    (
      emp# VarChar(11)
     ,mgr# VarChar(11)
     ,last_name VarChar(30)
     ,first_name VarChar(30)
     ,birthdate VarChar(10)
     ,salary VarChar(12)
    )
 ) AS t
;

-- adding type casts
WITH cte AS 
 (  -- base select here
   SELECT col
   FROM vt_csv
 )
SELECT  
      Cast(emp# AS INTEGER)
     ,Cast(mgr# AS INTEGER)
     ,last_name
     ,first_name
     ,Cast(birthdate AS DATE)
     ,Cast(salary AS DEC(10,2))
FROM TABLE
 ( CSVLD
    (cte.col
    ,','
    ,''''
    )
   RETURNS
    (
      emp# VarChar(11)
     ,mgr# VarChar(11)
     ,last_name VarChar(30)
     ,first_name VarChar(30)
     ,birthdate VarChar(10)
     ,salary VarChar(12)
    )
 ) AS t
;

-- cleanup
DROP TABLE vt_csv
;

/********************
 * STRTOK
 ********************/

-- create some example data 
CREATE VOLATILE TABLE vt_emails 
 (
   email_id int
  ,email VarChar(128)
 )
NO PRIMARY INDEX
ON COMMIT PRESERVE ROWS
;     
 
INSERT INTO vt_emails(1,'jane@myemail.com');
INSERT INTO vt_emails(2,'johndoe@domain.com');
INSERT INTO vt_emails(3,'jane.doe@subdomain.corp.com');
INSERT INTO vt_emails(4,'john.o.doe@gmail.com');
INSERT INTO vt_emails(5,'jdoe@mycomp.com');

SELECT
   email
  ,StrTok(email, '@', 1) AS email_user
  ,StrTok(email, '@', 2) AS email_domain
FROM vt_emails
;

SELECT  
   StrTok('one,,three,four', ',', 2)          --   three
  ,StrTok('one,,three,four', ',', 3)          --   four 
  ,StrTok('one,,three,four', ',', 4)          --   NULL 
  ,StrTok('this!! is--#3????', ' ,.-:;!?', 3) --   #3   
;



 /********************
 * STRTOK_SPLIT_TO_TABLE Table Function
 ********************/

WITH cte AS
 (
   SELECT email_id, email
   FROM vt_emails
 )
SELECT token
FROM TABLE
 (
   StrTok_Split_To_Table(cte.email_id -- key
                        ,cte.email    -- data
                        ,'.@')        -- delimiters
   RETURNS (email_id INTEGER
           ,ord INTEGER
           ,token VARCHAR(128)
           ) 
 ) AS t
ORDER BY email_id, ord
;


 /********************
 * STRTOK_SPLIT_TO_TABLE Table Function (cont.)
 ********************/
-- fails: 3706 Syntax error: Joined table is not supported in conjuction with table operators or table function invoked with variable input argument.
WITH cte AS
 (
   SELECT email_id, email
   FROM vt_emails
 )
SELECT 
   e.email_id
  ,e.email
  ,split.ord
  ,split.token
FROM TABLE
 (
   StrTok_Split_To_Table(cte.email_id -- key
                        ,cte.email    -- data
                        ,'.@')        -- delimiters
   RETURNS (email_id INTEGER
           ,ord INTEGER
           ,token VARCHAR(128)
           ) 
 ) AS split
JOIN vt_emails AS e
ON e.email_id = split.email_id
ORDER BY split.email_id, split.ord
;

WITH cte AS
 (
   SELECT email_id, email
   FROM vt_emails
 )
,split AS
 (
   SELECT *
   FROM TABLE
    (
      StrTok_Split_To_Table(cte.email_id -- key
                           ,cte.email    -- data
                           ,'.@')        -- delimiters
      RETURNS (email_id INTEGER
              ,ord INTEGER
              ,token VARCHAR(128)
              ) 
    ) AS t
 )
SELECT
   e.email_id
  ,e.email
  ,split.ord
  ,split.token
FROM split
JOIN vt_emails AS e
ON e.email_id = split.email_id
ORDER BY split.email_id, split.ord
;


-- cleanup
DROP TABLE vt_emails
;


 /********************
 * NVP
 ********************/

SELECT
   'ApplicationName=STUDIO;Version=17.20.0.202209150411;ClientUser=trainee_1;Source=MetadataQuery;Version=007' AS QB
  ,NVP(QB, 'Version', ';', '=')
  ,NVP(QB, 'Version', ';', '=', 2)
  ,NVP(QB, 'Version', ';', '=', 3)
;

SELECT
   'name1==STUDIO#;#Version==17.20.0.202209150411#;#ClientUser==trainee_1#;#Source==MetadataQuery' AS QB
  ,NVP(QB, 'Version', '#;#', '==', 1)
;


-- Default database for labs
--DATABASE finance_payroll;

DATABASE trainee_n;

/********************
 * Advanced String Functions Lab 1
 ********************/

HELP TABLE hr_payroll;
HELP TABLE hr_departments;
HELP TABLE hr_jobs;


/********************
 * Advanced String Functions Lab 1 Solution
 ********************/

-- include missing and invalid ids in the result
REPLACE MACRO employee_info(emp_list VARCHAR(1000)) AS
 (
   WITH split AS
    (
      SELECT TryCast(token AS INTEGER) AS emp#, tokennum, token
      FROM TABLE (STRTOK_SPLIT_TO_TABLE(1, :emp_list, ',')
           RETURNS (outkey INTEGER,  -- usually the PK of the table, here it's just a dummy
                    tokennum INTEGER, -- order of the token within the param string
                    token VARCHAR(128) CHARACTER SET UNICODE)
                 ) AS t 
    )
   SELECT 
      split.token AS emp# -- use token instead of emp#
     ,Coalesce(e.Last_Name, 'n/a') AS last_name
     ,e.First_Name
     ,j.Job_Title, d.Department_Name
   FROM finance_payroll.hr_payroll AS e
   LEFT JOIN finance_payroll.hr_jobs AS j
     ON e.job_code = j.job_code
   JOIN finance_payroll.hr_departments AS d
     ON e.department_number = d.department_number
   RIGHT JOIN split -- include all token
     ON e.employee_number = split.emp#
   ORDER BY tokennum
   ;
 )
;

EXEC employee_info('536792,301779,333824,445908,543446');

EXEC employee_info('111,347914,blah,236276')
;

