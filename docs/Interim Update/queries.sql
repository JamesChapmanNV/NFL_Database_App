/*
	Kansas State University
	CIS 761: Database Management Systems
	NFL Database Project - Interim Project Update 

	Vishnu Bondalakunta
	Chuck Zumbaugh
	James Chapman
*/
/*
	Write  at least 15 queries (ten question-type queries and five
	report-type queries) that are "interesting," substantially-different, and structurallydifferent,
	i.e., operations that require some of the more complex SQL constructs
	such as subqueries, aggregates, set operators, etc.

	Remember that, while queries are supposed to answer a particular question, the
	purpose of a report is to provide a summary of more of the content of the
	database. Sometimes the difference really comes down to quantity: while a query
	generates a single tuple or a small set of tuples, a report may generate dozens or
	more tuples. In general, a report is designed to be more human readable and to
	present information in tabular form. (See the original General Project Description
	document for some specific examples.)

	For the SQL queries demonstrated, ensure that there is at least one join, at least one
	nested query, at least one appropriate use of an aggregate function (such as min(),
	max(), avg(), sum(), etc.) within a select statement; at least one group-by, and at
	least one compound where condition (with at least a couple of sub-conditions that
	are different from join conditions). Note that these requirements ask for structurally
	different queries (these queries will be part of the 15 required queries).

	For the SQL reports demonstrated, at least two of your reports should be based on
	queries involving more than one table. You may employ concatenation to put
	together a full name or an address into a more readable form. You may also employ
	more than one query to construct a report. For instance, you may have a table with
	sales of a particular item or set of items, and then also compute the sales total.

	****************************
	Make sure that your script is well commented and it clearly describes your
	queries and the rationale for each of them. Furthermore, the results should be clearly
	labeled, well-organized and easy to read.
	****************************

*/


/*
	This section produces 2 queries used in the app for the commands top_comeback_wins & win_probability.
	The goal of top_comeback_wins top 10 teams with the most fourth-quarter comeback wins

	*******************
	*** Both queries use 2 VIEWs named game_scores & Third_Quarter_scores.
	VIEW game_scores & Third_Quarter_scores.
		game_scores(game_id, home_team_name, home_team_score, away_team_name, away_team_score, home_winner_bool)

	VIEW Third_Quarter_scores
		Third_Quarter_scores(game_id, home_team_name, home_team_score, away_team_name, away_team_score, away_team_winng_bool)
	*******************
*/


CREATE VIEW game_scores AS
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

CREATE VIEW Third_Quarter_scores AS
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


-- top 10 teams with the most fourth-quarter comeback wins
-- requires year as input
-- requires 2 Views - game_scores & Third_Quarter_scores
WITH ComebackWins AS (
	SELECT x.game_id, 
		CASE
			WHEN x.home_winner_bool = TRUE THEN x.home_team_name
			WHEN x.home_winner_bool = FALSE THEN x.away_team_name
			ELSE NULL 
		END AS team_name
	FROM game_scores x
	JOIN Third_Quarter_scores y 
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
WHERE s.season_year BETWEEN %s AND %s
GROUP BY c.team_name,t.primary_color,t.secondary_color
ORDER BY comebacks DESC
LIMIT 10;



-- requires a single team_name as input
-- requires 2 Views - game_scores & Third_Quarter_scores
-- returns all games played by given team with 3 columns
-- 		team_score-		given team score at end of 3rd quarter
-- 		opponent_score-	opponent team score at end of 3rd quarter
-- 		winner_bool-	if the team wins (true or false) NULL if tie

-- to be used for logistic regression to determine probability of win, 
-- given team_name and end of 3rd quarter scores
SELECT y.home_team_score AS all_team_scores, 
		y.away_team_score AS all_opponent_scores, 
		x.home_winner_bool AS winner_bool
FROM game_scores x
JOIN Third_Quarter_scores y 
	ON x.game_id = y.game_id 
WHERE y.home_team_name = %s
Union
SELECT y.away_team_score AS team_score, 
		y.home_team_score AS opponent_score, 
		NOT x.home_winner_bool AS winner_bool
FROM game_scores x
JOIN Third_Quarter_scores y 
	ON x.game_id = y.game_id 
WHERE y.away_team_name = %s;

/*
Find the total receiving yards for a given player in each week of the season that they played.
Query type: Report
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

/*
Truncated Output:
+----------+---------+-----------+--------------+----+---------------+
|first_name|last_name|season_year|season_type   |week|receiving_yards|
+----------+---------+-----------+--------------+----+---------------+
|Julio     |Jones    |2023       |Regular Season|17  |34             |
|Julio     |Jones    |2023       |Regular Season|16  |5              |
|Julio     |Jones    |2023       |Regular Season|15  |6              |
|Julio     |Jones    |2023       |Regular Season|12  |0              |
|Julio     |Jones    |2023       |Regular Season|11  |5              |
|Julio     |Jones    |2023       |Regular Season|8   |8              |
|Julio     |Jones    |2023       |Regular Season|7   |3              |
|Julio     |Jones    |2022       |Regular Season|17  |10             |
|Julio     |Jones    |2022       |Regular Season|16  |0              |
|Julio     |Jones    |2022       |Regular Season|14  |38             |
+----------+---------+-----------+--------------+----+---------------+

*/

/*
Find the average total points per game for different combinations of fields.
A given field can be played on either grass or turf field, and either indoors or outdoors.

Query Type: Question
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
	AVG(gs.home_team_score + gs.away_team_score) AS avg_total_points
FROM game_scores gs
JOIN games g ON gs.game_id = g.game_id
JOIN venues v ON g.venue_name = v.venue_name
GROUP BY v.grass,v.indoor
ORDER BY avg_total_points DESC;

/*
Output:

+-----+-------+-------------------+
|field|venue  |avg_total_points   |
+-----+-------+-------------------+
|Turf |Indoor |48.1671270718232044|
|Grass|Indoor |47.4365079365079365|
|Turf |Outdoor|44.8225165562913907|
|Grass|Outdoor|44.7786705624543462|
+-----+-------+-------------------+

*/

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
     a.first_name, 
     a.last_name,
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
	 
+---------+----------+---------+-------------+-------------+----------------+----------------+------------------+-------------+
|player_id|first_name|last_name|passing_yards|pass_attempts|pass_completions|touchdown_passes|passes_intercepted|passer_rating|
+---------+----------+---------+-------------+-------------+----------------+----------------+------------------+-------------+
|2330     |Tom       |Brady    |5602         |752          |491             |46              |10                |56.3         |
|2580     |Drew      |Brees    |4646         |586          |396             |31              |10                |56.3         |
|14881    |Russell   |Wilson   |4612         |524          |348             |37              |13                |60.4         |
|5529     |Philip    |Rivers   |4606         |621          |415             |27              |7                 |56.3         |
|4459     |Carson    |Palmer   |4554         |520          |329             |34              |10                |60.4         |
|12483    |Matthew   |Stafford |4445         |594          |397             |30              |14                |56.3         |
|16724    |Blake     |Bortles  |4368         |575          |341             |35              |13                |56.3         |
|5526     |Eli       |Manning  |4315         |575          |362             |33              |12                |56.3         |
|11237    |Matt      |Ryan     |4269         |581          |384             |19              |14                |56.3         |
|13994    |Cam       |Newton   |4175         |540          |318             |37              |12                |56.3         |
+---------+----------+---------+-------------+-------------+----------------+----------------+------------------+-------------+
	 
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

SELECT a.*,
       r.team_name,
       r.position_name,
       p.platoon,
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
						 
+----------+----------+---------+----------+------+------+-----------------+-----------+---------+-------------+-------------+----------+----------+------+
|athlete_id|first_name|last_name|dob       |height|weight|birth_city       |birth_state|team_name|position_name|platoon      |start_date|end_date  |active|
+----------+----------+---------+----------+------+------+-----------------+-----------+---------+-------------+-------------+----------+----------+------+
|1577      |Patrick   |Mannelly |1975-04-18|77    |265   |Atlanta          |GA         |Bears    |Unknown      |null         |2013-09-08|2013-12-29|False |
|2706      |Patrick   |Chukwurah|1979-03-01|73    |250   |Nigeria          |null       |Seahawks |Unknown      |null         |2013-01-13|2013-01-13|False |
|10455     |Patrick   |Willis   |1985-01-25|73    |240   |Bruceton         |TN         |49ers    |Linebacker   |Defense      |2014-09-07|2014-12-28|False |
|11496     |Patrick   |Bailey   |1985-11-19|76    |243   |Elmendorf        |TX         |Titans   |Unknown      |null         |2013-09-08|2013-12-29|False |
|12527     |Patrick   |Chung    |1987-08-19|71    |215   |Rancho Cucamonga |CA         |Patriots |Safety       |Defense      |2015-09-11|2021-01-03|False |
|13238     |Patrick   |Robinson |1987-09-07|71    |191   |Miami            |FL         |Saints   |Cornerback   |Defense      |2018-09-09|2021-01-17|False |
|13980     |Patrick   |Peterson |1990-07-11|73    |203   |Pompano Beach    |FL         |Steelers |Cornerback   |Defense      |2023-09-10|2023-12-31|True  |
|14332     |Patrick   |DiMarco  |1989-04-30|73    |234   |Altamonte Springs|FL         |Bills    |Fullback     |Offense      |2017-09-10|2020-01-04|False |
|14572     |Patrick   |Scales   |1988-02-11|75    |226   |Louisville       |KY         |Bears    |Long Snapper |Special Teams|2015-12-06|2023-12-31|True  |
|15474     |Patrick   |Edwards  |1988-10-25|69    |175   |Temple           |TX         |Lions    |Unknown      |null         |2013-09-08|2013-10-13|False |
+----------+----------+---------+----------+------+------+-----------------+-----------+---------+-------------+-------------+----------+----------+------+

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
Find the number of games each team played in the post-season.
   
Query Type: Report   
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

/*
Truncated Results:

+----------+---------------------------+--------+----------+----------+---------+
|team_name |total_postseason_game_count|wildcard|divisional|conference|superbowl|
+----------+---------------------------+--------+----------+----------+---------+
|Broncos   |8                          |0       |4         |2         |2        |
|Packers   |15                         |4       |7         |4         |0        |
|Bills     |9                          |5       |3         |1         |0        |
|Steelers  |9                          |5       |3         |1         |0        |
|Commanders|3                          |3       |0         |0         |0        |
+----------+---------------------------+--------+----------+----------+---------+

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
	v.city,
	v.state
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

+----------+--------------+--------------+----------+----------+----------------+----------+-----+
|date      |home_team_name|away_team_name|home_score|away_score|venue_name      |city      |state|
+----------+--------------+--------------+----------+----------+----------------+----------+-----+
|2021-10-10|Texans        |Patriots      |22        |25        |NRG Stadium     |Houston   |TX   |
|2020-11-22|Texans        |Patriots      |27        |20        |NRG Stadium     |Houston   |TX   |
|2019-12-02|Texans        |Patriots      |28        |22        |NRG Stadium     |Houston   |TX   |
|2018-09-09|Patriots      |Texans        |27        |20        |Gillette Stadium|Foxborough|MA   |
|2017-09-24|Patriots      |Texans        |36        |33        |Gillette Stadium|Foxborough|MA   |
|2017-01-15|Patriots      |Texans        |34        |16        |Gillette Stadium|Foxborough|MA   |
|2016-09-23|Patriots      |Texans        |27        |0         |Gillette Stadium|Foxborough|MA   |
|2015-12-14|Texans        |Patriots      |6         |27        |NRG Stadium     |Houston   |TX   |
|2013-12-01|Texans        |Patriots      |31        |34        |NRG Stadium     |Houston   |TX   |
|2013-01-13|Patriots      |Texans        |41        |28        |Gillette Stadium|Foxborough|MA   |
+----------+--------------+--------------+----------+----------+----------------+----------+-----+

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

SELECT v.*, teams.team_name
FROM venues v
JOIN teams ON teams.venue_name = v.venue_name
WHERE v.venue_name LIKE '%GEHA%';

/*
Results:

+-------------------------------+--------+-----------+-----+-----+------+---------+
|venue_name                     |capacity|city       |state|grass|indoor|team_name|
+-------------------------------+--------+-----------+-----+-----+------+---------+
|GEHA Field at Arrowhead Stadium|76416   |Kansas City|MO   |true |false |Chiefs   |
+-------------------------------+--------+-----------+-----+-----+------+---------+

*/

/*
Find the receiving stats for all players in a given season year and week.

Query Type: Report
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

/*
Truncated Results:

+---------+----------+---------+---------------+
|game_id  |first_name|last_name|receiving_yards|
+---------+----------+---------+---------------+
|401127948|Michael   |Thomas   |167            |
|401127981|Tyreek    |Hill     |157            |
|401128041|Amari     |Cooper   |147            |
|401127976|Christian |Kirk     |138            |
|401127944|DJ        |Moore    |120            |
+---------+----------+---------+---------------+

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


