--1--
SELECT ROUND(SUM(Total_Booking_Cost), 2) AS total_revenue
FROM airbnb_sales
WHERE Booking_Status = 'Confirmed';

--2--
SELECT ROUND(AVG(Price_Per_Night), 2) AS avg_price_per_night
FROM airbnb_sales;

--3--
SELECT Neighborhood, COUNT(*) AS booking_count
FROM airbnb_sales
GROUP BY Neighborhood
ORDER BY booking_count DESC
LIMIT 1;

--4--
SELECT Room_Type, COUNT(*) AS booking_count
FROM airbnb_sales
GROUP BY Room_Type;

--5--
SELECT COUNT(*) AS cancelled_bookings
FROM airbnb_sales
WHERE Booking_Status = 'Cancelled';

--6--
SELECT ROUND(AVG(Number_of_Nights), 2) AS avg_stay_duration
FROM airbnb_sales;

--7--
SELECT Cancellation_Policy, COUNT(*) AS policy_count
FROM airbnb_sales
GROUP BY Cancellation_Policy;

--8--
SELECT 
    TO_CHAR(Check_In_Date, 'YYYY-MM') AS month,
    ROUND(SUM(Total_Booking_Cost), 2) AS monthly_revenue
FROM airbnb_sales
WHERE Booking_Status = 'Confirmed'
GROUP BY TO_CHAR(Check_In_Date, 'YYYY-MM')
ORDER BY month;

--9--
SELECT 
    Host_ID, 
    ROUND(SUM(Total_Booking_Cost), 2) AS total_revenue
FROM airbnb_sales
WHERE Booking_Status = 'Confirmed'
GROUP BY Host_ID
ORDER BY total_revenue DESC
LIMIT 5;

--10--
SELECT 
    Room_Type, 
    Neighborhood, 
    ROUND(SUM(Total_Booking_Cost), 2) AS revenue
FROM airbnb_sales
WHERE Booking_Status = 'Confirmed'
GROUP BY Room_Type, Neighborhood
ORDER BY revenue DESC;

--11--
SELECT 
    Room_Type, 
    ROUND(AVG(Price_Per_Night), 2) AS avg_price
FROM airbnb_sales
GROUP BY Room_Type
HAVING COUNT(*) > 50;

--12--
SELECT 
    Cancellation_Policy,
    ROUND(100.0 * SUM(CASE WHEN Booking_Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_rate
FROM airbnb_sales
GROUP BY Cancellation_Policy;

--13--
SELECT COUNT(*) AS advance_bookings
FROM airbnb_sales
WHERE (Check_In_Date - Date_Booked) > 30;

--14--
SELECT ROUND(SUM(Total_Booking_Cost), 2) AS lost_revenue
FROM airbnb_sales
WHERE Booking_Status = 'Cancelled';

--15--
SELECT 
    Listing_ID, 
    COUNT(*) AS booking_count,
    ROUND(SUM(Total_Booking_Cost), 2) AS total_revenue
FROM airbnb_sales
WHERE Booking_Status = 'Confirmed'
GROUP BY Listing_ID
ORDER BY booking_count DESC
LIMIT 3;

--16--
SELECT 
    year_curr,
    revenue_curr,
    revenue_prev,
    ROUND(100.0 * (revenue_curr - revenue_prev) / revenue_prev, 2) AS growth_percent
FROM (
    SELECT 
        EXTRACT(YEAR FROM Check_In_Date) AS year_curr,
        ROUND(SUM(Total_Booking_Cost), 2) AS revenue_curr,
        LAG(ROUND(SUM(Total_Booking_Cost), 2)) OVER (ORDER BY EXTRACT(YEAR FROM Check_In_Date)) AS revenue_prev
    FROM airbnb_sales
    WHERE Booking_Status = 'Confirmed'
    GROUP BY EXTRACT(YEAR FROM Check_In_Date)
) AS yearly_data;

--17--
WITH host_revenue AS (
    SELECT 
        Host_ID, 
        ROUND(SUM(Total_Booking_Cost), 2) AS host_revenue
    FROM airbnb_sales
    WHERE Booking_Status = 'Confirmed'
    GROUP BY Host_ID
)
SELECT Host_ID, host_revenue
FROM host_revenue
WHERE host_revenue > (SELECT AVG(host_revenue) FROM host_revenue)
ORDER BY host_revenue DESC;

--18--
WITH monthly_bookings AS (
    SELECT 
        Neighborhood,
        TO_CHAR(TO_DATE(Check_In_Date, 'YYYY-MM-DD'), 'YYYY-MM') AS month,
        COUNT(*) AS booking_count,
        ROW_NUMBER() OVER (PARTITION BY Neighborhood ORDER BY COUNT(*) DESC) AS rank
    FROM airbnb_sales
    WHERE Booking_Status = 'Confirmed'
    GROUP BY Neighborhood, TO_CHAR(TO_DATE(Check_In_Date, 'YYYY-MM-DD'), 'YYYY-MM')
)
SELECT Neighborhood, month, booking_count
FROM monthly_bookings
WHERE rank = 1;

--19--
SELECT 
    Room_Type,
    ROUND(SUM(Total_Booking_Cost) / SUM(Guest_Count), 2) AS revenue_per_guest
FROM airbnb_sales
WHERE Booking_Status = 'Confirmed'
GROUP BY Room_Type
ORDER BY revenue_per_guest DESC;

--20--
WITH cancellation_stats AS (
    SELECT 
        Listing_ID,
        COUNT(*) AS total_bookings,
        SUM(CASE WHEN Booking_Status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
        ROUND(100.0 * SUM(CASE WHEN Booking_Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_rate
    FROM airbnb_sales
    GROUP BY Listing_ID
    HAVING COUNT(*) >= 10
)
SELECT Listing_ID, total_bookings, cancellations, cancellation_rate
FROM cancellation_stats
WHERE cancellation_rate > 50
ORDER BY cancellation_rate DESC;