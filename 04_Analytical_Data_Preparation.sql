USE xomdata_dataset;
GO

-- QUERY 4.1: KIỂM TRA DỮ LIỆU FACT SALES
SELECT
    s.row_id,
    s.order_id,
    s.order_date,
    s.customer_id,
    s.product_code,
    s.region_code,
    s.segment,

    COALESCE(c.gender, 'Unknown') AS gender,
    c.annual_income,
    c.education_level,
    c.occupation,

    COALESCE(p.product, 'Unknown / Unmatched') AS product_name,
    COALESCE(p.category, 'Unknown / Unmatched') AS category,
    COALESCE(p.subcategory, 'Unknown / Unmatched') AS subcategory,

    COALESCE(r.country, 'Unknown / Unmatched') AS country,
    COALESCE(r.region, 'Unknown / Unmatched') AS region,
    COALESCE(r.market, 'Unknown / Unmatched') AS market,

    s.quantity,
    s.sales,
    s.discount,
    s.profit

FROM e_commerce.ecom_sales AS s

LEFT JOIN e_commerce.customer AS c
    ON s.customer_id = c.customer_id

LEFT JOIN e_commerce.product AS p
    ON s.product_code = p.product_code

LEFT JOIN e_commerce.region AS r
    ON s.region_code = r.region_code;

-- QUERY 4.2.1: KIỂM TRA DIMENSION CUSTOMER
SELECT
    customer_id,
    gender,
    marital_status,
    annual_income,
    education_level,
    occupation,
    home_owner
FROM e_commerce.customer
ORDER BY customer_id;


-- QUERY 4.2.2: PHÂN NHÓM ĐỘ TUỔI KHÁCH HÀNG
SELECT
    CASE
        WHEN DATEDIFF(YEAR, birth_date, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, GETDATE()), birth_date) > GETDATE()
                   THEN 1
                   ELSE 0
               END BETWEEN 25 AND 34
            THEN '25-34'

        WHEN DATEDIFF(YEAR, birth_date, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, GETDATE()), birth_date) > GETDATE()
                   THEN 1
                   ELSE 0
               END BETWEEN 35 AND 44
            THEN '35-44'

        WHEN DATEDIFF(YEAR, birth_date, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, GETDATE()), birth_date) > GETDATE()
                   THEN 1
                   ELSE 0
               END BETWEEN 45 AND 54
            THEN '45-54'

        WHEN DATEDIFF(YEAR, birth_date, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, GETDATE()), birth_date) > GETDATE()
                   THEN 1
                   ELSE 0
               END BETWEEN 55 AND 64
            THEN '55-64'

        ELSE '65+'
    END AS age_group,

    COUNT(*) AS total_customers

FROM e_commerce.customer
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, birth_date, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, GETDATE()), birth_date) > GETDATE()
                   THEN 1
                   ELSE 0
               END BETWEEN 25 AND 34
            THEN '25-34'
        WHEN DATEDIFF(YEAR, birth_date, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, GETDATE()), birth_date) > GETDATE()
                   THEN 1
                   ELSE 0
               END BETWEEN 35 AND 44
            THEN '35-44'
        WHEN DATEDIFF(YEAR, birth_date, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, GETDATE()), birth_date) > GETDATE()
                   THEN 1
                   ELSE 0
               END BETWEEN 45 AND 54
            THEN '45-54'
        WHEN DATEDIFF(YEAR, birth_date, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, GETDATE()), birth_date) > GETDATE()
                   THEN 1
                   ELSE 0
               END BETWEEN 55 AND 64
            THEN '55-64'
        ELSE '65+'
    END
ORDER BY age_group;

-- QUERY 4.2.3: KIỂM TRA DIMENSION PRODUCT
SELECT
    product_code,
    product,
    category,
    subcategory
FROM e_commerce.product
ORDER BY product_code;

-- QUERY 4.2.4: KIỂM TRA DIMENSION REGION
SELECT
    region_code,
    city,
    state,
    country,
    region,
    market
FROM e_commerce.region
ORDER BY region_code;

-- QUERY 4.3.1: KIỂM TRA LIÊN KẾT FACT SALES VỚI CUSTOMER
SELECT
    COUNT(*) AS total_sales_rows,
    COUNT(DISTINCT s.customer_id) AS distinct_customer_ids,
    COUNT(c.customer_id) AS matched_customer_rows,
    SUM(CASE WHEN c.customer_id IS NULL THEN 1 ELSE 0 END) AS unmatched_customer_rows
FROM e_commerce.ecom_sales AS s
LEFT JOIN e_commerce.customer AS c
    ON s.customer_id = c.customer_id;

-- QUERY 4.3.2: KIỂM TRA LIÊN KẾT FACT SALES VỚI PRODUCT
SELECT
    COUNT(*) AS total_sales_rows,
    COUNT(DISTINCT s.product_code) AS distinct_product_codes,
    COUNT(p.product_code) AS matched_product_rows,
    SUM(CASE WHEN p.product_code IS NULL THEN 1 ELSE 0 END) AS unmatched_product_rows
FROM e_commerce.ecom_sales AS s
LEFT JOIN e_commerce.product AS p
    ON s.product_code = p.product_code;

-- QUERY 4.3.3: KIỂM TRA LIÊN KẾT FACT SALES VỚI REGION
SELECT
    COUNT(*) AS total_sales_rows,
    COUNT(DISTINCT s.region_code) AS distinct_region_codes,
    COUNT(r.region_code) AS matched_region_rows,
    SUM(CASE WHEN r.region_code IS NULL THEN 1 ELSE 0 END) AS unmatched_region_rows
FROM e_commerce.ecom_sales AS s
LEFT JOIN e_commerce.region AS r
    ON s.region_code = r.region_code;