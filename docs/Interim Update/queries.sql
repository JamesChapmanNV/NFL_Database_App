/*
	Kansas State University
	CIS 761: Database Management Systems
	NFL Database Project - Interim Project Update 

	Vishnu Bondalakunta
	Chuck Zumbaugh
	James Chapman

*/



/******************************************************************************
**** THIS IS A VIEW !!!                                                     ***
**** all_final_game_scores                                                  ***
*******************************************************************************
2 views were created and used in 3 queries.  The database lists the scores, of 
each quarter, of each game (linescores table). These views make the queries 
easier to understand and saves time writing queries.
Also, it's good practice, as a beginner.

VIEW explanation
****************************************
all_final_game_scores produces 6 attributes FOR EACH GAME:
	-game_id 
	-home_team_name
	-home_team_score
	-away_team_name
	-away_team_score
	-home_winner_bool (true if home team wins, NULL if tie )

TeamScores is a CTE  meant to find all scores, of each game, of each team.
This is because the table 'linescores' must be aggregated on score attribute.
'linescores' is organized by game_id & team_name, 
therefore requiring a self join of the TeamScores CTE (HOME & AWAY).

The first instance of TeamScores matches games.home_team_name 
The 2nd instance of TeamScores matches games.away_team_name

The attribute 'home_winner_bool' is created & produces
True if home team wins, NULL if the result is a tie
****************************************
*/
CREATE VIEW all_final_game_scores AS
WITH TeamScores AS (
    SELECT game_id, team_name, SUM(score) AS team_score
    FROM linescores
    GROUP BY game_id, team_name
)
	SELECT x.game_id, 
	x.home_team_name, 
	y.team_score AS home_team_score, 
	x.away_team_name, 
	z.team_score AS away_team_score,
    CASE
        WHEN y.team_score > z.team_score THEN TRUE
        WHEN y.team_score < z.team_score THEN FALSE
        ELSE NULL 
    END AS home_winner_bool
FROM games x
LEFT JOIN TeamScores y 
	ON x.game_id = y.game_id 
	AND x.home_team_name = y.team_name 
LEFT JOIN TeamScores z
	ON x.game_id = z.game_id 
	AND x.away_team_name = z.team_name ;

/******************************************************************************
**** THIS IS A VIEW !!!                                                     ***
**** all_third_quarter_scores                                               ***
*******************************************************************************
2 views were created and used in 3 queries.  The database lists the scores, of 
each quarter, of each game (linescores table). These views make the queries 
easier to understand and saves time writing queries.
Also, it's good practice, as a beginner.

VIEW explanation
****************************************
VIEW 'all_third_quarter_scores' produces 6 attributes for each game:
	-game_id 
	-home_team_name 
	-home_team_score (at end of 3rd quarter)
	-away_team_name
	-away_team_score (at end of 3rd quarter)
	-away_team_winng_bool (true if AWAY team is currently winning, NULL if tie )

ThirdQuarterTeamScores is a CTE meant to find all scores (AT THE END OF 3RD 
QUARTER), of each game, of each team.
This filters the linescores WHERE quarter <= 3.

The first instance of ThirdQuarterTeamScores matches games.home_team_name
The 2nd instance of ThirdQuarterTeamScores matches games.away_team_name

The attribute 'away_team_winng_bool' is created & produces
True if AWAY team IS WINNING, NULL if there is currently a tie
****************************************
*/
CREATE VIEW all_third_quarter_scores AS
WITH ThirdQuarterTeamScores AS (
    SELECT game_id, team_name, SUM(score) AS team_score
    FROM linescores
	WHERE quarter <= 3
    GROUP BY game_id, team_name
)
	SELECT x.game_id, 
	x.home_team_name, 
	y.team_score AS home_team_score, 
	x.away_team_name, 
	z.team_score AS away_team_score,
    CASE
        WHEN y.team_score < z.team_score THEN TRUE
        WHEN y.team_score > z.team_score THEN FALSE
        ELSE NULL 
    END AS away_team_winng_bool
FROM games x
LEFT JOIN ThirdQuarterTeamScores y 
	ON x.game_id = y.game_id 
	AND x.home_team_name = y.team_name 
LEFT JOIN ThirdQuarterTeamScores z
	ON x.game_id = z.game_id 
	AND x.away_team_name = z.team_name ;


/******************************************************************************
**** weekly_receiving_stats                                                 ***
*******************************************************************************
-- For each player, with receiving stats in a given week,
-- count the number of receiving yards.
-- INPUT: (%s,%s,%s) = (year, season_type, week) 
-- OUTPUT: all receivers with 4 columns
-- QUERY TYPE: Report 

Query explanation
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

+---------+--------------+---------------+
|game_id  |name          |receiving_yards|
+---------+--------------+---------------+
|401127948|Michael Thomas|167            |
|401127981|Tyreek Hill   |157            |
|401128041|Amari Cooper  |147            |
|401127976|Christian Kirk|138            |
|401127944|DJ Moore      |120            |
+---------+--------------+---------------+

(177 rows)
*/
SELECT g.game_id, a.first_name || ' ' || a.last_name AS name, SUM(yards) as Receiving_yards
FROM player_plays pp
JOIN plays p ON pp.play_id = p.play_id
JOIN athletes a ON pp.player_id = a.athlete_id
JOIN games g ON pp.game_id = g.game_id
JOIN season_dates s ON g.date = s.date
WHERE type='receiver'
	AND season_year = 2019
	AND season_type = 'Regular Season'
	AND week = 10
	AND play_type in ('Pass',
					'Rush',
					'Fumble Recovery (Own)',
					'Pass Reception',
					'Passing Touchdown')
Group by player_id, g.game_id, a.first_name, a.last_name
ORDER BY SUM(yards) DESC;

/******************************************************************************
**** athlete_receiving_stats                                                ***
*******************************************************************************
-- When given athletes_id, find receiving stats, for each week.
-- INPUT: (%s) = (athletes_id) 
-- OUTPUT: all games with receiving stats - 6 columns
-- QUERY TYPE: Question 

Query explanation
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

+-----------+-----------+--------------+----+---------------+
|name       |season_year|season_type   |week|receiving_yards|
+-----------+-----------+--------------+----+---------------+
|Julio Jones|2023       |Regular Season|17  |34             |
|Julio Jones|2023       |Regular Season|16  |5              |
|Julio Jones|2023       |Regular Season|15  |6              |
|Julio Jones|2023       |Regular Season|12  |0              |
|Julio Jones|2023       |Regular Season|11  |5              |
+-----------+-----------+--------------+----+---------------+

(134 rows)
*/
SELECT a.first_name || ' ' || a.last_name AS name, s.season_year, s.season_type, s.week, SUM(yards) as Receiving_yards
FROM player_plays pp
JOIN plays p ON pp.play_id = p.play_id
JOIN athletes a ON pp.player_id = a.athlete_id
JOIN games g ON pp.game_id = g.game_id
JOIN season_dates s ON g.date = s.date
WHERE a.athlete_id=13982
	AND pp.type='receiver'
	AND p.play_type in ('Pass',
						'Rush',
						'Fumble Recovery (Own)',
						'Pass Reception',
						'Passing Touchdown')
Group by a.athlete_id, a.first_name, a.last_name, s.season_year, s.season_type, s.week
ORDER BY s.season_year DESC, s.season_type DESC, s.week DESC;

/******************************************************************************
**** post_season_game_count                                                 ***
*******************************************************************************
-- For each team, count the number of postseason games played
-- There are 4 rounds of postseason games:
-- 		WildCard (similar to eighth-finals)
-- 		Divisional  (quarter-finals)
-- 		Conference (semi-finals)
-- 		SuperBowl (finals)
-- INPUT: 
-- OUTPUT: all teams with 6 columns
-- QUERY TYPE: Report 

Query explanation
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

/******************************************************************************
**** avg_pts_grass_indoor                                                   ***
*******************************************************************************
-- average points based on grass/turf & indoor/outdoor
-- indoor games seems to have greater points
-- grass/turf seems to not matter
-- INPUT: 
-- OUTPUT: average points scored 
-- QUERY TYPE: Report 

Query explanation
****************************************
Simple idea, how does indoor/outdoor affect total points?
How does grass/turf affect total points?
****************************************

Sample Query result 

 field |  venue  | avg_total_points
-------+---------+------------------
 Turf  | Indoor  |             48.2
 Grass | Indoor  |             47.4
 Turf  | Outdoor |             44.8
 Grass | Outdoor |             44.8
(4 rows)

*/

SELECT
    CASE
        WHEN v.grass THEN 'Grass'
        ELSE 'Turf'
    END AS field,
    CASE
        WHEN v.indoor THEN 'Indoor'
        ELSE 'Outdoor'
	END AS venue,
	ROUND( AVG(gs.home_team_score + gs.away_team_score), 1) AS avg_total_points
FROM all_final_game_scores gs
JOIN games g ON gs.game_id = g.game_id
JOIN venues v ON g.venue_name = v.venue_name
GROUP BY v.grass,v.indoor
ORDER BY avg_total_points DESC;

/******************************************************************************
**** team_rivals                                                            ***
*******************************************************************************
-- Find all games and info between 2 given teams
-- INPUT: (%s,%s,%s,%s) = (team1, team2, team2, team1) 
-- OUTPUT: all games with 8 columns, ordered by date desc
-- QUERY TYPE: Question 

Query explanation
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

Sample Query result (%s,%s,%s,%s) = (Texans, Patriots, Patriots, Texans)

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
WHERE (g.home_team_name LIKE '%Texans%' OR g.away_team_name LIKE '%Texans%')
  AND (g.home_team_name LIKE '%Patriots%' OR g.away_team_name LIKE '%Patriots%')
ORDER BY g.date DESC;



/******************************************************************************
**** top_comeback_wins                                                      ***
*******************************************************************************
-- Top 10 teams with the MOST 4th-quarter comeback wins
-- Definition of '4th-quarter comeback win': 
-- 		team is losing at end of 3rd-quarter, & wins the game
-- INPUT: (%s,%s) = (year, year) [range of years requested]
-- OUTPUT: 10 teams with 4 columns, ordered by num_of_comebacks
-- 		-team_name
-- 		-num_of_comebacks-	number of games with comeback wins
-- 		-primary_color
-- 		-secondary_color
-- QUERY TYPE: Question 

Query explanation
****************************************
This query requires 2 VIEWs named 'all_final_game_scores' & 'all_third_quarter_scores'
VIEW 'all_final_game_scores' produces 6 attributes for each game:
	-game_id 
	-home_team_name
	-home_team_score
	-away_team_name
	-away_team_score
	-home_winner_bool (true if home team wins, NULL if tie )

VIEW 'all_third_quarter_scores' produces 6 attributes for each game:
	-game_id 
	-home_team_name 
	-home_team_score (at end of 3rd quarter)
	-away_team_name
	-away_team_score (at end of 3rd quarter)
	-away_team_winng_bool (true if AWAY team is currently winning, NULL if tie )
****************************************

ComebackWins is a CTE  meant to find all games under the condition that
the WINNER of the game was LOSING at the end of the 3rd quarter.
ComebackWins produces the game_id and team_name (team that wins).

ComebackWins is joined with 'games' & 'season_dates' in order to filter by year.
This is joined with 'teams' to provide primary_color & secondary_color.

The "key" is to GROUP BY comebackwins.team_name & COUNT(*) AS comebacks,
This will produce the desired NUMBER OF GAMES EACH TEAM WON
& were LOSING at the end of the 3rd quarter.

****************************************
Sample Query result (%s,%s) = (2019, 2019)

 team_name | comebacks | primary_color | secondary_color
-----------+-----------+---------------+-----------------
 Texans    |         4 | 00143f        | c41230
 Seahawks  |         3 | 002a5c        | 69be28
 Bills     |         3 | 00338d        | d50a0a
 49ers     |         2 | aa0000        | b3995d
 Chiefs    |         2 | e31837        | ffb612
 Colts     |         2 | 003b75        | ffffff
 Saints    |         2 | d3bc8d        | 000000
 Jaguars   |         2 | 007487        | d7a22a
 Falcons   |         2 | a71930        | 000000
 Packers   |         2 | 204e32        | ffb612
(10 rows)

*/

WITH ComebackWins AS (
	SELECT x.game_id, 
		CASE
			WHEN x.home_winner_bool = TRUE THEN x.home_team_name
			WHEN x.home_winner_bool = FALSE THEN x.away_team_name
			ELSE NULL 
		END AS team_name
	FROM all_final_game_scores x
	JOIN all_third_quarter_scores y 
		ON x.game_id = y.game_id 
		AND x.home_winner_bool = y.away_team_winng_bool
)
SELECT
    c.team_name,
    COUNT(*) AS comebacks,
	t.primary_color,
	t.secondary_color
FROM ComebackWins c
LEFT JOIN games g ON c.game_id = g.game_id 
LEFT JOIN season_dates s ON g.date = s.date
LEFT JOIN teams t ON c.team_name = t.team_name
WHERE s.season_year BETWEEN 2019 AND 2019
GROUP BY c.team_name,t.primary_color,t.secondary_color
ORDER BY comebacks DESC
LIMIT 10;


/******************************************************************************
**** win_probability                                                        ***
*******************************************************************************
-- Query produces table with 3rd quarter scores of all games played by a given 
-- team (from input), AND whether that team won the game (Boolean).
-- 
-- The result is used, in the app, to find the probability of a given team 
-- (from input) to win the game based on the score at the end of the 3rd 
-- quarter (from input).
-- More explanation below.
-- 
-- APP INPUT: (team_name,  team_name_score_3rd_quarter,  opponent_score) 
-- QUERY INPUT: (%s) = (team_name) 
-- OUTPUT: all games played by input team, with 3 columns
-- 		-third_quarter_team_scores- score of input team
-- 		-opponent_scores- score of opponent, same game
-- 		-winner_bool- if input team wins, NULL if tie
-- QUERY TYPE: Question 

Query explanation
********************
This query requires 2 VIEWs 
VIEW 'all_final_game_scores' produces 6 attributes for each game:
	-game_id 
	-home_team_name
	-home_team_score
	-away_team_name
	-away_team_score
	-home_winner_bool (true if home team wins, NULL if tie )

VIEW 'all_third_quarter_scores' produces 6 attributes for each game:
	-game_id 
	-home_team_name 
	-home_team_score (at end of 3rd quarter)
	-away_team_name
	-away_team_score (at end of 3rd quarter)
	-away_team_winng_bool (true if AWAY team is currently winning, NULL if tie )
****************************************

This query is split into 2 subqueries, to find all games that input team
played as home team, and games played as away team.

Each subquery joins the 2 views (all_final_game_scores & all_third_quarter_scores)
and matches the input team name to home_team_name/away_team_name, respectively.

Note the NOT operator on the away team subquery (bottom).  This is because
all_final_game_scores.home_winner_bool is true if the home team wins.

****************************************
Sample Query result (%s) = (Texans)

 third_quarter_team_scores | opponent_scores | winner_bool
---------------------------+-----------------+-------------
                        20 |               6 | f
                         8 |              14 | f
                        14 |              24 | f
                        14 |              10 | t
                        17 |               3 | t
                        20 |               7 | t
                        21 |              16 | t
                        33 |               3 | t
                        20 |              24 | f
. . .
(186 rows)

*******************************************************************************
IN APP PROCESSING OF QUERY 
(logistic regression, unique to each team)

The input of this application command requires the team (used above), and the 
current LIVE 3rd quarter team score & opponent score. This is meant to be used 
at the end of the 3rd quarter, of a live game. 

The idea comes from the fact that certain teams tend to have better/worse 4th 
quarter performances. So each team has its unique probability distribution. 
Although this model is slightly naive (more features are required, etc.), 
this is a good proof of concept.

FURTHER, this brings up the topic of database choice. PostgreSQL does not offer 
in-database machine learning. Ideally, logistic regression like this would run
within the database engine, on server.

INPUTS
team_name- team of interest
team_score- input of current 3rd quarter team score
opponent_score- input of current 3rd quarter opponents score

SAMPLE CODE FROM APPLICATION
df = pd.DataFrame(self.last_result, columns=['third_quarter_team_scores', 
                                            'opponent_scores', 'winner_bool'])
df.loc[(df['winner_bool']=='f'),'winner_bool']= -1 # given team wins
df.loc[(df['winner_bool']=='t'),'winner_bool']= 1 # opponent wins
df.loc[(df['winner_bool'].isnull()),'winner_bool']= 0 # tie
df.fillna(0, inplace=True)
df['winner_bool'] = df['winner_bool'].astype('int64')
X = df[['third_quarter_team_scores', 'opponent_scores']] # features
y = df['winner_bool']  # Targets where -1 = away win, 0 = tie, 1 = home win
model = LogisticRegression(multi_class='multinomial', solver='lbfgs').fit(X.values, y.values)
probabilities = model.predict_proba([[team_score, opponent_score]])[0]
given_team_index = np.where(model.classes_==1)[0][0]
# display results
print(f'Given a score of {team_score} to {opponent_score},')
print(f'The probability of the {team_name} winning is {round(probabilities[given_team_index]*100, 1)}%')
****************************************

Sample app results


> Win_probability Texans 8 25
Given a score of 8 to 25,
The probability of the Texans winning is 2.7%

> Win_probability Texans 25 8
Given a score of 25 to 8,
The probability of the Texans winning is 96.0%

> Win_probability Texans 15 12
Given a score of 15 to 12,
The probability of the Texans winning is 64.0%

> Win_probability Texans 15 8
Given a score of 15 to 8,
The probability of the Texans winning is 81.6%

> Win_probability Dolphins 25 25
Given a score of 25 to 25,
The probability of the Dolphins winning is 55.4%

> Win_probability Raiders 25 25
Given a score of 25 to 25,
The probability of the Raiders winning is 57.8%

> Win_probability Panthers 25 25
Given a score of 25 to 25,
The probability of the Panthers winning is 40.3%

> Win_probability Patriots 25 25
Given a score of 25 to 25,
The probability of the Patriots winning is 71.8%

*/

SELECT y.home_team_score AS third_quarter_team_scores, 
		y.away_team_score AS opponent_scores, 
		x.home_winner_bool AS winner_bool
FROM all_final_game_scores x
JOIN all_third_quarter_scores y 
	ON x.game_id = y.game_id 
WHERE y.home_team_name = 'Texans'
UNION ALL
SELECT y.away_team_score AS third_quarter_team_scores, 
		y.home_team_score AS opponent_scores, 
		NOT x.home_winner_bool AS winner_bool
FROM all_final_game_scores x
JOIN all_third_quarter_scores y 
	ON x.game_id = y.game_id  
WHERE y.away_team_name = 'Texans';

/*
Find all games where the total number of points scored in the first quarter is greater than
the total number of points scored in any other quarter.

Query Type: Report
*/

SELECT g.game_id, g.date, g.home_team_name, g.away_team_name
FROM Games g
JOIN (SELECT game_id,
             SUM(CASE WHEN quarter = 1 THEN score ELSE 0 END) AS first_quarter_score,
             SUM(CASE WHEN quarter = 2 THEN score ELSE 0 END) AS second_quarter_score,
             SUM(CASE WHEN quarter = 3 THEN score ELSE 0 END) AS third_quarter_score,
             SUM(CASE WHEN quarter = 4 THEN score ELSE 0 END) AS fourth_quarter_score
      FROM Linescores
      GROUP BY game_id) ls ON g.game_id = ls.game_id
WHERE first_quarter_score > GREATEST(second_quarter_score, third_quarter_score, fourth_quarter_score);

/*
Truncated Output:

+---------+----------+--------------+--------------+
|game_id  |date      |home_team_name|away_team_name|
+---------+----------+--------------+--------------+
|330106028|2013-01-06|Commanders    |Seahawks      |
|330112007|2013-01-12|Broncos       |Ravens        |
|330908030|2013-09-08|Jaguars       |Chiefs        |
|330909028|2013-09-09|Commanders    |Eagles        |
|330912017|2013-09-13|Patriots      |Jets          |
|330915012|2013-09-15|Chiefs        |Cowboys       |
|330915027|2013-09-15|Buccaneers    |Saints        |
|330929013|2013-09-29|Raiders       |Commanders    |
|331006011|2013-10-06|Colts         |Seahawks      |
|331006025|2013-10-07|49ers         |Texans        |
+---------+----------+--------------+--------------+

*/

/*
Find information about the requested game, including scores and winner. The winner's primary
and secondary colors are returned.

Query Type: Question
*/

SELECT g.*,
       home_score.final_score_home,
       away_score.final_score_away,
       CASE
           WHEN home_score.final_score_home > away_score.final_score_away THEN home.primary_color
           ELSE away.primary_color END   AS primary_color,
       CASE
           WHEN home_score.final_score_home > away_score.final_score_away THEN home.secondary_color
           ELSE away.secondary_color END AS secondary_color
FROM games g
         JOIN (SELECT game_id, team_name, SUM(score) AS final_score_home
               FROM linescores
               GROUP BY game_id, team_name) home_score
              ON home_score.game_id = g.game_id AND home_score.team_name = g.home_team_name
         JOIN (SELECT game_id, team_name, SUM(score) AS final_score_away
               FROM linescores
               GROUP BY game_id, team_name) away_score
              ON away_score.game_id = g.game_id AND away_score.team_name = g.away_team_name
         JOIN teams home ON home.team_name = g.home_team_name
         JOIN teams away ON away.team_name = g.away_team_name
WHERE g.game_id = 330106033
  AND home_score.team_name = g.home_team_name
  AND away_score.team_name = g.away_team_name;

/*
Results:
  
+---------+----------+----------+--------------+--------------+----------------+--------+----------------+----------------+-------------+---------------+
|game_id  |date      |attendance|home_team_name|away_team_name|venue_name      |utc_time|final_score_home|final_score_away|primary_color|secondary_color|
+---------+----------+----------+--------------+--------------+----------------+--------+----------------+----------------+-------------+---------------+
|330106033|2013-01-06|0         |Ravens        |Colts         |M&T Bank Stadium|18:00:00|24              |9               |29126f       |9e7c0c         |
+---------+----------+----------+--------------+--------------+----------------+--------+----------------+----------------+-------------+---------------+
  
*/

/*
 Which stadium(s) has the most home wins in a given season year (has the greatest home-field advantage).
 A home win is counted when the team is playing at their home stadium, which may or may not be when
 they are considered the home team (for example in an international game). Additionally, only regular season
 games are considered.

 Query Type: Question
*/

WITH results AS (SELECT v.venue_name, t.team_name, SUM(CASE WHEN home_score > away_score THEN 1 ELSE 0 END) AS num_wins
               FROM venues v
                        JOIN teams t ON t.venue_name = v.venue_name
                        JOIN games g ON g.home_team_name = t.team_name AND g.venue_name = v.venue_name
                        JOIN (SELECT team_name, game_id, SUM(score) AS home_score
                              FROM linescores
                              GROUP BY team_name, game_id) AS home
                             ON home.game_id = g.game_id AND home.team_name = t.team_name
                        JOIN (SELECT team_name, game_id, SUM(score) AS away_score
                              FROM linescores
                              GROUP BY team_name, game_id) AS away
                             ON away.game_id = g.game_id AND away.team_name = g.away_team_name
               JOIN season_dates sd ON sd.date = g.date
               WHERE sd.season_year = 2022 AND sd.season_type = 'Regular Season'
               GROUP BY v.venue_name, t.team_name)
SELECT *
FROM results
WHERE num_wins >= ALL (SELECT num_wins
                     FROM results);
					 
/*
+-----------------+---------+--------+
|venue_name       |team_name|num_wins|
+-----------------+---------+--------+
|AT&T Stadium     |Cowboys  |8       |
|Levi's Stadium   |49ers    |8       |
|U.S. Bank Stadium|Vikings  |8       |
+-----------------+---------+--------+

*/

/*
This query retrieves statistics and calculates passer rating for NFL players in a season year.

Selecting player information along with calculated statistics and passer rating.
 
Passing Yards: This refers to the total number of yards gained by a team's offense through completed passes.

Pass Attempts: A pass attempt occurs when the quarterback throws the ball with the intention of completing a forward pass to a teammate. Pass attempts include both completed passes and incomplete passes 

Pass Completions: A pass completion happens when the quarterback successfully throws the ball to a teammate, and the teammate catches the ball without it touching the ground.

Touchdown Passes: This refers to the number of passes thrown by the quarterback that result in a touchdown.

Interceptions: An interception occurs when a defensive player catches a pass thrown by the quarterback intended for an offensive player.

Query Type: Report
*/

 SELECT 
     -- Selecting player ID, first name, and last name.
     a.athlete_id AS player_id, 
     a.first_name || ' ' || a.last_name AS name,
     -- Selecting passing yards, pass attempts, pass completions, touchdown passes, interceptions, and passer rating.
     passing_yards, 
     pass_attempts, 
     pass_completions, 
     touchdown_passes, 
     passes_intercepted,
     -- Calculating passer rating based on the NFL formula.
     ROUND(
         CASE WHEN pass_attempts > 0 -- Ensuring there are passing attempts to avoid division by zero.
             THEN (
                 (
                     -- Calculating completion percentage component of passer rating.
                     LEAST(GREATEST(((pass_completions / pass_attempts) - 0.3) * 5, 0), 2.375) +
                     -- Calculating yards per attempt component of passer rating.
                     LEAST(GREATEST(((passing_yards / pass_attempts) - 3) * 0.25, 0), 2.375) +
                     -- Calculating touchdown pass component of passer rating.
                     LEAST(GREATEST(((touchdown_passes / pass_attempts) * 20), 0), 2.375) +
                     -- Calculating interception component of passer rating.
                     LEAST(GREATEST((2.375 - (passes_intercepted / pass_attempts) * 25), 0), 2.375)
                 ) / 6
             ) * 100
             ELSE 0 -- If there are no passing attempts, set passer rating to 0.
         END, 1 -- Rounding the calculated passer rating to one decimal place.
     ) AS passer_rating
 -- Subquery to calculate intermediate statistics for each player.
 FROM (
     -- Selecting player ID along with aggregated statistics for passing attempts, completions, touchdowns, interceptions, and passing yards.
     SELECT 
         pp.player_id,
         SUM(CASE WHEN p.play_type = 'Pass Interception Return' THEN 1 ELSE 0 END) AS passes_intercepted,
         SUM(CASE WHEN p.play_type = 'Passing Touchdown' THEN 1 ELSE 0 END) AS touchdown_passes,
         SUM(CASE WHEN p.play_type IN ('Pass Reception', 'Passing Touchdown') THEN 1 ELSE 0 END) AS pass_completions,
         SUM(1) AS pass_attempts,
         SUM(p.yards) AS passing_yards
     FROM 
         player_plays pp -- Joining player_plays table to access player-specific plays.
     JOIN 
         plays p ON pp.play_id = p.play_id -- Joining plays table to access play information.
     JOIN 
         games g ON pp.game_id = g.game_id -- Joining games table to access game information.
     WHERE 
         EXTRACT(YEAR FROM g.date) = 2015 -- Filtering games from the year 2015.
         AND pp.type = 'passer' -- Selecting only players who are passers.
         AND (p.play_type IN ('Pass Reception', 'Passing Touchdown', 'Pass Incompletion', 'Pass Interception Return')) -- Filtering relevant play types.
     GROUP BY 
         pp.player_id -- Grouping statistics by player ID.
 ) AS stats -- Alias for the subquery to refer to its results.
 JOIN 
     athletes a ON stats.player_id = a.athlete_id -- Joining athletes table to access player names.
 ORDER BY 
     passing_yards DESC; -- Ordering the results by passing yards in descending order.
	 
/*
Truncated Results:
	 
+---------+--------------+-------------+-------------+----------------+----------------+------------------+-------------+
|player_id|name          |passing_yards|pass_attempts|pass_completions|touchdown_passes|passes_intercepted|passer_rating|
+---------+--------------+-------------+-------------+----------------+----------------+------------------+-------------+
|2330     |Tom Brady     |5602         |752          |491             |46              |10                |56.3         |
|2580     |Drew Brees    |4646         |586          |396             |31              |10                |56.3         |
|14881    |Russell Wilson|4612         |524          |348             |37              |13                |60.4         |
|5529     |Philip Rivers |4606         |621          |415             |27              |7                 |56.3         |
|4459     |Carson Palmer |4554         |520          |329             |34              |10                |60.4         |
+---------+--------------+-------------+-------------+----------------+----------------+------------------+-------------+

*/

/*
Find the % of the stadium that is filled for a given game.
	 
Query Type: Question	 
*/

SELECT ROUND(CAST(g.attendance AS DECIMAL) / CAST(v.capacity AS DECIMAL) * 100, 2) AS percent_fill
FROM games g
      JOIN venues v ON v.venue_name = g.venue_name
WHERE g.game_id = 330915001;

/*
Results:

98.35
*/

/*
Find the plays made by a given player in a given game.

Query Type: Report
*/

SELECT p.text,
       p.quarter,
       p.seconds_remaining,
       p.yards,
       p.score_value,
       p.play_type,
       p.start_down,
       p.end_down
FROM games g
         JOIN player_plays pp ON pp.game_id = g.game_id
         JOIN plays p ON p.play_id = pp.play_id
         JOIN athletes a ON a.athlete_id = pp.player_id
WHERE g.game_id = 401547557 AND a.athlete_id = 4361529;

/*
Truncated Results:

+-----------------------------------------------------------------------------------------------------------------------------+-------+-----------------+-----+-----------+-----------------+----------+--------+
|text                                                                                                                         |quarter|seconds_remaining|yards|score_value|play_type        |start_down|end_down|
+-----------------------------------------------------------------------------------------------------------------------------+-------+-----------------+-----+-----------+-----------------+----------+--------+
|(Shotgun) P.Mahomes pass short left to I.Pacheco to KC 14 for -11 yards (B.Nichols).                                         |1      |572              |-11  |0          |Pass Reception   |1         |2       |
|(Shotgun) P.Mahomes pass short left to I.Pacheco to KC 31 for 11 yards (N.Hobbs).                                            |1      |32               |11   |0          |Pass Reception   |1         |1       |
|(Shotgun) I.Pacheco left end to KC 32 for 1 yard (N.Hobbs, R.Spillane).                                                      |2      |900              |1    |0          |Rush             |1         |2       |
|(Shotgun) I.Pacheco left tackle to KC 45 for 4 yards (J.Robinson, J.Jenkins).                                                |2      |716              |4    |0          |Rush             |1         |2       |
|(Shotgun) I.Pacheco up the middle for 1 yard, TOUCHDOWN.H.Butker extra point is GOOD, Center-J.Winchester, Holder-T.Townsend.|2      |398              |1    |6          |Rushing Touchdown|3         |0       |
+-----------------------------------------------------------------------------------------------------------------------------+-------+-----------------+-----+-----------+-----------------+----------+--------+

*/

/*
Search for a given athlete, along with their current team. The current team is defined here as
the last team that they have played for. Because the roster dates are somewhat stale
(end with the last game of the previous season), their active status is defined as their last game being
played within the last year. Also return which side of the ball they play on (offense, defense,
special teams).

Query Type: Question
*/

SELECT a.athlete_id,
       a.first_name || ' ' || a.last_name as name,
       a.dob,
       a.height,
       a.weight,
       a.birth_city || ', ' || coalesce(a.birth_state, 'UNKNOWN') AS birth_place,
       r.team_name,
       r.position_name,
       coalesce(p.platoon, 'Unknown') AS platoon,
       r.start_date,
       r.end_date,
       CASE WHEN r.end_date < CURRENT_DATE - INTERVAL '1 year' THEN 'False' ELSE 'True' END AS active
FROM athletes a
         JOIN rosters r ON r.athlete_id = a.athlete_id
JOIN positions p ON p.position_name = r.position_name
WHERE first_name LIKE '%Patrick%'
  AND start_date >= ALL (SELECT start_date
                         FROM athletes a2
                                  JOIN rosters r2 ON r2.athlete_id = a2.athlete_id
                         WHERE a2.athlete_id = a.athlete_id);

/*
Truncated Results:
						 
+----------+-----------------+----------+------+------+--------------------+---------+-------------+-------+----------+----------+------+
|athlete_id|name             |dob       |height|weight|birth_place         |team_name|position_name|platoon|start_date|end_date  |active|
+----------+-----------------+----------+------+------+--------------------+---------+-------------+-------+----------+----------+------+
|1577      |Patrick Mannelly |1975-04-18|77    |265   |Atlanta, GA         |Bears    |Unknown      |Unknown|2013-09-08|2013-12-29|False |
|2706      |Patrick Chukwurah|1979-03-01|73    |250   |Nigeria, UNKNOWN    |Seahawks |Unknown      |Unknown|2013-01-13|2013-01-13|False |
|10455     |Patrick Willis   |1985-01-25|73    |240   |Bruceton, TN        |49ers    |Linebacker   |Defense|2014-09-07|2014-12-28|False |
|11496     |Patrick Bailey   |1985-11-19|76    |243   |Elmendorf, TX       |Titans   |Unknown      |Unknown|2013-09-08|2013-12-29|False |
|12527     |Patrick Chung    |1987-08-19|71    |215   |Rancho Cucamonga, CA|Patriots |Safety       |Defense|2015-09-11|2021-01-03|False |
+----------+-----------------+----------+------+------+--------------------+---------+-------------+-------+----------+----------+------+

*/

/*
Find the teams and scores for each game in a given season year and week.
						 
Query Type: Report
*/
 SELECT home.team_name   AS home_team,
        home.total_score AS home_score,
        away.team_name   AS away_team,
        away.total_score AS away_score,
        home_team.primary_color AS home_pc,
        home_team.secondary_color AS home_sc,
        away_team.primary_color AS away_pc,
        away_team.secondary_color AS away_sc
 FROM games
          JOIN season_dates s ON s.date = games.date
          JOIN (SELECT team_name, SUM(score) AS total_score
                FROM season_dates sd
                         JOIN games g ON sd.date = g.date
                         JOIN linescores l ON l.game_id = g.game_id
                WHERE season_year = 2018
                  AND week = 10
                GROUP BY team_name) AS home ON home.team_name = games.home_team_name
          JOIN (SELECT team_name, SUM(score) AS total_score
                FROM season_dates sd
                         JOIN games g ON sd.date = g.date
                         JOIN linescores l ON l.game_id = g.game_id
                WHERE season_year = 2018
                  AND week = 10
                GROUP BY team_name) AS away ON away.team_name = games.away_team_name
 JOIN teams home_team ON home_team.team_name = home.team_name
 JOIN teams away_team ON away_team.team_name = away.team_name
 WHERE season_year = 2018
   AND week = 10;

/*
Truncated Results:
   
+---------+----------+---------+----------+-------+-------+-------+-------+
|home_team|home_score|away_team|away_score|home_pc|home_sc|away_pc|away_sc|
+---------+----------+---------+----------+-------+-------+-------+-------+
|Steelers |52        |Panthers |21        |000000 |ffb612 |0085ca |000000 |
|Bears    |34        |Lions    |22        |0b1c3a |e64100 |0076b6 |bbbbbb |
|Bengals  |14        |Saints   |51        |fb4f14 |000000 |d3bc8d |000000 |
|Browns   |28        |Falcons  |16        |472a08 |ff3c00 |a71930 |000000 |
|Titans   |34        |Patriots |10        |4b92db |002a5c |002a5c |c60c30 |
+---------+----------+---------+----------+-------+-------+-------+-------+

*/

/*
Get the win-loss records for all teams in a given season. The results are given in home wins/losses
and away wins/losses

Query Type: Report
Note that this will be used as a question type query as well, where the record for a specific 
team is retrieved.
*/
SELECT home_team_name AS team_name, home_wins, home_losses, away_wins, away_losses
FROM (SELECT home_team_name,
             SUM(CASE WHEN home.score > away.score THEN 1 ELSE 0 END) AS home_wins,
             SUM(CASE WHEN home.score < away.score THEN 1 ELSE 0 END) AS home_losses
      FROM games g
               JOIN season_dates sd ON sd.date = g.date
               JOIN (SELECT team_name, game_id, SUM(score) AS score
                     FROM linescores
                     GROUP BY team_name, game_id) AS home
                    ON home.team_name = g.home_team_name AND home.game_id = g.game_id
               JOIN (SELECT team_name, game_id, SUM(score) AS score
                     FROM linescores
                     GROUP BY team_name, game_id) AS away
                    ON away.team_name = g.away_team_name AND away.game_id = g.game_id
      WHERE sd.season_year = 2021
      GROUP BY g.home_team_name) home_record
         JOIN (SELECT away_team_name,
                      SUM(CASE WHEN away.score > home.score THEN 1 ELSE 0 END) AS away_wins,
                      SUM(CASE WHEN away.score < home.score THEN 1 ELSE 0 END) AS away_losses
               FROM games g
                        JOIN season_dates sd ON sd.date = g.date
                        JOIN (SELECT team_name, game_id, SUM(score) AS score
                              FROM linescores
                              GROUP BY team_name, game_id) AS home
                             ON home.team_name = g.home_team_name AND home.game_id = g.game_id
                        JOIN (SELECT team_name, game_id, SUM(score) AS score
                              FROM linescores
                              GROUP BY team_name, game_id) AS away
                             ON away.team_name = g.away_team_name AND away.game_id = g.game_id
               WHERE sd.season_year = 2021
               GROUP BY g.away_team_name) away_record ON away_record.away_team_name = home_record.home_team_name
ORDER BY home_team_name;

/*
Truncated Results:

+---------+---------+-----------+---------+-----------+
|team_name|home_wins|home_losses|away_wins|away_losses|
+---------+---------+-----------+---------+-----------+
|49ers    |4        |4          |8        |4          |
|Bears    |3        |5          |3        |6          |
|Bengals  |6        |5          |7        |3          |
|Bills    |7        |3          |5        |4          |
|Broncos  |4        |5          |3        |5          |
+---------+---------+-----------+---------+-----------+

*/

/*
Find all games between two given teams.

Query Type: Question
*/

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

/*
Results:

+----------+--------------+--------------+----------+----------+----------------+--------------+
|date      |home_team_name|away_team_name|home_score|away_score|venue_name      |location      |
+----------+--------------+--------------+----------+----------+----------------+--------------+
|2021-10-10|Texans        |Patriots      |22        |25        |NRG Stadium     |Houston, TX   |
|2020-11-22|Texans        |Patriots      |27        |20        |NRG Stadium     |Houston, TX   |
|2019-12-02|Texans        |Patriots      |28        |22        |NRG Stadium     |Houston, TX   |
|2018-09-09|Patriots      |Texans        |27        |20        |Gillette Stadium|Foxborough, MA|
|2017-09-24|Patriots      |Texans        |36        |33        |Gillette Stadium|Foxborough, MA|
|2017-01-15|Patriots      |Texans        |34        |16        |Gillette Stadium|Foxborough, MA|
|2016-09-23|Patriots      |Texans        |27        |0         |Gillette Stadium|Foxborough, MA|
|2015-12-14|Texans        |Patriots      |6         |27        |NRG Stadium     |Houston, TX   |
|2013-12-01|Texans        |Patriots      |31        |34        |NRG Stadium     |Houston, TX   |
|2013-01-13|Patriots      |Texans        |41        |28        |Gillette Stadium|Foxborough, MA|
+----------+--------------+--------------+----------+----------+----------------+--------------+

*/

/*
Find the top 5 teams with the highest average attendance per game in a season, 
considering only games with an attendance above a certain threshold, 
and display the percentage change in attendance compared to the previous season:

Query Type: Question
*/

WITH AvgAttendance AS (
    SELECT 
        sd.season_year, 
        g.home_team_name, 
        ROUND(AVG(g.attendance)) AS avg_attendance_per_game,
        ROW_NUMBER() OVER (PARTITION BY g.home_team_name ORDER BY AVG(g.attendance) DESC) AS rn
    FROM 
        Season_Dates sd
    JOIN 
        Games g ON sd.date = g.date
    GROUP BY 
        sd.season_year, 
        g.home_team_name
),
PrevSeasonAttendance AS (
    SELECT 
        s1.season_year, 
        s1.home_team_name, 
        s1.avg_attendance_per_game AS curr_season_attendance,
        COALESCE(s2.avg_attendance_per_game, NULL) AS prev_season_attendance
    FROM 
        AvgAttendance s1
    LEFT JOIN LATERAL (
        SELECT 
            s2.avg_attendance_per_game
        FROM 
            AvgAttendance s2
        WHERE 
            s1.home_team_name = s2.home_team_name 
            AND s1.season_year = s2.season_year + 1
        LIMIT 1
    ) s2 ON true
)
SELECT 
    pa.season_year, 
    pa.home_team_name, 
    pa.curr_season_attendance, 
    CASE 
        WHEN pa.prev_season_attendance IS NULL THEN NULL
        ELSE ROUND(
            COALESCE(
                ((pa.curr_season_attendance - pa.prev_season_attendance) / NULLIF(pa.prev_season_attendance, 0)) * 100,
                0
            ), 
            3
        )
    END AS attendance_change_percentage
FROM 
    PrevSeasonAttendance pa
WHERE 
    (pa.home_team_name, pa.curr_season_attendance) IN (
        SELECT 
            home_team_name, 
            MAX(curr_season_attendance)
        FROM 
            PrevSeasonAttendance
        GROUP BY 
            home_team_name
    )
ORDER BY 
    pa.curr_season_attendance DESC
LIMIT 5;

/*
Results:

+-----------+--------------+----------------------+----------------------------+
|season_year|home_team_name|curr_season_attendance|attendance_change_percentage|
+-----------+--------------+----------------------+----------------------------+
|2023       |Cowboys       |93594                 |0.137                       |
|2016       |Rams          |83165                 |58.703                      |
|2013       |Giants        |80148                 |null                        |
|2019       |Jets          |78523                 |0.694                       |
|2015       |Packers       |78414                 |0.129                       |
+-----------+--------------+----------------------+----------------------------+

*/

/*
Get the venue information, including the home team that matches a given search criteria.

Query Type: Question
*/

SELECT v.venue_name,
       v.capacity,
       v.city || ', ' || v.state AS location,
       v.grass,
       v.indoor,
       teams.team_name
FROM venues v
         JOIN teams ON teams.venue_name = v.venue_name
WHERE v.venue_name LIKE '%GEHA%';

/*
Results:

+-------------------------------+--------+---------------+-----+------+---------+
|venue_name                     |capacity|location       |grass|indoor|team_name|
+-------------------------------+--------+---------------+-----+------+---------+
|GEHA Field at Arrowhead Stadium|76416   |Kansas City, MO|true |false |Chiefs   |
+-------------------------------+--------+---------------+-----+------+---------+

*/

/*
Find the average attendance per game for each team in the NFL for each year.

Query Type: Question
*/

SELECT sd.season_year, t.team_name, ROUND(AVG(g.attendance)) AS avg_attendance_per_game
FROM Season_Dates sd
JOIN Games g ON sd.date = g.date
JOIN Teams t ON g.home_team_name = t.team_name OR g.away_team_name = t.team_name
GROUP BY sd.season_year, t.team_name
ORDER BY sd.season_year, avg_attendance_per_game DESC;

/*
Truncated Results:

+-----------+----------+-----------------------+
|season_year|team_name |avg_attendance_per_game|
+-----------+----------+-----------------------+
|2013       |Cowboys   |79974                  |
|2013       |Giants    |75596                  |
|2013       |Broncos   |75303                  |
|2013       |Commanders|75000                  |
|2013       |Jets      |73069                  |
|2013       |Eagles    |71194                  |
|2013       |Patriots  |70371                  |
+-----------+----------+-----------------------+

*/

/*
Find a given user's information.

Query Type: Question
*/
SELECT *
FROM users
WHERE username = 'czumbaugh' AND password = 'myPass';

/*
Results:

+---+---------+--------+----------+---------+----------+------------------+-------------------+
|uid|username |password|first_name|last_name|created_on|favorite_team_name|favorite_athlete_id|
+---+---------+--------+----------+---------+----------+------------------+-------------------+
|19 |czumbaugh|myPass  |Chuck     |Zumbaugh |2024-04-27|null              |null               |
+---+---------+--------+----------+---------+----------+------------------+-------------------+

*/


