# E-Commerce Sales & Profitability Analysis

An end-to-end **Data Analyst portfolio project** exploring four years of
e-commerce transaction data (2020--2023) using **SQL Server** and
**Power BI**. The project focuses on sales performance, profitability,
discount patterns, products, customers, and geographic markets.

## Project Overview

The goal of this project is to turn raw e-commerce transaction data into
actionable business insights. SQL was used for data quality assessment,
KPI analysis, and validation. Power BI was used for data preparation,
dimensional modeling, DAX measures, and interactive dashboards.

The analysis is designed to answer questions such as:

-   How did sales and profit change over time?
-   Which customer segments, product categories, and markets contribute
    most to sales and profit?
-   How are discount levels associated with profitability?
-   Which regions have negative profit?
-   Where should the business investigate opportunities to improve
    profitability?

## Dataset

The dataset was accessed through the XómData e-commerce database. It
contains four source tables:

  ----------------------------------------------------------------------------
  Table                     Description                                   Rows
  ------------------------- --------------------- ----------------------------
  `e_commerce.ecom_sales`   Transaction-line                            51,290
                            sales data            

  `e_commerce.customer`     Customer attributes                         17,415

  `e_commerce.product`      Product, category,                          28,356
                            and subcategory       
                            attributes            

  `e_commerce.region`       Geographic and market                        3,828
                            attributes            
  ----------------------------------------------------------------------------

**Fact table grain:** one row represents one transaction line
(`row_id`), not one order. Therefore, order counts are calculated using
distinct `order_id` values.

**Analysis period:** 2020-01-01 to 2023-12-31.

> The source database was queried in read-only mode. No source records
> or database schema were modified.

## Tools & Technologies

-   **SQL Server / SSMS** --- data exploration, data quality checks, KPI
    analysis, and validation.
-   **Power BI Desktop** --- data transformation, data modeling,
    interactive reports, and visualization.
-   **Power Query** --- data preparation and handling unmatched
    dimension keys.
-   **DAX** --- calculated date table, calculated columns, and
    analytical measures.

## Project Workflow

### 1. Data Quality Assessment

The initial SQL assessment examined:

-   Row counts, date range, and key uniqueness.
-   Missing values and invalid values in important fields.
-   Referential integrity between transaction and dimension tables.
-   Potential duplicate business records.
-   Negative-profit transactions.

Important findings and treatment:

-   The sales fact table contains **51,290 transaction lines** and
    **25,728 distinct orders**.
-   Two transaction rows reference product keys that do not exist in the
    product dimension.
-   Two transaction rows reference a region key that does not exist in
    the region dimension. One row overlaps with the product-key issue.
-   Nine groups of possible duplicate business records were identified.
    They were retained because they could not be confirmed as
    duplicates.
-   Negative-profit records were retained because they are meaningful
    for profitability analysis, not automatically data errors.

### 2. KPI Analysis

Core business metrics were calculated and compared across years, months,
customer segments, discount bands, products, customer attributes,
markets, and regions.

Overall baseline metrics:

  KPI                                 Result
  --------------------------- --------------
  Total Sales                   6,517,674.00
  Total Profit                  1,065,413.58
  Profit Margin                       16.35%
  Distinct Orders                     25,728
  Distinct Customers                  17,415
  Total Units                        277,778
  Average Order Value (AOV)           253.33
  Average Discount                    14.29%

### 3. Data Preparation & Modeling

The Power BI model uses a star-schema structure:

-   `FactSales`
-   `DimCustomer`
-   `DimProduct`
-   `DimRegion`
-   `DimDate`

The fact table is related to each dimension through one-to-many
relationships, with single-direction filtering.

**Unmatched keys:** Instead of deleting affected transactions or
guessing missing dimension values, an `UNKNOWN` member was added to the
relevant dimensions in Power Query. The corresponding fact-table keys
were mapped to `UNKNOWN`. This preserves the transaction rows and makes
unmatched records visible in the report.

A dedicated date table (`DimDate`) was created and marked as the model's
date table.

### 4. Power BI Dashboard

The report contains six analytical pages and three pages for executive
insights:

  -----------------------------------------------------------------------
  Page                                Focus
  ----------------------------------- -----------------------------------
  1\. Overview                        Overall KPIs and sales/profit
                                      trends, category, segment, and
                                      market comparisons

  2\. Discount Analysis               Sales, profit, margin, and order
                                      distribution by discount band

  3\. Product Analysis                Category, subcategory, and
                                      top-product performance

  4\. Customer Analysis               Customer education, income group,
                                      gender, and occupation

  5\. Market Analysis                 Sales, profit, and profit margin by
                                      market

  6\. Region Analysis                 Sales and profit margin by
                                      geographic region

  7--9. Executive Insights            Key findings, business
                                      implications, and recommendations
  -----------------------------------------------------------------------

## Key Findings

### 1. Revenue growth did not translate into profit growth in 2023

-   Sales increased by **23.82%** in 2023 compared with 2022.
-   Profit decreased by **12.16%**.
-   Profit margin declined from **18.00%** to **12.77%**, a decrease of
    **5.23 percentage points**.

**Implication:** Revenue growth alone does not indicate improved
business performance. Profit and margin should be monitored alongside
sales.

### 2. The highest discount band is loss-making

For transaction lines with a discount above 30%:

-   Sales: **1,342,603**
-   Profit: **-295,701.40**
-   Profit margin: **-22.02%**

Profit margin decreases across the defined discount bands. This is an
observed association in the dataset; it does not by itself prove that
discounts caused the losses.

**Recommendation:** Review highly discounted transactions and identify
the products or product groups associated with negative profitability.

### 3. Europe generates more profit than Asia Pacific despite lower sales

  Market               Sales       Profit   Profit Margin
  -------------- ----------- ------------ ---------------
  Europe           1,487,444   331,644.70          22.30%
  Asia Pacific     1,831,162   228,499.59          12.48%

Europe generated approximately **103,145** more profit than Asia Pacific
despite having approximately **343,718** less sales.

**Implication:** The market with the highest sales is not necessarily
the market with the highest profit.

### 4. Body Care dominates sales

-   Body Care sales: **3,344,930**
-   Share of total sales: **51.32%**
-   Body Care profit: **563,835.65**
-   Face Care has the highest profit margin among the main product
    categories at **18.85%**.

**Recommendation:** Monitor the business's reliance on Body Care and
investigate opportunities to grow high-margin Face Care products.

### 5. Three regions have negative total profit

-   Central Asia: **-17.68%** profit margin.
-   Western Africa: **-15.56%** profit margin.
-   Western Asia: **-5.29%** profit margin.

**Recommendation:** Investigate product mix, discount patterns, and
other available regional factors before deciding on corrective actions.

## Key DAX Measures

Examples of core measures used in the report:

``` dax
Total Sales = SUM(FactSales[sales])

Total Profit = SUM(FactSales[profit])

Profit Margin = DIVIDE([Total Profit], [Total Sales], 0)

Total Orders = DISTINCTCOUNT(FactSales[order_id])

Total Customers = DISTINCTCOUNT(FactSales[customer_id])

Total Units = SUM(FactSales[quantity])

AOV = DIVIDE([Total Sales], [Total Orders], 0)

Average Discount = AVERAGE(FactSales[discount])
```

## Repository Structure

``` text
E-Commerce-Analytics/
│
├── README.md
├── SQL/
│   ├── 01_Data_Quality_Assessment.sql
│   ├── 02_KPI_Analysis.sql
│   └── 03_Data_Preparation_Validation.sql
│
├── PowerBI/
│   └── E-Commerce_Analytics.pbix


*The image files above are suggested screenshot names. Add report
screenshots to the `Images` folder and embed them in this README when
available.*

## Limitations & Considerations

-   The dataset does not provide order status, so cancellation or
    cart-abandonment analysis is outside the scope of this project.
-   The fact table is at transaction-line level. Distinct orders must be
    counted using `order_id`; order counts across discount bands may
    overlap when an order contains multiple discount levels.
-   Potential duplicate business records were retained because they were
    not confirmed duplicates.
-   Unmatched product and region keys were mapped to `UNKNOWN`; missing
    dimension attributes were not inferred.
-   The analysis identifies associations and patterns, not causal
    relationships.
-   Regional operating-cost details are not available, so the analysis
    cannot determine the underlying cause of negative regional profit.
-   The source does not establish whether the `sales` field represents
    gross or net sales; this README therefore refers to it simply as
    sales.

## How to Explore the Project

1.  Review the SQL scripts in the `SQL` folder to understand the data
    checks, KPI calculations, and validation.
2.  Open the `.pbix` file in Power BI Desktop to explore the data model,
    measures, filters, and report pages.
3.  Use the report's year and market slicers to explore changes across
    periods and geographic markets.

## Author

**Data Analyst Portfolio Project**

This project demonstrates practical skills in SQL querying, data quality
assessment, data preparation, dimensional modeling, DAX, Power BI
visualization, and business insight communication.
