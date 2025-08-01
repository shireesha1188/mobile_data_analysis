

--total people  from every location
select  location,
COUNT(CASE WHEN gender='male' THEN 1 END) AS male,
COUNT(CASE WHEN gender='female' THEN 1 END) AS female,
COUNT(CASE WHEN gender='other' THEN 1 END) AS others,
COUNT(*) AS [total] from mobile_usage
GROUP BY location;

--os used in each city
select location,COUNT(CASE WHEN os='iOS' THEN 1 END) AS IOS,
COUNT(CASE WHEN os='Android' THEN 1 END) AS Android from mobile_usage
GROUP BY location;
--total users of each category
select primary_use ,COunt(*) as total from mobile_usage
GROUP BY primary_use
ORDER BY total DESC;

--most used phone brand
select  brand,COUNT(*) as total from mobile_usage
GROUP BY brand 
ORDER BY total DESC;

--top locations with highest data usage
select  location,ROUND(SUM(data_usage),2) as highest from mobile_usage
GROUP BY location
ORDER BY highest DESC;

select os,ROUND(AVG(screen_time),2) as [screen time] from mobile_usage
GROUP BY os;

--avg screen time per age 
SELECT age, AVG(screen_time) AS avg_screen_time
FROM mobile_usage
GROUP BY age
ORDER BY avg_screen_time DESC;

--Find the most used phone brand among users with high data consumption.
select brand,COUNT(*) from mobile_usage
WHERE data_usage >(select AVG(data_usage) from mobile_usage)
GROUP BY brand;


--total people count
SELECT
  COUNT(CASE WHEN gender = 'male' THEN 1 END) AS male,
  COUNT(CASE WHEN gender = 'female' THEN 1 END) AS female,
  COUNT(CASE WHEN gender = 'other' THEN 1 END) AS others,
  COUNT(*) AS total
FROM mobile_usage;
