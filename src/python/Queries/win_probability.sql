-- requires a single team_name (%s,%s) as input
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