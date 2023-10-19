CREATE TABLE star1 (
    country VARCHAR(10),
    state VARCHAR(2),
    yr INTEGER,
    qtr VARCHAR(2),
    sales INTEGER
);

SELECT
    *
FROM
    star1 PIVOT (
        SUM(sales) FOR qtr IN ('Q1' AS Q1, 'Q2' AS Q2, 'Q3' AS Q3)
    ) dt;

SELECT
    *
FROM
    (
        SELECT
            *
        FROM
            star1 PIVOT(
                SUM(sales) FOR qtr IN ('Q1' AS Q1, 'Q2' AS Q2, 'Q3' AS Q3)
            ) dt
    ) dt1 UNPIVOT(sales FOR qtr IN (Q1, Q2, Q3)) dt2;

SELECT
    *
FROM
    Employee
WHERE
    Job_Code = 412101
    AND Department_Number IN (
        SELECT
            Department_Number
        FROM
            Department
        WHERE
            Department_Name LIKE '%Support%'
    );

SELECT
    *
FROM
    Employee
WHERE
    Job_Code IN (
        SELECT
            Job_Code
        FROM
            Job
        WHERE
            Description LIKE '%Manager%'
    )
    AND Department_Number IN (
        SELECT
            Department_Number
        FROM
            Department
        WHERE
            Department_Name LIKE '%Support%'
    );

SELECT
    *
FROM
    Department
WHERE
    Department_Number NOT IN (
        SELECT
            Department_Number
        FROM
            Employee
        WHERE
            Department_Number IS NOT NULL
    );

SELECT
    Last_Name
FROM
    Employee
WHERE
    Department_Number IN (
        SELECT
            Department_Number
        FROM
            Department
    );

SELECT
    Last_Name,
    Department_Name
FROM
    Employee
    INNER JOIN Department ON Employee.Department_Number = Department.Department_Number;

--SQL-89 (ANSI-89) (Implicit Form)
SELECT
    e.Last_Name,
    e.First_Name,
    e.Department_Number,
    d.Manager_Employee_Number
FROM
    Employee e,
    Department d
WHERE
    e.Department_Number = d.Department_Number
    AND e.Last_Name = 'Brown';

--SQL-92 (ANSI-92) (Explicit Form)
SELECT
    e.Last_Name,
    e.First_Name,
    e.Department_Number,
    d.Manager_Employee_Number
FROM
    Employee AS e
    INNER JOIN Department AS d ON e.Department_Number = d.Department_Number
WHERE
    e.Last_Name = 'Brown';

--Without Parentheses
SELECT
    e.Last_Name AS "Ln",
    e.Department_Number AS Dn,
    j.Description AS "Desc"
FROM
    Employee AS e
    JOIN Department AS d ON e.Department_Number = d.Department_Number
    JOIN Job AS j ON e.Job_Code = j.Job_Code;

--With Parentheses
SELECT
    e.Last_Name AS "Ln",
    e.Department_Number AS Dn,
    j.Description AS "Desc"
FROM
    (
        (
            Employee AS e
            JOIN Department AS d ON e.Department_Number = d.Department_Number
        )
        JOIN job AS j ON e.Job_Code = j.Job_Code
    );

--The ORDER BY must be on the last SELECT, and it must be a positional reference (i.e., not on a column name).
SELECT
    Last_Name,
    Department_Number AS DeptNo,
    Salary_Amount
FROM
    Employee
WHERE
    Department_Number = 401
UNION
ALL
SELECT
    Last_Name,
    Department_Number,
    Salary_Amount
FROM
    Employee
WHERE
    Salary_Amount BETWEEN 35000
    AND 38000
ORDER BY
    2,
    1;

SELECT
    Last_Name,
    Salary_Amount
FROM
    Employee
WHERE
    Job_Code BETWEEN 312101
    AND 412101
EXCEPT
SELECT
    Last_Name,
    Salary_Amount
FROM
    Employee
WHERE
    Salary_Amount BETWEEN 25000
    AND 35000;

SELECT
    e.Last_Name,
    d.Department_Number,
    j.Job_Code
FROM
    (
        (
            Employee e
            JOIN Department d ON e.Department_Number = d.Department_Number
        )
        JOIN Job j ON e.Job_Code = j.Job_Code
    );

SELECT
    e.Last_Name,
    e.Department_Number AS DeptNo,
    e.Job_Code AS JCD,
    d.Department_Name AS DName,
    j.Description AS "Desc"
FROM
    Employee e
    LEFT JOIN Department d ON e.Department_Number = d.Department_Number
    LEFT JOIN Job j ON e.Job_Code = j.Job_Code;

SELECT
    Last_name
FROM
    Employee
WHERE
    Department_number IN (
        SELECT
            Department_number
        FROM
            Department
        WHERE
            Department_name LIKE ('%research%')
    );

SELECT
    last_name,
    department_number,
    salary_amount
FROM
    Employee ee
WHERE
    EXISTS (
        SELECT
            *
        FROM
            Department dd
        WHERE
            ee.Department_Number = dd.Department_Number
    );

SELECT
    Manager_Employee_Number,
    Department_Number,
    Job_Code
FROM
    Employee ee
WHERE
    NOT EXISTS (
        SELECT
            *
        FROM
            Department d
        WHERE
            ee.Department_Number = d.Department_Number
    )
    AND NOT EXISTS (
        SELECT
            *
        FROM
            Job j
        WHERE
            ee.Job_code = j.Job_Code
    );

SELECT
    DeptNo
FROM
    Dept D
WHERE
    NOT EXISTS (
        SELECT
            *
        FROM
            Emp E
        WHERE
            E.DeptNo = D.DeptNo
    );

SELECT
    manager_employee_number AS Mgr,
    department_number AS Dept,
    job_code AS JCd,
    SUM(salary_amount) AS SumSal
FROM
    Employee_Sales.Employee
GROUP BY
    1,
    2,
    3
ORDER BY
    1,
    2,
    3;

SELECT
    last_name,
    department_number,
    salary_amount
FROM
    Employee e
WHERE
    salary_amount > (
        SELECT
            AVG(salary_amount)
        FROM
            Employee d
        WHERE
            e.department_number = d.department_number
    );

SELECT
    last_name,
    first_name,
    CASE
        USER
        WHEN 'sql01' THEN department_number
        WHEN 'sql02' THEN manager_employee_number
        ELSE NULL
    END
FROM
    Employee
WHERE
    job_code = 512101;

SELECT
    last_name (CHAR(11)),
    (date - hire_date) / 365.25 AS On_The_Job,
    (date - birthdate) / 365.25 AS AGE,
    CASE
        WHEN Age > 60
        AND On_The_Job > 20 THEN 'Gold Plan'
        WHEN Age > 55
        AND On_The_Job > 15 THEN 'Silver Plan'
        ELSE 'Bronze Plan'
    END AS Plan
WHERE
    Age > 50
    AND On_The_Job > 10
FROM
    Employee
ORDER BY
    4 DESC;

--CASE
SELECT
    SUM(
        CASE
            department_number
            WHEN 401 THEN salary_amount
            ELSE 0
        END
    ) / SUM(salary_amount)
FROM
    Employee;

--CASE with Aggregation
SELECT
    CAST (
        SUM(
            CASE
                department_number
                WHEN 401 THEN salary_amount
                ELSE 0
            END
        ) / SUM(salary_amount) AS DECIMAL(2, 2)
    ) AS Sal_Ratio
FROM
    Employee;

--Without NULLIF
SELECT
    job_code AS Job,
    hourly_billing_rate AS Rate
FROM
    Job
WHERE
    job_code < 200000;

--With NULLIF
SELECT
    job_code AS Job,
    NULLIF(hourly_billing_rate, 0) AS Rate
FROM
    Job
WHERE
    job_code < 200000;

--Using COALESCE
SELECT
    last_name,
    COALESCE(
        office_phone,
        cell_phone,
        pager_number,
        home_phone,
        fax_number,
        'No Number Found'
    ) AS Phone Number
FROM
    Phone_Table;

--Using CASE
SELECT
    last_name,
    CASE
        WHEN office_phone IS NOT NULL THEN office_phone
        WHEN cell_phone IS NOT NULL THEN cell_phone
        WHEN pager_number IS NOT NULL THEN pager_number
        WHEN home_phone IS NOT NULL THEN home_phone
        WHEN fax_number IS NOT NULL THEN fax_number
        ELSE 'No Number Found'
    END AS Phone Number
FROM
    Phone_Table;

SELECT
    last_name,
    salary_amount,
    AvgSal
FROM
    Employee e,
    (
        SELECT
            AVG(salary_amount)
        FROM
            Employee
    ) AS AvgT (AvgSal)
WHERE
    e.salary_amount > AvgT.AvgSal;

SELECT
    last_name,
    salary_amount,
    AvgSal
FROM
    Employee e
    CROSS JOIN (
        SELECT
            AVG(salary_amount) AS AvgSal
        FROM
            Employee
    ) AS AvgT
WHERE
    e.salary_amount > AvgT.AvgSal;

SELECT
    last_name,
    salary_amount,
    AvgSal
FROM
    Employee e
    JOIN (
        SELECT
            AVG(salary_amount) AS AvgSal
        FROM
            Employee
    ) AvgT ON e.salary_amount > AvgT.AvgSal;

--Complex Derived Table JOIN
SELECT
    d.department_name,
    e.last_name,
    e.salary_amount,
    AvgT.AvgSal
FROM
    Employee e
    INNER JOIN Department d ON e.department_number = d.department_number
    INNER JOIN (
        SELECT
            department_number,
            AVG(salary_amount) AS AvgSal
        FROM
            Employee
        GROUP BY
            1
    ) AS AvgT ON e.department_number = AvgT.department_number
WHERE
    e.salary_amount > AvgT.AvgSal
ORDER BY
    1;

--Including the NULL Department
SELECT
    e.department_number,
    e.last_name,
    e.salary_amount,
    AvgT.AvgSal
FROM
    Employee e
    INNER JOIN (
        SELECT
            department_number,
            AVG(salary_amount) AS AvgSal
        FROM
            Employee
        GROUP BY
            1
    ) AS AvgT
WHERE
    COALESCE(e.Department_Number, -1) = COALESCE(AvgT.department_number, -1)
    AND e.salary_amount > AvgT.AvgSal
ORDER BY
    1;

CREATE TABLE SQL01.Employee AS Employee_Sales.Employee WITH [NO] DATA;

--Create table
CREATE TABLE birthdays (
    empno INTEGER NOT NULL,
    lname CHAR(20) NOT NULL,
    fname VARCHAR(30),
    birth DATE
) UNIQUE PRIMARY INDEX (empno);

--INSERT SELECT
INSERT INTO
    birthdays
SELECT
    employee_number,
    last_name,
    first_name,
    birthdate
FROM
    Employee
WHERE
    department_number = 403;

--Task: Give everyone in all the support departments a 10% raise.
--Using a Subquery
UPDATE
    Employee
SET
    salary_amount = salary_amount * 1.10
WHERE
    department_number IN (
        SELECT
            department_number
        FROM
            Department
        WHERE
            department_name LIKE '%Support%'
    );

--Using a Correlated Subquery
UPDATE
    Employee e
SET
    salary_amount = salary_amount * 1.10
WHERE
    department_number = (
        SELECT
            department_number
        FROM
            Department d
        WHERE
            e.department_number = d.department_number
            AND department_name LIKE '%Support%'
    );

--Using a INNER JOIN
UPDATE
    Employee [ FROM Department ]
SET
    salary_amount = salary_amount * 1.10
WHERE
    Employee.department_number = Department.department_number
    AND department_name LIKE '%Support%';

--NCSSQ Inner query does not reference the outer table
SELECT
    last_name,
    salary_amount,
    department_number
FROM
    Employee
WHERE
    salary_amount > (
        SELECT
            AVG(salary_amount)
        FROM
            Employee
    )
ORDER BY
    1;

--CSSQ Inner query does reference the outer table.
SELECT
    last_name,
    salary_amount,
    department_number
FROM
    Employee e1
WHERE
    salary_amount > (
        SELECT
            AVG(salary_amount)
        FROM
            Employee e2
        WHERE
            e1.department_number = e2.department_number
    )
ORDER BY
    1;

CREATE VIEW emp_403 AS
SELECT
    employee_number,
    last_name,
    salary_amount
FROM
    Employee
WHERE
    department_number = 403;

--Direct method
CREATE VIEW emp_view (emp, dept, lname, fname, sal) AS
SELECT
    employee_number,
    department_number,
    last_name,
    first_name,
    salary_amount
FROM
    Employee
WHERE
    dept = 401;

--Using AS method
CREATE VIEW emp_view AS
SELECT
    employee_number AS Emp,
    department_number AS Dept,
    last_name AS Lname,
    first_name AS Fname,
    salary_amount AS Sal
FROM
    Employee
WHERE
    dept = 401;

CREATE VIEW emp_dept AS
SELECT
    e.employee_number,
    e.last_name,
    e.first_name,
    e.salary_amount,
    d.department_name,
    d.manager_employee_number
FROM
    Employee_Sales.employee e
    INNER JOIN Employee_Sales.Department d ON d.department_number = e.department_number;

CREATE VIEW SQLA_View AS
SELECT
    (employee_number (FORMAT '9999')) (CHAR(4)) AS Emp,
    (department_number (FORMAT '999')) (VARCHAR(3)) AS Dept,
    last_name AS Name,
    first_name,
    (salary_amount / 12 (FORMAT '$$$$,$$9.99')) (CHAR(11)) AS Mon_Salary
FROM
    Employee;

CREATE MACRO emp_401 AS (
    SELECT
        Employee_Number,
        Last_Name,
        Salary_Amount
    FROM
        Employee
    WHERE
        department_number = 401;

);

CREATE MACRO Dept_Job AS (
    SELECT
        Department_Name
    FROM
        Employee_Sales.Department
    WHERE
        Department_Number = 401;

SELECT
    Description
FROM
    Employee_Sales.Job
WHERE
    Job_Code = 412101;

);

REPLACE MACRO get_sal (empNo INTEGER) AS (
    SELECT
        employee_number,
        last_name,
        salary_amount
    FROM
        employee
    WHERE
        employee_number = :empNo;

);

CREATE
SET
    VOLATILE TABLE XYZ.vt_deptsal1,
    FALLBACK,
    CHECKSUM = DEFAULT,
    LOG (
        deptno SMALLINT,
        avgsal DECIMAL(9, 2),
        maxsal DECIMAL(9, 2),
        minsal DECIMAL(9, 2),
        sumsal DECIMAL(9, 2),
        empcnt SMALLINT
    ) PRIMARY INDEX (deptno) ON COMMIT DELETE ROWS;

CREATE
SET
    GLOBAL TEMPORARY TABLE XYZ.GT_DeptSal,
    FALLBACK,
    CHECKSUM = DEFAULT,
    LOG (
        DeptNo SMALLINT,
        AvgSal DECIMAL(9, 2),
        MaxSal DECIMAL(9, 2),
        MinSal DECIMAL(9, 2),
        SumSal DECIMAL(9, 2),
        EmpCnt SMALLINT
    ) UNIQUE PRIMARY INDEX (DeptNo) ON COMMIT DELETE ROWS;

SELECT
    Employee_Number,
    Salary_Amount,
    QUANTILE (100, salary_amount) AS Quant
FROM
    Employee
WHERE
    Department_Number = 401;

--Example of Non ANSI translation
SELECT
    Employee_Number,
    Salary_Amount,
    QUANTILE (100, salary_amount) AS Quant
FROM
    Employee
WHERE
    Department_Number = 401;

--Example of ANSI translation
SELECT
    Employee_Number,
    Salary_Amount,
    (
        RANK() OVER (
            ORDER BY
                Salary_Amount
        ) -1
    ) * 100 / COUNT(*) OVER() AS Quant
FROM
    Employee
WHERE
    Department_Number = 401;

SELECT
    SUM(sals)
FROM
    (
        SELECT
            Salary_Amount
        FROM
            Employee QUALIFY QUANTILE(100, Salary_Amount) >= 75
    ) AS temp(sals);

SELECT
    Manager_Employee_Number AS Mgr,
    Department_Number AS Dept,
    SUM(Salary_Amount) AS SumSal
FROM
    Employee
WHERE
    Department_Number < 402
GROUP BY
    ROLLUP (Manager_Employee_Number, Department_Number)
ORDER BY
    1,
    2;

SELECT
    CASE
        GROUPING (Department_Number)
        WHEN 1 THEN 'Total'
        ELSE COALESCE(Department_Number, 'Null Dept')
    END AS Deptno,
    SUM(Salary_Amount)
FROM
    Employee
GROUP BY
    ROLLUP (Department_Number)
ORDER BY
    1;

SELECT
    BirthDate,
    TRUNC(BirthDate, 'CC') (FORMAT 'yyyy-mm-dd') AS "cc1",
    TRUNC(BirthDate, 'year') (FORMAT 'yyyy-mm-dd') AS "year",
    TRUNC(BirthDate, 'month') (FORMAT 'yyyy-mm-dd') AS "month"
FROM
    Employee
WHERE
    Department_Number = 401;

SELECT
    REGEXP_REPLACE(
        'Friday is the best day',
        'day',
        'DAY EVER',
        1,
        2,
        'c'
    );

SELECT
    TO_CHAR(DATE '2003-12-23', 'DD-MON-YYYY');

SELECT
    *
FROM
    Flights
WHERE
    origin = 'LAX'
UNION
ALL
SELECT
    *
FROM
    Flights_1Stop
UNION
ALL
SELECT
    *
FROM
    Flights_2Stops;

WITH RECURSIVE All_Trips (Origin, Destination, Cost, Depth) AS (
    SELECT
        Origin,
        Destination,
        Cost,
        0
    FROM
        Flights
    WHERE
        Origin = 'LAX'
    UNION
    ALL
    SELECT
        All_Trips.Origin,
        Flights.Destination,
        All_Trips.Cost + Flights.cost,
        All_Trips.Depth + 1
    FROM
        All_Trips
        JOIN Flights ON All_Trips.Destination = Flights.Origin
        AND All_Trips.Depth < 3
)
SELECT
    *
FROM
    All_Trips
ORDER BY
    4;

REPLACE RECURSIVE VIEW All_Trips_View (Origin, Destination, Cost, Depth) AS (
    SELECT
        Origin,
        Destination,
        Cost,
        0
    FROM
        Flights
    UNION
    ALL
    SELECT
        Flights.origin,
        Flights.Destination,
        All_Trips_View.Cost + Flights.Cost,
        All_Trips_View.Depth + 1
    FROM
        All_Trips_View,
        Flights
    WHERE
        All_Trips_View.Destination = Flights.Origin
        AND All_Trips_View.Depth < 12
        AND All_Trips_View.Origin <> Flights.Destination
);

REPLACE RECURSIVE VIEW All_Trips_View (Origin, Destination, Cost, Depth) AS (
    SELECT
        Origin,
        Destination,
        Cost,
        0
    FROM
        Flights
    UNION
    ALL
    SELECT
        All_Trips_View.Origin,
        Flights.Destination,
        All_Trips_View.Cost + Flights.Cost,
        All_Trips_View.Depth + 1
    FROM
        All_Trips_View,
        Flights
    WHERE
        All_Trips_View.Destination = Flights.Origin
        AND All_Trips_View.Depth < 12
        AND All_Trips_View.Origin <> Flights.Destination
);