-- Enter descriptions of interesting statistics to query:

-- 1. Find the teams with the highest average attendance per game in a specific season.

-- Find total passing, rushing, and receiving yards for top players in a given game

-- QUERY TYPE: Question

-- 15+ query requirement: Satisfied(? Not sure about compound where)

WITH stats AS (SELECT first_name || ' ' || last_name AS name,
                      r.position_name,
                      r.team_name,
                      CASE
                          WHEN r.position_name = 'Quarterback'
                              THEN 'Passing Yards'
                          ELSE play_type END AS play_type,
                      total_yards
               FROM athletes ath
                        JOIN (SELECT play_type, athlete_id, date, SUM(yards) AS total_yards
                              FROM (SELECT CASE
                                               WHEN play_type = 'Pass Reception' THEN 'Receiving Yards'
                                               WHEN play_type = 'Passing Touchdown' THEN 'Receiving Yards'
                                               WHEN play_type = 'Two Point Pass' THEN 'Receiving Yards'
                                               WHEN play_type = 'Rushing Touchdown' THEN 'Rush'
                                               WHEN play_type = 'Two Point Rush' THEN 'Rush'
                                               ELSE play_type END AS play_type,
                                           athlete_id,
                                           date,
                                           yards
                                    FROM games
                                             JOIN player_plays pp ON games.game_id = pp.game_id
                                             JOIN plays p ON pp.play_id = p.play_id
                                             JOIN athletes a ON a.athlete_id = pp.player_id
                                    WHERE games.game_id = 401547557
                                      AND play_type IN ('Rush', 'Rushing Touchdown', 'Two Point Rush', 'Pass Reception',
                                                        'Passing Touchdown', 'Two Point Pass')) AS p
                              GROUP BY play_type, p.athlete_id, date) AS x ON x.athlete_id = ath.athlete_id
                        JOIN rosters r
                             ON r.athlete_id = ath.athlete_id AND r.start_date <= x.date AND r.end_date >= x.date
                        JOIN positions pos ON pos.position_name = r.position_name
               WHERE pos.platoon = 'Offense'
               ORDER BY x.play_type, total_yards DESC)
SELECT *
FROM stats
WHERE total_yards >= ALL (SELECT MAX(total_yards)
                          FROM stats s2
                          WHERE s2.play_type = stats.play_type);