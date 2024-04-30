-- ***  weekly_receiving_stats ***
-- For each player, with receiving stats in a given week,
-- count the number of receiving yards.
-- INPUT: (%s,%s,%s) = (year, season_type, week) 
-- OUTPUT: all receivers with 4 columns
-- QUERY TYPE: Report 

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

Sample Query result (%s,%s,%s) = (2019, 'Regular Season', 10)

  game_id  | first_name |   last_name    | receiving_yards
-----------+------------+----------------+-----------------
 401127948 | Michael    | Thomas         |             167
 401127981 | Tyreek     | Hill           |             157
 401128041 | Amari      | Cooper         |             147
 401127976 | Christian  | Kirk           |             138
 401127944 | DJ         | Moore          |             120
 401127944 | Davante    | Adams          |             118
 401127952 | Darius     | Slayton        |             113
 401128041 | Dalvin     | Cook           |             110

(177 rows)

*/

SELECT g.game_id, a.first_name, a.last_name, SUM(yards) as Receiving_yards
FROM player_plays pp
JOIN plays p ON pp.play_id = p.play_id
JOIN athletes a ON pp.player_id = a.athlete_id
JOIN games g ON pp.game_id = g.game_id
JOIN season_dates s ON g.date = s.date
WHERE type='receiver'
	AND season_year = %s
	AND season_type = %s
	AND week = %s
	AND play_type in ('Pass',
					'Rush',
					'Fumble Recovery (Own)',
					'Pass Reception',
					'Passing Touchdown')
Group by player_id, g.game_id, a.first_name, a.last_name
ORDER BY SUM(yards) DESC;
