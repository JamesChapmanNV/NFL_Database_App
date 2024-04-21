-- Find the plays made by a given player in a given game. This will require a second to pull the
-- player info so it doesn't get replicated many times
-- QUERY TYPE: Report
-- 15+ query requirement: Not satisfied(No group by used, no aggregate function used)
SELECT p.text,
       p.quarter,
       p.seconds_remaining,
       p.yards,
       p.score_value,
       p.play_type,
       p.start_down,
       p.end_down
FROM games g
         JOIN player_plays pp ON pp.game_id = g.game_id
         JOIN plays p ON p.play_id = pp.play_id
         JOIN athletes a ON a.athlete_id = pp.player_id
WHERE g.game_id = 401547557
  AND a.athlete_id = 4361529;

-- Query to get the athlete details. This can be used to find the athlete ID for the above
-- query so the user doesn't need to deal with it
SELECT *
FROM athletes
WHERE first_name = 'Isiah' AND last_name = 'Pacheco';