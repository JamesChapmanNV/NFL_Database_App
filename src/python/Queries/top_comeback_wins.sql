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
