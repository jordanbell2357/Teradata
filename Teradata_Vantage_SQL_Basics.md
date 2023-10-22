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

```sql

```