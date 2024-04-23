-- Enter descriptions of interesting statistics to query:

-- 1. Find the teams with the highest average attendance per game in a specific season.

-- Find total passing, rushing, and receiving yards for top players in a given game

-- QUERY TYPE: Question

-- 15+ query requirement: Satisfied(? Not sure about compound where)

WITH stats AS (SELECT first_name, last_name, position_name, r.team_name, play_type, total_yards
               FROM athletes ath
                        JOIN (SELECT play_type, athlete_id, date, SUM(yards) AS total_yards
                              FROM games
                                       JOIN player_plays pp ON games.game_id = pp.game_id
                                       JOIN plays p ON pp.play_id = p.play_id
                                       JOIN athletes a ON a.athlete_id = pp.player_id
                              WHERE games.game_id = 401437790
                                AND play_type IN ('Rush', 'Pass Reception')
                              GROUP BY play_type, a.athlete_id, date) AS x ON x.athlete_id = ath.athlete_id
                        JOIN rosters r ON r.athlete_id = ath.athlete_id AND r.start_date <= x.date AND r.end_date >= x.date
               ORDER BY x.play_type, total_yards DESC)
SELECT *
FROM stats
WHERE total_yards >= ALL (
    SELECT max(total_yards)
    FROM stats s2
    WHERE s2.position_name = stats.position_name AND s2.play_type = stats.play_type
    );
