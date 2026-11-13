USE xomdata_dataset;
GO
--Query 1: KIỂM TRA CHẤT LƯỢNG DỮ LIỆU
-- 1.Kiểm tra số lượng dòng
SELECT COUNT(*) AS total_rows
FROM e_commerce.ecom_sales;

-- 2.Kiểm tra ngày sớm nhất và muộn nhất
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM e_commerce.ecom_sales;

-- 3.Kiểm tra giá trị NULL trong các cột quan trọng
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN product_code IS NULL THEN 1 ELSE 0 END) AS null_product_code,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM e_commerce.ecom_sales;

-- 4.Kiểm tra số lượng đơn hàng và khách hàng
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_units
FROM e_commerce.ecom_sales;

--KIỂM TRA TRÙNG LẶP VÀ CÁC GIÁ TRỊ BẤT THƯỜNG
-- 1.Kiểm tra row_id có bị trùng không
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT row_id) AS distinct_row_ids
FROM e_commerce.ecom_sales;
-- 2.Kiểm tra giá trị số bất thường
SELECT
    SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS invalid_quantity,
    SUM(CASE WHEN sales < 0 THEN 1 ELSE 0 END) AS negative_sales,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS loss_rows,
    SUM(CASE WHEN discount < 0 OR discount > 1 THEN 1 ELSE 0 END)
        AS discount_outside_0_1
FROM e_commerce.ecom_sales;
-- 3 kiểm tra NULL trong các bảng danh mục
SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)
        AS null_customer_id
FROM e_commerce.customer;

SELECT
    SUM(CASE WHEN product_code IS NULL THEN 1 ELSE 0 END)
        AS null_product_code
FROM e_commerce.product;

SELECT
    SUM(CASE WHEN region_code IS NULL THEN 1 ELSE 0 END)
        AS null_region_code
FROM e_commerce.region;
-- 4.Kiểm tra khóa khách hàng và sản phẩm có khớp bảng danh mục không
SELECT
    SUM(CASE WHEN c.customer_id IS NULL THEN 1 ELSE 0 END)
        AS unmatched_customer_rows,
    SUM(CASE WHEN p.product_code IS NULL THEN 1 ELSE 0 END)
        AS unmatched_product_rows,
    SUM(CASE WHEN r.region_code IS NULL THEN 1 ELSE 0 END)
        AS unmatched_region_rows
FROM e_commerce.ecom_sales s
LEFT JOIN e_commerce.customer c
    ON s.customer_id = c.customer_id
LEFT JOIN e_commerce.product p
    ON s.product_code = p.product_code
LEFT JOIN e_commerce.region r
    ON s.region_code = r.region_code;
-- Có 2 dòng không tìm thấy product_code trong bảng sản phẩm và 2 dòng không tìm thấy region_code trong bảng khu vực. 
-- => Tìm và kiểm tra xem có phải lỗi dữ liệu không
-- A.Các dòng có product_code không khớp bảng product
SELECT
    s.row_id,
    s.order_id,
    s.product_code,
    s.sales,
    s.profit
FROM e_commerce.ecom_sales AS s
LEFT JOIN e_commerce.product AS p
    ON s.product_code = p.product_code
WHERE p.product_code IS NULL;

-- B.Các dòng có region_code không khớp bảng region
SELECT
    s.row_id,
    s.order_id,
    s.region_code,
    s.sales,
    s.profit
FROM e_commerce.ecom_sales AS s
LEFT JOIN e_commerce.region AS r
    ON s.region_code = r.region_code
WHERE r.region_code IS NULL;

--Kiểm tra Khóa chính của các bảng danh mục có bị trùng không
-- Kiểm tra khóa khách hàng
SELECT customer_id, COUNT(*) AS duplicate_count
FROM e_commerce.customer
GROUP BY customer_id
HAVING COUNT(*) > 1;
-- Kiểm tra khóa sản phẩm
SELECT product_code, COUNT(*) AS duplicate_count
FROM e_commerce.product
GROUP BY product_code
HAVING COUNT(*) > 1;
-- Kiểm tra khóa khu vực
SELECT region_code, COUNT(*) AS duplicate_count
FROM e_commerce.region
GROUP BY region_code
HAVING COUNT(*) > 1;

--Kiểm tra — Giá trị NULL và bất thường ở các cột chưa kiểm tra
SELECT
    SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END) AS null_row_id,
    SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS null_segment,
    SUM(CASE WHEN region_code IS NULL THEN 1 ELSE 0 END) AS null_region_code,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS null_discount,
    SUM(CASE WHEN sales <= 0 THEN 1 ELSE 0 END) AS non_positive_sales,
    SUM(CASE WHEN discount < 0 OR discount > 1 THEN 1 ELSE 0 END)
        AS invalid_discount
FROM e_commerce.ecom_sales;

--Kiểm tra — Dòng dữ liệu trùng hoàn toàn
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
HAVING COUNT(*) > 1;
--Kiểm tra chi tiết dữ liệu trùng 

SELECT
    row_id,
    order_id,
    order_date,
    customer_id,
    product_code,
    quantity,
    sales,
    discount,
    profit,
    duplicate_count
FROM (
    SELECT
        row_id,
        order_id,
        order_date,
        customer_id,
        product_code,
        quantity,
        sales,
        discount,
        profit,
        COUNT(*) OVER (
            PARTITION BY
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
        ) AS duplicate_count
    FROM e_commerce.ecom_sales
) AS t
WHERE duplicate_count > 1
ORDER BY order_id, product_code, row_id;

--Kiểm tra tổng số bản ghi nghi ngờ trùng để biết chính xác có bao nhiêu dòng dư thừa tiềm năng và ảnh hưởng tài chính nếu loại bỏ một bản ghi trong mỗi nhóm.
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
)
SELECT
    COUNT(*) AS duplicate_groups,
    SUM(duplicate_count) AS rows_in_duplicate_groups,
    SUM(duplicate_count - 1) AS potential_extra_rows,
    SUM((duplicate_count - 1) * sales) AS potential_sales_impact,
    SUM((duplicate_count - 1) * profit) AS potential_profit_impact
FROM DuplicateGroups;
--duplicate_groups: số nhóm trùng.
--rows_in_duplicate_groups: tổng số dòng thuộc các nhóm trùng.
--potential_extra_rows: số dòng dư thừa nếu mỗi nhóm chỉ giữ một dòng.
--potential_sales_impact: doanh thu có thể bị ảnh hưởng nếu loại các dòng dư thừa.
--potential_profit_impact: lợi nhuận có thể bị ảnh hưởng tương ứng

--TỔNG KẾT
-- KẾT QUẢ KIỂM TRA CHẤT LƯỢNG DỮ LIỆU:
--
-- 1. Phát hiện 11.041 dòng có lợi nhuận âm.
--    Đây có thể là các giao dịch kinh doanh bị thua lỗ,
--    không nhất thiết là lỗi dữ liệu.
--    Cần phân tích thêm để xác định nguyên nhân.
--
-- 2. Phát hiện 2 dòng có mã sản phẩm (product_code)
--    không khớp với bảng danh mục sản phẩm (product).
--
-- 3. Phát hiện 2 dòng có mã khu vực (region_code)
--    không khớp với bảng danh mục khu vực (region).
--
-- 4. Phát hiện 9 nhóm bản ghi có thông tin nghiệp vụ
--    giống nhau nhưng khác row_id.
--    - Tổng số dòng thuộc các nhóm nghi ngờ trùng: 18.
--    - Số dòng dư thừa tiềm năng: 9.
--    - Doanh thu có thể bị ảnh hưởng: 703.00.
--    - Lợi nhuận có thể bị ảnh hưởng: 270.90.
--
-- LƯU Ý:
-- Các trường hợp trên mới là kết quả phát hiện ban đầu.
-- Cần điều tra và xác minh nguyên nhân trước khi quyết định
-- sửa đổi hoặc loại bỏ dữ liệu.
--
-- Không thực hiện chỉnh sửa hoặc xóa bất kỳ dữ liệu gốc nào
-- trong quá trình kiểm tra chất lượng dữ liệu này.