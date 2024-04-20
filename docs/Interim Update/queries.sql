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


























































