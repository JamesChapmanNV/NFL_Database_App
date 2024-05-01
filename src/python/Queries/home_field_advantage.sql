WITH results AS (SELECT v.venue_name, t.team_name, SUM(CASE WHEN home_score > away_score THEN 1 ELSE 0 END) AS num_wins
                 FROM venues v
                          JOIN teams t ON t.venue_name = v.venue_name
                          JOIN games g ON g.home_team_name = t.team_name AND g.venue_name = v.venue_name
                          JOIN (SELECT team_name, game_id, SUM(score) AS home_score
                                FROM linescores
                                GROUP BY team_name, game_id) AS home
                               ON home.game_id = g.game_id AND home.team_name = t.team_name
                          JOIN (SELECT team_name, game_id, SUM(score) AS away_score
                                FROM linescores
                                GROUP BY team_name, game_id) AS away
                               ON away.game_id = g.game_id AND away.team_name = g.away_team_name
                          JOIN season_dates sd ON sd.date = g.date
                 WHERE sd.season_year = %s AND sd.season_type = 'Regular Season'
                 GROUP BY v.venue_name, t.team_name)
SELECT *
FROM results
WHERE num_wins >= ALL (SELECT num_wins
                       FROM results);