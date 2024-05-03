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
      WHERE sd.season_year = %s
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
               WHERE sd.season_year = %s
               GROUP BY g.away_team_name) away_record ON away_record.away_team_name = home_record.home_team_name
WHERE home_team_name = %s
ORDER BY home_team_name;