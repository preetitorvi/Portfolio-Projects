-- TABLE 1

SELECT *
FROM artist -- Consists of artist_id Artist Names,
 -- nationality, style, birth and death

SELECT count(*)
FROM artist -- Number of records 421

SELECT DISTINCT nationality
FROM artist -- 18 distinct nationalities

SELECT DISTINCT style
FROM artist -- 35 distinct styles
 WITH artist_age AS
	(SELECT full_name,
			death,
			birth,
			death - birth AS age
		FROM artist) -- Calculate artist age to know average life span

SELECT cast(avg(age) AS int)
FROM artist_age -- Average age is 66

SELECT nationality,
	count(full_name) AS count_of_artists
FROM artist
GROUP BY nationality
ORDER BY count_of_artists DESC -- Most artists are of French Nationality, followed by American
 --=============================================
 -- TABLE 2

SELECT *
FROM canvas_size -- Consists of size_id, height,width and label of the art work

SELECT count(*)
FROM canvas_size -- Number of records 200
 --=============================================
 -- TABLE 3

SELECT *
FROM image_link -- Number of records 14775
 -- Consists of work_id, url, thumbnail_small_url, thumbnail_large_url
 --=============================================
 -- TABLE 4

SELECT *
FROM museum
SELECT count(*)
FROM museum -- Number of records 57
 -- Consists of museum_id, museum name, address, city, state, postal, country, phone, url

SELECT country,
	count(name) AS museums_per_country
FROM museum
GROUP BY country
ORDER BY museums_per_country DESC -- USA has the most number of museums
 --=============================================
 -- TABLE 5

SELECT *
FROM museum_hours
SELECT count(*)
FROM museum_hours-- Number of records 351
 -- museum_id, day, open, close timing

SELECT DISTINCT DAY
FROM museum_hours -- Thursday is spelled as Thusday for few entries
 --=============================================
 -- TABLE 6

SELECT *
FROM product_size
SELECT count(*)
FROM product_size-- Number of records 110347
 -- work_id, size_id, sale_price, regular_price
 --=============================================
 -- TABLE 7

SELECT *
FROM subject
SELECT count(*)
FROM subject -- Number of records 6771
 -- Consists of work_id, subject

SELECT DISTINCT subject
FROM subject -- 29 distinct subjects
 --=============================================
 -- TABLE 8

SELECT *
FROM
WORK
SELECT count(*)
FROM
WORK-- Number of records 14776
 -- Consists of work_id, name, artist_id, style, museum_id

SELECT artist_id,
	count(work_id) AS count_of_artist_work
FROM
WORK
GROUP BY artist_id
ORDER BY artist_id -- count of work for each artist


 -- =======================Answer a few questions related to dataset ====================


--Fetch all the paintings which are not displayed on any museums?

SELECT name AS paintings
FROM
WORK
WHERE museum_id IS NULL 


--Are there museums without any paintings?

SELECT *
FROM museum 
WHERE museum_id not in
				(SELECT DISTINCT museum_id
				 FROM
                 WORK) -- Answer : NO museums are without paintings


-- How many paintings have an asking price of more than their regular price?

	SELECT *
	FROM product_size WHERE sale_price > regular_price 
	
	
-- Identify the paintings whose asking price is less than 50% of its regular price

	SELECT *
	FROM product_size WHERE sale_price < (regular_price /2) 
	

-- Which canvas size costs the most?

	SELECT c.label,
		p.sale_price
	FROM product_size p
	JOIN canvas_size c ON p.size_id = c.size_id::text WHERE sale_price =
		(SELECT max(sale_price)
			FROM product_size)
	SELECT cs.label AS canva,
		ps.sale_price
	FROM
		(SELECT *,
				rank() over(ORDER BY sale_price DESC) AS rnk
			FROM product_size) ps
	JOIN canvas_size cs ON cs.size_id::text=ps.size_id WHERE ps.rnk=1;

-- Delete duplicate records from work, product_size, subject tables

SELECT w.work_id,
	name,
	artist_id,
	style,
	museum_id,
	count(*)
FROM
WORK w
GROUP BY w.work_id,
	name,
	artist_id,
	style,
	museum_id
HAVING count(*) > 1


SELECT work_id,
	size_id,
	sale_price,
	regular_price
FROM product_size
GROUP BY work_id,
	size_id,
	sale_price,
	regular_price
HAVING count(*) >1

SELECT work_id,
	subject,
	count(*)
FROM subject
GROUP BY work_id,
	subject
HAVING count(*) >1 -- 58 rows


-- Identify the museums with invalid city information in the given dataset

SELECT *
FROM museum
WHERE city ~ '^[0-9]' 


-- Museum_Hours table has 1 invalid entry. Identify it and remove it.

	SELECT *
	FROM museum_hours WHERE DAY not in ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')
	
	
--Fetch the top 10 most famous painting subject

	SELECT DISTINCT subject
	FROM subject WITH x AS
		(SELECT subject,
				count(1) AS count_of_paintings,
				rank() over(ORDER BY count(1) DESC) rnk
			FROM
			WORK w
			INNER JOIN subject s ON w.work_id = s.work_id
			GROUP BY subject)
	SELECT subject,
		count_of_paintings
	FROM x WHERE rnk <=10
	SELECT *
	FROM
		(SELECT s.subject,
				count(1) AS no_of_paintings,
				rank() over(ORDER BY count(1) DESC) AS ranking
			FROM
			WORK w
			JOIN subject s ON s.work_id=w.work_id
			GROUP BY s.subject) x WHERE ranking <= 10;

--Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT name,
	city
FROM museum_hours mh
JOIN museum m ON mh.museum_id = m.museum_id
WHERE mh.day = ('Sunday')
	AND EXISTS
		(SELECT 1
			FROM museum_hours mh2
			WHERE mh2.museum_id = mh.museum_id
				AND mh2.day = 'Monday' )
ORDER BY m.museum_id 



--Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

SELECT m.name,
	city,
	country,
	count(work_id) AS number_of_paintings
FROM museum m
JOIN
WORK w ON m.museum_id = w.museum_id
GROUP BY m.name,
	city,
	country
ORDER BY number_of_paintings DESC
LIMIT 5
SELECT m.name AS museum,
	m.city,
	m.country,
	x.no_of_painintgs
FROM
	(SELECT m.museum_id,
			count(1) AS no_of_painintgs,
			rank() over(ORDER BY count(1) DESC) AS rnk
		FROM
		WORK w
		JOIN museum m ON m.museum_id=w.museum_id
		GROUP BY m.museum_id) x
JOIN museum m ON m.museum_id=x.museum_id
WHERE x.rnk<=5;

WITH num_of_paintings AS
	(SELECT m.museum_id,
			count(1) AS no_of_painintgs,
			rank() over(ORDER BY count(1) DESC) AS rnk
		FROM
		WORK w
		JOIN museum m ON m.museum_id=w.museum_id
		GROUP BY m.museum_id)
SELECT m.name AS museum,
	m.city,
	m.country,
	num_of_paintings.no_of_painintgs
FROM num_of_paintings
JOIN museum m ON m.museum_id=num_of_paintings.museum_id
WHERE num_of_paintings.rnk<=5;

-- How many museums are open every single day?

SELECT count(*) AS number_of_museums_open
FROM
	(SELECT museum_id,
			count(1)
		FROM museum_hours
		GROUP BY museum_id
		HAVING count(1) =7) AS x 
		
-- Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

SELECT full_name,
	rnk
FROM artist a
JOIN
	(SELECT artist_id,
			count(*) AS no_of_paintings,
			rank() over(ORDER BY count(*) DESC) AS rnk
		FROM
		WORK
		GROUP BY artist_id)x ON a.artist_id = x.artist_id
        WHERE rnk <= 5 


--Which museum is open for the longest during a day.
--Dispay museum name, state and hours open and which day?

	SELECT name,
		city,
		state,
		country,
		OPEN,
		CLOSE,
		duration_in_hrs
	FROM
		(SELECT museum_id,
				DAY,
				OPEN,
				CLOSE,
				to_timestamp(OPEN,'HH:MI AM'),
				to_timestamp(CLOSE,'HH:MI PM'),
				(to_timestamp(CLOSE,'HH:MI PM')-to_timestamp(OPEN,'HH:MI AM')) AS duration_in_hrs,
				dense_rank() over(ORDER BY(to_timestamp(CLOSE,'HH:MI PM')- to_timestamp(OPEN,'HH:MI AM')) DESC) AS rnk
			FROM museum_hours) x
	JOIN museum m ON x.museum_id = m.museum_id WHERE rnk =1 
	

--==================================
-- Which museum has the most no of most popular painting style?
 WITH pop_style AS
		(SELECT style,
				count(*) AS count_of_paintings,
				rank() over(ORDER BY count(*) DESC) rnk
			FROM
			WORK w
			WHERE style IS NOT NULL
			GROUP BY style),
		museum_with_style AS
		(SELECT m.museum_id,
				m.name,
				ps.style,
				count(*) AS painting_count,
				rank() over(ORDER BY count(*) DESC) AS rnk
			FROM museum m
			JOIN
			WORK w ON m.museum_id = w.museum_id
			JOIN pop_style ps ON w.style = ps.style
			WHERE m.museum_id IS NOT NULL
			GROUP BY m.museum_id,
				m.name,
				ps.style)
	SELECT name AS museum_name,
		style,
		painting_count
	FROM museum_with_style WHERE rnk =1 
	
	
-- Identify the artists whose paintings are displayed in multiple countries
 WITH art_mul_countries AS
		(SELECT DISTINCT a.full_name,
				country--, count(*)
            FROM
			WORK w
			JOIN museum m ON w.museum_id = m.museum_id
			JOIN artist a ON a.artist_id = w.artist_id
			WHERE w.museum_id IS NOT NULL --group by w.artist_id, w.museum_id,city,country
--having count(*) > 1
            ORDER BY a.full_name)
SELECT full_name,
	   count(1) AS rnk
  FROM art_mul_countries
GROUP BY full_name
HAVING count(*) >1
ORDER BY 2 DESC 



--Display the country and the city with most no of museums.
--Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.

SELECT country,
	city,
	count(1) AS num_of_museum
FROM museum m
GROUP BY country,
	city
ORDER BY num_of_museum DESC WITH cte_country AS
	(SELECT country,
			count(1),
			rank() over(ORDER BY count(1) DESC) AS rnk
		FROM museum
		GROUP BY country),
	cte_city AS
	(SELECT city,
			count(1),
			rank() over(ORDER BY count(1) DESC) AS rnk
		FROM museum
		GROUP BY city)
SELECT string_agg(DISTINCT country.country,', '),
	   string_agg(city.city,	', ')
FROM cte_country country
CROSS JOIN cte_city city
WHERE country.rnk = 1
	AND city.rnk = 1;


--Identify the artist and the museum where the most expensive and least expensive painting is placed.
 WITH sale_price AS
	(SELECT *,
			rank() over(ORDER BY sale_price DESC) AS m_rnk,
			rank() over(ORDER BY sale_price) AS l_rnk
		FROM product_size ps)
SELECT DISTINCT w.name,
	a.full_name,
	m.name,
	sp.sale_price
FROM sale_price sp
JOIN
WORK w ON sp.work_id = w.work_id
JOIN artist a ON w.artist_id = a.artist_id
JOIN museum m ON w.museum_id = m.museum_id
WHERE m_rnk =1
	OR l_rnk =1 
	
-- Which are the 3 most popular and 3 least popular painting styles
 WITH pop AS
		(SELECT style,
				count(1) AS cnt,
				rank() over(ORDER BY count(1) DESC) AS rnk,
				rank() over() AS no_of_records
			FROM
			WORK
			WHERE style IS NOT NULL
			GROUP BY style)
	SELECT style,
		(CASE
			WHEN rnk <=3 THEN 'Most Popular'
			ELSE 'Least Popular'
			END) AS remarks
	FROM pop WHERE rnk <=3
	               OR rnk >= no_of_records -3
	FROM
	WORK
	
--==========================

ALTER TABLE product_size
ALTER COLUMN size_id::integer ;


ALTER TABLE product_size
ALTER COLUMN regular_price TYPE integer;