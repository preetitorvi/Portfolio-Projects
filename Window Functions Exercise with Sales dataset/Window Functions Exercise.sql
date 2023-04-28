-- Exercise to understand the WIndow Functions

SELECT *
FROM PRODUCTS

SELECT *
FROM ORDERS

SELECT *
FROM ORDER_ITEMS 


-- Understanding Group by vs Partition by
/*
However, while the result of a GROUP BY aggregates all rows,
the result of a window function using PARTITION BY aggregates each partition independently.
Without the PARTITION BY clause, the result set is one single partition.
*/ 

-- group by
-- aggregates the data and combines into a single row

SELECT MODEL_YEAR,
	AVG(LIST_PRICE)
FROM PRODUCTS
GROUP BY MODEL_YEAR 


-- partition by
-- doesn't aggregate the data to form one row but gives the avg across multiple rows

SELECT MODEL_YEAR, 
	PRODUCT_NAME, 
	LIST_PRICE, 
	AVG(LIST_PRICE) OVER (PARTITION BY MODEL_YEAR) AVG_PRICE
FROM PRODUCTS 
ORDER BY PRODUCT_NAME 


/* Window Frame Extent
A window frame is the selected set of rows in the partition over which aggregation will occur.
Put simply, they are a set of rows that are somehow related to the current row.
if we only want to get 5 rows before the current row, then we will specify the range using 5 PRECEDING
if we only want to get 5 rows after the current row, then we will specify the range using 5 FOLLOWING
*/ 


-- Ranking Functions
--ROW_NUMBER()
--Assigns a sequential integer to each row within the partition of a result set.
 
 
 --  /* Rank all products by price */

SELECT PRODUCT_NAME,
	LIST_PRICE,
	ROW_NUMBER() OVER (ORDER BY LIST_PRICE) AS ROW_NUM,
	RANK() OVER(ORDER BY LIST_PRICE) AS RANK_NUM,
	DENSE_RANK() OVER(ORDER BY LIST_PRICE) AS DENSE_NUM,
	PERCENT_RANK() OVER (ORDER BY LIST_PRICE) AS PCT_RANK_NUM,
	NTILE(10) OVER(ORDER BY LIST_PRICE) AS NTILE_NUM,
	CUME_DIST() OVER(ORDER BY LIST_PRICE) AS CUME_DIS
FROM PRODUCTS 

/*Value window functions
FIRST_VALUE() and LAST_VALUE() retrieve the first and last value respectively from an ordered
list of rows, where the order is defined by ORDER BY.*/ 

/* Find the difference in price from the cheapest alternative */
SELECT PRODUCT_NAME,
	LIST_PRICE,
	FIRST_VALUE(LIST_PRICE) OVER (ORDER BY LIST_PRICE 
								  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS CHEAPEST_PRICE
FROM PRODUCTS 


/* Find the difference in price from the priciest alternative */
SELECT PRODUCT_NAME,
	LIST_PRICE,
	LAST_VALUE(LIST_PRICE) OVER (ORDER BY LIST_PRICE 
								 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS CHEAPEST_PRICE
FROM PRODUCTS 


/* Find the difference in price from the nth alternative */
SELECT PRODUCT_NAME,
	LIST_PRICE,
	NTH_VALUE(LIST_PRICE,
		10) OVER (ORDER BY LIST_PRICE 
				  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS CHEAPEST_PRICE
FROM PRODUCTS 



--Aggregate window functions
SELECT ORDER_ID,
	PRODUCT_ID,
	DISCOUNT,
	AVG(DISCOUNT) OVER (PARTITION BY PRODUCT_ID) AS AVG_DISCOUNT,
	MIN(DISCOUNT) OVER (PARTITION BY PRODUCT_ID) AS MIN_DISCOUNT,
	MAX(DISCOUNT) OVER (PARTITION BY PRODUCT_ID) AS MAX_DISCOUNT
FROM ORDER_ITEMS
WHERE PRODUCT_ID = 184 --using group by

SELECT PRODUCT_ID,
	AVG(DISCOUNT),
	MIN(DISCOUNT),
	MAX(DISCOUNT)
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID --184 0.1625000024214387 0.05 0.2


/*LEAD, LAG
The LEAD and LAG locate a row relative to the current row.

*/ -- Compare this years sales with last years
WITH YEARLY_ORDERS AS
	(SELECT EXTRACT(YEARFROM ORDER_DATE) AS SALES_YEAR,
			COUNT(DISTINCT ORDER_ID) AS SALES
		FROM ORDERS
		GROUP BY SALES_YEAR)
SELECT *,
	LAG(SALES) OVER (ORDER BY SALES_YEAR) LAST_YEAR_SALES,
	LAG(SALES) OVER (ORDER BY SALES_YEAR) - SALES DIFF_FROM_LAST_YEAR
FROM YEARLY_ORDERS 


-- Compare this years sales with next years
WITH YEARLY_ORDERS AS
	(SELECT EXTRACT(YEARFROM ORDER_DATE) AS SALES_YEAR,
			COUNT(DISTINCT ORDER_ID) AS SALES
		FROM ORDERS
		GROUP BY SALES_YEAR)
SELECT *,
	LEAD(SALES) OVER (ORDER BY SALES_YEAR) NEXT_YEAR_SALES,
	LEAD(SALES) OVER (ORDER BY SALES_YEAR) - SALES DIFF_FROM_LAST_YEAR
FROM YEARLY_ORDERS