/*1. Who is the senior most employee based on job title?*/

SELECT * 
from employee
ORDER BY levels desc
limit 1;

/*2. Which countries have the most Invoices?*/

SELECT billing_country, COUNT(*) as total
from invoice
GROUP BY billing_country
order by total desc;

/*3. What are top 3 value of total invoices*/

SELECT total
from invoice
ORDER BY total desc
limit 3;

/*4. Which city has the best customers? We would like to throw a promotional Musical Festival in the city we
made the most money. Write a query that returns one city that has the highest sum of invoices totals. Return both
the city name and sum of all invoices totals. */

SELECT billing_city, SUM(total) as total_invoices
FROM invoice
GROUP BY billing_city
ORDER BY total_invoices DESC
limit 1;

/*5. Who is the best customer? The customer who has spent the most money will be declared the best customer.
Write a query that returns the person who has spent the most money.*/

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) as total
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total DESC
limit 1;

/*6. Write query to return the email, first name, last name & genre of all the Rock Music listners. Return your
list alphabetically by email starting with A. */


SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON i.customer_id = c.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

/*7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns Artist
name and total track count of the top 10 rock bands.*/

SELECT a.name, a.artist_id, COUNT(a.artist_id) as Number_of_Songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist a ON a.artist_id = album.artist_id
JOIN genre g ON g.genre_id = track.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY a.artist_id
ORDER BY Number_of_Songs DESC
limit 10;

/*8. Return all the track names that have a song length longer than the average song length. Return the Name and 
Milliseconds for each track. Order by the song length with the longest songs listed first */

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) as Avg_length
	from track
)
order by milliseconds DESC;

/*9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name 
and total spent */

WITH best_selling_artist AS (
	SELECT artist.artist_id as artist_ID, artist.name as artist_name, 
	SUM(invoice_line.unit_price*invoice_line.quantity)
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.quantity*il.unit_price)
FROM invoice
JOIN customer c ON c.customer_id = invoice.customer_id
JOIN invoice_line il ON il.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = il.track_id
JOIN album ON album.album_id = track.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = album.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC;

/*10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the 
genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres */

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(li.quantity) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line li
		JOIN invoice ON invoice.invoice_id = li.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = li.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2, 1 DESC
	),
	max_genre_per_country AS (
		SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2
	)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

-- Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top 
-- customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

WITH customer_country AS(
	SELECT c.customer_id,first_name,last_name,billing_country, SUM(total) as Max_Spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	FROM invoice i
	JOIN customer c ON c.customer_id = i.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM customer_country WHERE RowNo = 1






