-- ---------
-- Query 1:
-- Selecting the category name and the average film length by each name
-- Then ordering by name for alphabetical order
-- ---------
select c.name as category_name, avg(f.length) as average_film_length
from category c
join film_category fc on c.category_id=fc.category_id
join film f on fc.film_id=f.film_id
Group by c.name
Order by c.name;

-- ---------
-- Query 2:
-- Using union we are able to first find the highest average film length and find the lowest 
-- and then pair them with their categories as well
-- ---------

WITH category_avg_lengths AS (
    SELECT c.name AS category_name, AVG(f.length) AS average_film_length
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id
    GROUP BY c.name
)
SELECT c1.category_name, c1.average_film_length AS highest_and_lowest_average_film_length
FROM category_avg_lengths c1
WHERE c1.average_film_length = (SELECT MAX(average_film_length) FROM category_avg_lengths)

UNION ALL

SELECT c2.category_name, c2.average_film_length AS lowest_average_film_length
FROM category_avg_lengths c2
WHERE c2.average_film_length = (SELECT MIN(average_film_length) FROM category_avg_lengths);

-- ---------
-- Query 3:
-- first searches for customer id and name in category action
-- Then procedes to find customer id not in comedy and classic
-- ---------

select Distinct cu.customer_id, cu.first_name, cu.last_name
from customer cu
join rental r on cu.customer_id=r.customer_id
join inventory i on r.inventory_id=i.inventory_id
join film f on i.film_id=f.film_id
join film_category fc on f.film_id=fc.film_id
join category c on fc.category_id=c.category_id
where c.name='Action'
AND cu.customer_id NOT IN (
	select DISTINCT cu.customer_id
	from customer cu
	join rental r on cu.customer_id=r.customer_id
	join inventory i on r.inventory_id=i.inventory_id
	join film f on i.film_id=f.film_id
	join film_category fc on f.film_id=fc.film_id
	join category c on fc.category_id=c.category_id
	where c.name in('Comedy','Classic')
    );

-- ---------
-- Query 4:
-- Searches for actor id name last name and count with language name english
-- grouping it by actor and then descending the count allows a limit of 1 to get the most english movies
-- ---------

Select a.actor_id, a.first_name, a.last_name, COUNT(*) AS english_movie_count
from actor a
join film_actor fa on a.actor_id=fa.actor_id
join film f on fa.film_id=f.film_id
join language l on f.language_id=l.language_id
where l.name= 'English'
Group by a.actor_id
order by english_movie_count DESC
Limit 1;

-- ---------
-- Query 5:
-- Checking the distinct film id we are able to use date difference of 10 days and first name Mike
-- to find out the count of movies in which were rented out 10 days via Mike
-- ---------

SELECT COUNT(DISTINCT f.film_id) as ten_day_rental_by_mike
FROM film f
join inventory i on f.film_id=i.film_id
join rental r on i.inventory_id=r.inventory_id
JOIN staff s ON r.staff_id = s.staff_id
WHERE s.first_name = 'Mike' 
AND DATEDIFF(r.return_date, r.rental_date) = 10;

-- ---------
-- Query 6:
-- first in the middle of the SQL we search for the movie with the higher actor count
-- The surounding then tells us which actors were in that movie and orders them alphabetically
-- ---------

SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
WHERE fa.film_id = (
    SELECT film_id
    FROM (
        SELECT film_id, COUNT(*) AS actor_count
        FROM film_actor
        GROUP BY film_id
        ORDER BY actor_count DESC
        LIMIT 1
    ) AS most_actors
)
ORDER BY a.first_name, a.last_name;

