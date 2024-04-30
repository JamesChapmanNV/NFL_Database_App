-- ***  team_rivals ***
-- Find all games between 2 given teams
-- INPUT: (%s,%s,%s,%s) = (team1, team2, team2, team1) 
-- OUTPUT: all games with 8 columns, ordered by date desc
-- QUERY TYPE: Question 

/*Query explanation
****************************************
This query requires 1 VIEW named 'all_final_game_scores'
VIEW 'all_final_game_scores' produces 6 attributes for each game:
	-game_id 
	-home_team_name
	-home_team_score
	-away_team_name
	-away_team_score
	-home_winner_bool (true if home team wins, NULL if tie )
****************************************

Sample Query result (%s,%s,%s,%s) = (Texans, Patriots, Texans, Patriots)

    date    | home_team_name | away_team_name | home_team_score | away_team_score |    venue_name    |    city    | state
------------+----------------+----------------+-----------------+-----------------+------------------+------------+-------
 2021-10-10 | Texans         | Patriots       |              22 |              25 | NRG Stadium      | Houston    | TX
 2020-11-22 | Texans         | Patriots       |              27 |              20 | NRG Stadium      | Houston    | TX
 2019-12-02 | Texans         | Patriots       |              28 |              22 | NRG Stadium      | Houston    | TX
 2018-09-09 | Patriots       | Texans         |              27 |              20 | Gillette Stadium | Foxborough | MA
 2017-09-24 | Patriots       | Texans         |              36 |              33 | Gillette Stadium | Foxborough | MA
 2017-01-15 | Patriots       | Texans         |              34 |              16 | Gillette Stadium | Foxborough | MA
 2016-09-23 | Patriots       | Texans         |              27 |               0 | Gillette Stadium | Foxborough | MA
 2015-12-14 | Texans         | Patriots       |               6 |              27 | NRG Stadium      | Houston    | TX
 2013-12-01 | Texans         | Patriots       |              31 |              34 | NRG Stadium      | Houston    | TX
 2013-01-13 | Patriots       | Texans         |              41 |              28 | Gillette Stadium | Foxborough | MA
(10 rows)

*/

SELECT g.date, 
	g.home_team_name, 
	g.away_team_name, 
	a.home_team_score, 
	a.away_team_score, 
	v.venue_name,
	v.city,
	v.state
FROM games g
JOIN all_final_game_scores a ON g.game_id = a.game_id
JOIN venues v ON g.venue_name = v.venue_name
WHERE (g.home_team_name LIKE %s OR g.away_team_name LIKE %s)
  AND (g.home_team_name LIKE %s OR g.away_team_name LIKE %s)
ORDER BY g.date DESC;

