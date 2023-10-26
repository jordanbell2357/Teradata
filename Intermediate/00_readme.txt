/*********
 *** 
 *** Some preparation needed for 
 ***  - Intermediate SQL
 ***  - SQL for Business Users (5 days)
 *** 
 *** The .SQL files should be distributed to students and copied into Studio's Project Explorer directory
 *** 
 *** 
 *** Submit following statements as dbc (or any other privileged user)
 *********/


-- preparation needed for SQL class
GRANT SELECT ON finance_payroll TO TT_Access_R;

-- to allow FLUSH QUERY LOGGING WITH DEFAULT;
-- not really needed
GRANT EXECUTE ON DBC.DBQLAccessMacro TO TT_Access_R;

-- Preparing the stage tables used in the INSERT/UPDATE/DELETE & MERGE modules
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
   Operation,
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
;INSERT INTO finance_payroll.trans_staging_2
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