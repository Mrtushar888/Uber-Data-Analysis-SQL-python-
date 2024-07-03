use uber_database;

-- Total trips
SELECT COUNT(DISTINCT tripid) AS total_trips
FROM trip_details;

-- Total drivers
SELECT COUNT(DISTINCT driverid) AS total_drivers
FROM trips;

-- Total earnings
SELECT SUM(fare) AS total_earnings
FROM trips;

-- Total completed trips
select sum(end_ride) from trip_details;

-- Total searches
SELECT 
    SUM(searches) AS total_searches,
    SUM(searches_got_estimate) AS total_searches_got_estimate,
    SUM(searches_for_quotes) AS total_searches_for_quotes,
    SUM(searches_got_quotes) AS total_searches_got_quotes,
    SUM(customer_not_cancelled) AS total_customer_not_cancelled,
    SUM(driver_not_cancelled) AS total_driver_not_cancelled,
    SUM(otp_entered) AS total_otp_entered,
    SUM(end_ride) AS total_end_ride
FROM trip_details;

-- Total searches which got estimate
SELECT SUM(searches_got_estimate) AS total_searches_got_estimate
FROM trip_details;

-- Total searches for quotes
SELECT SUM(searches_for_quotes) AS total_searches_for_quotes
FROM trip_details;

-- Total searches which got quotes
SELECT SUM(searches_got_quotes) AS total_searches_got_quotes
FROM trip_details;

-- Total driver cancelled
SELECT count(*)-SUM(driver_not_cancelled) AS total_driver_cancelled
FROM trip_details;

-- Total OTP entered
SELECT SUM(otp_entered) AS total_otp_entered
FROM trip_details;

-- Total end ride
SELECT SUM(end_ride) AS total_end_ride
FROM trip_details;


-- Average distance per trip
SELECT AVG(distance) AS average_distance_per_trip
FROM trips;

-- Average fare per trip
SELECT SUM(fare)/COUNT(*) AS average_fare_per_trip
FROM trips;

-- Distance travelled
SELECT SUM(distance) AS total_distance_travelled
FROM trips;

-- Most used payment method
select a.method from payment a inner join 
(SELECT faremethod,count(distinct tripid) from trips group by faremethod order by count(distinct tripid) desc limit 1)b 
on a.id=b.faremethod ;

-- The highest payment was made through which instrument
select a.method from payment a inner join
(select faremethod,max(fare) from trips group by faremethod order by max(fare) desc limit 2) b
on a.id=b.faremethod;

-- highest payment method
select faremethod,max(fare) from trips group by faremethod order by max(fare) desc;

-- Which two locations had the most trips end
select a.Assembly from assembly a inner join
(SELECT loc_to, count(loc_to) from trips group by loc_to order by count(loc_to) desc limit 2) b
on a.id=b.loc_to;

-- Which two locations had the most trips by loc_to number
select * from
(select *,dense_rank() over(order by trip desc) rnk 
from
(SELECT loc_from,loc_to, count(loc_to) trip from trips group by loc_from,loc_to order by count(loc_to) desc limit 2)a)b
where rnk=1;

-- Top 5 earning drivers
select * from 
(select *,dense_rank() over(order by total_earnings desc) rnk from
(SELECT driverid, SUM(fare) AS total_earnings
FROM trips
GROUP BY driverid)a)b 
where rnk < 6;

-- Which duration had more trips
select * from
(select *,dense_rank() over (order by trip_count desc) rnk from
(SELECT duration, COUNT(distinct tripid) AS trip_count
FROM trips
GROUP BY duration
ORDER BY trip_count DESC)a)b
where rnk=1;

-- Which driver, customer pair had more orders
SELECT driverid, custid, COUNT(distinct tripid) AS order_count
FROM trips
GROUP BY driverid, custid
ORDER BY order_count DESC
LIMIT 1;
-- OR
select * from
(select *,dense_rank() over (order by order_count desc) rnk from 
(SELECT driverid, custid, COUNT(distinct tripid) AS order_count
FROM trips
GROUP BY driverid, custid)a)b
where rnk=1;

-- Search to estimate rate
SELECT (SUM(searches_got_estimate)/SUM(searches)*100) AS search_to_estimate_rate
FROM trip_details;

-- Estimate to search for quote rates
SELECT (SUM(searches_for_quotes)/SUM(searches_got_estimate)*100) AS estimate_to_search_for_quote_rate
FROM trip_details;

-- Quote acceptance rate
SELECT (SUM(searches_got_quotes)/SUM(searches_for_quotes)*100) AS quote_acceptance_rate
FROM trip_details;

-- Quote to booking rate
SELECT (SUM(end_ride)/SUM(searches_got_quotes)*100) AS quote_to_booking_rate
FROM trip_details;

-- Booking cancellation rate
SELECT ((count(tripid)-(SUM(driver_not_cancelled)) + (count(tripid)-SUM(customer_not_cancelled)))/SUM(end_ride)) AS booking_cancellation_rate
FROM trip_details;

-- Conversion rate
SELECT (SUM(end_ride)/SUM(searches)*100) AS conversion_rate
FROM trip_details;

-- Which area got highest trips in which duration
SELECT area, duration, COUNT(*) AS trip_count
FROM trips
JOIN duration ON trips.durationid = duration.durationid
GROUP BY area, duration
ORDER BY trip_count DESC
LIMIT 1;


-- Which duration got the highest no of trips
select * from (select * ,rank() over (partition by duration order by cnt desc) rnk from (SELECT duration,loc_from,count(tripid) cnt from trips
group by duration,loc_from)a)b
where rnk=1;

--  Which area got the highest fares, cancellations, trips
select * from (select *, rank() over(order by sum desc) rnk from 
(SELECT loc_from , sum(fare) sum from trips group by loc_from)a)b
where rnk=1; 

select * from (select *, rank() over(order by cancelled desc) rnk from 
(SELECT loc_from , count(*)-sum(driver_not_cancelled) cancelled from trip_details group by loc_from)a)b
where rnk=1; 

select * from (select *, rank() over(order by cancelled desc) rnk from 
(SELECT loc_from , count(*)-sum(customer_not_cancelled) cancelled from trip_details group by loc_from)a)b
where rnk=1; 