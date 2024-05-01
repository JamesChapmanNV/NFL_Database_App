SELECT p.quarter,
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
WHERE g.game_id = %s
  AND a.athlete_id = %s;