/****************************************************
 Snowflake SQL Reference — Oracle Developer Cheat Sheet
 Author: Sapna
 Purpose: Key syntax differences Oracle vs Snowflake
****************************************************/

-- ============================================
-- 1. ROW LIMITING
-- ============================================
-- Oracle:
-- SELECT * FROM orders WHERE ROWNUM <= 10;

-- Snowflake:
SELECT * FROM orders LIMIT 10;


-- ============================================
-- 2. CURRENT DATE
-- ============================================
-- Oracle: SYSDATE
-- Snowflake:
SELECT CURRENT_DATE() AS today,
       CURRENT_TIMESTAMP() AS now;


-- ============================================
-- 3. DATE TRUNCATION
-- ============================================
-- Oracle: TRUNC(date, 'MM')
-- Snowflake: argument order flips!
SELECT DATE_TRUNC('month', CURRENT_DATE()) AS first_of_month,
       DATE_TRUNC('year',  CURRENT_DATE()) AS first_of_year;


-- ============================================
-- 4. DATE ARITHMETIC
-- ============================================
-- Oracle: ADD_MONTHS(date, 3)
-- Snowflake:
SELECT DATEADD(month,  3, CURRENT_DATE()) AS three_months_ahead,
       DATEADD(day,  -30, CURRENT_DATE()) AS thirty_days_ago,
       DATEDIFF(day, '2024-01-01'::DATE, CURRENT_DATE()) AS days_since_jan;


-- ============================================
-- 5. NULL HANDLING
-- ============================================
-- Oracle: NVL(col, 0)
-- Snowflake:
SELECT COALESCE(null, 'default value') AS coalesce_example,
       NULLIF(100, 100)                AS nullif_example,
       IFF(1=1, 'true', 'false')       AS iff_example;


-- ============================================
-- 6. QUALIFY — Snowflake only (replaces subquery)
-- ============================================
-- Oracle needed a subquery:
-- SELECT * FROM (SELECT *, ROW_NUMBER() OVER (...) rn FROM t) WHERE rn = 1;

-- Snowflake QUALIFY:
SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY O_CUSTKEY
    ORDER BY O_TOTALPRICE DESC
) = 1;


-- ============================================
-- 7. WINDOW FUNCTIONS
-- ============================================
SELECT O_CUSTKEY,
       O_ORDERDATE,
       O_TOTALPRICE,
       -- Running total per customer
       SUM(O_TOTALPRICE) OVER (
           PARTITION BY O_CUSTKEY
           ORDER BY O_ORDERDATE
       ) AS running_total,
       -- Previous order value
       LAG(O_TOTALPRICE, 1, 0) OVER (
           PARTITION BY O_CUSTKEY
           ORDER BY O_ORDERDATE
       ) AS prev_order_value,
       -- Rank within customer
       DENSE_RANK() OVER (
           PARTITION BY O_CUSTKEY
           ORDER BY O_TOTALPRICE DESC
       ) AS value_rank
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
ORDER BY O_CUSTKEY, O_ORDERDATE
LIMIT 50;


-- ============================================
-- 8. CTEs — identical to Oracle
-- ============================================
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', O_ORDERDATE) AS order_month,
        COUNT(*)                          AS order_count,
        SUM(O_TOTALPRICE)                 AS total_revenue
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
    GROUP BY 1
),
top_months AS (
    SELECT *
    FROM monthly_revenue
    WHERE total_revenue > 100000000
)
SELECT *
FROM top_months
ORDER BY order_month;


-- ============================================
-- 9. JOINS — ANSI only (no Oracle (+) syntax)
-- ============================================
-- Oracle old style: WHERE a.id = b.id(+) NOT supported
-- Snowflake ANSI:
SELECT o.O_ORDERKEY,
       o.O_TOTALPRICE,
       c.C_NAME
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
    ON o.O_CUSTKEY = c.C_CUSTKEY
LIMIT 20;


-- ============================================
-- 10. SNOWFLAKE ONLY FEATURES
-- ============================================

-- Time Travel: query data as it was 1 hour ago
-- SELECT * FROM my_table AT (OFFSET => -3600);

-- Zero-copy Clone: instant table copy, no storage cost
-- CREATE TABLE my_table_dev CLONE my_table;

-- Dynamic Data Masking: protect PII
-- CREATE OR REPLACE MASKING POLICY phone_mask AS
--   (val STRING) RETURNS STRING ->
--   CASE
--     WHEN CURRENT_ROLE() IN ('SYSADMIN') THEN val
--     ELSE CONCAT('***-***-', RIGHT(val, 4))
--   END;
