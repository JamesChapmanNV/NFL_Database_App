-- Find information for the requested game, including the scores and winner.
-- QUERY TYPE: Question 
-- 15+ query requirement: Satisfied(? Not sure about compound where requirement)
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
  
/* Query result

  game_id  |    date    | attendance | home_team_name | away_team_name |    venue_name    | utc_time | final_score_home | final_score_away | primary_color | secondary_color
-----------+------------+------------+----------------+----------------+------------------+----------+------------------+------------------+---------------+-----------------
 330106033 | 2013-01-06 |          0 | Ravens         | Colts          | M&T Bank Stadium | 18:00:00 |               24 |                9 | 29126f        | 9e7c0c
(1 row)

*/