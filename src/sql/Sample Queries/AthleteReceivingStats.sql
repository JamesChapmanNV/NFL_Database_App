--  receiving stats individual given athlete ID
SELECT a.first_name, a.last_name, s.season_year, s.season_type, s.week, SUM(yards) as Receiving_yards
FROM player_plays pp
JOIN plays p ON pp.play_id = p.play_id
JOIN athletes a ON pp.player_id = a.athlete_id
JOIN games g ON pp.game_id = g.game_id
JOIN season_dates s ON g.date = s.date
WHERE a.athlete_id=13982
	AND pp.type='receiver'
	AND p.play_type in ('Pass',
						'Rush',
						'Fumble Recovery (Own)',
						'Pass Reception',
						'Passing Touchdown')
Group by a.athlete_id, a.first_name, a.last_name, s.season_year, s.season_type, s.week
ORDER BY s.season_year DESC, s.season_type DESC, s.week DESC;