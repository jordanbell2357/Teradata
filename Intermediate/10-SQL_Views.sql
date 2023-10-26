/********************
 * Module Views
 ********************/

DATABASE employee_sales;


/********************
 * Creating and Using Views
 ********************/

SELECT
   e.employee_number AS emp#
  ,e.first_name || ' ' || e.last_name
  ,j.description
  ,d.department_name
FROM employee AS e 
JOIN job AS j
  ON e.job_code = j.job_code
JOIN department AS d
  ON e.department_number = d.department_number
WHERE j.description LIKE '%Engineer%'
ORDER BY employee_number
;

CREATE VIEW trainee_1.engineers AS
SELECT
   e.employee_number AS emp#
  ,e.first_name || ' ' || e.last_name AS fullname
  ,j.description
  ,d.department_name
FROM employee AS e 
JOIN job AS j
  ON e.job_code = j.job_code
JOIN department AS d
  ON e.department_number = d.department_number
WHERE j.description LIKE '%Engineer%'
;

SELECT * 
FROM trainee_1.engineers
;

-- alternative syntax to define column aliases
CREATE VIEW trainee_1.engineers (emp#, full_name, description, department_name) AS
SELECT
   e.employee_number AS emp#
  ,e.first_name || ' ' || e.last_name AS fullname
  ,j.description
  ,d.department_name
FROM employee AS e 
JOIN job AS j
  ON e.job_code = j.job_code
JOIN department AS d
  ON e.department_number = d.department_number
WHERE j.description LIKE '%Engineer%'
;

/********************
 * Replacing a View
 ********************/

REPLACE VIEW trainee_1.engineers AS
SELECT
   e.employee_number AS emp#
  ,e.first_name || ' ' || e.last_name AS fullname
  ,j.description
  ,d.department_name
  ,Round(e.salary_amount, -4) AS sal_rounded
FROM employee AS e 
JOIN job AS j
  ON e.job_code = j.job_code
JOIN department AS d
  ON e.department_number = d.department_number
WHERE j.description LIKE '%Engineer%'
;  
  
SELECT * 
FROM trainee_1.engineers
;


/********************
 * Views and TOP n
 ********************/

REPLACE VIEW trainee_1.Top_5_Employees AS  
SELECT TOP 5
   first_name
  ,last_name
  ,hire_date
  ,salary_amount
  ,department_number AS dept#
  ,job_code
FROM  Employee
ORDER BY Salary_Amount DESC
;

SELECT * 
FROM trainee_1.Top_5_Employees
;


/********************
 * View Column Info
 ********************/

HELP VIEW trainee_1.Top_5_Employees;

SELECT * 
FROM dbc.ColumnsV
WHERE DatabaseName = USER
  AND TableName = 'Top_5_Employees'
;


/********************
 * Updatable Views
 ********************/

REPLACE VIEW high_sal_employees AS
SELECT
   employee_number
  ,salary_amount
  ,department_number AS dept#
FROM emp_copy
WHERE Salary_Amount > 60000
WITH CHECK OPTION
;

--EXPLAIN
UPDATE high_sal_employees
SET Salary_Amount = 50000
WHERE employee_number = 1017
;

EXPLAIN
DELETE FROM high_sal_employees
;




-- Default database for labs
DATABASE finance_payroll;

/********************
 * Views Lab 1
 ********************/

HELP TABLE hr_payroll;


/********************
 * Views Lab 2
 ********************/

HELP TABLE hr_payroll;


/********************
 * CASE Lab 3
 ********************/

HELP TABLE hr_payroll;


/********************
 * Views Lab 1 Solution
 ********************/

CREATE VIEW trainee_1.Active_Employees AS
SELECT *
FROM HR_Payroll
WHERE Hire_End_Date IS NULL
;

SHOW VIEW trainee_1.Active_Employees
;
HELP VIEW trainee_1.Active_Employees
;
HELP COLUMN trainee_1.Active_Employees.*
;

REPLACE VIEW trainee_1.Active_Employees AS
SELECT 
   Employee_Number
  ,Last_Name
  ,First_Name
  ,Department_Number
  ,Division_Number
  ,Job_Code
  ,Hire_Date
  ,Years_Service
  ,Scheduled_Hours
  ,Annual_Salary
FROM HR_Payroll
WHERE Hire_End_Date IS NULL
;


/********************
 * Views Lab 2 Solution
 ********************/

REPLACE VIEW trainee_1.dept_info AS
SELECT department_number AS dept#
  ,Count(*)              AS emp_cnt
  ,Min(annual_salary)    AS min_sal
  ,Avg(annual_salary)    AS avg_sal
  ,Median(annual_salary) AS median_sal
  ,Max(annual_salary)    AS max_sal
  ,Sum(annual_salary)    AS sum_sal
FROM trainee_1.Active_Employees
GROUP BY department_number
;

SELECT * 
FROM trainee_1.dept_info
;

EXPLAIN
SELECT * 
FROM trainee_1.dept_info
;

SELECT
   Min(max_sal) AS min_max
  ,Avg(max_sal) AS avg_max
  ,Max(max_sal) AS max_max
  ,Count(*)     AS dept_count
  ,Sum(emp_cnt) AS emp_count
FROM trainee_1.dept_info
WHERE emp_cnt > 30
  AND dept# BETWEEN 40 AND 80
;

EXPLAIN
SELECT
   Min(max_sal) AS min_max
  ,Avg(max_sal) AS avg_max
  ,Max(max_sal) AS max_max
  ,Count(*)     AS dept_count
  ,Sum(emp_cnt) AS emp_count
FROM trainee_1.dept_info
WHERE emp_cnt > 30
  AND dept# BETWEEN 40 AND 80
;