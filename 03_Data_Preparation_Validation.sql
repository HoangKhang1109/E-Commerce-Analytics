-- QUERY 3: DATA PREPARATION & VALIDATION
--Từ Query 1, chúng ta đã phát hiện:
-- 2 giao dịch có product_code không khớp.
-- 2 giao dịch có region_code không khớp.
-- 9 nhóm bản ghi có dấu hiệu trùng, tổng cộng 18 dòng.
-- 11.041 giao dịch có lợi nhuận âm nhưng đây không mặc định là lỗi dữ liệu.
-- 124 khách hàng có giới tính NULL.
USE xomdata_dataset;
GO
-- 3.1 KIỂM TRA CẤU TRÚC CÁC BẢNG

SELECT
    TABLE_SCHEMA AS table_schema,
    TABLE_NAME AS table_name,
    ORDINAL_POSITION AS column_position,
    COLUMN_NAME AS column_name,
    DATA_TYPE AS data_type,
    CHARACTER_MAXIMUM_LENGTH AS max_length,
    NUMERIC_PRECISION AS numeric_precision,
    NUMERIC_SCALE AS numeric_scale,
    IS_NULLABLE AS is_nullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'e_commerce'
    AND TABLE_NAME IN (
        'ecom_sales',
        'customer',
        'product',
        'region'
    )
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;

    -- 3.1.1 KIỂM TRA KHÓA CHÍNH BẢNG CUSTOMER
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_ids
FROM e_commerce.customer;


-- 3.1.2 KIỂM TRA KHÓA CHÍNH BẢNG PRODUCT
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_code) AS unique_product_codes,
    SUM(CASE WHEN product_code IS NULL THEN 1 ELSE 0 END) AS null_product_codes
FROM e_commerce.product;


-- 3.1.3 KIỂM TRA KHÓA CHÍNH BẢNG REGION
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT region_code) AS unique_region_codes,
    SUM(CASE WHEN region_code IS NULL THEN 1 ELSE 0 END) AS null_region_codes
FROM e_commerce.region;


-- 3.1.4 KIỂM TRA KHÓA LIÊN KẾT BẢNG SALES
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)
        AS null_customer_ids,

    SUM(CASE WHEN product_code IS NULL THEN 1 ELSE 0 END)
        AS null_product_codes,

    SUM(CASE WHEN region_code IS NULL THEN 1 ELSE 0 END)
        AS null_region_codes
FROM e_commerce.ecom_sales;
--Kết quá: Không phát hiện khóa chính bị NULL hoặc trùng lặp, cũng không có khóa liên kết NULL trong bảng giao dịch.

-- 3.2 KIỂM TRA DỮ LIỆU KHÔNG KHỚP GIỮA CÁC BẢNG
-- 3.2.1 TÌM GIAO DỊCH CÓ PRODUCT_CODE KHÔNG TỒN TẠI TRONG BẢNG PRODUCT
SELECT
    -- Mã dòng giao dịch
    s.row_id,
    -- Mã đơn hàng
    s.order_id,
    -- Ngày đặt hàng
    s.order_date,
    -- Mã sản phẩm không khớp
    s.product_code,
    -- Số lượng sản phẩm
    s.quantity,
    -- Doanh thu
    s.sales,
    -- Lợi nhuận
    s.profit

FROM e_commerce.ecom_sales s
LEFT JOIN e_commerce.product p
    ON s.product_code = p.product_code
WHERE p.product_code IS NULL
ORDER BY s.row_id;
--Kết quả: có giao dịch không tìm thấy sản phẩm tương ứng trong bảng e_commerce.product
--Cách xử lý: Chưa xóa hai giao dịch này và không tự ý sửa product_code, vì chưa có dữ liệu xác nhận mã sản phẩm đúng. Khi phân tích sản phẩm, ta có thể gom chúng vào nhóm Unknown / Unmatched bằng LEFT JOIN và CASE WHEN.

-- 3.2.2 TÌM GIAO DỊCH CÓ REGION_CODE KHÔNG TỒN TẠI TRONG BẢNG REGION
SELECT
    s.row_id,
    s.order_id,
    s.order_date,
    s.region_code,
    s.sales,
    s.profit
FROM e_commerce.ecom_sales s
LEFT JOIN e_commerce.region r
    ON s.region_code = r.region_code
WHERE r.region_code IS NULL
ORDER BY s.row_id;
--Nhận xét: có đúng 2 giao dịch sử dụng region_code = RRR0001 nhưng mã này không tồn tại trong bảng e_commerce.region.
--Note: giao dịch có row_id = 25220 đồng thời không khớp cả Product và Region. Đây là cùng một dòng dữ liệu, không phải hai giao dịch khác nhau.
--Cách xử lý: Giữ nguyên dữ liệu gốc, không tự suy đoán mã Region thay thế. Khi phân tích theo khu vực, có thể đưa các dòng này vào nhóm Unknown / Unmatched.


--Query 3.2.3 – Kiểm tra Customer không khớp
SELECT
    s.row_id,
    s.order_id,
    s.order_date,
    s.customer_id,
    s.sales,
    s.profit
FROM e_commerce.ecom_sales s
LEFT JOIN e_commerce.customer c
    ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL
ORDER BY s.row_id;
--Nhận xét: Không tìm thấy Null


--Query 3.3 – Kiểm tra ngày giao dịch
--Query 3.3.1 KIỂM TRA NGÀY GIAO DỊCH BỊ NULL HOẶC NẰM NGOÀI KHOẢNG 2020-2023
SELECT
    row_id,
    order_id,
    order_date,
    sales,
    profit
FROM e_commerce.ecom_sales
WHERE order_date IS NULL
   OR order_date < '20200101'
   OR order_date >= '20240101'
ORDER BY order_date;

--Query 3.3.2 – Kiểm tra tính hợp lệ của dữ liệu số
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS invalid_quantity,

    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN sales < 0 THEN 1 ELSE 0 END) AS negative_sales,

    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS null_discount,
    SUM(CASE WHEN discount < 0 OR discount > 1 THEN 1 ELSE 0 END) AS invalid_discount,

    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM e_commerce.ecom_sales;

-- 3.4.1 KIỂM TRA CÁC NHÓM GIAO DỊCH CÓ DẤU HIỆU TRÙNG LẶP
SELECT
    order_id,
    order_date,
    customer_id,
    segment,
    region_code,
    product_code,
    quantity,
    sales,
    discount,
    profit,
    COUNT(*) AS duplicate_count
FROM e_commerce.ecom_sales
GROUP BY
    order_id,
    order_date,
    customer_id,
    segment,
    region_code,
    product_code,
    quantity,
    sales,
    discount,
    profit
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, order_id;
--Nhận xét: Phát hiện 9 nhóm giao dịch trùng thông tin nghiệp vụ, mỗi nhóm xuất hiện 2 lần. Đây là vấn đề chất lượng dữ liệu cần được xác minh với nguồn dữ liệu. Giữ nguyên dữ liệu gốc và không tự ý loại bỏ.

--Query 3.4.2 – Xem chi tiết các dòng nghi trùng
WITH DuplicateGroups AS (
    SELECT
        order_id,
        order_date,
        customer_id,
        segment,
        region_code,
        product_code,
        quantity,
        sales,
        discount,
        profit
    FROM e_commerce.ecom_sales
    GROUP BY
        order_id,
        order_date,
        customer_id,
        segment,
        region_code,
        product_code,
        quantity,
        sales,
        discount,
        profit
    HAVING COUNT(*) > 1
)
SELECT
    s.row_id,
    s.order_id,
    s.order_date,
    s.customer_id,
    s.product_code,
    s.quantity,
    s.sales,
    s.discount,
    s.profit
FROM e_commerce.ecom_sales s
INNER JOIN DuplicateGroups d
    ON s.order_id = d.order_id
    AND s.order_date = d.order_date
    AND s.customer_id = d.customer_id
    AND s.segment = d.segment
    AND s.region_code = d.region_code
    AND s.product_code = d.product_code
    AND s.quantity = d.quantity
    AND s.sales = d.sales
    AND s.discount = d.discount
    AND s.profit = d.profit
ORDER BY
    s.order_id,
    s.row_id;
--Kết luận xử lý: Ghi nhận 9 nhóm potential duplicates, Không xóa 9 dòng dư giả định, Giữ nguyên 51.290 dòng dữ liệu gốc, Đưa vấn đề này vào phần Data Quality của báo cáo dự án.

--Query 3.5 – Kiểm tra tính nhất quán giữa các bảng
--Query 3.5.1 – Kiểm tra thông tin NULL trong bảng Customer.
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN first_name IS NULL THEN 1 ELSE 0 END) AS null_first_name,
    SUM(CASE WHEN last_name IS NULL THEN 1 ELSE 0 END) AS null_last_name,
    SUM(CASE WHEN birth_date IS NULL THEN 1 ELSE 0 END) AS null_birth_date,
    SUM(CASE WHEN marital_status IS NULL THEN 1 ELSE 0 END) AS null_marital_status,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN email_address IS NULL THEN 1 ELSE 0 END) AS null_email,
    SUM(CASE WHEN annual_income IS NULL THEN 1 ELSE 0 END) AS null_annual_income,
    SUM(CASE WHEN education_level IS NULL THEN 1 ELSE 0 END) AS null_education,
    SUM(CASE WHEN occupation IS NULL THEN 1 ELSE 0 END) AS null_occupation,
    SUM(CASE WHEN home_owner IS NULL THEN 1 ELSE 0 END) AS null_home_owner
FROM e_commerce.customer;
--Nhận xét: Trong tổng số 17.415 khách hàng, có 124 khách hàng chưa xác định giới tính, tương đương khoảng 0,71%.
--Cách xử lý đề xuất: Không xóa 124 khách hàng, Khi phân tích, sử dụng nhóm Unknown thay cho NULL,  Giữ nguyên dữ liệu gốc trong SQL Server.

--Query 3.5.2 – Kiểm tra thông tin Product
SELECT
    COUNT(*) AS total_products,

    SUM(CASE WHEN product IS NULL THEN 1 ELSE 0 END) AS null_product_name,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN subcategory IS NULL THEN 1 ELSE 0 END) AS null_subcategory
FROM e_commerce.product;

--Query 3.5.3 – Kiểm tra thông tin Region
SELECT
    COUNT(*) AS total_regions,

    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country,

    SUM(CASE WHEN country_latitude IS NULL THEN 1 ELSE 0 END) AS null_latitude,
    SUM(CASE WHEN country_longitude IS NULL THEN 1 ELSE 0 END) AS null_longitude,

    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN market IS NULL THEN 1 ELSE 0 END) AS null_market
FROM e_commerce.region;

--Query 3.6 – Kiểm tra tính hợp lý của dữ liệu khách hàng
-- 3.6.1 KIỂM TRA NGÀY SINH KHÁCH HÀNG
SELECT
    customer_id,
    birth_date,
    DATEDIFF(YEAR, birth_date, GETDATE())
        - CASE
            WHEN DATEADD(
                YEAR,
                DATEDIFF(YEAR, birth_date, GETDATE()),
                birth_date
            ) > GETDATE()
            THEN 1
            ELSE 0
          END AS customer_age
FROM e_commerce.customer
WHERE birth_date > CAST(GETDATE() AS DATE)
   OR birth_date < '19000101'
ORDER BY birth_date;

-- 3.6.2 THỐNG KÊ PHÂN BỐ ĐỘ TUỔI KHÁCH HÀNG
WITH CustomerAge AS (
    SELECT
        customer_id,

        -- Tính tuổi khách hàng và điều chỉnh nếu chưa đến sinh nhật trong năm hiện tại
        DATEDIFF(YEAR, birth_date, GETDATE())
        - CASE
            WHEN DATEADD(
                YEAR,
                DATEDIFF(YEAR, birth_date, GETDATE()),
                birth_date
            ) > GETDATE()
            THEN 1
            ELSE 0
          END AS customer_age
    FROM e_commerce.customer
    WHERE birth_date IS NOT NULL
),
AgeMedian AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY customer_age)
        OVER () AS median_age
    FROM CustomerAge
),
AgeSummary AS (
    SELECT
        COUNT(*) AS total_customers,
        MIN(customer_age) AS min_age,
        MAX(customer_age) AS max_age,

        -- Tính tuổi trung bình của khách hàng
        CAST(AVG(CAST(customer_age AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_age
    FROM CustomerAge
)
SELECT
    s.total_customers,
    s.min_age,
    s.max_age,
    s.avg_age,

    -- Chuyển tuổi trung vị sang kiểu số thập phân để hiển thị thống nhất
    CAST(m.median_age AS DECIMAL(10,2)) AS median_age
FROM AgeSummary s
CROSS JOIN AgeMedian m;

--Query 3.6.3 – Phân nhóm khách hàng theo độ tuổi
WITH CustomerAge AS (
    SELECT
        customer_id,

        -- Tính tuổi khách hàng và điều chỉnh nếu chưa đến sinh nhật trong năm hiện tại
        DATEDIFF(YEAR, birth_date, GETDATE())
        - CASE
            WHEN DATEADD(
                YEAR,
                DATEDIFF(YEAR, birth_date, GETDATE()),
                birth_date
            ) > GETDATE()
            THEN 1
            ELSE 0
          END AS customer_age
    FROM e_commerce.customer
    WHERE birth_date IS NOT NULL
),
AgeGroup AS (
    SELECT
        customer_id,
        customer_age,
        CASE
            WHEN customer_age BETWEEN 25 AND 34 THEN '25-34'
            WHEN customer_age BETWEEN 35 AND 44 THEN '35-44'
            WHEN customer_age BETWEEN 45 AND 54 THEN '45-54'
            WHEN customer_age BETWEEN 55 AND 64 THEN '55-64'
            WHEN customer_age >= 65 THEN '65+'
            ELSE 'Unknown'
        END AS age_group
    FROM CustomerAge
)
SELECT
    age_group,
    COUNT(*) AS total_customers,

    -- Tính tỷ trọng khách hàng trong từng nhóm tuổi
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS customer_percentage
FROM AgeGroup
GROUP BY age_group
ORDER BY
    CASE age_group
        WHEN '25-34' THEN 1
        WHEN '35-44' THEN 2
        WHEN '45-54' THEN 3
        WHEN '55-64' THEN 4
        WHEN '65+' THEN 5
        ELSE 6
    END;

--Query 3.7 – Kiểm tra giá trị phân loại
-- 3.7.1 KIỂM TRA CÁC GIÁ TRỊ PHÂN LOẠI TRONG CỘT GENDER
SELECT
    COALESCE(gender, 'Unknown') AS gender,
    COUNT(*) AS total_customers
FROM e_commerce.customer
GROUP BY gender
ORDER BY total_customers DESC;
--Kết quả:Có 124 khách hàng chưa xác định giới tính.
--Cách xử lý: Giữ nguyên M, F; chuyển NULL thành Unknown khi hiển thị báo cáo. Không tự suy đoán giới tính.

-- 3.7.2 KIỂM TRA CÁC GIÁ TRỊ PHÂN LOẠI TRONG CỘT MARITAL_STATUS
SELECT
    COALESCE(marital_status, 'Unknown') AS marital_status,
    COUNT(*) AS total_customers
FROM e_commerce.customer
GROUP BY marital_status
ORDER BY total_customers DESC;


-- 3.7.3 KIỂM TRA CÁC GIÁ TRỊ PHÂN LOẠI TRONG CỘT EDUCATION_LEVEL
SELECT
    education_level,
    COUNT(*) AS total_customers
FROM e_commerce.customer
GROUP BY education_level
ORDER BY total_customers DESC;

-- 3.7.4 KIỂM TRA CÁC GIÁ TRỊ PHÂN LOẠI TRONG CỘT OCCUPATION
SELECT
    occupation,
    COUNT(*) AS total_customers
FROM e_commerce.customer
GROUP BY occupation
ORDER BY total_customers DESC;

-- 3.7.5 KIỂM TRA CÁC GIÁ TRỊ PHÂN LOẠI TRONG CỘT HOME_OWNER
SELECT
    COALESCE(home_owner, 'Unknown') AS home_owner,
    COUNT(*) AS total_customers
FROM e_commerce.customer
GROUP BY home_owner
ORDER BY total_customers DESC;

-- 3.7.6 KIỂM TRA CÁC GIÁ TRỊ PHÂN LOẠI TRONG CỘT SEGMENT
SELECT
    COALESCE(segment, 'Unknown') AS segment,
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS total_orders
FROM e_commerce.ecom_sales
GROUP BY segment
ORDER BY total_records DESC;

-- 3.7.7 KIỂM TRA CÁC GIÁ TRỊ PHÂN LOẠI TRONG CỘT CATEGORY
SELECT
    COALESCE(category, 'Unknown') AS category,
    COUNT(*) AS total_products,
    COUNT(DISTINCT subcategory) AS total_subcategories
FROM e_commerce.product
GROUP BY category
ORDER BY total_products DESC;

-- 3.7.8 KIỂM TRA CÁC GIÁ TRỊ PHÂN LOẠI TRONG CỘT SUBCATEGORY
SELECT
    category,
    subcategory,
    COUNT(*) AS total_products
FROM e_commerce.product
GROUP BY
    category,
    subcategory
ORDER BY
    category,
    total_products DESC;


-- 3.7.9 KIỂM TRA CÁC GIÁ TRỊ PHÂN LOẠI TRONG BẢNG REGION
SELECT
    region,
    market,
    COUNT(*) AS total_locations,
    COUNT(DISTINCT country) AS total_countries
FROM e_commerce.region
GROUP BY
    region,
    market
ORDER BY
    market,
    region;