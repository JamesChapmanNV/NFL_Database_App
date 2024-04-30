/*
	Kansas State University
	CIS 761: Database Management Systems
	NFL Database Project - Interim Project Update 

	Vishnu Bondalakunta
	Chuck Zumbaugh
	James Chapman
*/

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
SELECT a.first_name, a.last_name, s.season_year, s.season_type, s.week, SUM(yards) as Receiving_yards
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

-- ***  avg_pts_grass_indoor ***
-- average points based on grass/turf & indoor/outdoor
-- indoor games seems to have greater points
-- grass/turf seems to not matter
-- INPUT: 
-- OUTPUT: average points scored 
-- QUERY TYPE: Report 

/*Query explanation
****************************************
Simple idea,  how does indoor/outdoor affect points
 how does grass/turf affect points?
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


/*** VIEW all_final_game_scores ***
2 views were created and used in 3 queries.  The database lists the scores,
of each quarter, of each game (linescores table). These views make the
queries easier to understand and saves time writing queries.
Also, it's good practice, as a beginner.

VIEW explanation
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

/*** VIEW all_third_quarter_scores ***
2 views were created and used in 3 queries.  The database lists the scores,
of each quarter, of each game (linescores table). These views make the
queries easier to understand and saves time writing queries.
Also, it's good practice, as a beginner.

VIEW explanation
VIEW 'all_third_quarter_scores' produces 6 attributes for each game:
	-game_id 
	-home_team_name 
	-home_team_score (at end of 3rd quarter)
	-away_team_name
	-away_team_score (at end of 3rd quarter)
	-away_team_winng_bool (true if AWAY team is currently winning, NULL if tie )

ThirdQuarterTeamScores is a CTE meant to 
find all scores (AT THE END OF 3RD QUARTER), of each game, of each team.
This filters the linescores WHERE quarter <= 3.

The first instance of ThirdQuarterTeamScores matches games.home_team_name
The 2nd instance of ThirdQuarterTeamScores matches games.away_team_name

The attribute 'away_team_winng_bool' is created & produces
True if AWAY team IS WINNING, NULL if there is currently a tie
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

-- ***  team_rivals ***
-- Find all games and info between 2 given teams
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


-- *** top_comeback_wins ***
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

/* Query explanation
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


-- *** win_probability ***
-- Query produces table with 3rd quarter scores of all games
-- played by a given team (from input), 
-- AND whether that team won the game (Boolean).
-- 
-- The result is used, in the app, to find the probability of 
-- a given team (from input) to win the game based on 
-- the score at the end of the 3rd quarter (from input).
-- Below is further explanation.
-- 
-- INPUT: (%s) = (team_name) 
-- OUTPUT: all games played by input team, with 3 columns
-- 		-third_quarter_team_scores- score of input team
-- 		-opponent_scores- score of opponent, same game
-- 		-winner_bool- if input team wins, NULL if tie
-- QUERY TYPE: Question 

/* Query explanation
********************
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

****************************************
IN APP PROCESSING OF QUERY 
(logistic regression, unique to each team)

The input of this application command requires the team (used above), and the current LIVE
3rd quarter team score & opponent score.  This is meant to be used at the end of the 3rd quarter,
of a live game. 

The idea comes from the fact that certain teams tend to have better/worse 4th quarter performances.
So each team has its unique probability distribution. Although this model is 
slightly naive (more features are required, etc.), this is a good proof of concept.

INPUTS
team_score- input of current 3rd quarter team score
opponent_score- input of current 3rd quarter opponents score

SAMPLE CODE FROM APPLICATION
df = pd.DataFrame(self.last_result, columns=['third_quarter_team_scores', 'opponent_scores', 'winner_bool'])
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


















