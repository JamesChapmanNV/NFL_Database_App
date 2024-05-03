SELECT g.date,
	g.home_team_name,
	g.away_team_name,
	a.home_team_score,
	a.away_team_score,
	v.venue_name,
	v.city,
	v.state
FROM games g
JOIN all_final_game_scores a ON g.game_id = a.game_id
JOIN venues v ON g.venue_name = v.venue_name
JOIN season_dates sd ON sd.date = g.date
WHERE (g.home_team_name LIKE %s OR g.away_team_name LIKE %s)
  AND (g.home_team_name LIKE %s OR g.away_team_name LIKE %s)
  AND sd.season_year = %s
ORDER BY g.date DESC;