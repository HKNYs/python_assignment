----SUBQUERIES----
--**************************************

-- A subquery is a query nested inside another statement such as SELECT, INSERT, UPDATE or DELETE.
-- A subquery must be enclosed in parentheses.
-- The inner query can be run by itself.
-- The subquery in a SELECT clause must return a single value.
-- The subquery in a FROM clause must be used with an alias.
-- An ORDER BY clause is not allowed to use in a subquery.(unless TOP, OFFSET or FOR XML is also specified)


-- Subquery in SELECT Statement
-- The subquery in a SELECT clause must return a single value.

SELECT  order_id, list_price,
		(
		SELECT AVG (list_price)
		FROM sale.order_item
		) AS avg_price
FROM    sale.order_item;


-- Subquery in FROM Clause
-- The subquery in a FROM clause must be used with an alias.

SELECT order_id, order_date
FROM   (
	   SELECT TOP 5 *
	   FROM sale.orders
	   ORDER BY order_date DESC
	   ) A;


-- Subquery in WHERE Clause

SELECT order_id, order_date
FROM sale.orders
WHERE order_date IN (
					 SELECT TOP 5 order_date
					 FROM sale.orders
					 ORDER BY order_date DESC
					 );

-----------------------------------------------------------------------------------

-- ****Single-Row Subqueries**** --
--**************************************

-- QUESTION: Write a query that shows all employees in the store where Davis Thomas works.
-- (Davis Thomas'ýn çalýþtýðý maðazadaki tüm personeli listeleyin)

SELECT *
FROM sale.staff
WHERE store_id = (
		SELECT store_id
		FROM sale.staff
		WHERE first_name = 'Davis' AND last_name = 'Thomas');


-- QUESTION: Write a query that shows the employees for whom Charles Cussona is a first-degree manager.(To which employees are Charles Cussona a first-degree manager?)
-- (Charles Cussona'nýn birinci derece yönetici olduðu personeli listeleyin)

SELECT *
FROM sale.staff
WHERE manager_id = (
		SELECT staff_id
		FROM sale.staff
		WHERE first_name = 'Charles' AND last_name = 'Cussona');


-- QUESTION: Write a query that returns the list of products that are more expensive than the product named 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)'.(Also show model year and list price)
-- 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)' isimli üründen pahalý olan ürünleri listeleyin.
-- Product id, product name, model_year, fiyat, marka adý ve kategori adý alanlarýna ihtiyaç duyulmaktadýr.

SELECT product_id, product_name, model_year, list_price
FROM product.product
WHERE list_price > (
		SELECT list_price
		FROM product.product
		WHERE product_name LIKE 'Pro-Series 49-Class Full HD%');
      --WHERE product_name = 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)'

-----------------------------------------------------------------------------------

-- ****Multiple-Row Subqueries**** --
--**************************************

-- They are used with multiple-row operators such as IN, NOT IN, ANY, and ALL.

-- QUESTION: Write a query that returns the first name, last name, and order date of customers who ordered on the same dates as Laurel Goldammer.
-- (Laurel Goldammer isimli müþterinin alýþveriþ yaptýðý tarihlerde alýþveriþ yapan tüm müþterilerin ad, soyad ve sipariþ tarihi bilgileri listeleyin)

SELECT a.first_name, a.last_name, b.order_date
FROM sale.customer a, sale.orders b
WHERE a.customer_id=b.customer_id
	  AND b.order_date IN(
		  SELECT order_date
		  FROM sale.customer c, sale.orders o
		  WHERE c.customer_id=o.customer_id
			  AND first_name='Laurel'
			  AND last_name='Goldammer');


SELECT a.first_name, a.last_name, b.order_date
FROM sale.customer a
INNER JOIN sale.orders b
	ON a.customer_id=b.customer_id
WHERE b.order_date IN(
		SELECT o.order_date 
		FROM sale.customer c
		INNER JOIN sale.orders o
			ON c.customer_id=o.customer_id
		WHERE c.first_name='Laurel' AND c.last_name='Goldammer')


-- QUESTION: List the products that ordered in the last 10 orders in Buffalo city.
-- (Buffalo þehrinde son 10 sipariþte sipariþ verilen ürünleri listeleyin)

SELECT DISTINCT p.product_name
FROM product.product p, sale.order_item oi
WHERE p.product_id=oi.product_id
	AND oi.order_id IN (
		SELECT TOP 10 o.order_id
		FROM sale.customer c, sale.orders o
		WHERE c.customer_id=o.customer_id
			AND city='Buffalo'
		ORDER BY o.order_date DESC)

-----------------------------------------------------------------------------------

-- ****Correlated Subqueries**** --
--**************************************

-- A correlated subquery is a subquery that uses the values of the outer query. In other words, the correlated subquery depends on the outer query for its values.
-- Because of this dependency, a correlated subquery cannot be executed independently as a simple subquery.
-- Correlated subqueries are used for row-by-row processing. Each subquery is executed once for every row of the outer query.
-- A correlated subquery is also known as repeating subquery or synchronized subquery.


SELECT product_id, product_name, p.category_id, list_price 
		--(select avg(list_price) from product.product where category_id=p.category_id)
FROM product.product p
WHERE list_price < (SELECT AVG(list_price) FROM product.product WHERE category_id=p.category_id)


SELECT product_id, product_name, p.category_id, list_price,
		(SELECT AVG(list_price) FROM product.product WHERE category_id=p.category_id)
FROM product.product p
WHERE list_price < (SELECT AVG(list_price) FROM product.product WHERE category_id=p.category_id)



-- EXISTS / NOT EXISTS

-- QUESTION: Write a query that returns a list of States where 'Apple - Pre-Owned iPad 3 - 32GB - White' product is not ordered
-- 'Apple - Pre-Owned iPad 3 - 32GB - White' isimli ürünün sipariþ verilmediði state'leri döndüren bir sorgu yazýnýz. (müþterilerin state'leri üzerinden)

SELECT DISTINCT state
FROM sale.customer x
WHERE NOT EXISTS(
	SELECT c.state
	FROM product.product p, sale.order_item oi, sale.orders o, sale.customer c
	WHERE p.product_id=oi.product_id
		AND oi.order_id=o.order_id
		AND o.customer_id=c.customer_id
		AND p.product_name='Apple - Pre-Owned iPad 3 - 32GB - White'
		AND c.state=x.state)


SELECT DISTINCT state
FROM sale.customer 
WHERE state NOT IN(
	SELECT c.state
	FROM product.product p, sale.order_item oi, sale.orders o, sale.customer c
	WHERE p.product_id=oi.product_id
		AND oi.order_id=o.order_id
		AND o.customer_id=c.customer_id
		AND p.product_name='Apple - Pre-Owned iPad 3 - 32GB - White')



-- QUESTION: Write a query that returns stock information of the products in Davi techno Retail store. 
-- The BFLO Store hasn't  got any stock of that products.

-- Davi techno maðazasýndaki ürünlerin stok bilgilerini döndüren bir sorgu yazýn. 
-- Bu ürünlerin The BFLO Store maðazasýnda stoðu bulunmuyor.

SELECT b.product_id, b.quantity
FROM sale.store a, product.stock b
WHERE a.store_id=b.store_id
		AND a.store_name='Davi techno Retail'
		AND b.quantity>0
		AND NOT EXISTS (
						SELECT *
						FROM sale.store y, product.stock x
						WHERE y.store_id=x.store_id
							AND y.store_name='The BFLO Store'
							AND x.quantity>0
							AND b.product_id=x.product_id
							)

-------------------------------------------------------------

SELECT	product_id, quantity
FROM	product.stock A
		INNER JOIN
		sale.store B
		ON	A.store_id = B.store_id
WHERE	B.store_name = 'Davi Techno Retail'
AND		a.quantity>0
AND		A.product_id NOT IN (
						SELECT	product_id
						FROM	product.stock X
								INNER JOIN
								sale.store Y
								ON	X.store_id = Y.store_id
						WHERE	Y.store_name = 'The BFLO Store'
						AND		X.quantity>0
						)

-------------------------------------------------------------

WITH CTE as
(
    SELECT store_name, product_id, quantity
    FROM product.stock A, sale.store B
    WHERE A.store_id = B.store_id
    AND store_name = 'Davi techno Retail'
), CTE2 AS (
    SELECT store_name, product_id, quantity
    FROM product.stock A, sale.store B
    WHERE A.store_id = B.store_id
    AND store_name = 'The BFLO Store'
)
SELECT *
FROM CTE cte
WHERE product_id NOT IN (SELECT product_id FROM CTE2 WHERE quantity > 0)



-- QUESTION: Write a query that creates a new column named "total_price" calculating the total prices of the products on each order.
-- order id'lere göre toplam list price larý hesaplayýn.

SELECT order_id, SUM(list_price) AS total_price
FROM sale.order_item
GROUP BY order_id
-------------------
SELECT order_id, product_id, list_price,
	(
	 SELECT SUM(list_price) 
	 FROM sale.order_item
	 WHERE order_id=oi.order_id
	 ) AS total_price
FROM sale.order_item oi;

-----------------------------------------------------------------------------------

----CTE's (Common Table Expression)----
--********************************************

-- Common Table Expression exists for the duration of a single statement. That means they are only usable inside of the query they belong to.
-- It is also called "with statement".
-- CTE is just syntax so in theory it is just a subquery. But it is more readable.
-- An ORDER BY clause is not allowed to use in a subquery.(unless TOP, OFFSET or FOR XML is also specified)
-- Each column must have a name.



-- QUESTION: List customers who have an order prior to the last order date of a customer named Jerald Berray and are residents of the city of Austin. 
-- (Jerald Berray isimli müþterinin son sipariþinden önce sipariþ vermiþ 
-- ve Austin þehrinde ikamet eden müþterileri listeleyin)


WITH CTE AS
(
	SELECT TOP 1 order_date AS last_order_date
	FROM sale.customer c, sale.orders o
	WHERE c.customer_id=o.customer_id
		AND first_name='Jerald'
		AND last_name='Berray'
	ORDER BY order_date DESC
)
SELECT c.customer_id, c.first_name, c.last_name, c.city, o.order_date
FROM sale.customer c, sale.orders o, CTE
WHERE c.customer_id=o.customer_id
	AND o.order_date < CTE.last_order_date
	AND city='Austin'
ORDER BY o.order_date ASC;

----------------------

WITH CTE (last_order_date) AS
(
	SELECT TOP 1 order_date
	FROM sale.customer c, sale.orders o
	WHERE c.customer_id=o.customer_id
		AND first_name='Jerald'
		AND last_name='Berray'
	ORDER BY order_date DESC
)
SELECT c.customer_id, c.first_name, c.last_name, c.city, o.order_date
FROM sale.customer c, sale.orders o, CTE
WHERE c.customer_id=o.customer_id
	AND o.order_date < CTE.last_order_date
	AND city='Austin'
ORDER BY o.order_date ASC;

-------------------------

WITH t1 AS
(
	SELECT MAX(order_date) AS last_order_date
	FROM sale.customer c
	INNER JOIN sale.orders o
		ON c.customer_id=o.customer_id
	WHERE c.first_name='Jerald' and last_name='Berray'
)
SELECT a.customer_id, a.first_name, a.last_name, a.city, b.order_date
FROM sale.customer a, sale.orders b, t1
WHERE a.customer_id=b.customer_id
	and b.order_date < t1.last_order_date
	and a.city='AUSTÝN'



-- QUESTION: List all customers their orders are on the same dates with Laurel Goldammer.
-- Laurel Goldammer isimli müþterinin alýþveriþ yaptýðý tarihte/tarihlerde alýþveriþ yapan tüm müþterileri listeleyin.
-- Müþteri adý, soyadý ve sipariþ tarihi bilgilerini listeleyin.

WITH T1 AS
	(
		SELECT order_date 
		FROM sale.customer c, sale.orders o
		WHERE c.customer_id=o.customer_id
			AND first_name='Laurel'
			AND last_name='Goldammer'
	)
SELECT c.first_name, c.last_name, o.order_date
FROM sale.customer c, sale.orders o, T1
WHERE c.customer_id=o.customer_id
	AND o.order_date = T1.order_date



-- QUESTION: List the stores whose turnovers are under the average store turnovers in 2018.
-- (2018 yýlýnda tüm maðazalarýn ortalama cirosunun altýnda ciroya sahip maðazalarý listeleyin)

WITH TotalTurnover AS
	(
		SELECT s.store_name ,SUM(list_price * quantity * (1-discount)) AS turnover
		FROM sale.order_item oi, sale.orders o, sale.store s
		WHERE oi.order_id=o.order_id
			AND o.store_id=s.store_id
			--AND YEAR(o.order_date) = 2018
		GROUP BY store_name
	),
AvgTurnover AS
	(
		SELECT AVG(turnover) AS avg_turnover
		FROM TotalTurnover
	)
SELECT *
FROM TotalTurnover, AvgTurnover
WHERE TotalTurnover.turnover < AvgTurnover.avg_turnover


-- QUESTION: Write a query that returns the net amount of their first order for customers who placed their first order after 2019-10-01.
-- (Ýlk sipariþini 2019-10-01 tarihinden sonra veren müþterilerin ilk sipariþlerinin net tutarýný döndürünüz)

;WITH cte AS
	(
		SELECT customer_id, MIN(order_id) min_orders
		FROM sale.orders
		GROUP BY customer_id
	)
SELECT o.customer_id, o.order_id, SUM(quantity* list_price* (1-discount)) net_amount
FROM sale.order_item oi, sale.orders o, cte
WHERE oi.order_id=o.order_id
	AND o.order_date > '2019-10-01'
	AND o.order_id=min_orders
GROUP BY o.customer_id, o.order_id