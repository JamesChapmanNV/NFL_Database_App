-- city -> zip does not hold
SELECT CASE
		WHEN count(city) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT city
		FROM venues
		GROUP BY city
		HAVING count(DISTINCT zipcode) > 1) x;
		
-- state -> city does not hold
SELECT CASE
		WHEN count(state) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT state
		FROM venues
		GROUP BY state
		HAVING count(DISTINCT city) > 1) x;
		
-- name -> city holds
SELECT CASE
		WHEN count(fullname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT fullname
		FROM venues
		GROUP BY fullname
		HAVING count(DISTINCT city) > 1) x;
		
-- name -> venue_id holds
SELECT CASE
		WHEN count(fullname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT fullname
		FROM venues
		GROUP BY fullname
		HAVING count(DISTINCT venue_id) > 1) x;
		
-- city -> state holds
SELECT CASE
		WHEN count(city) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT city
		FROM venues
		GROUP BY city
		HAVING count(DISTINCT state) > 1) x;
		
-- city -> name does not hold
SELECT CASE
		WHEN count(city) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT city
		FROM venues
		GROUP BY city
		HAVING count(DISTINCT fullname) > 1) x;
		
-- city, state -> zip does not hold
SELECT CASE
		WHEN count(city) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT city
		FROM venues
		GROUP BY city, state
		HAVING count(DISTINCT zipcode) > 1) x;

-- This is due to the Vikings using Huntington Bank Stadium for a couple of years
SELECT v1.city,
	v1.state,
	v1.zipcode,
	v2.zipcode,
	v1.fullname,
	v2.fullname
FROM venues v1,
	venues v2
WHERE v1.city = v2.city
	AND v1.state = v2.state
	AND v1.zipcode != v2.zipcode

-- We do have some games played here
SELECT *
FROM games
WHERE venue_id = 3953

-- city, state -> name does not hold
SELECT CASE
		WHEN count(city) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT city
		FROM venues
		GROUP BY city, state
		HAVING count(DISTINCT fullname) > 1) x;