
-- Practical Assignment - Task 1




-- 1. Number of records in the City table

SELECT COUNT(*) AS city_count
FROM City;



-- 2. Plans (name, price) that include an internet data plan,plus the internet plan's name, data allowance (MB), price, and the operator's name

SELECT
    p.name          AS plan_name,
    p.price         AS plan_price,
    idp.name        AS internet_plan_name,
    idp.data_mb     AS data_allowance_mb,
    idp.price       AS internet_plan_price,
    mno.name        AS operator_name
FROM Plan p
JOIN InternetDataPlan idp ON idp.plan_id = p.plan_id
JOIN MobileNetworkOperator mno ON mno.operator_id = p.operator_id;



-- 3. Operators and plans (name, price) that include at least 100 free minutes for calls within the Lithuanian network

SELECT
    mno.name    AS operator_name,
    p.name      AS plan_name,
    p.price     AS plan_price
FROM Plan p
JOIN CallPlan cp ON cp.plan_id = p.plan_id
JOIN MobileNetworkOperator mno ON mno.operator_id = p.operator_id
WHERE cp.free_minutes_national >= 100;



-- 4. Number of users in each city

SELECT
    c.name          AS city_name,
    COUNT(pe.person_id) AS user_count
FROM City c
LEFT JOIN Person pe ON pe.city_id = c.city_id
GROUP BY c.city_id, c.name;



-- 5. Cities with no users

SELECT c.name AS city_name
FROM City c
LEFT JOIN Person pe ON pe.city_id = c.city_id
WHERE pe.person_id IS NULL;



-- 6a. Average number of users per city, EXCLUDING cities with no users

SELECT AVG(user_count) AS avg_users_per_city_excluding_empty
FROM (
    SELECT c.city_id, COUNT(pe.person_id) AS user_count
    FROM City c
    JOIN Person pe ON pe.city_id = c.city_id
    GROUP BY c.city_id
) sub;


-- 6b. Average number of users per city, INCLUDING cities with no users

SELECT AVG(user_count) AS avg_users_per_city_including_empty
FROM (
    SELECT c.city_id, COUNT(pe.person_id) AS user_count
    FROM City c
    LEFT JOIN Person pe ON pe.city_id = c.city_id
    GROUP BY c.city_id
) sub;



-- 7. Operator(s) offering the largest number of plans

SELECT mno.name AS operator_name, plan_counts.plan_count
FROM MobileNetworkOperator mno
JOIN (
    SELECT operator_id, COUNT(*) AS plan_count
    FROM Plan
    GROUP BY operator_id
) plan_counts ON plan_counts.operator_id = mno.operator_id
WHERE plan_counts.plan_count = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM Plan
        GROUP BY operator_id
    ) max_counts
);



-- 8. People who subscribed to any plan between January 3, 2025 and January 10, 2025 (inclusive)

SELECT
    pe.first_name,
    pe.last_name,
    p.name          AS plan_name,
    s.start_date    AS contract_start_date
FROM Subscription s
JOIN Person pe ON pe.person_id = s.person_id
JOIN Plan p ON p.plan_id = s.plan_id
WHERE s.start_date BETWEEN '2025-01-03' AND '2025-01-10';



-- 9. Average price of plans offered by each operator, sorted by average price descending

SELECT
    mno.name AS operator_name,
    AVG(p.price) AS avg_plan_price
FROM MobileNetworkOperator mno
JOIN Plan p ON p.operator_id = mno.operator_id
GROUP BY mno.operator_id, mno.name
ORDER BY avg_plan_price DESC;



-- 10. Number of additional services provided by each operator

SELECT
    mno.name AS operator_name,
    COUNT(a.service_id) AS additional_service_count
FROM MobileNetworkOperator mno
LEFT JOIN AdditionalService a ON a.operator_id = mno.operator_id
GROUP BY mno.operator_id, mno.name;
