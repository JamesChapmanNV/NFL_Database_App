
-- Find the scores for each game in a week
-- Accepts input of season year and week
SELECT home.team_name   AS home_team,
       home.total_score AS home_score,
       away.team_name   AS away_team,
       away.total_score AS away_score
FROM games
         JOIN season_dates s ON s.date = games.date
         JOIN (SELECT team_name, SUM(score) AS total_score
               FROM season_dates sd
                        JOIN games g ON sd.date = g.date
                        JOIN linescores l ON l.game_id = g.game_id
               WHERE season_year = 2018
                 AND week = 10
               GROUP BY team_name) AS home ON home.team_name = games.home_team
         JOIN (SELECT team_name, SUM(score) AS total_score
               FROM season_dates sd
                        JOIN games g ON sd.date = g.date
                        JOIN linescores l ON l.game_id = g.game_id
               WHERE season_year = 2018
                 AND week = 10
               GROUP BY team_name) AS away ON away.team_name = games.away_team
WHERE season_year = 2018
  AND week = 10;