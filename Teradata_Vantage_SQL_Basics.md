# Teradata Vantage SQL Basics

```sql
SELECT manager_employee_number AS mgr#
  ,department_number AS dept#
  ,last_name
  ,first_name
  ,salary_amount / 12 AS monthly_sal
FROM employee_sales.employee
ORDER BY mgr#, last_name;
```

```sql
SELECT manager_employee_number as mgr#,
department_number AS dept#,
last_name,
first_name,
salary_amount / 12 AS monthly_sal
FROM employee_sales.employee
WHERE monthly_sal > 4000
ORDER BY monthly_sal DESC:
```

```sql
HELP TABLE FINANCE_PAYROLL.hr_departments;
```

## Lab 1

```sql
SELECT
department_number AS dept_no,
department_name,
budget_amount AS budget
FROM finance_payroll.hr_departments
WHERE budget_amount > 20000000
ORDER BY budget DESC;
```

```sql
SELECT
first_name,
last_name,
birthdate,
hire_date,
years_service AS YS
FROM finance_payroll.hr_payroll
WHERE years_service > 40
ORDER BY hire_date;
```

```sql
SELECT DISTINCT
trans_type,
operation
FROM finance_payroll.fin_trans
ORDER BY
trans_type,
operation;
```

```sql
SELECT
first_name,
last_name,
department_number AS dept#
FROM employee_sales.Employee
WHERE dept# BETWEEN 402 and 501
ORDER BY dept#;
```

```sql
SELECT
first_name,
last_name,
hire_date
FROM employee_sales.employee
WHERE first_name IN ('James','John','Carol','Nora','John')
ORDER BY first_name;
```

```sql
SELECT *
FROM finance_payroll.hr_payroll
WHERE annual_salary > 90000
AND hire_date >= DATE '2010-01-01'
AND years_service > 5
ORDER BY years_service, annual_salary DESC;
```

```sql
SELECT *
FROM finance_payroll.hr_payroll
WHERE
(
annual_salary > 90000
AND hire_date >= DATE '2010-01-01'
AND years_service > 5
)
OR
(
annual_salary > 90000
AND years_service > 40
)
ORDER BY years_service, annual_salary DESC;
```

```sql
SELECT 'Emma' || ' ' || 'O''Brian';
```

```sql
SELECT Transaction_Mode
FROM dbc.SessionInfoV
WHERE SessionNo = SESSION;
```

```sql
SELECT Last_Name
FROM employee_sales.employee
WHERE TRIM(Last_Name) LIKE '%er';
```

```sql
CREATE VOLATILE TABLE vt_like_test
(
    i int,
    c char(4),
    v varchar(4)
)
UNIQUE PRIMARY INDEX(i)
ON COMMIT PRESERVE ROWS;

INSERT INTO vt_like_test VALUES(1, 'a', 'a');
INSERT INTO vt_like_test VALUES(2, 'a ', 'a ');
INSERT INTO vt_like_test VALUES(3, 'a  ', 'a  ');
INSERT INTO vt_like_test VALUES(4, 'a   ', 'a   ');
INSERT INTO vt_like_test VALUES(5, ' a  ', ' a  ');

SELECT i, c || '#'
FROM vt_like_test
WHERE c = 'a  '
ORDER BY i;

SELECT i, v || '#'
FROM vt_like_test
WHERE v = 'a  '
ORDER BY i;

SELECT i, v || '#'
FROM vt_like_test
WHERE V LIKE 'a%'
ORDER BY i;
```

```sql
SELECT description
FROM employee_sales.job
WHERE description LIKE ALL ('%Support%','System%');
```

```sql
SELECT description
FROM employee_sales.job
WHERE description LIKE ANY ('%Support%','System%');
```


```sql
CREATE VOLATILE TABLE vt_match(pattern varchar(20)) ON COMMIT PRESERVE ROWS;
INSERT INTO vt_match VALUES('%Support%');
INSERT INTO vt_match VALUES('System%');

SELECT description
FROM employee_sales.job
WHERE description LIKE ANY
(
    SELECT pattern
    FROM vt_match
);
```

```sql
SELECT 
    first_name,
    UPPER(first_name) AS upper_name,
    LOWER(first_name) AS lower_name
FROM employee
WHERE department_number = 403;
```

```sql
SELECT 
    first_name,
    Char_Length(first_name) AS len_first,
    last_name,
    Char_Length(last_name) AS len_last,
    Char_Length(Trim(last_name)) AS len_trimmed
FROM employee_sales.employee
WHERE department_number = 403;
```

```sql
SELECT 
    Trim(Leading '0' From '0000007890') AS LeadingZeroTrim,
    Trim(Both '_' From '_no_spaces_') AS BothSidesTrim,
    Trim(Trailing 'x' From '12345xXxxXXxx') AS TrailingXTrim
;
```

```sql
SELECT OTranslate('replace characters', 'ea', 'io');
SELECT OTranslate('It''s CASE specific', 'aeiou', '*****');
SELECT OTranslate('remove vowels', 'aeiou', '');
SELECT OTranslate('1.234.567,89', '.,', ',.');
```

```sql
SELECT 
  'Count the spaces in this sentence' AS x,
  OTranslate(x, ' ', '') AS x_replaced,
  (CHAR_LENGTH(x) - CHAR_LENGTH(x_replaced))
;
```

```csv
Count the spaces in this sentence,Countthespacesinthissentence,5
```

```sql
SELECT 
  'Count that blah blah blah!' AS x,
  'blah' AS word,
  OReplace(x, word) AS x_replaced,
  (Char_Length(x) - Char_Length(x_replaced)) / Char_Length(word)
;
```

```csv
Count that blah blah blah!,blah,Count that   !,3
```

```sql
-- Fetching the position of substring 'ar' in the column 'first_name'
SELECT 
    first_name,                                     -- Employee's first name
    Position('ar' IN first_name) AS pos,            -- Position of substring 'ar'
    Position('ar' IN (first_name (CaseSpecific))) AS pos_cs, -- Case-sensitive position
    Position('' IN first_name) AS pos_zero         -- Position of empty string, always 1
FROM 
    employee_sales.Employee                                       
WHERE 
    pos > 0                                        -- Only consider rows where 'ar' is found
ORDER BY 
    pos, first_name;                               -- Sort by position, then by name
```

```sql
SELECT 
    first_name,
    Position('ar' IN first_name) AS pos,
    Instr(first_name, 'ar') AS instr,
    Instr(first_name, '') AS instr_zero
FROM 
    employee_sales.Employee
WHERE 
    pos > 0
ORDER BY 
    pos, first_name;
```

```sql
SELECT 
    'Teradata' AS string_expression,
    4 AS len,
    Left(string_expression, len),
    Substring(string_expression FROM 1 FOR len),
    Right(string_expression, len),
    Substring(string_expression FROM Char_Length(string_expression)+1 - len)
;
```

```sql
SELECT
Substring(first_name FROM 1 FOR 1)
|| '. ' || last_name AS name,
hire_date,
years_service AS YS,
Lpad(Trim(department_number), 4, '0') AS dept#,
job_code
FROM finance_payroll.hr_payroll
WHERE last_name LIKE '%-%'
AND years_service > 10
ORDER BY last_name;
```

```csv
A. Beckes-Scott,1996-02-21,13,0052,120760
G. Brinkley-Jones,1990-09-24,12,0070,107345
L. Cooley-Freeman,2000-04-24,13,0053,105129
J. Davis-Talbot,1990-03-19,21,0070,101210
L. Guerin-Stewart,1986-06-26,11,0041,107113
C. Hornsby-Mccoy,2006-03-08,12,0012,400280
B. Lanis-Austin,2001-05-21,17,0050,405470
B. Netter-Beauchamp,1977-04-20,30,0041,111108
P. Norman-Porter,2005-10-31,13,0044,110625
R. Piha-Paul,1987-10-20,25,0012,104205
M. Ruffins-Mims,2005-11-07,13,0060,105357
M. Shelmire-Asbury,2007-09-10,11,0053,105445
R. Thomas-Anderson,1977-12-01,29,0060,105393
```

```sql
SELECT
1e-1 + 2e-1 AS a,
3e-1 AS b,
a-b
WHERE a <> b;
```

```sql
SELECT 45654.4565 AS x,
Round(x, 3),
Round(x, 2),
Round(x,-3);
```

```sql
SELECT department_number AS dept#,
RANDOM(1,9) AS rnd1,
RANDOM(1,9) AS rnd2
FROM employee_sales.department;
```

```sql
SELECT 
    department_number AS dept#,
    employee_number AS emp#,
    salary_amount,
    Width_Bucket(salary_amount, 25000, 45000, 4) AS wb
FROM employee_sales.employee
WHERE department_number = 401
ORDER BY salary_amount;
```

```sql
SELECT
first_name || ' ' || middle_initial || ' ' || last_name AS full_name,
hire_date,
years_service AS YS,
Round(annual_salary, -4) AS salary_rounded
FROM finance_payroll.hr_payroll
WHERE department_number = 54
AND years_service >= 5
ORDER BY annual_salary DESC;
```

```sql
SELECT Current_Date - DATE '2020-01-01';
```

```sql
SELECT hire_date,
Last_Day(hire_date) AS end_of_month
FROM employee_sales.employee
WHERE department_number = 401;
```

```sql
SELECT
hire_date,
To_Char(hire_date, 'Day') AS weekday_hire,
Next_Day(hire_date, 'sun') AS next_sunday
FROM employee_sales.employee
WHERE department_number = 401
ORDER BY DayNumber_Of_Week(hire_date, 'iso');
```

```sql
SELECT
    DATE '2022-08-17' AS dt,
    Trunc(dt, 'cc'),    -- Century starts with the year 1
    Trunc(dt, 'yy'),    -- Year starts on January 1st
    Trunc(dt, 'iy'),    -- ISO year starts on a Monday
    Trunc(dt, 'mm'),    -- First day of month
    Trunc(dt, 'q'),     -- First day of quarter
    Trunc(dt, 'ww'),    -- Week starts on Sunday
    Trunc(dt, 'iw'),    -- Week starts on Monday (ISO)
    Trunc(dt, 'dy');    -- Week start on the same day of the week as January 1st of the year
```

<table><thead><tr><th><span>'format'</span></th><th><span>Desription</span></th><th><span>Returns</span></th></tr></thead><tbody><tr><td><em>CC, SCC</em></td><td>Century</td><td>January 1st of the first year of the century: 19<strong><span>01</span></strong>, 20<strong><span>01</span></strong>, etc.<br></td></tr><tr><td><em>SYYY, YYYY, YEAR, SYEAR, YYY, YY, Y</em></td><td>Year</td><td><p>the first day of the year: 'YYYY-<strong><span>01</span></strong>-<strong><span>01</span></strong>'</p></td></tr><tr><td><em>IYYY, IYY, IY, I<br></em></td><td><p>ISO Year</p></td><td><p>the first day of the year, as defined by ISO 8601 standard</p></td></tr><tr><td><em>MONTH, MON, MM, RM<br></em></td><td>Month<br></td><td>the first day of the month<br></td></tr><tr><td>Q<br></td><td>Quarter<br></td><td>the first day of the quarter<br></td></tr><tr><td><em>WW</em><br></td><td>Week<br></td><td><p>the same day of the week as January 1st of the year</p></td></tr><tr><td><em>IW<br></em></td><td>Week</td><td><p>the Monday of the ISO week</p></td></tr><tr><td><em>W</em><br></td><td>Week</td><td>the same day of the week as the first day of the month<br></td></tr><tr><td><em>DAY, DY, D<br></em></td><td>Week</td><td>the Sunday of the week<br></td></tr><tr><td><em>DDD, DD, J<br></em></td><td>Day</td><td><p>the start of the day: 'YYYY-MM-DD<span>&nbsp;</span><strong><span>00:00:00</span></strong>'.<br>This is the default if 'format' is omitted</p></td></tr><tr><td><em>HH, HH12, HH24<br></em></td><td>Hour</td><td><p>the start of the hour: 'HH:<strong><span>00:00</span></strong>'</p></td></tr><tr><td><em>MI</em><br></td><td>Minute</td><td><p>the start of the minute: 'HH:MI:<strong><span>00</span></strong>'</p></td></tr></tbody></table>

```sql
SELECT
    DATE '2022-08-17' AS dt,
    Add_Months(dt, 2)                  AS add_2_months,
    Add_Months(dt, 12*14)              AS add_14_years,
    Add_Months(dt, -11)                AS subtract_11_months,
    Add_Months('1970-01-01', 2)        AS implicit_cast,
    Add_Months(DATE '1970-01-01', 14)  AS date_literal,
    Add_Months(TIMESTAMP '2022-08-17 09:56:21.71-04:00', 1)
;
```

```sql
SELECT CAST(Months_Between(Current_Date, DATE '1970-01-01')/12 AS SMALLINT) AS age;
```

```sql
REPLACE FUNCTION calculate_age(birthdate DATE, today DATE) 
RETURNS SMALLINT 
SPECIFIC age_date
RETURNS NULL ON NULL INPUT
CONTAINS SQL
DETERMINISTIC
COLLATION INVOKER
INLINE TYPE 1
    RETURN Cast(Months_Between(today, birthdate) / 12 AS SMALLINT)
;

SELECT
    DATE '2000-02-29' AS birthdate,
    DATE '2022-02-28' AS today,
    calculate_age(DATE '2000-02-29', DATE '2022-02-28') AS age,
    (Cast(today AS INT) - Cast(birthdate AS INT)) / 10000 AS age
;
```

<table><thead><tr><th><span>'format'</span></th><th><span>Description</span></th></tr></thead><tbody><tr><td><p><em>- / , . ; : "text"</em></p></td><td><p>Punctuation characters and text enclosed in quotation marks are inserted as-is.</p></td></tr><tr><td><em>D</em></td><td>Day of week (1-7)<br></td></tr><tr><td><em>DAY</em></td><td><p>Name of day</p></td></tr><tr><td><em>DY</em></td><td><p>Abbreviated name of day</p></td></tr><tr><td><em>DD</em></td><td>Day of month<br></td></tr><tr><td><em>DDD</em></td><td>Day of year<br></td></tr><tr><td><em>FF</em></td><td>Fractional seconds<br></td></tr><tr><td><em>HH&nbsp;</em><em>|</em><span>&nbsp;</span><em>HH12</em></td><td>Hour of the day (1-12)</td></tr><tr><td><em>HH24</em></td><td>Hour of the day (0-24)<br></td></tr></tbody></table>

<table><thead><tr><th><span>'format'</span></th><th><span>Description</span></th></tr></thead><tbody><tr><td><em>IYYY</em></td><td>4-digit year based on the ISO standard (0001-9999)<br></td></tr><tr><td><em>MI</em></td><td>Minute (0-59)<br></td></tr><tr><td><em>MM</em></td><td>Month (01-12)<br></td></tr><tr><td><em>MON</em></td><td>Abbreviated name of month<br></td></tr><tr><td><em>MONTH</em></td><td>Name of month<br></td></tr><tr><td><em>AM&nbsp;</em>|<span>&nbsp;</span><em>PM</em></td><td><p>Meridian indicator</p></td></tr><tr><td><em>RM</em></td><td>Roman numeral month (I-XII)<br></td></tr><tr><td><em>SS</em></td><td>Second (0-59)<br></td></tr><tr><td><em>SSSSS</em></td><td>Seconds past midnight (0-86399)<br></td></tr><tr><td><em>TZH</em></td><td>Time zone hour<br></td></tr><tr><td><em>TZM</em></td><td><p>Time zone minute</p></td></tr><tr><td><em>YYYY</em></td><td>4-digit year &nbsp;(0001-9999)<br></td></tr></tbody></table>

```sql
SELECT 
    first_name || ' ' || middle_initial || ' ' || last_name AS full_name,
    TO_CHAR(hire_date, 'FMDay, dd Month yyyy') AS hire_date,
    CAST(Months_Between(hire_date, birthdate) / 12 AS SMALLINT) AS hire_age,
    years_service AS YS,
    ROUND(annual_salary, -4) AS salary_rounded
FROM 
    finance_payroll.hr_payroll
WHERE 
    department_number = 54
    AND years_service >= 5
ORDER BY 
    annual_salary;
```

> Relating the earlier concepts of “inner” and “outer” to subqueries is basically a positional one.  The query that is the object of the IN or NOT IN is referred to as the INNER query, and its table as the INNER table. The table that we are projecting column values from is referred to as the OUTER table, and its query as the OUTER query.

```sql
SELECT *
FROM employee_sales.employee
WHERE department_number IN
(
SELECT department_number FROM employee_sales.department
);
```

> To do so, begin from the lowest level and move outward to the outermost query. The bottom example illustrates how two separate subqueries, ANDed together, might be interpreted as a separate condition. If they were ORed together then the business question would be “People who are managers or work in support departments.” This is not an example of nested subqueries, which will be discussed next.


```sql
SELECT *
FROM employee_sales.employee
WHERE job_code = 412101
AND department_number IN
(
SELECT department_number
FROM employee_sales.department
WHERE department_name LIKE '%Support%'
);
```

```sql
SELECT *
FROM employee_sales.employee
WHERE job_code IN
(
SELECT job_code
FROM employee_sales.job
WHERE description LIKE '%Manager%'
)
AND department_number IN
(
SELECT department_number
FROM employee_sales.department
WHERE department_name LIKE '%Support%'
);
```

```sql
SELECT *
FROM employee_sales.employee
WHERE (department_number, employee_number) IN
(
    SELECT department_number, manager_employee_number
    FROM employee_sales.department
);
```

```sql
SELECT *
FROM employee_sales.department
WHERE department_number NOT IN
(
    SELECT department_number
    FROM employee_sales.employee
    WHERE department_number IS NOT NULL
);
```

```sql
SELECT job_code, job_title
FROM finance_payroll.hr_jobs
WHERE legacy_flag = 0
AND job_code BETWEEN 330000 AND 339999
AND job_code IN
(
    SELECT job_code
    FROM finance_payroll.hr_payroll
    WHERE hire_end_date IS NULL
)
ORDER BY job_code;
```

```sql
SELECT first_name || ' ' || last_name AS fullname, birthdate, annual_salary
FROM finance_payroll.hr_payroll AS p
WHERE hire_end_date IS NULL
AND p.annual_salary < 80000
AND job_code IN
(
    SELECT job_code
    FROM finance_payroll.hr_jobs
    WHERE job_title LIKE '%administrator%'
)
ORDER BY
    EXTRACT(MONTH FROM birthdate),
    EXTRACT(DAY FROM birthdate);
```

```sql
SELECT job_code, job_title
FROM finance_payroll.hr_jobs
WHERE legacy_flag = 0
AND job_code NOT IN
(
    SELECT job_code
    FROM finance_payroll.hr_payroll
    WHERE hire_end_date IS NULL
    AND job_code IS NOT NULL
)
ORDER BY job_title;
```

```sql
SELECT district_name, region, num_inhabitants, average_salary
FROM finance_payroll.fin_district
WHERE num_inhabitants < 60000
AND district_id IN
(
    SELECT district_id
    FROM finance_payroll.fin_account
    WHERE account_id IN
    (
        SELECT account_id
        FROM finance_payroll.fin_loan
        WHERE status = 'D'
    )
)
ORDER BY district_name;
```

```sql
SELECT 
    employee_sales.employee.employee_number AS emp#,
    employee_sales.employee.last_name,
    employee_sales.employee.department_number AS dept#e,
    employee_sales.department.department_number AS dept#d,
    employee_sales.department.department_name
FROM 
    employee_sales.employee INNER JOIN employee_sales.department
ON 
    employee_sales.employee.department_number = employee_sales.department.department_number
ORDER BY 
    dept#e, emp#;
```

> Also, notice that the "ON" clause references the join condition. The WHERE clause is used to reference conditions that are "residual" to the join. The "ON" clause is mandatory if the keyword JOIN is present for an inner join. Join conditions when using the "implicit" form are not mandatory. We shall discuss this later in the module.

```sql
--Implicit join
SELECT
    e.last_name,
    e.first_name,
    e.department_number,
    d.manager_employee_number
FROM 
    employee_sales.employee AS e, employee_sales.department AS d
WHERE 
    e.department_number = d.department_number
AND 
    e.last_name = 'Brown';

--Explicit join
SELECT
    e.last_name,
    e.first_name,
    e.department_number,
    d.manager_employee_number
FROM 
    employee_sales.employee AS e
JOIN 
    employee_sales.department AS d
ON 
    e.department_number = d.department_number
WHERE 
    e.last_name = 'Brown';
```

> Implicit Join as shown in the example above, is often referred to as the “implicit” form (Inner Join is not stated so it is implied) while the Explicit Join shown in the example is referred to as the “explicit” form (Inner Join is stated). Another term some may use for the top form is the “comma” form.  When using the explicit form, the INNER keyword is optional.
>
> Also, notice that the "ON" clause references the join condition. The WHERE clause is used to reference conditions that are "residual" to the join. The "ON" clause is mandatory if the keyword JOIN is present for an inner join. Join conditions when using the "implicit" form are not mandatory. We shall discuss this later in the module.

```sql
--Explicit join
SELECT
    e.last_name,
    d.department_name,
    j.description
FROM 
    employee_sales.employee AS e
JOIN 
    employee_sales.department AS d
ON 
    e.department_number = d.department_number
JOIN 
    employee_sales.job AS j
ON 
    e.job_code = j.job_code;

--Implicit join
SELECT
    e.last_name,
    d.department_name,
    j.description
FROM 
    employee_sales.employee AS e,
    employee_sales.department AS d,
    employee_sales.job AS j
WHERE 
    e.department_number = d.department_number
AND 
    e.job_code = j.job_code;
```

> Display the first and last names of employees working in department 301 along with the first and last names of their managers.

```sql
SELECT
    emp.employee_number AS emp_emp#,
    emp.first_name AS emp_fnm,
    emp.last_name AS emp_lnm,
    mgr.employee_number AS mgr_emp#,
    mgr.first_name AS mgr_fnm,
    mgr.last_name AS mgr_lnm
FROM 
    employee_sales.employee AS emp
JOIN 
    employee_sales.employee AS mgr
ON 
    emp.manager_employee_number = mgr.employee_number
WHERE 
    emp.department_number = 301;
```

```sql
--Implicit Cross Join (SQL-89)
SELECT
    e.employee_number AS emp#,
    e.last_name,
    d.department_number AS dept#,
    d.department_name
FROM 
    employee_sales.employee AS e,
    employee_sales.department AS d;

--Explicit Cross Join (SQL-92)
SELECT
    e.employee_number AS emp#,
    e.last_name,
    d.department_number AS dept#,
    d.department_name
FROM 
    employee_sales.employee AS e
CROSS JOIN 
    employee_sales.department AS d;
```

```sql
RETRIEVE employee_sales.employee.last_name;
```

```sql
SELECT DISTINCT
j.job_code,
j.job_title
FROM finance_payroll.hr_jobs AS j
JOIN finance_payroll.hr_payroll AS p
ON j.job_code = p.job_code
WHERE j.legacy_flag = 0
AND j.job_code BETWEEN 330000 AND 339999
AND p.hire_end_date IS NULL
ORDER BY j.job_code;
```

```sql
SELECT
p.first_name || ' ' || p.last_name AS fullname,
p.birthdate,
p.annual_salary
FROM finance_payroll.hr_payroll AS p 
JOIN finance_payroll.hr_jobs AS j
ON j.job_code = p.job_code
WHERE p.hire_end_date IS NULL
AND p.annual_salary < 80000
AND j.job_title LIKE '%administrator%'
ORDER BY
EXTRACT(MONTH FROM p.birthdate),
EXTRACT(DAY FROM p.birthdate);
```

```sql
SELECT
    Substring(mgr.first_name FROM 1 FOR 1) || '.' || mgr.last_name AS mgr_name,
    mgr.annual_salary AS mgr_sal,
    Substring(emp.first_name FROM 1 FOR 1) || '.' || emp.last_name AS emp_name,
    emp.annual_salary AS emp_sal,
    emp_sal - mgr_sal AS difference
FROM finance_payroll.hr_departments AS d
JOIN finance_payroll.hr_payroll AS mgr
    ON d.manager_employee_number = mgr.employee_number
JOIN finance_payroll.hr_payroll AS emp
    ON d.department_number = emp.department_number
WHERE emp.hire_end_date IS NULL
    AND emp_sal > mgr_sal
ORDER BY difference DESC;
```

```sql
SELECT 
    e.employee_number AS emp#,
    e.last_name,
    e.department_number AS dept#e,
    d.department_number AS dept#d,
    d.department_name
FROM 
    employee_sales.employee AS e
LEFT JOIN 
    employee_sales.department AS d
ON 
    e.department_number = d.department_number
ORDER BY 
    dept#e, emp#;
```

```sql
SELECT
j.job_code,
j.job_title
FROM finance_payroll.hr_jobs AS j
LEFT JOIN finance_payroll.hr_payroll AS p
ON j.job_code = p.job_code
WHERE p.job_code IS NULL
AND legacy_flag = 0
ORDER BY j.job_title;
```

> Added WHERE-condition in the subquery "correlates" the inner and the outer select via a join-like condition

> The result of SQL Exists is a Boolean value TRUE or FALSE, if the subquery returns one or more records it returns TRUE otherwise it returns FALSE. But EXISTS never returns UNKNOWN.

```sql
SELECT
job_code,
description
FROM employee_sales.job AS j
WHERE EXISTS
(
SELECT *
FROM employee_sales.employee AS e
WHERE salary_amount < 30000
AND e.job_code = j.job_code
)
ORDER BY job_code;
```

```sql
SELECT 
    first_name || ' ' || last_name AS fullname,
    birthdate,
    annual_salary
FROM 
    finance_payroll.hr_payroll AS p
WHERE 
    hire_end_date IS NULL
AND 
    annual_salary < 80000
AND EXISTS 
    (
        SELECT 1
        FROM finance_payroll.hr_jobs AS j
        WHERE p.job_code = j.job_code
        AND job_title LIKE '%administrator%'
    )
ORDER BY 
    Extract(MONTH FROM birthdate),
    Extract(DAY FROM birthdate);
```

> Aggregate functions perform operations that summarize information found in tables, i.e., one can expect that a certain amount of detailed information will be lost when performing aggregations. In our first example, we see that a single row is returned, representing the minimum, maximum, sum, and average of all salary amounts for all employees and a number of rows with a known salary amount. COUNT(*) provides us with a mechanism that can be used to count actual rows. It doesn’t matter if NULLs appear for each and every column value in a row, it still gets counted!

```sql
SELECT
department_number AS dept#,
MIN(salary_amount) AS MinSal,
MAX(salary_amount) AS MaxSal,
SUM(salary_amount) AS SumSal,
COUNT(salary_amount) AS CntSal,
COUNT(*) AS CntStar
FROM employee_sales.employee
WHERE salary_amount > 30000
GROUP BY department_number
HAVING CntStar >= 3
ORDER BY department_number;
```

```sql
SELECT
j.job_code,
j.job_title,
COUNT(p.job_code) AS Cnt,
SUM(p.annual_salary) AS sumsal
FROM finance_payroll.hr_jobs AS j
LEFT JOIN finance_payroll.hr_payroll AS p
ON j.job_code = p.job_code
WHERE j.legacy_flag = 0
AND j.job_code BETWEEN 330000 AND 339999
GROUP BY 1,2
ORDER BY j.job_code;
```

```sql
SELECT
a.account_id,
COUNT(*) AS Cnt,
SUM(amount) AS sum_amt
FROM finance_payroll.fin_account AS a
JOIN finance_payroll.fin_trans AS t
ON a.account_id = t.account_id
WHERE a.district_id = 1
AND t.trans_date BETWEEN DATE '2018-01-05' AND DATE '2018-01-25'
GROUP BY 1
HAVING sum_amt < -4000
ORDER BY sum_amt ASC;
```

```sql
SELECT
WIDTH_BUCKET(amount, 0, 5000, 10) AS wb,
COUNT(*) AS Cnt,
MIN(amount) AS min_amt,
AVG(amount) AS avg_amt,
MEDIAN(amount) AS med_amt,
MAX(amount) AS max_amt,
SUM(amount) AS sum_amt
FROM finance_payroll.fin_trans
WHERE trans_type = 'C' --credit
AND trans_date BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
GROUP BY wb
ORDER BY wb;
```

```sql
SELECT 
    last_name,
    first_name,
    birthdate,
    CASE Extract(MONTH From birthdate)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
        ELSE '<invalid>'
    END AS month_name
FROM employee_sales.employee;
```

```sql
SELECT TOP 10
    employee_number AS emp#,
    first_name,
    last_name,
    birthdate,
    Add_Months(birthdate, age * 12) AS birthday,
    Cast(Months_Between(Current_Date-1, birthdate) / 12 AS INT) + 1 AS age
FROM employee_sales.employee
ORDER BY
    CASE
        WHEN Extract(MONTH From birthdate) < Extract(MONTH From Current_Date) THEN 1
        WHEN Extract(MONTH From birthdate) = Extract(MONTH From Current_Date)
        AND Extract(DAY From birthdate) < Extract(DAY From Current_Date) THEN 1
        ELSE 0
    END,
    Extract(MONTH From birthdate),
    Extract(DAY From birthdate);
```

```sql
SELECT
description,
hourly_billing_rate/NULLIF(hourly_cost_rate,0) AS cost_ratio
FROM employee_sales.job
WHERE description LIKE '%analyst%'
ORDER BY cost_ratio
NULLS LAST;
```

```sql
SELECT
description,
hourly_cost_rate
FROM employee_sales.job
WHERE description LIKE '%analyst%';
```

> Select the number of transactions between '2018-01-05' and '2018-01-25' (trans_date) and the sum of transaction amounts (amount) for accounts from district_id 1.
>
> Only return accounts with a sum less than -4000.
>
> Order by sum(trans_amount).
>
> Split transactions into debits (amount < 0) and credits (amount > 0)

```sql
SELECT
    a.account_id,
    COUNT(*) AS Cnt,
    SUM(t.amount) AS sum_amt,
    COUNT(CASE WHEN t.amount < 0 THEN 1 END) AS cnt_D,
    SUM(CASE WHEN t.amount < 0 THEN t.amount ELSE 0 END) AS sum_D,
    COUNT(CASE WHEN t.amount > 0 THEN 1 END) AS cnt_C,
    SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) AS sum_C
FROM finance_payroll.fin_account AS a
JOIN finance_payroll.fin_trans AS t
    ON a.account_id = t.account_id
WHERE a.district_id = 1
AND t.trans_date BETWEEN DATE '2018-01-05' AND DATE '2018-01-25'
GROUP BY a.account_id
HAVING sum_amt < -4000
ORDER BY sum_amt;
```

> Select all active (hire_end_date is NULL) employees with an annual_salary over 120,000
>
> If the budget_amount of the employee's department is less than 20,000,000 include the budget and calculate the percentage each salary represents of the departmental budget, otherwise return a NULL
>
> Order by lastname

```sql
SELECT
    p.first_name,
    p.last_name,
    p.annual_salary,
    p.department_number AS dept,
    d.department_name,
    CASE WHEN d.budget_amount < 2000000 THEN d.budget_amount END AS budget,
    100 * p.annual_salary / d.budget_amount AS "% of budget"
FROM finance_payroll.hr_payroll AS p
JOIN finance_payroll.hr_departments AS d
    ON p.department_number = d.department_number
WHERE p.annual_salary > 120000
AND p.hire_end_date IS NULL
ORDER BY p.last_name;
```

> Create a report showing the number and average annual_salary of all currently active (hire_end_date is NULL) employees working full-time (80 scheduled_hours biweekly).
>
> Group employees into seven ranges by years of service (years_service)

```sql
SELECT 
    CASE 
        WHEN years_service <= 5 THEN '1: <= 5'
        WHEN years_service <= 10 THEN '2: 6-10'
        WHEN years_service <= 15 THEN '3: 11-15'
        WHEN years_service <= 20 THEN '4: 16-20'
        WHEN years_service <= 30 THEN '5: 21-30'
        WHEN years_service <= 40 THEN '6: 31-40'
        ELSE '7: > 40'
    END AS YoS_range,
    Count(*) AS Cnt,
    Avg(annual_salary) AS avg_sal
FROM finance_payroll.hr_payroll
WHERE hire_end_date IS NULL
AND scheduled_hours = 80
GROUP BY 1
ORDER BY 1;
```

> Derived Tables are also named "inline view", "sub-select" or "sub-query".

```sql
SELECT 
    e.department_number AS dept#,
    e.job_code,
    e.employee_number AS emp#,
    e.last_name,
    e.salary_amount AS salary,
    salary - eg.AvgSal AS diff2avg,
    salary - eg.MaxSal AS diff2max
FROM 
    employee_sales.employee AS e
JOIN
    (
        SELECT 
            department_number,
            AVG(salary_amount) AS AvgSal,
            MAX(salary_amount) AS MaxSal
        FROM 
            employee_sales.employee
        GROUP BY 
            department_number
        WHERE 
            department_number IN (301, 501)
    ) AS eg
ON 
    dept# = eg.department_number
WHERE 
    e.department_number IN (301, 501);
```

> A Common Table Expression (CTE) is defined as a SELECT statement in the WITH clause at the top of the query and used in FROM.

> Rules and Restrictions 
>
> 1. Wrapped in parentheses
> 2. Table alias required
> 3. Calculated columns must be aliased
> 4. No ORDER BY allowed

```sql
SELECT 
    e.department_number AS dept#,
    e.job_code,
    e.employee_number AS emp#,
    e.last_name,
    e.salary_amount AS salary,
    salary - eg.AvgSal AS diff2avg,
    salary - eg.MaxSal AS diff2max
FROM 
    employee_sales.employee AS e
JOIN
    (
        SELECT 
            department_number,
            AVG(salary_amount) AS AvgSal,
            MAX(salary_amount) AS MaxSal
        FROM 
            employee_sales.employee
        GROUP BY 
            department_number
        WHERE 
            department_number IN (301, 501)
    ) AS eg
ON 
    dept# = eg.department_number
WHERE 
    e.department_number IN (301, 501);
```

```sql
-- CTEs
WITH cte AS
(
    SELECT
        e.department_number AS dept#
        ,e.job_code
        ,e.employee_number  AS emp#
        ,e.last_name
        ,e.salary_amount    AS salary
    FROM employee_sales.employee AS e
    WHERE e.department_number IN (301, 501)
)
,eg AS
(
    SELECT
        dept#
        ,Avg(salary) AS AvgSal
        ,Max(salary) AS MaxSal
    FROM cte
    GROUP BY dept#
)
SELECT
    e.*
    ,salary - eg.AvgSal AS diff2avg
    ,salary - eg.MaxSal AS diff2max
FROM cte AS e
JOIN eg
ON e.dept# = eg.dept#;
```

```sql
--Same result using a CTE in a DT:
WITH cte AS
(
    SELECT
        e.department_number AS dept#
        ,e.job_code
        ,e.employee_number  AS emp#
        ,e.last_name
        ,e.salary_amount    AS salary
    FROM employee_sales.employee AS e
    WHERE e.department_number IN (301, 501)
)
SELECT
    e.*
    ,salary - eg.AvgSal AS diff2avg
    ,salary - eg.MaxSal AS diff2max
FROM cte AS e
JOIN
(
    SELECT
        dept#
        ,Avg(salary) AS AvgSal
        ,Max(salary) AS MaxSal
    FROM cte
    GROUP BY dept#
) AS eg
ON e.dept# = eg.dept#;
```

> Calculate the minimum/average/maximum of the maximum annual_salary per department with over 50 active (hire_end_date is null) employees.
>
> Add the number of departments and the number of employees included in the calculation.
>
> Use either a Derived Table or a Common Table Expression to solve this nested aggregation.

```sql
SELECT
    MIN(max_sal) AS min_max,
    AVG(max_sal) AS avg_max,
    MAX(max_sal) AS max_max,
    COUNT(*) AS dept_count,
    SUM(emp_count) AS emp_count
FROM
(
    SELECT 
        department_number,
        MAX(annual_salary) AS max_sal,
        COUNT(*) AS emp_count
    FROM finance_payroll.hr_payroll
    WHERE hire_end_date IS NULL
    GROUP BY department_number
    HAVING Count(*) > 50
) AS dt;

WITH cte AS
(
    SELECT 
        department_number,
        MAX(annual_salary) AS max_sal,
        COUNT(*) AS emp_count
    FROM finance_payroll.hr_payroll
    WHERE hire_end_date IS NULL
    GROUP BY department_number
    HAVING COUNT(*) > 50
)
SELECT
    MIN(max_sal) AS min_max,
    AVG(max_sal) AS avg_max,
    MAX(max_sal) AS max_max,
    COUNT(*) AS dept_count,
    Sum(emp_count) AS emp_count
FROM cte;
```

> Write a query to report the employees with the highest overtime_pay per department in 2017 (sal_year). Consider only employees with at least 200 overtime_hours. Order by descending overtime pay. Solve it using either Derived Tables (DT), Common Table Expressions (CTE), Common Table Expressions (CTE)  + Derived Tables (DT), Multi-column Subquery

```sql
--Derived Table
SELECT
    p.employee_number,
    p.first_name,
    p.last_name,
    p.department_number,
    p.job_code,
    p.total_pay,
    p.overtime_pay,
    p.overtime_hours
FROM finance_payroll.hr_salary_hist AS p
JOIN
(
    SELECT
        department_number,
        Max(overtime_pay) AS max_overtime
    FROM finance_payroll.hr_salary_hist
    WHERE sal_year = 2017
    AND overtime_hours > 200
    GROUP BY department_number
) AS dt
ON p.department_number = dt.department_number
AND p.overtime_pay = dt.max_overtime
WHERE p.sal_year = 2017
AND overtime_hours > 200
ORDER BY p.overtime_pay DESC;

--Common Table Expression (CTE)
WITH cte AS
(
    SELECT
        employee_number,
        first_name,
        last_name,
        department_number,
        job_code,
        total_pay,
        overtime_pay,
        overtime_hours
    FROM finance_payroll.hr_salary_hist AS t
    WHERE sal_year = 2017
    AND overtime_hours > 200
),
max_pay AS
(
    SELECT
        department_number,
        Max(overtime_pay) AS max_overtime
    FROM cte
    GROUP BY department_number
)
SELECT
    p.*
FROM cte AS p
JOIN max_pay AS mp
ON p.department_number = mp.department_number
AND p.overtime_pay = mp.max_overtime
ORDER BY p.overtime_pay DESC;

--Common Table Expression (CTE) + Derived Table (DT)
WITH cte AS
(
    SELECT
        employee_number,
        first_name,
        last_name,
        department_number,
        job_code,
        total_pay,
        overtime_pay,
        overtime_hours
    FROM finance_payroll.hr_salary_hist AS t
    WHERE sal_year = 2017
    AND overtime_hours > 200
)
SELECT
    p.*
FROM cte AS p
JOIN
(
    SELECT
        department_number,
        Max(overtime_pay) AS max_overtime
    FROM cte
    GROUP BY department_number
) AS dt
ON p.department_number = dt.department_number
AND p.overtime_pay = dt.max_overtime
ORDER BY p.overtime_pay DESC;

--Multi-Column Subquery
SELECT 
    employee_number,
    first_name,
    last_name,
    department_number AS dept#,
    job_code,
    total_pay,
    overtime_pay,
    overtime_hours
FROM finance_payroll.hr_salary_hist AS p
WHERE sal_year = 2017
AND overtime_hours > 200
AND (department_number, overtime_pay) IN 
(
    SELECT 
        department_number,
        Max(overtime_pay) AS max_overtime
    FROM finance_payroll.hr_salary_hist
    WHERE sal_year = 2017
    AND overtime_hours > 200
    GROUP BY department_number
)
ORDER BY overtime_pay DESC;
```

> Set operators are aptly named for what they operate on – sets of data. Whereas inner joins and outer joins return rows based upon some matching condition, set operators deal with differences or commonalities among entire projected rows, not just certain columns as referenced as conditional criteria (predicate) or selected columns (projection).

> The data types in the first SELECT statement determine the data types of corresponding columns in the result set

> Each query connected by UNION is performed to produce a result consisting of a set of rows. The union must include the same number of columns from each table in each SELECT statement (more formally, they must be of the same degree), and the data types of these columns should be compatible. All the result sets are then combined into a single result set that has the data type of the columns specified in the first SELECT statement in the union.

```sql
SELECT area_code, phone
FROM employee_sales.location_Phone
WHERE area_code IN (609,804,919)

UNION

SELECT area_code, phone
FROM employee_sales.employee_phone
WHERE area_code IN (609,804,919)

ORDER BY 1,2;
```

> You can specify the ALL option for each UNION operator in the query to retain every occurrence of duplicate rows in the final result.

```sql
SELECT area_code, phone
FROM employee_sales.employee_Phone
WHERE area_code IN (609,804,919)

INTERSECT ALL

SELECT area_code, phone
FROM employee_sales.location_phone
WHERE area_code IN (609,804,919)

ORDER BY 1,2;
```

> INTERSECT ALL can be rewritten as INNER JOIN using all columns in the Select list and calculated ROW_NUMBERs.

```sql
SELECT ep.area_code,
    ep.phone
    FROM
    
    (
    SELECT area_code,
        phone,
        ROW_NUMBER() OVER (PARTITION BY area_code, phone ORDER BY 1) AS rn
        FROM employee_sales.employee_Phone
        WHERE area_code IN (609,804,919)
    
    ) AS ep
    
    JOIN
    
    (
    SELECT area_code,
        phone,
        ROW_NUMBER() OVER (PARTITION BY area_code, phone
        ORDER BY 1) AS rn
        FROM employee_sales.Location_phone
        WHERE area_code IN (609,804,919)
    
    ) AS lp
    
    ON ep.area_code = lp.area_code
    
    AND ep.phone     = lp.phone
    
    AND ep.rn        = lp.rn
    ORDER BY 1,
        2;
```

```sql
SELECT area_code, phone
FROM employee_sales.employee_Phone
WHERE area_code IN (609,804,919)

EXCEPT

SELECT area_code, phone
FROM employee_sales.location_phone
WHERE area_code IN (609,804,919)

ORDER BY 1,2;
```

> Each query connected by EXCEPT is executed to produce a result consisting of a set of rows. The exception must include the same number of columns from each table in each SELECT statement (more formally, they must be of the same degree), and the data types of these columns should be compatible.

> EXCEPT can be rewritten as NOT EXISTS using all columns in the Select list (if no NULLs exist).

```sql
SELECT DISTINCT area_code, phone
FROM employee_sales.employee_Phone AS ep
WHERE area_code IN (609,804,919)
AND NOT EXISTS
 (
   SELECT area_code, phone
   FROM employee_sales.Location_phone AS lp
   WHERE area_code IN (609,804,919)
   AND (ep.area_code = lp.area_code)
   AND (ep.phone = lp.phone)
 )
ORDER BY 1, 2;
```

> The ALL option instructs the database to preserve duplicate rows.
>
> Should be used if uniqueness is not required or the result is known to be unique to avoid expensive DISTINCT operation

```sql
SELECT area_code, phone
FROM employee_sales.location_Phone
WHERE area_code IN (609,804,919)

UNION ALL

SELECT area_code, phone
FROM employee_sales.employee_phone
WHERE area_code IN (609,804,919)

ORDER BY 1,2;
```

```sql
SELECT 'loc' AS src, area_code, phone
FROM employee_sales.location_Phone
WHERE area_code IN (609,804,919)

UNION

SELECT 'emp' AS src, area_code, phone
FROM employee_sales.employee_phone
WHERE area_code IN (609,804,919)

ORDER BY 2, 3, 1;
```

```sql
SELECT area_code, phone
FROM employee_sales.employee_Phone
WHERE area_code IN (609,804,919)

EXCEPT ALL

SELECT area_code, phone
FROM employee_sales.location_phone
WHERE area_code IN (609,804,919)

ORDER BY 1,2;
```

> Find all accounts (fin_account) with both:
>
> 1. At least three orders with an average amount over 500 (fin_order)
> 2. A loan status of 'B' or 'D' (fin_loan)
>
> Order the result set by account_id

```sql
SELECT 
    account_id,
    district_id,
    create_date
FROM finance_payroll.fin_account
WHERE account_id IN
(
    SELECT account_id
    FROM finance_payroll.fin_order
    GROUP BY account_id
    HAVING COUNT(*) >= 3
    AND AVG(amount) > 500
    
    INTERSECT
    
    SELECT account_id
    FROM finance_payroll.fin_loan
    WHERE status IN ('B', 'D')
)
ORDER BY account_id;
```

> Find all accounts (fin_account) in districts 1 or 5 with:
>
> 1. At least three orders with an average amount over 500 (fin_order)
> 2. But no loan status of 'B' or 'D' (fin_loan)
>
> Order the result set by account_id

```sql
SELECT 
    account_id,
    district_id,
    create_date
FROM finance_payroll.fin_account
WHERE account_id IN
(
    SELECT account_id
    FROM finance_payroll.fin_order
    GROUP BY account_id
    HAVING COUNT(*) >= 3
    AND AVG(amount) > 500
    
    EXCEPT
    
    SELECT account_id
    FROM finance_payroll.fin_loan
    WHERE status IN ('B', 'D')
)
AND district_id IN (1, 5)
ORDER BY account_id;
```

```sql
--Count
SELECT employee_number AS emp#,
first_name,
last_name,
hire_date
FROM finance_payroll.hr_payroll
SAMPLE 3;

--Fraction
SELECT employee_number AS emp#,
first_name,
last_name,
hire_date
FROM finance_payroll.hr_payroll
SAMPLE 0.001;
```

```sql
SELECT HashAmp()+1 AS n; -- returns number of AMPs

SELECT "AMP", Count(*) AS Cnt
FROM
(
    SELECT HashAmp(HashBucket(HashRow(employee_number))) AS "AMP"
    FROM finance_payroll.hr_payroll -- any large table
    SAMPLE 360 -- use number of AMPs n * 10 here
) AS dt
GROUP BY "AMP"
ORDER BY "AMP";
```

> The WITH REPLACEMENT option specifies that sampling is to be done with replacement. The default is sampling without replacement. Sampling without replacement is assumed implicitly if you do not specify WITH REPLACEMENT explicitly.

> Sampling without replacement is analogous to selecting rows from a SET table in that each row sampled is unique, and once a row is sampled, is not returned to the sampling pool. As a result, requesting a number of samples greater than the cardinality of the table returns an error or warning. Whenever multiple samples are requested, they are mutually exclusive.

> Stratified random sampling, sometimes called proportional or quota random sampling, is a sampling method that divides a heterogeneous population of interest into homogeneous subgroups, or strata, and then takes a random sample from each of those subgroups.
>
> The result of this homogeneous stratification of the population is that stratified random sampling represents not only the overall population but also key subgroups. For example, a retail application might divide a customer population into subgroups composed of customers who pay for their purchases with cash, those who pay by check, and those who buy on credit.

```sql
SELECT *
FROM finance_payroll.fin_trans  -- 1,056,320 rows
WHERE amount > 1000  -- 112,238 rows
SAMPLE 0.01  -- 1,122 rows (exactly)
;

SELECT *
FROM
(
    SELECT *
    FROM finance_payroll.fin_trans  -- 1,056,320 rows
    SAMPLE 0.1  -- 105,632 rows (includes approx. 11,224 rows > 1000)
) AS dt
WHERE amount > 1000
SAMPLE 0.1;  -- 1,122 rows (approx.)
```

> Calculate some statistics of the amount column in the fin_trans table: Row Count, Minimum, Maximum, Average, Median and Standard Deviation.
>
> Use multiple sample sizes of 1%, 10%, 25%, 50% and 100% of the rows. 
>
> Order the result set by sample size.

```sql
SELECT
    CASE sid
        WHEN 1 THEN 1
        WHEN 2 THEN 10
        WHEN 3 THEN 25
        ELSE 50
    END AS "% sample",
    COUNT(*),
    MIN(amount) AS min_amt,
    AVG(amount) AS avg_amt,
    MEDIAN(amount) AS median_amt,
    MAX(amount) AS max_amt,
    STDDEV_SAMP(amount) AS stddev_amt
FROM 
(
    SELECT
        SAMPLEID AS sid,
        amount
    FROM finance_payroll.fin_trans
    SAMPLE RANDOMIZED ALLOCATION 0.01, 0.1, 0.25, 0.5
) AS dt
GROUP BY 1

UNION ALL

SELECT
    100,
    COUNT(*),
    MIN(amount) AS min_amt,
    AVG(amount) AS avg_amt,
    MEDIAN(amount) AS median_amt,
    MAX(amount) AS max_amt,
    STDDEV_SAMP(amount) AS stddev_amt
FROM finance_payroll.fin_trans
ORDER BY 1;
```

```sql
SELECT TOP 5
department_number,
budget_amount
FROM employee_sales.department
ORDER BY 2 DESC;

SELECT TOP 5 WITH TIES
department_number,
budget_amount
FROM employee_sales.department
ORDER BY 2 DESC;
```

```sql
SELECT TOP 0.01 PERCENT
employee_number AS emp#,
first_name,
last_name,
hire_date
FROM finance_payroll.hr_payroll
ORDER BY hire_date DESC;

SELECT TOP 0.01 PERCENT WITH TIES
employee_number AS emp#,
first_name,
last_name,
hire_date
FROM finance_payroll.hr_payroll
ORDER BY hire_date DESC;
```

```sql
SELECT TOP 6
employee_number,
salary_amount
FROM employee_sales.employee
ORDER BY salary_amount ASC NULLS LAST;
```

> Check how rows are picked by an unordered TOP 5000 for a partitioned table.
>
> Count the number of
>
> 1. distinct AMPs (based on HASHAMP(HASHBUCKET(HASHROW(account_id)))) 
> 2. distinct partitions (using the PARTITION keyword)

```sql
WITH base_data AS
(
    SELECT TOP 5000
        HashAmp(HashBucket(HashRow(account_id))) AS "AMP",
        PARTITION AS part#,
        trans_date
    FROM finance_payroll.fin_trans
)
SELECT
    COUNT(*) AS #rows,
    COUNT(DISTINCT "AMP") AS #AMPs,
    Count(DISTINCT part#) AS #Partitions,
    MIN(trans_date) AS min_trans_date,
    MAX(trans_date) AS max_trans_date
FROM base_data;
```

