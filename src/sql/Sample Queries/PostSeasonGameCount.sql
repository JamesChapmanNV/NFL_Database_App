-- ***  post_season_game_count ***
-- For each team, count the number of postseason games played
-- There are 4 rounds of postseason games:
-- 		WildCard (similar to eighth-finals)
-- 		Divisional  (quarter-finals)
-- 		Conference (semi-finals)
-- 		SuperBowl (finals)
-- INPUT: 
-- OUTPUT: all teams with 6 columns
-- QUERY TYPE: Report 

/*Query explanation
****************************************
Find all games each team played in the postseason, as home_team or away_team.
Postseason games are identified by a season type
Postseason weeks are numbered 1-5, week 4 is Pro bowl (ignored)
****************************************

Sample Query result 

 team_name  | total_postseason_game_count | wildcard | divisional | conference | superbowl
------------+-----------------------------+----------+------------+------------+-----------
 Broncos    |                           8 |        0 |          4 |          2 |         2
 Packers    |                          15 |        4 |          7 |          4 |         0
 Bills      |                           9 |        5 |          3 |          1 |         0
 Steelers   |                           9 |        5 |          3 |          1 |         0
 Commanders |                           3 |        3 |          0 |          0 |         0
 Colts      |                           9 |        5 |          3 |          1 |         0
 49ers      |                          15 |        3 |          5 |          5 |         2
 Titans     |                           7 |        3 |          3 |          1 |         0
 Eagles     |                          11 |        4 |          3 |          2 |         2
 Patriots   |                          20 |        2 |          7 |          7 |         4
 Dolphins   |                           2 |        2 |          0 |          0 |         0
 Seahawks   |                          17 |        7 |          6 |          2 |         2
 Ravens     |                          11 |        5 |          4 |          1 |         1
 Chargers   |                           5 |        3 |          2 |          0 |         0
 Jaguars    |                           5 |        2 |          2 |          1 |         0
 Chiefs     |                          19 |        4 |          7 |          5 |         3
 Bears      |                           2 |        2 |          0 |          0 |         0
 Texans     |                           8 |        5 |          3 |          0 |         0
 Panthers   |                           7 |        2 |          3 |          1 |         1
 Saints     |                           9 |        4 |          4 |          1 |         0
 Cardinals  |                           4 |        2 |          1 |          1 |         0
 Rams       |                          10 |        3 |          3 |          2 |         2
 Lions      |                           2 |        2 |          0 |          0 |         0
 Cowboys    |                           8 |        4 |          4 |          0 |         0
 Falcons    |                           7 |        1 |          3 |          2 |         1
 Giants     |                           3 |        2 |          1 |          0 |         0
 Bengals    |                          11 |        6 |          2 |          2 |         1
 Vikings    |                           7 |        4 |          2 |          1 |         0
 Raiders    |                           2 |        2 |          0 |          0 |         0
 Buccaneers |                           7 |        3 |          2 |          1 |         1
 Browns     |                           2 |        1 |          1 |          0 |         0
(31 rows)

*/


SELECT team_name, 
	count (*) AS total_postseason_game_count,
    sum(CASE WHEN week=1 THEN 1 ELSE 0 END) AS WildCard,
    sum(CASE WHEN week=2 THEN 1 ELSE 0 END) AS Divisional,
    sum(CASE WHEN week=3 THEN 1 ELSE 0 END) AS Conference,
    sum(CASE WHEN week=5 THEN 1 ELSE 0 END) AS SuperBowl
FROM (
	SELECT g.home_team_name as team_name, sd.week
	FROM games g 
	JOIN season_dates sd ON g.date = sd.date
	WHERE sd.season_type = 'Post Season'
	
	Union ALL
	SELECT g.away_team_name as team_name, sd.week
	FROM games g 
	JOIN season_dates sd ON g.date = sd.date
	WHERE sd.season_type = 'Post Season') team_week
group by team_name;


