-- first_name, last_name -> athlete_id does not hold
SELECT CASE
		WHEN count(firstname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT firstname
		FROM athletes
		GROUP BY firstname, lastname
		HAVING count(DISTINCT athlete_id) > 1) x;

-- firstname, lastname -> debutyear does not hold
SELECT CASE
		WHEN count(firstname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT firstname
		FROM athletes
		GROUP BY firstname, lastname
		HAVING count(DISTINCT debutyear) > 1) x;

-- firstname, lastname -> age does not hold
SELECT CASE
		WHEN count(firstname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT firstname
		FROM athletes
		GROUP BY firstname, lastname
		HAVING count(DISTINCT age) > 1) x;

-- firstname, lastname -> displaydraft does not hold
SELECT CASE
		WHEN count(firstname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT firstname
		FROM athletes
		GROUP BY firstname, lastname
		HAVING count(DISTINCT displaydraft) > 1) x;
		
-- firstname, lastname, displaybirthplace -> athlete_id does not hold
SELECT CASE
		WHEN count(firstname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT firstname
		FROM athletes
		GROUP BY firstname, lastname, displaybirthplace
		HAVING count(DISTINCT athlete_id) > 1) x;

-- The above FD is problematic due to the below. But it looks fake, so we should be able to eliminate it through cleaning.
SELECT a1.firstname,
	a1.lastname,
	a1.athlete_id,
	a2.athlete_id
FROM athletes a1,
	athletes a2
WHERE a1.firstname = a2.firstname
	AND a1.lastname = a2.lastname
	AND a1.displaybirthplace = a2.displaybirthplace
	AND a1.athlete_id != a2.athlete_id;
		
-- firstname, lastname, displaybirthplace -> displaydob holds
SELECT CASE
		WHEN count(firstname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT firstname
		FROM athletes
		GROUP BY firstname, lastname, displaybirthplace
		HAVING count(DISTINCT displaydob) > 1) x;
		
-- firstname, lastname, displaybirthplace -> debutyear does not hold
SELECT CASE
		WHEN count(firstname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT firstname
		FROM athletes
		GROUP BY firstname, lastname, displaybirthplace
		HAVING count(DISTINCT debutyear) > 1) x;
		
-- firstname, lastname, displaybirthplace -> displaydraft holds
SELECT CASE
		WHEN count(firstname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT firstname
		FROM athletes
		GROUP BY firstname, lastname, displaybirthplace
		HAVING count(DISTINCT displaydraft) > 1) x;
		
-- firstname, lastname, displaybirthplace -> age does not hold
SELECT CASE
		WHEN count(firstname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT firstname
		FROM athletes
		GROUP BY firstname, lastname, displaybirthplace
		HAVING count(DISTINCT age) > 1) x;

-- firstname, lastname, displaydob -> athlete_id does not hold
SELECT CASE
		WHEN count(firstname) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT firstname
		FROM athletes
		GROUP BY firstname, lastname, displaydob
		HAVING count(DISTINCT athlete_id) > 1) x;a
