-- Enter descriptions of interesting statistics to query:

-- 1. Find the teams with the highest average attendance per game in a specific season.


-- Find total passing, rushing, and receiving yards for each player in a given game
SELECT first_name, last_name, position_name, play_type, total_yards
FROM athletes ath
         JOIN (SELECT play_type, athlete_id, SUM(yards) AS total_yards
               FROM games
                        JOIN player_plays pp ON games.game_id = pp.game_id
                        JOIN plays p ON pp.play_id = p.play_id
                        JOIN athletes a ON a.athlete_id = pp.player_id
               WHERE games.game_id = 400554214
                 AND play_type IN ('Rush', 'Pass Reception')
               GROUP BY play_type, a.athlete_id) AS x ON x.athlete_id = ath.athlete_id
JOIN rosters r ON r.athlete_id = ath.athlete_id AND r.game_id = 400554214
ORDER BY x.play_type, total_yards DESC;