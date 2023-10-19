SELECT
    Last_Name AS Name,
    Salary_Amount AS Salary,
    Department_Number AS Dept,
    COUNT(Salary) OVER (
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
    ) AS Total_Count
FROM
    Employee
WHERE
    Department_Number = 401
ORDER BY
    1;

SELECT
    Last_Name AS Name,
    Salary_Amount AS Salary,
    Department_Number AS Dept,
    COUNT(*) OVER () AS Total_Count
FROM
    Employee
WHERE
    Department_Number = 401
ORDER BY
    1;

SELECT
    Last_Name AS Name,
    Salary_Amount AS Salary,
    Department_number AS Dept,
    AVG(Salary) OVER () AS GrpAvg
FROM
    Employee
WHERE
    Department_Number = 401 QUALIFY Salary > GrpAvg;

SELECT
    Last_Name AS Name,
    Salary_Amount AS Salary,
    Department_Number AS Dept,
    COUNT(Salary) OVER (PARTITION BY Dept)
FROM
    Employee
WHERE
    Department_Number IN (301, 501);

SELECT
    ItemID,
    SalesDate,
    Sales,
    SUM(Sales) OVER (
        ORDER BY
            SalesDate ROWS UNBOUNDED PRECEDING
    )
FROM
    SalesHist
WHERE
    ItemId IN (4, 6);

SELECT
    ItemID,
    SalesDate,
    Sales,
    SUM(Sales) OVER (
        ORDER BY
            SalesDate ROWS 2 PRECEDING
    )
FROM
    SalesHist
WHERE
    ItemId = 1
WHERE
    ItemId IN (4, 6);

SELECT
    ItemID,
    SalesDate,
    Sales,
    AVG(Sales) OVER (
        ORDER BY
            SalesDate ROWS BETWEEN 2 PRECEDING
            AND 1 PRECEDING
    )
FROM
    SalesHist
WHERE
    ItemId = 1
    AND SalesDate BETWEEN DATE '2008-05-24'
    AND DATE '2008-05-31';

--find the daily differences of sales from one week to the next for item 1
SELECT
    SalesDate,
    (
        (((SalesDate) - (DATE '1901-01-06')) MOD 7) + 1
    ) AS DayOfWeek,
    Sales,
    Sales - MIN(Sales) OVER (
        ORDER BY
            SalesDate ROWS BETWEEN 7 PRECEDING
            AND 7 PRECEDING
    ) AS Diff
FROM
    SalesHist
WHERE
    ItemId = 1
    AND SalesDate BETWEEN DATE '2008-05-25'
    AND DATE '2008-06-07';

SELECT
    ItemId,
    Sales,
    RANK() OVER (
        ORDER BY
            Sales ASC
    ) AS "Rank"
FROM
    SalesHist QUALIFY "Rank" < 4;

SELECT
    Last_Name,
    First_Name,
    Department_Number,
    ROW_NUMBER() OVER (
        ORDER BY
            Last_Name
    )
FROM
    Employee
WHERE
    Department_Number IN (401, 501);

SELECT
    Last_Name,
    ROW_NUMBER() OVER (
        ORDER BY
            Last_Name
    ) RANK() OVER (
        ORDER BY
            Last_Name
    )
FROM
    Employee
WHERE
    Department_Number IN (401, 302);

SEL Prod_id,
Prod,
sales,
RANK() OVER(
    ORDER BY
        sales WITH TIES LOW
) as RLow,
RANK() OVER(
    ORDER BY
        sales WITH TIES HIGH
) as RHigh,
RANK() OVER(
    ORDER BY
        sales WITH TIES DENSE
) as RDense,
RANK() OVER(
    ORDER BY
        sales WITH TIES AVG
) as RAvg
FROM
    performance
GROUP BY
    1,
    2,
    3;

SELECT
    StartDate,
    FavColor,
    FIRST_VALUE(FavColor) OVER(
        ORDER BY
            StartDate ROWS BETWEEN 2 PRECEDING
            AND 2 FOLLOWING
    )
FROM
    FvTab3
ORDER BY
    StartDate;

