/********************
 * Module Data Types and Functions: Binary Data 
 ********************/

DATABASE employee_sales;


/********************
 * Byte Conversion Functions
 ********************/


-- Always returns a VARBYTE(31750) 
-- May require a typecast to avoid popping up the "LOB disposition" dialog in Studio 
SELECT
   To_Bytes('01b69b4ba630f34e', 'base16')                                                  --  01-b6-9b-4b-a6-30-f3-4e
  ,To_Bytes('0000000110110110100110110100101110100110001100001111001101001110', 'base2')   --  01-b6-9b-4b-a6-30-f3-4e
  ,To_Bytes('06664664564614171516', 'base8')                                               --  01-b6-9b-4b-a6-30-f3-4e

  ,To_Bytes('00FF', 'base16')                                                              --  00-ff
  ,To_Bytes('FF',   'base16')  -- Leading zeros added if MSB = 1                           --  00-ff
  ,To_Bytes('Hello world!', 'ascii') (VARBYTE(30))                                         --  48-65-6c-6c-6f-20-77-6f-72-6c-64-21
;

-- Always returns a VARCHAR(31750) CHARACTER SET Unicode   
-- Leading zeros always omitted
SELECT
   From_Bytes('FF'xb,       'base10')                -- '-1'
  ,From_Bytes('00FF'xb,     'base10')                -- '255'
  ,From_Bytes('FFFF'xb,     'base10')                -- '-1'
  ,From_Bytes('00FFFF'xb,   'base10')                -- '65535'
  ,From_Bytes('000000FF'xb, 'base10')                -- '65535'
  ,From_Bytes('000000FF'xb, 'base16')                -- 'FF'
  
  ,From_Bytes('01b69b4ba630f34e'xb, 'base10')        -- '123456789012345678'
  ,From_Bytes('01b69b4ba630f34e'xb, 'base8')         -- '6664664564614171516'

  ,From_Bytes('0001'xb, 'base2')                     -- '1'
  -- Add leading zeros
  ,LPad(From_Bytes('0001'xb, 'base2'), 16, '0')      -- '0000000000000001'
  ,From_Bytes('48656c6c6f20776f726c6421'xb, 'ascii') -- 'Hello world!'
;

-- Convert VARBYTE(n) to a binary string with leading zeros
SELECT
   '0001b69b4ba630f34e'xb AS in_byte
  ,Translate(Lpad ( -- From_Bytes truncates leading zeroes
                    -- without the leading zero byte a minus sign 
                    -- will be returned if MSB = 1
                    From_Bytes('00'xb || in_byte, 'base2') 
                    -- calculate the number of digits needed to display
                  , BYTES(in_byte) * 8
                    -- add back leading zeroes
                  , '0'
                  ) 
             -- No UNICODE needed, switch to LATIN to save space
             USING Unicode_to_Latin) AS byte2bin
;

-- Should be creates as a SQL_UDF
REPLACE FUNCTION byte2binary2(in_byte VARBYTE(128))
-- RETURN VarChar must be 8*in_byte 
-- No UNICODE needed, switch to LATIN to save space
RETURNS VARCHAR(1024) CHARACTER SET Latin
LANGUAGE SQL
CONTAINS SQL
DETERMINISTIC
RETURNS NULL ON NULL INPUT
SQL SECURITY DEFINER
COLLATION INVOKER
INLINE TYPE 1
RETURN
   LPad ( -- From_Bytes truncates leading zeroes
          -- without the leading byte a minus sign might be returned
          From_Bytes('00'xb || in_byte, 'base2') 
        , Bytes(in_byte) * 8 -- calculate the number of digits needed to display
        , '0' -- add leading zeroes
        ) 
;

SELECT byte2binary('0001b69b4ba630f34e'xb)
;


/********************   
 * BitAnd, BitOr, BitXOr and BitNot
 ********************/

-- All bit functions work on BYTE and integers
SELECT
   15785 AS i                         --  15,785  
  ,To_Byte(i) AS b                    --   3d-a9  
  ,LPad(From_Bytes('00'xb || b, 'base2'), 16, '0') -- 0011110110101001
  
  ,BitAnd(i, '0F0F'XB) AS i_and       --   3,337  
--  ,BitAnd(b, '00FF00FF'XB) AS b_and --   0d-09  
  ,Cast(BitAnd(b, '0F0F'XB) AS BYTE(2)) AS b_and 
  ,LPad(From_Bytes('00'xb || b_and, 'base2'), 16, '0') -- 0000110100001001
  
  ,BitOr(i, '0F0F'XB) AS i_or         --  16,303  
--  ,BitOr(b, '00FF00FF'XB) AS b_or   --   3f-af  
  ,Cast(BitOr(b, '0F0F'XB) AS BYTE(2)) AS b_or  
  ,LPad(From_Bytes('00'xb || b_or, 'base2'), 16, '0') -- 0011111110101111
  
  ,BitXOr(i, '0F0F'XB) AS i_xor       --  12,966  
--  ,BitXOr(b, '00FF00FF'XB) AS b_xor --   32-a6  
  ,Cast(BitXOr(b, '0F0F'XB) AS BYTE(2)) AS b_xor
  ,LPad(From_Bytes('00'xb || b_xor, 'base2'), 16, '0') -- 0011001010100110
  
  ,BitNot(i) AS i_not                 -- -15,786  
--  ,BitNot(b) AS b_not               --   c2-56  
  ,Cast(BitNot(b) AS BYTE(2)) AS b_not
  ,LPad(From_Bytes('00'xb || b_not, 'base2'), 16, '0') -- 1100001001010110
;  

-- BitNot = (-n-1)
SELECT
   12345678 AS n
  ,To_Byte(n)
  ,To_Byte(-n-1)      -- same result
  ,To_Byte(BitNot(n)) -- same result
;
/********************   
 * Byte − Integer Conversion
 ********************/

-- MSB set to 1 indicates negative value
SELECT
   To_Byte(-1) AS "-1"                               -- ff
  ,LPad(From_Bytes('00'xb || "-1", 'base2'), 8, '0') -- 11111111

  ,To_Byte(255) AS "255"                               -- 00-ff
  ,LPad(From_Bytes('00'xb || "255", 'base2'), 16, '0') -- 0000000011111111

  ,To_Byte(Cast(-1 AS SMALLINT)) AS "-1 smallint"              -- ff-ff
  ,LPad(From_Bytes('00'xb || "-1 smallint", 'base2'), 16, '0') -- 1111111111111111

  ,To_Byte(65535) AS "65535"                             -- 00-00-ff-ff
  ,LPad(From_Bytes('00'xb || "65535", 'base2'), 32, '0') -- 00000000000000001111111111111111

  ,To_Byte(15785) AS "15785"                             -- 3d-a9
  ,LPad(From_Bytes('00'xb || "15785", 'base2'), 16, '0') -- 0011110110101001

  ,To_Byte(16711935) AS "16711935"                          -- 00-ff-00-ff
  ,LPad(From_Bytes('00'xb || "16711935", 'base2'), 32, '0') -- 00000000111111110000000011111111

  ,To_Byte(Cast(123456789012345678 AS BIGINT)) AS "123456789012345678" --  01-b6-9b-4b-a6-30-f3-4e
  ,LPad(From_Bytes('00'xb || "123456789012345678", 'base2'), 64, '0')  -- 0000000110110110100110110100101110100110001100001111001101001110
;

SELECT
   To_Byte(-1) AS b1                                 -- 3d-a9
  ,BitOr(Cast(0 AS BYTEINT), b1)                     -- -1
  ,To_Byte(15785) AS b2                              -- 3d-a9
  ,BitOr(Cast(0 AS SMALLINT), b2)                    -- 15,785
  ,To_Byte(16711935) AS b4                           -- 00-ff-00-ff
  ,BitOr(Cast(0 AS INT), b4)                         -- 16,711,935
  ,To_Byte(Cast(123456789012345678 AS BIGINT)) AS b8 -- 01-b6-9b-4b-a6-30-f3-4e
  ,BitOr(Cast(0 AS BIGINT), b8)                      -- 123,456,789,012,345,678
;


/********************   
 * Shift and Rotate
 ********************/

SELECT
   15785 AS i                         --  15,785  
  ,To_Byte(i) AS b                    --   3d-a9 
  ,LPad(From_Bytes('00'xb || b, 'base2'), 16, '0') -- 0011110110101001

  ,ShiftLeft(i, 4) AS shift_i         --  -9,584 
--  ,shiftleft(b, 4) AS shift_b       --   da-90  
  ,Cast(ShiftLeft(b, 4) AS BYTE(2)) AS shift_b
  ,LPad(From_Bytes('00'xb || shift_b, 'base2'), 16, '0') -- 1101101010010000
  
  ,RotateLeft(i, 4) AS rot_i          --  -9,581  
--  ,rotateleft(b, 4) AS rot_b        --   da-93  
  ,Cast(RotateLeft(b, 4) AS BYTE(2)) AS rot_b
  ,LPad(From_Bytes('00'xb || rot_b, 'base2'), 16, '0') -- 1101101010010011
;  
  

SELECT
   15785 AS i                         --  15,785  
  ,To_Byte(i) AS b                    --   3d-a9  
  ,LPad(From_Bytes('00'xb || b, 'base2'), 16, '0') -- 0011110110101001
  
  ,ShiftRight(i, 4) AS shift_i        --     986  
--  ,shiftright(b, 4) AS shift_b      --   03-da  
  ,Cast(ShiftRight(b, 4) AS BYTE(2)) AS shift_b
  ,LPad(From_Bytes('00'xb || shift_b, 'base2'), 16, '0') -- 0000001111011010
    
  ,RotateRight(i, 4) AS rot_i         -- -27.686  
--  ,rotateright(b, 4) AS rot_b       --   93-da  
  ,Cast(RotateRight(b, 4) AS BYTE(2)) AS rot_b
  ,LPad(From_Bytes('00'xb || rot_b, 'base2'), 16, '0') -- 1001001111011010
;


/********************   
 * Other Bit Functions
 ********************/
SELECT
   BYTES('01b69b4ba630f34e'xb) -- 8
  ,BYTES('003da900'xbv)        -- 4
;

SELECT
   15785 AS i                -- 15,785 
  ,To_Byte(i) AS b           -- 3d-a9  
  ,LPad(From_Bytes('00'xb || b, 'base2'), 16, '0') -- 0011110110101001
   
  ,GetBit(i,0) AS GetBit0    -- 1
  ,GetBit(i,2) AS GetBit2    -- 0
  
  ,SetBit(i,2) AS SetBit2    -- 15,789
  ,To_Byte(SetBit2) AS SetBit2b -- 3d-ad  
  ,LPad(From_Bytes('00'xb || SetBit2b, 'base2'), 16, '0') -- 0011110110101101
    
  ,SetBit(i,0,0) AS SetBit0  -- 15,784
  ,To_Byte(SetBit0) AS SetBit0b -- 3d-a8  
  ,LPad(From_Bytes('00'xb || SetBit0b, 'base2'), 16, '0') -- 0011110110101000
 
  ,CountSet(b) AS count1    -- 9
  ,CountSet(b, 0) AS count0 -- 7
;

SELECT 
   15785 AS i                         --  15,785 
  ,To_Byte(i) AS b                    --   3d-a9  
  ,LPad(From_Bytes('00'xb || b, 'base2'), 16, '0') -- 0011110110101001

--  ,SubBitStr(b, 4, 4) AS sub        -- 0a
  ,Cast(SubBitStr(b, 4, 4) AS BYTE(1)) AS sub   -- 0a
--  ,SubBitStr(b, 0, 8) AS byte1      -- a9
  ,Cast(SubBitStr(b, 0, 8) AS BYTE(1)) AS byte1 -- a9
  ,Substr(b, 2, 1)  -- a9 
  ,Substring(b FROM 2 FOR 1)  -- a9 
;


-- Default database for labs
--DATABASE finance_payroll;

/********************
 * Data Types and Functions: Binary Data Lab 1
 ********************/

CREATE VOLATILE TABLE vt_ip
 ( 
   id INT NOT NULL PRIMARY KEY
  ,ip VARCHAR(18) CHARACTER SET Latin NOT NULL
  ,ip_b BYTE(4) NOT NULL
 )
ON COMMIT PRESERVE ROWS
;

INSERT INTO vt_ip VALUES(1, '127.0.0.1',          '7f000001'xb);
INSERT INTO vt_ip VALUES(2, '110.206.245.243',    '6ecef5f3'xb);
INSERT INTO vt_ip VALUES(3, '110.206.245.243/20', '6ecef5f3'xb);
INSERT INTO vt_ip VALUES(4, '192.168.1.100',      'c0a80164'xb);


/********************
 * Data Types and Functions: Binary Data Lab 1 Solution
 ********************/

SELECT
   ip
  ,To_Byte( ShiftLeft(Cast(StrTok(ip, '.',  1) AS INT), 24)
          + ShiftLeft(Cast(StrTok(ip, '.',  2) AS INT), 16)
          + ShiftLeft(Cast(StrTok(ip, '.',  3) AS INT), 8) 
          +           Cast(StrTok(ip, './', 4) AS INT)
          ) AS ip2bin
FROM vt_ip
;

SELECT
   ip_b
  ,Trim(ShiftRight(BitAnd('FF000000'xi, ip_b), 24) (FORMAT 'zz9.')) ||
   Trim(ShiftRight(BitAnd('00FF0000'xi, ip_b), 16) (FORMAT 'zz9.')) ||
   Trim(ShiftRight(BitAnd('0000FF00'xi, ip_b),  8) (FORMAT 'zz9.')) ||
   Trim(           BitAnd('000000FF'xi, ip_b)      (FORMAT 'zz9' )) AS bin2ip
FROM vt_ip
;


-- These functions should be created as a SQL_UDF
-- Convert text IP-address to binary
REPLACE FUNCTION ip2byte(ip VARCHAR(15) CHARACTER SET Latin)
RETURNS BYTE(4)
LANGUAGE SQL
CONTAINS SQL
DETERMINISTIC
RETURNS NULL ON NULL INPUT
SQL SECURITY DEFINER
COLLATION INVOKER
INLINE TYPE 1
RETURN
   To_Byte( ShiftLeft(Cast(StrTok(ip, '.',  1) AS INT), 24)
          + ShiftLeft(Cast(StrTok(ip, '.',  2) AS INT), 16)
          + ShiftLeft(Cast(StrTok(ip, '.',  3) AS INT), 8) 
          +           Cast(StrTok(ip, './', 4) AS INT)
          )
;

-- Convert binary IP-address to text
REPLACE FUNCTION byte2ip(ip_b BYTE(4))
RETURNS VARCHAR(20) CHARACTER SET Latin
LANGUAGE SQL
CONTAINS SQL
DETERMINISTIC
RETURNS NULL ON NULL INPUT
SQL SECURITY DEFINER
COLLATION INVOKER
INLINE TYPE 1
RETURN
   Trim(ShiftRight(BitAnd('FF000000'xi, ip_b), 24) (FORMAT 'zz9.')) ||
   Trim(ShiftRight(BitAnd('00FF0000'xi, ip_b), 16) (FORMAT 'zz9.')) ||
   Trim(ShiftRight(BitAnd('0000FF00'xi, ip_b),  8) (FORMAT 'zz9.')) ||
-- fails when used in UDF: Optimizer bug?
-- Trim(           BitAnd('000000FF'xi, ip_b)     (Format 'zz9')) 
   Trim(      BitAnd(Cast('000000FF'xi AS INT), ip_b)  (FORMAT 'zz9')) 
;


SELECT
   ip
  ,ip_b
  ,Cast(StrTok(ip, './', 5) AS INT) AS netmask_bits
  ,ShiftLeft( 'ffffffff'xb, 32 - netmask_bits ) (BYTE(4)) AS netmask 
  ,ShiftRight('ffffffff'xb,      netmask_bits ) (BYTE(4)) AS netmask_inv
  ,BitNot(netmask) (BYTE(4))                              AS netmask_inv2
  ,BitAnd(ip_b, netmask)    (BYTE(4)) AS network_address
  ,BitOr(ip_b, netmask_inv) (BYTE(4)) AS broadcast_address
FROM vt_ip
WHERE netmask_bits IS NOT NULL
;


