/********************
 * Module Typecast Functions
 ********************/

DATABASE employee_sales;


/********************
 * Data Type Conversion using CAST
 ********************/

SELECT
   Cast('127'     AS INTEGER)         -- 127
  ,Cast('127.9'   AS INTEGER)         -- 127        Truncated
  ,Cast('127.9'   AS DECIMAL(10,0))   -- 128.       Rounded
  ,Cast('127.2'   AS DECIMAL(10,2))   -- 127.20
--  ,Cast('127.2'   AS DECIMAL(4,2))    --            Error 2616 Numeric overflow occurred during computation
  ,Cast('127,2'   AS DECIMAL(10,2))   -- 1272.00    Comma = 1000 seperator
  ,Cast( 127.2    AS VARCHAR(10))     -- ' 127.2'  
  ,Cast(127.2     AS VARCHAR(2))      -- '12'       Truncated! (Teradata mode)
                                      --            Error 3996 Right truncation of string data (in ANSI mode only)
  ,Cast( 12       AS VARCHAR(3))      -- '12'
  ,Cast(''        AS INTEGER)         -- 0
  ,Cast(','       AS INTEGER)         -- 0
--  ,Cast(last_name AS INTEGER)         --            Error 2621 Bad character in format or data of employee.last_name.
;


/********************
 * Data Type Conversion using Teradata syntax
 ********************/

SELECT
   '127'    (INTEGER)          -- 127         
  ,'127.9'  (INTEGER)          -- 127        Truncated
  ,'127.9'  (DECIMAL(10,0))    -- 128.       Rounded
  ,'127.2'  (DECIMAL(10,2))    -- 127.20
--  ,'127.2'  (DECIMAL(4,2))   --            Error 2616 Numeric overflow occurred during computation
  ,'127,2'  (DECIMAL(10,2))    -- 1272.00    Comma = 1000 seperator
  , 127.2   (VARCHAR(10))      -- ' 127.2'
  , 127.2   (VARCHAR(2))       -- ' 1'       Truncated!
  , 12      (VARCHAR(3))       -- '  1'      Truncated!
  ,''       (INTEGER)          -- 0
  ,','      (INTEGER)          -- 0
--  ,last_name(INTEGER)          --            Error 2621 Bad character in format or data of employee.last_name.
;


/********************
 * TRYCAST
 ********************/

SELECT
   TryCast('127'     AS INTEGER)         -- 127
  ,TryCast('127.9'   AS INTEGER)         -- 127        Truncated
  ,TryCast('127.9'   AS DECIMAL(10,0))   -- 128.       Rounded
  ,TryCast('127.2'   AS DECIMAL(10,2))   -- 127.20
  ,TryCast('127.2'   AS DECIMAL(4,2))    -- NULL
  ,TryCast('127,2'   AS DECIMAL(10,2))   -- 1272.00    Comma = 1000 seperator
  ,TryCast(''        AS INTEGER)         -- 0
  ,TryCast(','       AS INTEGER)         -- 0
  ,TryCast(last_name AS INTEGER)         -- NULL
;


/********************
 * TO_CHAR
 ********************/

SELECT
   To_Char(127  )     -- '127'
  ,To_Char(127.9)     -- '127.9'
  ,To_Char(127.2e+02) -- '12720
  ,To_Char(-1.2345)   -- '-1.2345'
;


/********************
 * Data Type Conversion using TO_NUMBER
 ********************/

SELECT
   To_Number('127'  )     --    127
  ,To_Number('127.9')     --    127.9
  ,To_Number('127.2e+02') -- 12,720
  ,To_Number('127,2')     --   NULL
  ,To_Number(''     )     --   NULL
  ,To_Number(','    )     --   NULL
  ,To_Number(last_name)   --   NULL
;

/********************
 * TO_NUMBER and TO_CHAR: Format Examples
 ********************/
SELECT
   To_Number('$123.30')                                                               -- NULL
  ,To_Number('$123.30','L999999D99')                                                  -- 123.3
  ,To_Number('123.30€','999999D99L','NLS_CURRENCY=''€''')                             -- 123.3
  ,To_Number('€123.30','L999999D99','NLS_CURRENCY=''€''')                             -- 123.3
  ,To_Number('£123.30','U999999D99','NLS_DUAL_CURRENCY=''£''')                        -- 123.3
  ,To_Number('Dollar123','C999','NLS_ISO_CURRENCY=''Dollar''')                        -- 123
  ,To_Number('123.456,789','999G999G999G999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')  -- 123,456.789
  ,To_Number('123.456,789','999G999G999G999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')  -- 123,456.789
  
  -- may be easier to remove/change characters
  ,To_Number(oTranslate('$123.456,789', ',.$', '.'))                                  -- 123,456.789
;
  

SELECT
   To_Char(123.30,'99.99')                                                -- '######' -- value overflows mask!
  ,To_Char(123.30,'L999999D99')                                           -- '    $123.30'
  ,To_Char(123.30,'FML999999D99')                                         -- '$123.30'
  ,To_Char(123.30,'FML999999D99')                                         -- '$123.30'
  ,To_Char(123.30,'999G999G999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')   -- '         123.300'
  ,To_Char(123.30,'FM999G999G999D999', 'NLS_NUMERIC_CHARACTERS = '',.''') -- '123.300'
;



/********************
 * DateTime Type Casts
 ********************/

SET TIME ZONE -4;

SELECT
   Cast(     DATE '2022-05-15' AS TIMESTAMP(0))                            -- 2022-05-15 00:00:00          Midnight             
  ,Cast(TIMESTAMP '2022-05-15 09:56:21.71' AS DATE)                        -- 2022-05-15                   Time truncated       
  ,Cast(TIMESTAMP '2022-05-15 09:56:21.71' AS TIME(2))                     --            09:56:21.71       Date truncated       
  ,Cast(TIMESTAMP '2022-05-15 09:56:21.71' AS TIME(2) WITH TIME Zone)      --            09:56:21.71-04:00 Session time zone    
  ,Cast(TIMESTAMP '2022-05-15 09:56:21.71' AS TIMESTAMP(2) WITH TIME Zone) -- 2022-05-15 09:56:21.71-04:00 Session time zone    
  ,     TIMESTAMP '2022-05-15 09:56:21.71'       AT 0                      -- 2022-05-15 13:56:21.71+00:00 Adjusted to time zone
  ,     TIMESTAMP '2022-05-15 09:56:21.71+01:00' AT 0                      -- 2022-05-15 08:56:21.71+00:00 Adjusted to time zone
  ,     TIMESTAMP '2022-05-15 09:56:21.71+01:00' AT LOCAL                  -- 2022-05-15 04:56:21.71-04:00 Adjusted to time zone
  ,     TIMESTAMP '2022-05-15 09:56:21.71+01:00' AT 'america pacific'      -- 2022-05-15 01:56:21.71-07:00 Adjusted to time zone
  ,Cast(TIMESTAMP '2022-05-15 09:56:21.71+01:00' AS TIME(2))               --            04:56:21.71       Session time zone    
  ,Cast(TIMESTAMP '2022-05-15 09:56:21.71+01:00' AS TIMESTAMP(2))          -- 2022-05-15 04:56:21.71       Session time zone    
  ,Cast(                TIME '09:56:21.71+01:00' AS TIMESTAMP(2))          -- 2022-08-17 04:56:21.71       Current_Date added   
;


/********************
 * Data Type Conversion using TO_CHAR: DateTime
 ********************/

SELECT
   DATE '2022-08-15' AS dt                         -- '2022-08-15'
  ,To_Char(dt)                                     -- '2022/08/15'
  ,To_Char(dt, 'yyyy-mm-dd')                       -- '2022-08-15'
  ,To_Char(dt, 'MON dd yyyy')                      -- 'AUG 15 2022'
  ,To_Char(dt, 'Dy DY dy')                         -- 'Mon MON mon'
  ,To_Char(dt, 'FMDay, RM DdSP Year')              -- 'Monday, VIII Fifteen Twenty Twenty-Two' 
  ,TIMESTAMP '2022-08-15 19:56:21.71-04:00' AS ts  -- '2022-08-15 19:56:21.71-04:00'
  ,To_Char(ts)                                     -- '2022-08-15 19:56:21.71-04:00'
  ,To_Char(ts, 'HH:mi:ss AM')                      -- '07:56:21 PM'
  ,To_Char(ts, 'HH24"h"mi"m"ss"s"')                -- '19h56m21s'
  ,To_Char(ts, 'Day, MONTH dd. yyyy')              -- 'Monday   , AUGUST       15. 2022'
  ,To_Char(ts, 'FMday, Month dd. yyyy')            -- 'monday, August 15. 2022'
;


/********************
 * Data Type Conversion using TO_DATE & TO_TIMESTAMP
 ********************/

SELECT
   To_Date('2022/05/15', 'yyyy/mm/dd')             -- 2022-05-15                                                                 
  ,To_Date('MAY 15 2022', 'MON dd yyyy')           -- 2022-05-15
  ,To_Timestamp('2022-05-15 09:56:21.71')          -- 2022-05-15 09:56:21.710000
  ,To_Timestamp_TZ('2022-05-15 09:56:21.71-04:00') -- 2022-05-15 09:56:21.710000-04:00
;


/********************
 * CAST using FORMAT
 ********************/

SELECT 
   CAST('$12345.30' AS decimal(10,2))
  ,CAST('12345.30$' AS decimal(10,2) FORMAT 'GZ(I)D9(F)$')
  ,CAST('08/24/2022' AS DATE FORMAT 'MM/DD/YYYY')
  ,CAST('24 AUG 2022' AS DATE FORMAT 'DDbMMMbYYYY')
;
SELECT
   Cast(127 AS FORMAT '9(10)')                      -- still numeric
  ,Cast(Cast(127 AS FORMAT '9(10)') AS VarChar(20)) -- explicit cast
  ,Trim(Cast(127 AS FORMAT '9(10)'))                -- implicit cast
  ,Trim(Cast(12345678 AS FORMAT '9(5)'))            -- value overflows mask!
-- legacy syntax
  ,      127 (FORMAT '9(10)')                       -- still numeric 
  ,Cast((127 (FORMAT '9(10)')) AS VarChar(20))      -- explicit cast
  ,Trim(127 (FORMAT '9(10)'))                       -- implicit cast
;

