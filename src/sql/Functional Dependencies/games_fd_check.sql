-- season_type -> week does not hold
SELECT CASE
		WHEN count(season_type) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT season_type
		FROM games
		GROUP BY season_type
		HAVING count(DISTINCT WEEK) > 1) x;

-- week -> season_type does not hold
SELECT CASE
		WHEN count(week) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT week
		FROM games
		GROUP BY week
		HAVING count(DISTINCT season_type) > 1) x;

-- week, date -> year holds
SELECT CASE
		WHEN count(week) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT week
		FROM games
		GROUP BY week, date
		HAVING count(DISTINCT year) > 1) x;	
		
-- date -> year holds
SELECT CASE
		WHEN count(date) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT date
		FROM games
		GROUP BY date
		HAVING count(DISTINCT year) > 1) x;

-- date, season_type -> week holds
SELECT CASE
		WHEN count(date) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT date
		FROM games
		GROUP BY date, season_type
		HAVING count(DISTINCT WEEK) > 1) x;
		
-- date -> game_id does not hold
SELECT CASE
		WHEN count(date) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT date
		FROM games
		GROUP BY date
		HAVING count(DISTINCT game_id) > 1) x;
		
-- Date -> week holds
SELECT CASE
		WHEN count(date) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT date
		FROM games
		GROUP BY date
		HAVING count(DISTINCT week) > 1) x;
		
-- Date, week, season_type -> game_id does not hold
SELECT CASE
		WHEN count(date) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT date
		FROM games
		GROUP BY date, week, season_type
		HAVING count(DISTINCT game_id) > 1) x;
		
-- date, week -> name does not hold
SELECT CASE
		WHEN count(date) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT date
		FROM games
		GROUP BY date, week
		HAVING count(DISTINCT name) > 1) x;
		
-- home_team_id, away_team_id -> name does not hold
SELECT CASE
		WHEN count(home_team_id) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT home_team_id
		FROM games
		GROUP BY home_team_id, away_team_id
		HAVING count(DISTINCT name) > 1) x;
		
-- Technically, this does not hold but it is due to differences in naming
select g1.away_team_id, g1.name, g2.name from
games g1, games g2
where g1.home_team_id = g2.home_team_id and g1.away_team_id = g2.away_team_id
and g1.name != g2.name

-- home_team_id, away_team_id -> game_id does not hold
SELECT CASE
		WHEN count(home_team_id) = 0 THEN 'true'
		ELSE 'false'
		END AS holds
FROM
	(SELECT home_team_id
		FROM games
		GROUP BY home_team_id, away_team_id
		HAVING count(DISTINCT game_id) > 1) x;