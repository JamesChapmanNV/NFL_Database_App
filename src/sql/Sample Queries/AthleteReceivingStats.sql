-- ***  athlete_receiving_stats ***
-- When given athletes_id, find receiving stats, for each week.
-- INPUT: (%s) = (athletes_id) 
-- OUTPUT: all game 2 with receiving stats with 6 columns
-- QUERY TYPE: Question 

/*Query explanation
****************************************
Receiving yards are found in the play-by-play data (plays table).

However, we must use the player_plays table to find all players that acted
as a receiver (identified by player_plays.type='receiver'.)

Also, the attribute (plays.play_type) must be in the following list:
('Pass','Rush','Fumble Recovery (Own)','Pass Reception','Passing Touchdown')

This might seem redundant, however, the difference can be explained by:
A player acts as a receiver (player_plays.type='receiver') 
but the offense receives a penalty (plays.play_type='penalty') of 10 yards.
The athlete does not receive a -10 yard passing play.

There are other types (incomplete pass, interception, etc.), but this works.

****************************************

Sample Query result (%s) = (13982)

first_name | last_name | season_year |  season_type   | week | receiving_yards
------------+-----------+-------------+----------------+------+-----------------
 Julio      | Jones     |        2023 | Regular Season |   17 |              34
 Julio      | Jones     |        2023 | Regular Season |   16 |               5
 Julio      | Jones     |        2023 | Regular Season |   15 |               6
 Julio      | Jones     |        2023 | Regular Season |   12 |               0
 Julio      | Jones     |        2023 | Regular Season |   11 |               5
 Julio      | Jones     |        2023 | Regular Season |    8 |               8
 Julio      | Jones     |        2023 | Regular Season |    7 |               3
 Julio      | Jones     |        2022 | Regular Season |   17 |              10
 Julio      | Jones     |        2022 | Regular Season |   16 |               0

(134 rows)


*/
SELECT a.first_name || ' ' || a.last_name AS name, s.season_year, s.season_type, s.week, SUM(yards) as Receiving_yards
FROM player_plays pp
JOIN plays p ON pp.play_id = p.play_id
JOIN athletes a ON pp.player_id = a.athlete_id
JOIN games g ON pp.game_id = g.game_id
JOIN season_dates s ON g.date = s.date
WHERE a.athlete_id=%s
	AND pp.type='receiver'
	AND p.play_type in ('Pass',
						'Rush',
						'Fumble Recovery (Own)',
						'Pass Reception',
						'Passing Touchdown')
Group by a.athlete_id, a.first_name, a.last_name, s.season_year, s.season_type, s.week
ORDER BY s.season_year DESC, s.season_type DESC, s.week DESC;