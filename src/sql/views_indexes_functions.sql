
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





























































