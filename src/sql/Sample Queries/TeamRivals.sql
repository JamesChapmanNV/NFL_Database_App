
-- Find all games between 2 given teams
-- QUERY TYPE: question 

SELECT g.date, 
	g.home_team_name, 
	g.away_team_name, 
	l1.score AS home_score, 
	l2.score AS away_score, 
	v.venue_name,
	v.city || ', ' || coalesce(v.state, 'UNKNOWN') AS location
FROM games g
JOIN (
    SELECT game_id, team_name, sum(score) AS score
    FROM linescores
    GROUP BY game_id, team_name
) l1 ON g.game_id = l1.game_id AND g.home_team_name = l1.team_name
JOIN (
    SELECT game_id, team_name, sum(score) AS score
    FROM linescores
    GROUP BY game_id, team_name
) l2 ON g.game_id = l2.game_id AND g.away_team_name = l2.team_name
JOIN venues v ON g.venue_name = v.venue_name
WHERE (g.home_team_name LIKE '%Texans%' OR g.away_team_name LIKE '%Texans%')
  AND (g.home_team_name LIKE '%Patriots%' OR g.away_team_name LIKE '%Patriots%')
ORDER BY g.date DESC;

/* SAMPLE OUTPUT


	date    | home_team_name | away_team_name | home_score | away_score |    venue_name    |    city    | state
------------+----------------+----------------+------------+------------+------------------+------------+-------
 2021-10-10 | Texans         | Patriots       |          6 |          0 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          0 |         10 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          0 |          6 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          0 |          9 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          0 |          0 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          7 |         10 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          7 |          6 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          7 |          9 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          7 |          0 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          9 |         10 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          9 |          6 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          9 |          9 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          9 |          0 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          6 |         10 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          6 |          6 | NRG Stadium      | Houston    | TX
 2021-10-10 | Texans         | Patriots       |          6 |          9 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          3 |          7 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          3 |          3 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          3 |          7 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          3 |          3 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          3 |          7 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          3 |          3 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          3 |          7 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          3 |          3 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |         14 |          3 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |         14 |          7 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |         14 |          3 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |         14 |          7 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          7 |          3 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          7 |          7 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          7 |          3 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |          7 |          7 | NRG Stadium      | Houston    | TX
 2019-12-02 | Texans         | Patriots       |          7 |          3 | NRG Stadium      | Houston    | TX
 2019-12-02 | Texans         | Patriots       |          7 |         13 | NRG Stadium      | Houston    | TX
 2019-12-02 | Texans         | Patriots       |          7 |          6 | NRG Stadium      | Houston    | TX
 2019-12-02 | Texans         | Patriots       |          7 |          0 | NRG Stadium      | Houston    | TX
 2019-12-02 | Texans         | Patriots       |          7 |          3 | NRG Stadium      | Houston    | TX
 2019-12-02 | Texans         | Patriots       |          7 |         13 | NRG Stadium      | Houston    | TX
 2019-12-02 | Texans         | Patriots       |          7 |          6 | NRG Stadium      | Houston    | TX
:

 2015-12-14 | Texans         | Patriots       |          3 |          3 | NRG Stadium      | Houston    | TX
 2015-12-14 | Texans         | Patriots       |          3 |         10 | NRG Stadium      | Houston    | TX
 2015-12-14 | Texans         | Patriots       |          3 |          7 | NRG Stadium      | Houston    | TX
 2015-12-14 | Texans         | Patriots       |          3 |          7 | NRG Stadium      | Houston    | TX
 2015-12-14 | Texans         | Patriots       |          3 |          3 | NRG Stadium      | Houston    | TX
 2015-12-14 | Texans         | Patriots       |          3 |         10 | NRG Stadium      | Houston    | TX
 2015-12-14 | Texans         | Patriots       |          3 |          7 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |         10 |          7 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |         13 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |         14 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |          0 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |          7 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |         13 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |         14 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |          0 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |          7 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |         13 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |         14 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |          0 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |          7 |          7 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |         10 |         13 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |         10 |         14 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |         10 |          0 | NRG Stadium      | Houston    | TX
 2013-01-13 | Patriots       | Texans         |         10 |          0 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |          7 |         10 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |          7 |          0 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |          7 |         15 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         10 |          3 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         10 |         10 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         10 |          0 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         10 |         15 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |          7 |          3 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         14 |          3 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         14 |         10 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         14 |          0 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         14 |         15 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         10 |          3 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         10 |         10 | Gillette Stadium | Foxborough | MA
 2013-01-13 | Patriots       | Texans         |         10 |         15 | Gillette Stadium | Foxborough | MA
(160 rows)




*/
