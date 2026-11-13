--QUERY 2: SALES KPI ANALYSIS
USE xomdata_dataset;
GO
--2.1	Overall Business Performance - Tổng quan hiệu quả kinh doanh
SELECT
--Tổng doanh thu
    SUM(sales) AS total_sales,
--Tổng toàn bộ lợi nhuận, bao gồm cả các giao dịch có lợi nhuận âm và tính biên lợi nhuận.
    SUM(profit) AS total_profit,
    CAST(
        SUM(profit) * 100.0 / NULLIF(SUM(sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,
--Tổng số lượng sản phẩm bán ra.
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_units,
--Giá trị doanh thu trung bình trên mỗi đơn hàng
    CAST(
        SUM(sales) * 1.0 /
        NULLIF(COUNT(DISTINCT order_id), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_value,
--Tính tỷ lệ chiết khấu trung bình trên các dòng bán hàng, với giả định discount được lưu theo tỷ lệ 0–1.
    CAST(
        AVG(discount) * 100.0
        AS DECIMAL(10, 2)
    ) AS average_discount_pct
FROM e_commerce.ecom_sales;
--Nhận xét:
-- Doanh thu đạt khoảng 6.52 triệu và lợi nhuận khoảng 1.07 triệu.
-- Profit Margin đạt 16.35%, nghĩa là cứ 100 đơn vị doanh thu thì dữ liệu ghi nhận khoảng 16.35 đơn vị lợi nhuận.
-- Có 25,728 đơn hàng và 17,415 khách hàng duy nhất.
-- AOV đạt 253.33, được tính bằng tổng doanh thu chia cho số đơn hàng.
-- Discount trung bình là 14.29%. Đây là trung bình theo dòng sản phẩm trong bảng ecom_sales, chưa chắc là mức giảm giá trung bình của mỗi đơn hàng.

--2.2	Yearly Sales & Profit -	Doanh thu và lợi nhuận theo năm
SELECT
    YEAR(order_date) AS sales_year,

    -- Tổng doanh thu theo năm
    SUM(sales) AS total_sales,

    -- Tổng lợi nhuận theo năm
    SUM(profit) AS total_profit,

    -- Biên lợi nhuận theo năm (%)
    CAST(
        SUM(profit) * 100.0 / NULLIF(SUM(sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,

    -- Tổng số đơn hàng theo năm
    COUNT(DISTINCT order_id) AS total_orders,

    -- Tổng số khách hàng duy nhất theo năm
    COUNT(DISTINCT customer_id) AS total_customers,

    -- Tổng số lượng sản phẩm bán ra theo năm
    SUM(quantity) AS total_units,

    -- Giá trị đơn hàng trung bình theo năm (AOV)
    CAST(
        SUM(sales) * 1.0 /
        NULLIF(COUNT(DISTINCT order_id), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_value

FROM e_commerce.ecom_sales

GROUP BY YEAR(order_date)

ORDER BY sales_year;
--  Business Insights:
--  Phát hiện chính
--  Doanh thu năm 2023 tăng khoảng 23.9%, nhưng lợi nhuận giảm khoảng 12.2% và biên lợi nhuận giảm từ 18.00% xuống 12.77%.
--      - Câu hỏi kinh doanh cần điều tra
--      - Có phải mức chiết khấu năm 2023 tăng?
--      - Nhóm sản phẩm nào có lợi nhuận thấp?
--      - Chi phí hoặc cơ cấu sản phẩm có thay đổi không?


--2.3	Monthly Sales Trend	- Xu hướng doanh thu theo tháng
SELECT
    -- Ngày đầu tiên của mỗi tháng
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS sales_month,

    -- Tổng doanh thu theo tháng
    SUM(sales) AS total_sales,

    -- Tổng lợi nhuận theo tháng
    SUM(profit) AS total_profit,

    -- Biên lợi nhuận theo tháng (%)
    CAST(
        SUM(profit) * 100.0 / NULLIF(SUM(sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,

    -- Tổng số đơn hàng theo tháng
    COUNT(DISTINCT order_id) AS total_orders,

    -- Tổng số lượng sản phẩm bán ra theo tháng
    SUM(quantity) AS total_units

FROM e_commerce.ecom_sales
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    sales_month;
--Tổng kết:
--   Doanh thu
--      -Tháng có doanh thu cao nhất: 12/2023 — 280,918.
--      -Tháng có doanh thu thấp nhất: 02/2020 — 49,815.
--      -Doanh thu tháng 12/2023 cao hơn khoảng 5.64 lần tháng 02/2020.
--      -Tháng 11 và 12 thường có doanh thu cao; tuy nhiên cần thêm dữ liệu để xác định đây có phải tính mùa vụ ổn định hay không.
--   Lợi nhuận
--      -Lợi nhuận cao nhất: 06/2022 — 41,810.49.
--      -Trong khi đó, tháng 12/2023 có doanh thu cao nhất nhưng lợi nhuận chỉ đạt 32,383.11.
--      -Điều này cho thấy doanh thu cao không đồng nghĩa lợi nhuận cao nhất.
--   Biên lợi nhuận
--      -Cao nhất: 03/2020 — 21.40%.
--      -Thấp nhất: 02/2023 — 10.21%.
--      -Năm 2023, biên lợi nhuận ở mức thấp trong hầu hết các tháng, phù hợp với kết quả tổng hợp theo năm ở Query 2.2.
-- Business Insight: Although monthly sales increased over time, profit did not grow at the same pace. The declining profit margin throughout 2023 suggests that the business should investigate discount policies, product profitability, and changes in its sales mix


--2.4	Average Order Value (AOV) by Customer Segmen - Giá trị đơn hàng trung bình theo nhóm khách hàng
SELECT
    -- Nhóm khách hàng
    segment,

    -- Tổng doanh thu theo nhóm khách hàng
    SUM(sales) AS total_sales,

    -- Tổng lợi nhuận theo nhóm khách hàng
    SUM(profit) AS total_profit,

    -- Tổng số đơn hàng theo nhóm khách hàng
    COUNT(DISTINCT order_id) AS total_orders,

    -- Tổng số khách hàng duy nhất theo nhóm
    COUNT(DISTINCT customer_id) AS total_customers,

    -- Giá trị đơn hàng trung bình theo nhóm khách hàng
    CAST(
        SUM(sales) * 1.0 /
        NULLIF(COUNT(DISTINCT order_id), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_value,

    -- Biên lợi nhuận theo nhóm khách hàng (%)
    CAST(
        SUM(profit) * 100.0 / NULLIF(SUM(sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct

FROM e_commerce.ecom_sales
GROUP BY segment
ORDER BY total_sales DESC;

--Business Insights 
--1. Corporate is the primary revenue contributor: Corporate accounts for approximately 58.9% of total sales, with the highest AOV at 497.24.
--2. Consumer drives order volume: Consumer contributes approximately 51.7% of total orders, making it the largest segment by transaction volume.
--3. Self-Employed has the highest profit margin: Despite generating the lowest revenue, this segment achieves a 17.26% profit margin.


--2.5	Profit Margin Analysis - Phân tích biên lợi nhuận
SELECT
    -- Phân loại mức chiết khấu
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.1 THEN 'Low Discount'
        WHEN discount <= 0.2 THEN 'Medium Discount'
        WHEN discount <= 0.3 THEN 'High Discount'
        ELSE 'Very High Discount'
    END AS discount_group,

    -- Tổng doanh thu theo nhóm chiết khấu
    SUM(sales) AS total_sales,

    -- Tổng lợi nhuận theo nhóm chiết khấu
    SUM(profit) AS total_profit,

    -- Mức chiết khấu trung bình (%)
    CAST(
        AVG(discount) * 100.0
        AS DECIMAL(10, 2)
    ) AS average_discount_pct,

    -- Biên lợi nhuận theo nhóm chiết khấu (%)
    CAST(
        SUM(profit) * 100.0 / NULLIF(SUM(sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,

    -- Tổng số đơn hàng theo nhóm chiết khấu
    COUNT(DISTINCT order_id) AS total_orders,

    -- Tổng số lượng sản phẩm theo nhóm chiết khấu
    SUM(quantity) AS total_units

FROM e_commerce.ecom_sales
GROUP BY
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.1 THEN 'Low Discount'
        WHEN discount <= 0.2 THEN 'Medium Discount'
        WHEN discount <= 0.3 THEN 'High Discount'
        ELSE 'Very High Discount'
    END
ORDER BY
    MIN(discount);
--Phân tích kết quả:
    --Nhóm không chiết khấu — nhóm đóng góp lợi nhuận lớn nhất. Đặc biệt, lợi nhuận của nhóm này lớn hơn tổng lợi nhuận toàn bộ dữ liệu. Điều đó có nghĩa các nhóm chiết khấu còn lại cộng lại đang làm giảm lợi nhuận tổng thể.
    --Chiết khấu tăng — biên lợi nhuận giảm.Ta thấy một xu hướng giảm rất rõ ràng. Nhóm Very High Discount không chỉ có biên lợi nhuận thấp mà còn ghi nhận lợi nhuận âm 295,701.40.
--Đề xuất kinh doanh:
--      Rà soát các chương trình giảm giá trên 30%.
--      Kiểm tra những sản phẩm thường xuyên được bán với mức giảm giá cao.
--      Đánh giá hiệu quả chương trình khuyến mãi dựa trên lợi nhuận thay vì chỉ nhìn vào doanh thu.
--Business Insights: Discount and Profitability Analysis: The analysis revealed a strong negative relationship between discount levels and profit margins. Transactions with discounts above 30% generated a negative profit margin of -22.02%, resulting in a total loss of 295,701.40. In contrast, transactions without discounts achieved a 31.30% profit margin.

--Query 2.6 — Discount & Profitability by Year - PHÂN TÍCH CHIẾT KHẤU VÀ LỢI NHUẬN THEO NĂM
--Liệu mức chiết khấu cao có phải là một trong những yếu tố liên quan đến sự sụt giảm biên lợi nhuận trong năm 2023?

SELECT
    -- Năm bán hàng
    YEAR(order_date) AS sales_year,

    -- Phân loại mức chiết khấu
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.1 THEN 'Low Discount'
        WHEN discount <= 0.2 THEN 'Medium Discount'
        WHEN discount <= 0.3 THEN 'High Discount'
        ELSE 'Very High Discount'
    END AS discount_group,

    -- Tổng doanh thu theo năm và nhóm chiết khấu
    SUM(sales) AS total_sales,

    -- Tổng lợi nhuận theo năm và nhóm chiết khấu
    SUM(profit) AS total_profit,

    -- Mức chiết khấu trung bình (%)
    CAST(
        AVG(discount) * 100.0
        AS DECIMAL(10, 2)
    ) AS average_discount_pct,

    -- Biên lợi nhuận theo năm và nhóm chiết khấu (%)
    CAST(
        SUM(profit) * 100.0 / NULLIF(SUM(sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,

    -- Số đơn hàng duy nhất trong từng nhóm
    COUNT(DISTINCT order_id) AS total_orders

FROM e_commerce.ecom_sales
GROUP BY
    YEAR(order_date),
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.1 THEN 'Low Discount'
        WHEN discount <= 0.2 THEN 'Medium Discount'
        WHEN discount <= 0.3 THEN 'High Discount'
        ELSE 'Very High Discount'
    END
ORDER BY
    sales_year,
    MIN(discount);


--Query 2.7 — Product Category & Subcategory Analysis - PHÂN TÍCH DOANH THU VÀ LỢI NHUẬN THEO DANH MỤC SẢN PHẨM (Subcategory)
SELECT
    -- Danh mục sản phẩm
    COALESCE(p.category, 'Unknown / Unmatched') AS category,

    -- Danh mục sản phẩm cấp nhỏ hơn
    COALESCE(p.subcategory, 'Unknown / Unmatched') AS subcategory,

    -- Tổng doanh thu theo danh mục
    SUM(s.sales) AS total_sales,

    -- Tổng lợi nhuận theo danh mục
    SUM(s.profit) AS total_profit,

    -- Biên lợi nhuận theo danh mục (%)
    CAST(
        SUM(s.profit) * 100.0 / NULLIF(SUM(s.sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,

    -- Tổng số đơn hàng theo danh mục
    COUNT(DISTINCT s.order_id) AS total_orders,

    -- Tổng số lượng sản phẩm bán ra
    SUM(s.quantity) AS total_units

FROM e_commerce.ecom_sales AS s
LEFT JOIN e_commerce.product AS p
    ON s.product_code = p.product_code
GROUP BY
    p.category,
    p.subcategory
ORDER BY
    total_sales DESC;
--Nhận xét:
--  Nail care products: dẫn đầu cả doanh thu và lợi nhuận, là danh mục đóng góp quan trọng.
--  Brushes and applicators: doanh thu 378,310 nhưng biên lợi nhuận chỉ 11.73%, thấp nhất trong các danh mục có dữ liệu khớp.
--  Fragrances: biên lợi nhuận 11.90%, cũng cần được theo dõi.
--  Face moisturizing products: biên lợi nhuận đạt 18.85%, cao nhất trong các danh mục có dữ liệu khớp.
--  Unknown / Unmatched: có 2 dòng bán hàng, doanh thu 90 và lợi nhuận 45. Đây là 2 dòng không tìm thấy mã sản phẩm trong Query 1.
--Business Insights: Product Performance Analysis: Nail care products generated the highest revenue (701,065) and profit (126,939.43). However, brushes and applicators showed a relatively low profit margin of 11.73%, indicating an area that may require further investigation.


--Query 2.8 — Sales & Profit by Product Category - PHÂN TÍCH DOANH THU VÀ LỢI NHUẬN THEO DANH MỤC SẢN PHẨM (Category)
SELECT
    -- Danh mục sản phẩm
    COALESCE(p.category, 'Unknown / Unmatched') AS category, --Gán các sản phẩm không có danh mục
    -- Tổng doanh thu theo danh mục
    SUM(s.sales) AS total_sales,
    -- Tổng lợi nhuận theo danh mục
    SUM(s.profit) AS total_profit,
    -- Biên lợi nhuận theo danh mục (%)
    CAST(
        SUM(s.profit) * 100.0 / NULLIF(SUM(s.sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,

    -- Tổng số đơn hàng theo danh mục
    COUNT(DISTINCT s.order_id) AS total_orders,
    -- Tổng số lượng sản phẩm bán ra
    SUM(s.quantity) AS total_units

FROM e_commerce.ecom_sales AS s
LEFT JOIN e_commerce.product AS p
    ON s.product_code = p.product_code
GROUP BY
    p.category
ORDER BY
    total_sales DESC;
--Nhận xét: Kết quả cho thấy Body care là danh mục kinh doanh chủ lực, đóng góp hơn một nửa tổng doanh thu và lợi nhuận. Tuy nhiên, Face care mới là danh mục có biên lợi nhuận cao nhất.
--Business Insights:  Product Category Performance: Body care was the largest revenue contributor, accounting for approximately 51.3% of total sales and generating 563,835.65 in profit. Face care achieved the highest profit margin at 18.85%, while Home and Accessories recorded the lowest margin among the main categories at 13.77%.


--Query 2.9 — Customer Analysis  
-- Thống kê theo trình độ học vấn
SELECT
    education_level,
    -- Số lượng khách hàng
    COUNT(DISTINCT customer_id) AS total_customers
FROM e_commerce.customer
GROUP BY education_level
ORDER BY total_customers DESC;

-- Thống kê theo nghề nghiệp
SELECT
    -- Nghề nghiệp
    occupation,
    -- Số lượng khách hàng
    COUNT(DISTINCT customer_id) AS total_customers
FROM e_commerce.customer
GROUP BY occupation
ORDER BY total_customers DESC;

-- Thống kê theo giới tính
SELECT
    gender,
    -- Số lượng khách hàng
    COUNT(DISTINCT customer_id) AS total_customers
FROM e_commerce.customer
GROUP BY gender
ORDER BY total_customers DESC;


-- Thống kê khoảng thu nhập
WITH income_stats AS (
    SELECT
        annual_income,
        -- Tính thu nhập trung vị bằng PERCENTILE_CONT
        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY annual_income)
            OVER () AS median_income
    FROM e_commerce.customer
    WHERE annual_income IS NOT NULL
)

SELECT
    MIN(annual_income) AS min_income,
    MAX(annual_income) AS max_income,
    CAST(
        AVG(annual_income)
        AS DECIMAL(18, 2)
    ) AS average_income,
    CAST(
        MAX(median_income)
        AS DECIMAL(18, 2)
    ) AS median_income
FROM income_stats;

--2.10 PHÂN TÍCH HIỆU QUẢ KINH DOANH THEO ĐẶC ĐIỂM KHÁCH HÀNG
--— Doanh thu và lợi nhuận theo trình độ học vấn
SELECT
    c.education_level,
    SUM(s.sales) AS total_sales,
    SUM(s.profit) AS total_profit,
    -- Tỷ suất lợi nhuận trên doanh thu (%)
    CAST(
        SUM(s.profit) * 100.0 / NULLIF(SUM(s.sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,
    COUNT(DISTINCT s.order_id) AS total_orders,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    -- Giá trị đơn hàng trung bình
    CAST(
        SUM(s.sales) * 1.0 /
        NULLIF(COUNT(DISTINCT s.order_id), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_value
FROM e_commerce.ecom_sales s
INNER JOIN e_commerce.customer c
    ON s.customer_id = c.customer_id
GROUP BY c.education_level
ORDER BY total_sales DESC;
--Business Insights: Customer segmentation analysis revealed that the Bachelor's degree segment generated the highest revenue (1.85M), while customers with Graduate Degrees achieved the highest profit margin (18.37%). This highlights differences between revenue contribution and profitability across education segments.

--— Doanh thu và lợi nhuận theo nghề nghiệp
SELECT
    c.occupation,
    SUM(s.sales) AS total_sales,
    SUM(s.profit) AS total_profit,
    -- Tỷ suất lợi nhuận trên doanh thu (%)
    CAST(
        SUM(s.profit) * 100.0 / NULLIF(SUM(s.sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,

    -- Số lượng đơn hàng
    COUNT(DISTINCT s.order_id) AS total_orders,
    -- Số lượng khách hàng
    COUNT(DISTINCT s.customer_id) AS total_customers,
    -- Giá trị đơn hàng trung bình
    CAST(
        SUM(s.sales) * 1.0 /
        NULLIF(COUNT(DISTINCT s.order_id), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_value
FROM e_commerce.ecom_sales s
INNER JOIN e_commerce.customer c
    ON s.customer_id = c.customer_id
GROUP BY c.occupation
ORDER BY total_sales DESC;
--Business Insights: Customer segmentation by occupation showed that Professional customers generated the highest revenue (1.93M), while Skilled Manual customers achieved the highest profit margin (17.53%). Clerical customers recorded the highest average order value (261.09).

--DOANH THU VÀ LỢI NHUẬN THEO GIỚI TÍNH
SELECT
    -- Giới tính, giữ lại cả nhóm chưa xác định
    COALESCE(c.gender, 'Unknown') AS gender,
    SUM(s.sales) AS total_sales,
    SUM(s.profit) AS total_profit,
    -- Tỷ suất lợi nhuận trên doanh thu (%)
    CAST(
        SUM(s.profit) * 100.0 / NULLIF(SUM(s.sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,
    COUNT(DISTINCT s.order_id) AS total_orders,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    -- Giá trị đơn hàng trung bình
    CAST(
        SUM(s.sales) * 1.0 /
        NULLIF(COUNT(DISTINCT s.order_id), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_value

FROM e_commerce.ecom_sales s
LEFT JOIN e_commerce.customer c
    ON s.customer_id = c.customer_id
GROUP BY COALESCE(c.gender, 'Unknown')
ORDER BY total_sales DESC;
--Business Insights: Gender-based customer analysis showed a nearly balanced revenue contribution between female (49.9%) and male customers (49.3%). Male customers achieved a slightly higher profit margin (16.49%), while female customers recorded a higher average order value (256.22).

--DOANH THU VÀ LỢI NHUẬN THEO NHÓM THU NHẬP
SELECT
    -- Phân loại khách hàng theo thu nhập hằng năm
    CASE
        WHEN c.annual_income < 30000 THEN 'Low Income'
        WHEN c.annual_income < 60000 THEN 'Middle Income'
        WHEN c.annual_income < 90000 THEN 'Upper-Middle Income'
        WHEN c.annual_income >= 90000 THEN 'High Income'
        ELSE 'Unknown'
    END AS income_group,

 
    SUM(s.sales) AS total_sales,
    SUM(s.profit) AS total_profit,
    -- Tỷ suất lợi nhuận trên doanh thu (%)
    CAST(
        SUM(s.profit) * 100.0 / NULLIF(SUM(s.sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,
    -- Số lượng đơn hàng
    COUNT(DISTINCT s.order_id) AS total_orders,
    -- Số lượng khách hàng
    COUNT(DISTINCT s.customer_id) AS total_customers,
    -- Giá trị đơn hàng trung bình
    CAST(
        SUM(s.sales) * 1.0 /
        NULLIF(COUNT(DISTINCT s.order_id), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_value

FROM e_commerce.ecom_sales s
LEFT JOIN e_commerce.customer c
    ON s.customer_id = c.customer_id

GROUP BY
    CASE
        WHEN c.annual_income < 30000 THEN 'Low Income'
        WHEN c.annual_income < 60000 THEN 'Middle Income'
        WHEN c.annual_income < 90000 THEN 'Upper-Middle Income'
        WHEN c.annual_income >= 90000 THEN 'High Income'
        ELSE 'Unknown'
    END

ORDER BY
    CASE
        WHEN MIN(c.annual_income) IS NULL THEN 5
        ELSE MIN(c.annual_income)
    END;

--Business Insights: Income-based customer segmentation revealed that Upper-Middle Income customers generated the highest revenue (2.41M) and profit (399.96K), while Middle Income customers achieved the highest profit margin (16.58%). Interestingly, High Income customers recorded the lowest average order value (248.10), challenging the assumption that higher-income customers necessarily place higher-value orders.


--2.11.Regional Analysis - Doanh thu và lợi nhuận theo thị trường và khu vực
SELECT
    -- Thị trường
    COALESCE(r.market, 'Unknown') AS market,
    -- Khu vực
    COALESCE(r.region, 'Unknown') AS region,
    -- Tổng doanh thu
    SUM(s.sales) AS total_sales,
    -- Tổng lợi nhuận
    SUM(s.profit) AS total_profit,
    -- Tỷ suất lợi nhuận trên doanh thu (%)
    CAST(
        SUM(s.profit) * 100.0 / NULLIF(SUM(s.sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,

    -- Số lượng đơn hàng
    COUNT(DISTINCT s.order_id) AS total_orders,
    -- Số lượng khách hàng
    COUNT(DISTINCT s.customer_id) AS total_customers,

    -- Giá trị đơn hàng trung bình
    CAST(
        SUM(s.sales) * 1.0 /
        NULLIF(COUNT(DISTINCT s.order_id), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_value

FROM e_commerce.ecom_sales s
LEFT JOIN e_commerce.region r
    ON s.region_code = r.region_code

GROUP BY
    COALESCE(r.market, 'Unknown'),
    COALESCE(r.region, 'Unknown')
ORDER BY total_sales DESC;
--Business Insights: Regional analysis identified significant profitability differences across markets. Western Europe generated the highest revenue (762.86K) and profit (171.51K), while Southeastern Asia recorded a low profit margin of 1.67% despite generating 423.77K in revenue. Western Asia and Western Africa reported negative profits, highlighting potential areas for further investigation.

--Business Performance by Market - TỔNG HỢP HIỆU QUẢ KINH DOANH THEO THỊ TRƯỜNG
SELECT
    -- Thị trường
    COALESCE(r.market, 'Unknown') AS market,
    -- Tổng doanh thu
    SUM(s.sales) AS total_sales,
    -- Tổng lợi nhuận
    SUM(s.profit) AS total_profit,
    -- Tỷ suất lợi nhuận trên doanh thu (%)
    CAST(
        SUM(s.profit) * 100.0 / NULLIF(SUM(s.sales), 0)
        AS DECIMAL(10, 2)
    ) AS profit_margin_pct,

    -- Số lượng đơn hàng
    COUNT(DISTINCT s.order_id) AS total_orders,
    -- Số lượng khách hàng
    COUNT(DISTINCT s.customer_id) AS total_customers,
    -- Giá trị đơn hàng trung bình
    CAST(
        SUM(s.sales) * 1.0 /
        NULLIF(COUNT(DISTINCT s.order_id), 0)
        AS DECIMAL(18, 2)
    ) AS average_order_value

FROM e_commerce.ecom_sales s
LEFT JOIN e_commerce.region r
    ON s.region_code = r.region_code
GROUP BY COALESCE(r.market, 'Unknown')
ORDER BY total_sales DESC;
--Nhận xét: Asia Pacific có doanh thu cao nhất nhưng Europe mới là thị trường có hiệu quả lợi nhuận tốt nhất.
--Business Insights: Market-level analysis revealed that Asia Pacific generated the highest revenue (1.83M), while Europe achieved the highest profit (331.64K) and profit margin (22.30%). Despite having lower revenue, Europe generated approximately 103K more profit than Asia Pacific, highlighting differences in profitability across markets.
