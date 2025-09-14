-- 15 Business Problems

--Q1 Count the number of Movies vs TV shows 
SELECT  type,count(*) AS Count_of_type
FROM netflix
GROUP BY 1

--Q2 Find the most common Rating for Movies and TV shows 
--Method 1/
SELECT type , rating
FROM
(SELECT type,rating,count(*),
RANK() OVER (PARTITION BY type ORDER BY count(*)DESC ) ranking
FROM netflix
GROUP BY 1,2 ) AS popular_rating
WHERE ranking = 1

--Method 2/
WITH most_common_rating AS(
     SELECT type,rating,count(*),
     RANK() OVER (PARTITION BY type ORDER BY count(*)DESC ) ranking
     FROM netflix
     GROUP BY 1,2
	 )
SELECT type, rating FROM most_common_rating WHERE ranking = 1

--Q3 list of all Movies released in a specific year(2020)
SELECT type , title, release_year
FROM  netflix 
WHERE type = 'Movie' AND release_year = 2020

--Q4 Find the top 5 countries with the most content on Netflix
SELECT country , COUNT(show_id) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5

--Q5 Identify The Longest Movie
SELECT Show_id, type , title , duration
FROM netflix
WHERE type = 'Movie'
AND duration IN (SELECT MAX(duration) FROM netflix)

--Q6 Find Content Added in the Last 5 Years
SELECT *, TO_DATE(date_added, 'Month DD ,YYYY')
FROM netflix 
WHERE  TO_DATE(date_added, 'Month DD ,YYYY') >= CURRENT_DATE -INTERVAL '5 years'

--Q7 Find all the Movies/TV shows by director "Rajiv Chilaka"
SELECT show_id, type, title, director
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'

--Q8 List all TV shows with more than 5 seasons
--Method 1/
SELECT show_id,type,title, director,casts,seasons
FROM 
(SELECT  show_id,type,title, director,casts, SPLIT_PART(duration,' ',1)::int AS seasons
 FROM netflix)
 where type = 'TV Show'
 AND seasons > 5

--Method 2/
 SELECT * 
 FROM netflix 
 WHERE type LIKE 'TV Show'
 AND SPLIT_PART(duration ,' ',1)::int > 5

 --Q9 Count the number of content items in each genre
 SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre -- Separating multiple genres to a single columns 
 ,COUNT(*) Total_content 
 from netflix
 GROUP BY 1
 ORDER BY 2 DESC

--Q10 Find each year and the average number of contents release release by India 
--   Return top 5 years with the highest average content release   
SELECT country,EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) AS year,
ROUND(COUNT(*)::numeric/(SELECT COUNT(*)FROM netflix WHERE country ='India')*100,2) AS Avg_Content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5

--Q11 List all Movies that are documentaries
SELECT * 
FROM netflix 
WHERE listed_in ILIKE '%documentaries%'

--Q12 Find all contents without a director 
SELECT * 
FROM netflix 
WHERE director IS NULL

--Q13 Find how many movies actor 'Salman Khan' appeared in last 10 years
SELECT * 
FROM netflix 
where casts ILIKE '%salman khan%'
AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10

--Q14 Find the Top 10 actors who have appeared in the highest number of movies produced in india
SELECT UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--Q15 categorize the content based on the presence of the keywords 'kill and 'violence
-- in the descriptive field. Label content containing these keywords as 'Bad'and all
-- other content as 'Good'. count how many items fall into each category.
WITH content_type AS(
     SELECT * ,
	 CASE
	 WHEN description ILIKE '%kill%'
	 OR   description ILIKE '%violence%'
	 THEN 'Bad content'
	 ELSE 'Good content'
	 END category
	 FROM netflix
)
SELECT category , COUNT(*) AS total_content
FROM content_type
GROUP BY 1
ORDER BY 2 DESC







