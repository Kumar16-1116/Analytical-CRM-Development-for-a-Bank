USE crm_analysis;

SHOW TABLES;
SELECT *
FROM customerdetails;

-- 1.What is the distribution of account balances across different regions?
SELECT Geography_location, SUM(Balance) AS account_balances
FROM customerdetails
GROUP BY Geography_location
ORDER BY account_balances DESC;

-- 2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. 

SELECT Surname AS customers, SUM(EstimatedSalary) AS `Highest Estimated Salary`
FROM customerdetails
WHERE  MONTH(Joining_date) IN (10,11,12)
GROUP BY customers
ORDER BY `Highest Estimated Salary` DESC
LIMIT 5;

-- 3.	Calculate the average number of products used by customers who have a credit card. (SQL)
SELECT surname AS Customers,ROUND(AVG(NumOfProducts), 2) AS `Average Number of Products`
FROM customerdetails
WHERE HasCrCard=1
GROUP BY surname;

-- 4.	Determine the churn rate by gender for the most recent year in the dataset.
WITH CTE AS(
	SELECT Gender,COUNT(customerId) AS `Churn`
	FROM customerdetails
	WHERE Exited=1 AND YEAR(Joining_date)=(SELECT MAX(YEAR(Joining_date))
											FROM customerdetails)
	GROUP BY Gender
), totalCTE AS
(
	SELECT Gender,COUNT(*) AS `total`
	FROM customerdetails
    GROUP BY Gender
)
SELECT a.Gender, ROUND(((churn/total)*100), 2) AS `churn rate`
FROM CTE a
JOIN totalCTE b
ON a.Gender=b.Gender
GROUP BY a.Gender;

-- 5.	Compare the average credit score of customers who have exited and those who remain. (SQL)

SELECT Churn_status,ROUND(AVG(Credit_score),2) AS `Average Credit Score`
FROM customerdetails
GROUP BY Churn_status;

-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of 
-- active accounts? (SQL)

SELECT Gender,
ROUND(AVG(EstimatedSalary),2) AS `Highest Average Estimated Salary`,
COUNT(customerId) AS`Count of Active Member`
FROM customerdetails
WHERE Active_member=1
GROUP BY Gender,Active_member
ORDER BY `Highest Average Estimated Salary` DESC 
LIMIT 1;

-- 7.	Segment the customers based on their credit score and identify the segment with the highest 
-- exit rate. (SQL)

SELECT CASE WHEN Credit_score BETWEEN 350 AND 450 THEN '350-450'
WHEN Credit_score BETWEEN 450 AND 550 THEN '450-550'
WHEN Credit_score BETWEEN 550 AND 650 THEN '550-650'
WHEN Credit_score BETWEEN 650 AND 750 THEN '650-750'
ELSE '750-850' END AS CreditScoreRange,
COUNT(customerId) AS customers
FROM customerdetails
WHERE Exited=1
GROUP BY CreditScoreRange
ORDER BY customers DESC;

-- 8.	Find out which geographic region has the highest number of active customers with a tenure 
-- greater than 5 years. (SQL)
SELECT Geography_location,COUNT(CustomerId) AS `Active Customers`
FROM customerdetails
WHERE Active_member=1 AND Tenure>5
GROUP BY Geography_location
ORDER BY `Active Customers` DESC
LIMIT 1;

-- 9.	What is the impact of having a credit card on customer churn, based on the available data?

SELECT Member_status,COUNT(customerId) AS `Customer Churn`
FROM customerdetails
WHERE Exited=1 AND Member_status='Active Member'
GROUP BY Member_status;

-- Example --- Example Example Example

SELECT Member_status, COUNT(customerId) AS `Customer Churn`
FROM customerdetails
WHERE Exited = 1
GROUP BY Member_status;

-- 10.	For customers who have exited, what is the most common number of products they have used?

SELECT NumOfProducts,COUNT(customerId) AS customers
FROM customerdetails
WHERE Exited=1
GROUP BY NumOfProducts
ORDER BY customers DESC 
LIMIT 1;

--  11.	Examine the trend of customer exits over time and identify any seasonal patterns (yearly or monthly).
--  Prepare the data through SQL and then visualize it.

SELECT YEAR(Joining_date) AS Years,COUNT(CustomerId) AS CustomersCount
FROM customerdetails
WHERE Exited=1
GROUP BY Years
ORDER BY CustomersCount DESC;

-- 12.	Analyze the relationship between the number of products and the account balance for customers who have exited.

SELECT NumOfProducts,ROUND(AVG(Balance),2) AS `Account Balance`
FROM customerdetails
WHERE Exited=1
GROUP BY NumOfProducts
ORDER BY `Account Balance` DESC;

-- 13.	Identify any potential outliers in terms of spend among customers who have remained with the bank.

SELECT COUNT(customerID) AS customer_count, NumOfProducts,ROUND(AVG(Balance),2) AS `Account Balance`
FROM customerdetails
WHERE Exited=1
GROUP BY NumOfProducts
ORDER BY `Account Balance` DESC;

-- 14.	Can you create a dashboard incorporating the visuals mentioned above and additionally derive 
-- more KPIs if possible?

SELECT 
ROUND(AVG(Balance), 2) AS Average_Balance,
ROUND(AVG(Credit_score), 2) AS Average_Credit_Score,
ROUND(AVG(EstimatedSalary), 2) AS Average_Estimated_Salary,
MAX(Balance) AS Max_Balance,
MIN(Balance) AS Min_Balance,
MAX(Tenure) AS Max_Tenurity,
MAX(EstimatedSalary) AS Max_Estimated_Salary,
MIN(EstimatedSalary) AS Min_Estimated_Salary
FROM customerdetails;


-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id.
--  Also, rank the gender according to the average value. (SQL)

WITH CTE AS(
	SELECT Gender,Geography_location,ROUND(AVG(EstimatedSalary),2) AS average_value
	FROM customerdetails
	GROUP BY Gender,Geography_location
)
SELECT DENSE_RANK() OVER(ORDER BY average_value DESC) AS Ranks ,Gender,Geography_location,average_value
FROM CTE;

-- 16.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

SELECT Age_bracket,AVG(Tenure) AS `Average Tenure`
FROM customerdetails
WHERE Exited=1
GROUP BY Age_bracket
ORDER BY Age_bracket;

/* 17. Is there any direct correlation between the salary and the balance of the customers? And is it different for people who have exited or not?
18. Is there any correlation between the salary and the Credit score of customers?
Answer:  Used POWER BI for both questions */


-- 19.Rank each bucket of credit score as per the number of customers who have churned the bank.

SELECT CreditScoreRange, customers, RANK() OVER (ORDER BY customers DESC) AS customer_rank
FROM ( SELECT CASE 
WHEN Credit_score BETWEEN 300 AND 579 THEN '300-579'
WHEN Credit_score BETWEEN 580 AND 669 THEN '580-669'
WHEN Credit_score BETWEEN 670 AND 739 THEN '670-739'
WHEN Credit_score BETWEEN 740 AND 799 THEN '740-799'
ELSE '800-855'
END AS CreditScoreRange, COUNT(customerId) AS customers
FROM customerdetails
WHERE Exited = 1
GROUP BY CreditScoreRange) AS ChurnCounts
ORDER BY customer_rank;

-- 20.	According to the age buckets find the number of customers who have a credit card. 
-- Also, retrieve those buckets that have a lesser than average number of credit cards per bucket.

SELECT Age_bracket,COUNT(HasCrCard) AS `number of customers`
FROM customerdetails
WHERE HasCrCard=1 
GROUP BY Age_bracket
HAVING `number of customers`<(SELECT AVG(tc) AS avrg
FROM (SELECT COUNT(customerId) AS tc
FROM customerDetails
WHERE HasCrCard=1)a) ;


-- 21.	Rank the Locations as per the number of people who have churned the bank and the average balance of the learners.

WITH CTE AS(
SELECT Geography_location,COUNT(customerId) AS `number of people`,ROUND(AVG(Balance),2) AS `average balance`
FROM customerdetails
WHERE Exited=1
GROUP BY Geography_location
)
SELECT DENSE_RANK() OVER(ORDER BY `number of people`DESC,`average balance` DESC) AS Ranks,
Geography_location,`number of people`,`average balance`
FROM CTE;


-- SUBJECTIVE QUESTIONS

-- Utilize SQL queries to segment customers based on demographics, 
-- account details, and transaction behaviours.

SELECT *
FROM customerdetails;

-- Segment Customers by Age Group

SELECT
CASE
WHEN age < 20 THEN 'Under 20'
WHEN age BETWEEN 20 AND 29 THEN '20-29'
WHEN age BETWEEN 30 AND 39 THEN '30-39'
WHEN age BETWEEN 40 AND 49 THEN '40-49'
WHEN age BETWEEN 50 AND 59 THEN '50-59'
ELSE '60+' END AS age_group, COUNT(*) AS customer_count
FROM customerdetails
GROUP BY age_group
ORDER BY age_group asc;

-- Count of all customers according to credit score range

SELECT CASE 
WHEN Credit_score BETWEEN 300 AND 579 THEN '300-579'
WHEN Credit_score BETWEEN 580 AND 669 THEN '580-669'
WHEN Credit_score BETWEEN 670 AND 739 THEN '670-739'
WHEN Credit_score BETWEEN 740 AND 799 THEN '740-799'
ELSE '800-855'
END AS CreditScoreRange, COUNT(customerId) AS customers
FROM customerdetails
GROUP BY CreditScoreRange;

-- Grography wise coustomer count.

SELECT Geography_location, COUNT(CustomerId) AS customer_count
FROM customerdetails
GROUP BY Geography_location
ORDER BY customer_count DESC;

-- Geography_location wise total balance

SELECT Geography_location, SUM(Balance) AS Total_balance
FROM customerdetails
GROUP BY Geography_location
ORDER BY Total_balance DESC;

SELECT * FROM customerdetails;

-- Product wise customer count 
SELECT NumOfProducts, COUNT(CustomerId) AS customer_count
FROM customerdetails
GROUP BY NumOfProducts
ORDER BY customer_count DESC;

-- What is the current churn rate per year and overall as well in the bank?

-- YEAR WISE CHURN RATE
SELECT YEAR(Joining_date) AS year, COUNT(CASE WHEN Exited = 1 THEN 1 END) AS churned_customers,
COUNT(CustomerId) AS total_customers,
ROUND((COUNT(CASE WHEN Exited = 1 THEN 1 END) / COUNT(CustomerId)), 2) * 100 AS churn_rate
FROM customerdetails
GROUP BY YEAR(Joining_date)
ORDER BY year;
    
-- OVERALL CHURN RATE

SELECT COUNT(CASE WHEN Exited = 1 THEN 1 END) AS churned_customers,
COUNT(CustomerId) AS total_customers,
(COUNT(CASE WHEN Exited = 1 THEN 1 END) / COUNT(CustomerId)) * 100 AS overall_churn_rate
FROM customerdetails;
    
-- NumOfProducts wsie churn rate
SELECT NumOfProducts, COUNT(CustomerId) AS total_customers,
COUNT(CASE WHEN Exited = 1 THEN 1 END) AS churned_customers,
ROUND((COUNT(CASE WHEN Exited = 1 THEN 1 END) / COUNT(CustomerId)), 2) * 100 AS churn_rate
FROM customerdetails
GROUP BY NumOfProducts
ORDER BY total_customers DESC;

-- age group wise exit count

SELECT Age_bracket, COUNT(CustomerId) AS total_customers,
COUNT(CASE WHEN Exited = 1 THEN 1 END) AS churned_customers
FROM customerdetails
GROUP BY Age_bracket
ORDER BY total_customers DESC;    
    
-- THANK YOU