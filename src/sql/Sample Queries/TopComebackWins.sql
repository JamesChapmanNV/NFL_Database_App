-- *** top_comeback_wins ***
-- Top 10 teams with the MOST 4th-quarter comeback wins
-- Definition of '4th-quarter comeback win': 
-- 		team is losing at end of 3rd-quarter, & wins the game
-- INPUT: (%s,%s) = (year, year) [range of years requested]
-- OUTPUT: ( team_name, num_of_comebacks, primary_color, secondary_color )
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

ComebackWins is joined with games & season_dates in order to filter by year.
This is joined with teams to provide primary_color & secondary_color.

The 'key' is to GROUP BY comebackwins.team_name & COUNT(*) AS comebacks,
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


/* QUERY WITHOUT USING VIEWS
WITH TeamScores AS (
    SELECT game_id, team_name, SUM(score) AS team_score
    FROM linescores
    GROUP BY game_id, team_name
), 
GameScores AS (
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
	AND x.away_team_name = z.team_name 
), 
ThirdQuarterTeamScores AS (
    SELECT game_id, team_name, SUM(score) AS team_score
    FROM linescores
	WHERE quarter <= 3
    GROUP BY game_id, team_name
), 
ThirdQuarterScores AS (
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
	AND x.away_team_name = z.team_name 
), 
ComebackWins AS (
	SELECT x.game_id, 
		CASE
			WHEN x.home_winner_bool = TRUE THEN x.home_team_name
			WHEN x.home_winner_bool = FALSE THEN x.away_team_name
			ELSE NULL 
		END AS team_name
	FROM GameScores x
	JOIN ThirdQuarterScores y 
		ON x.game_id = y.game_id 
		AND x.home_winner_bool = y.away_team_winng_bool
)
SELECT
    team_name,
    COUNT(*) AS comebacks
FROM ComebackWins c
LEFT JOIN games g ON c.game_id = g.game_id 
LEFT JOIN season_dates s ON g.date = s.date
WHERE s.season_year = 2019
GROUP BY team_name
ORDER BY comebacks DESC
LIMIT 5;
*/
