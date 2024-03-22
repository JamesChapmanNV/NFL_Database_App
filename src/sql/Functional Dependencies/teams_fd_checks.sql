-- abbreviation -> location holds
SELECT CASE
		WHEN count(abbreviation) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT abbreviation
		FROM teams
		GROUP BY abbreviation
		HAVING count(DISTINCT location) > 1) x;
		
-- abbreviation -> color holds
SELECT CASE
		WHEN count(abbreviation) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT abbreviation
		FROM teams
		GROUP BY abbreviation
		HAVING count(DISTINCT color) > 1) x;

-- abbreviation -> alternatecolor holds
SELECT CASE
		WHEN count(abbreviation) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT abbreviation
		FROM teams
		GROUP BY abbreviation
		HAVING count(DISTINCT alternatecolor) > 1) x;
		
-- abbreviation -> name holds
SELECT CASE
		WHEN count(abbreviation) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT abbreviation
		FROM teams
		GROUP BY abbreviation
		HAVING count(DISTINCT name) > 1) x;