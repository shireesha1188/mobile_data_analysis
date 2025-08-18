
--1.avg screen time and data_usage per age group
SELECT age_group, 
       ROUND(AVG(screen_time),1) AS avg_screen_time,
       ROUND(AVG(data_usage),1) AS avg_data_usage 
FROM (
    SELECT *,
        CASE 
            WHEN age BETWEEN 15 AND 25 THEN '15-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age BETWEEN 41 AND 50 THEN '41-50'
            WHEN age BETWEEN 51 AND 60 THEN '51-60'
			ELSE '60+'
        END AS age_group
    FROM mobile_usage
) AS grouped_data
GROUP BY age_group
order by age_group ASC;

--2.top 10 most engaged users based on screen time,data usage

WITH PowerUsers AS (
    SELECT user_id, location, brand, os, 
           screen_time, data_usage, 
            
           ROW_NUMBER() OVER (ORDER BY screen_time DESC, data_usage DESC) AS rank
    FROM mobile_usage
)
SELECT * FROM PowerUsers WHERE rank <= 10;

--3.which brand most preferred by each age group

WITH group_data AS (
    SELECT 
        CASE 
            WHEN age BETWEEN 15 AND 25 THEN '15-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age BETWEEN 41 AND 50 THEN '41-50'
            WHEN age BETWEEN 51 AND 60 THEN '51-60'
            ELSE '60+'
        END AS age_group,
        brand
    FROM mobile_usage
)
SELECT TOP 1 WITH TIES age_group, brand, COUNT(*) AS total_count
FROM group_data
GROUP BY age_group, brand
ORDER BY 
    ROW_NUMBER() OVER (PARTITION BY age_group ORDER BY COUNT(*) DESC);

--4.most common prinary_usage by age_group
WITH AgeGroupUsage AS (
    SELECT age_group, primary_use, COUNT(*) AS usage_count
    FROM (
        SELECT 
            CASE 
                WHEN age BETWEEN 15 AND 25 THEN '15-25'
                WHEN age BETWEEN 26 AND 40 THEN '26-40'
                WHEN age BETWEEN 41 AND 50 THEN '41-50'
                WHEN age BETWEEN 51 AND 60 THEN '51-60'
                ELSE '60+'
            END AS age_group,
            primary_use
        FROM mobile_usage
    ) categorized_data
    GROUP BY age_group, primary_use
)
SELECT age_group, primary_use, usage_count
FROM (
    SELECT *, 
           RANK() OVER (PARTITION BY age_group ORDER BY usage_count DESC) AS rank
    FROM AgeGroupUsage
) ranked_data
WHERE rank = 1;

--5. top primary_usage in each cities

WITH CityUsage AS (
    SELECT 
        location,
        primary_use,
        COUNT(*) AS usage_count
    FROM mobile_usage
    GROUP BY location, primary_use
)
SELECT TOP 1 WITH TIES location, primary_use, usage_count
FROM CityUsage
ORDER BY RANK() OVER (PARTITION BY primary_use ORDER BY usage_count DESC);

--6.total users of primary_usage in each location

select location,sum(CASE WHEN primary_use='Education' THEN 1 ELSE 0 END) AS education,
                sum(CASE WHEN primary_use='Entertainment' THEN 1 ELSE 0 END) AS entertainment,
                sum(CASE WHEN primary_use='Gaming' THEN 1 ELSE 0 END) AS gaming,
                sum(CASE WHEN primary_use='Social Media' THEN 1 ELSE 0 END) AS social_media,
                sum(CASE WHEN primary_use='Work' THEN 1 ELSE 0 END) AS work from mobile_usage
GROUP BY location;
--7.most top brands in each location

WITH BrandSales AS (
    SELECT 
        location, 
        brand, 
        count(*) AS total_sales
    FROM mobile_usage
    GROUP BY location, brand
)
SELECT TOP 1 WITH TIES location, brand, total_sales
FROM BrandSales

ORDER BY RANK() OVER (PARTITION BY location ORDER BY total_sales DESC);

-- 8.Identifies which brand retains the most active users
SELECT brand, COUNT(user_id) AS active_users
FROM mobile_usage
WHERE screen_time > (SELECT AVG(screen_time) FROM mobile_usage)
GROUP BY brand
ORDER BY active_users DESC;

--9.Identifies low-engagement users (potential churners)

SELECT user_id, location, brand, os,
       screen_time, data_usage
FROM mobile_usage
WHERE screen_time < (SELECT AVG(screen_time) FROM mobile_usage)
  AND data_usage < (SELECT AVG(data_usage) FROM mobile_usage);

