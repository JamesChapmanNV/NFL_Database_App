SELECT g.game_id, g.date, g.home_team_name, g.away_team_name, ls.first_quarter_score
FROM Games g
JOIN (SELECT game_id,
             SUM(CASE WHEN quarter = 1 THEN score ELSE 0 END) AS first_quarter_score,
             SUM(CASE WHEN quarter = 2 THEN score ELSE 0 END) AS second_quarter_score,
             SUM(CASE WHEN quarter = 3 THEN score ELSE 0 END) AS third_quarter_score,
             SUM(CASE WHEN quarter = 4 THEN score ELSE 0 END) AS fourth_quarter_score
      FROM Linescores
      GROUP BY game_id) ls ON g.game_id = ls.game_id
JOIN season_dates sd ON g.date = sd.date
WHERE first_quarter_score > GREATEST(second_quarter_score, third_quarter_score, fourth_quarter_score)
    {year_filter};