SELECT
    CASE
        WHEN v.grass THEN 'Grass'
        ELSE 'Turf'
    END AS field,
    CASE
        WHEN v.indoor THEN 'Indoor'
        ELSE 'Outdoor'
	END AS venue,
	ROUND( AVG(gs.home_team_score + gs.away_team_score), 1) AS avg_total_points
FROM all_final_game_scores gs
JOIN games g ON gs.game_id = g.game_id
JOIN venues v ON g.venue_name = v.venue_name
GROUP BY v.grass,v.indoor
ORDER BY avg_total_points DESC;


