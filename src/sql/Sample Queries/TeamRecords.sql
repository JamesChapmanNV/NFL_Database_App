/*
 Get the team's win-loss record for a given season, or get all team's win-loss records
 for a given season. This includes both regular and post-season.

 Query Type: Question/Report
 */

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
      WHERE sd.season_year = 2021
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
               WHERE sd.season_year = 2021
               GROUP BY g.away_team_name) away_record ON away_record.away_team_name = home_record.home_team_name
ORDER BY home_team_name;

/*
Query Results:

+----------+---------+-----------+---------+-----------+
|team_name |home_wins|home_losses|away_wins|away_losses|
+----------+---------+-----------+---------+-----------+
|49ers     |4        |4          |8        |4          |
|Bears     |3        |5          |3        |6          |
|Bengals   |6        |5          |7        |3          |
|Bills     |7        |3          |5        |4          |
|Broncos   |4        |5          |3        |5          |
|Browns    |6        |3          |2        |6          |
|Buccaneers|8        |2          |6        |3          |
|Cardinals |3        |5          |8        |2          |
|Chargers  |5        |4          |4        |4          |
|Chiefs    |9        |3          |5        |3          |
|Colts     |4        |5          |5        |3          |
|Commanders|3        |5          |4        |5          |
|Cowboys   |5        |4          |7        |2          |
|Dolphins  |6        |3          |3        |5          |
|Eagles    |3        |5          |6        |4          |
|Falcons   |2        |6          |5        |4          |
|Giants    |3        |5          |1        |8          |
|Jaguars   |3        |6          |0        |8          |
|Jets      |3        |6          |1        |7          |
|Lions     |3        |5          |0        |8          |
|Packers   |8        |1          |5        |4          |
|Panthers  |2        |6          |3        |6          |
|Patriots  |4        |5          |6        |3          |
|Raiders   |5        |4          |5        |4          |
|Rams      |7        |3          |9        |2          |
|Ravens    |5        |4          |3        |5          |
|Saints    |3        |5          |6        |3          |
|Seahawks  |3        |5          |4        |5          |
|Steelers  |6        |2          |3        |6          |
|Texans    |2        |7          |2        |6          |
|Titans    |7        |3          |5        |3          |
|Vikings   |5        |3          |3        |6          |
+----------+---------+-----------+---------+-----------+


 */