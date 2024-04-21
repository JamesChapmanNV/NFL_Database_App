-- Find information for the requested game, including the scores and winner.
-- QUERY TYPE: Question 

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