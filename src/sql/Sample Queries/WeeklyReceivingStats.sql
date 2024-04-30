--  receiving stats in a week 
SELECT g.game_id, a.first_name || ' ' || a.last_name AS name, SUM(yards) as Receiving_yards
FROM player_plays pp
JOIN plays p ON pp.play_id = p.play_id
JOIN athletes a ON pp.player_id = a.athlete_id
JOIN games g ON pp.game_id = g.game_id
JOIN season_dates s ON g.date = s.date
WHERE type='receiver'
	AND season_year = 2019
	AND season_type = 'Regular Season'
	AND week = 10
	AND play_type in ('Pass',
					'Rush',
					'Fumble Recovery (Own)',
					'Pass Reception',
					'Passing Touchdown')
Group by player_id, g.game_id, a.first_name, a.last_name
ORDER BY SUM(yards) DESC;
