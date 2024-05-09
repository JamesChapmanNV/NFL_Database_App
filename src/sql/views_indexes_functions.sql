-- This file is used to create views, indexes, & functions
-- 


/*** all_final_game_scores ***
VIEW explanation
all_final_game_scores produces 6 attributes for each game:
	-game_id 
	-home_team_name
	-home_team_score
	-away_team_name
	-away_team_score
	-home_winner_bool (true if home team wins, NULL if tie )

TeamScores is a CTE  meant to find all scores of each game of each team.
This is because the table 'linescores' must be aggregated on score attribute.
'linescores' is organized by game_id & team_name, 
requiring a self join of the TeamScores CTE.

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

/*** all_third_quarter_scores ***
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

CREATE INDEX idx_play_athlete_game ON player_plays(game_id, player_id, play_id);
CREATE INDEX idx_date ON games(date);
CREATE INDEX idx_home_team ON games(home_team_name);
CREATE INDEX idx_away_team ON games(away_team_name);



CREATE INDEX idx_pp_play_id ON player_plays(play_id);
CREATE INDEX idx_pp_game_id ON player_plays(game_id);
CREATE INDEX idx_plays_play_id ON plays(play_id);
CREATE INDEX idx_athletes_first_name ON athletes(first_name);
CREATE INDEX idx_rosters_athlete_id ON rosters(athlete_id);
CREATE INDEX idx_linescores_game_id ON linescores(game_id);

