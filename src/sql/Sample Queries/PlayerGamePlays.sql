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
  
  /* (partial) Query result
	                                                                         text                                                                         | quarter | seconds_remaining | yards | score_value |     play_type     | start_down | end_down
------------------------------------------------------------------------------------------------------------------------------------------------------+---------+-------------------+-------+-------------+-------------------+------------+----------
 (Shotgun) P.Mahomes pass short right to I.Pacheco pushed ob at KC 31 for 10 yards (D.Deablo).                                                        |       2 |               217 |    10 |           0 | Pass Reception    |          1 |        1
 (Shotgun) I.Pacheco up the middle to KC 28 for 2 yards (M.Koonce).                                                                                   |       4 |               542 |     2 |           0 | Rush              |          1 |        2
 (Shotgun) I.Pacheco right tackle pushed ob at LV 9 for 8 yards (J.Jones).                                                                            |       4 |               389 |     8 |           0 | Rush              |          1 |        2
 I.Pacheco right end pushed ob at LV 5 for 4 yards (T.Moehrig).                                                                                       |       4 |               349 |     4 |           0 | Rush              |          2 |        1
 I.Pacheco right guard to LV 2 for 3 yards (D.Deablo, R.Spillane). PENALTY on KC-C.Humphrey, Offensive Holding, 10 yards, enforced at LV 5 - No Play. |       4 |               313 |   -10 |           0 | Rush              |          1 |        1
 (Shotgun) P.Mahomes pass short left to I.Pacheco to KC 14 for -11 yards (B.Nichols).                                                                 |       1 |               572 |   -11 |           0 | Pass Reception    |          1 |        2
 (Shotgun) P.Mahomes pass short left to I.Pacheco to KC 31 for 11 yards (N.Hobbs).                                                                    |       1 |                32 |    11 |           0 | Pass Reception    |          1 |        1
 (Shotgun) I.Pacheco left end to KC 32 for 1 yard (N.Hobbs, R.Spillane).                                                                              |       2 |               900 |     1 |           0 | Rush              |          1 |        2
 (Shotgun) I.Pacheco left tackle to KC 45 for 4 yards (J.Robinson, J.Jenkins).                                                                        |       2 |               716 |     4 |           0 | Rush              |          1 |        2
 (Shotgun) I.Pacheco up the middle for 1 yard, TOUCHDOWN.H.Butker extra point is GOOD, Center-J.Winchester, Holder-T.Townsend.                        |       2 |               398 |     1 |           6 | Rushing Touchdown |          3 |        0
 (Shotgun) I.Pacheco up the middle for 1 yard, TOUCHDOWN.H.Butker extra point is GOOD, Center-J.Winchester, Holder-T.Townsend.                        |       2 |               398 |     1 |           6 | Rushing Touchdown |          3 |        0
 (No Huddle, Shotgun) I.Pacheco left guard to KC 43 for 3 yards (J.Jenkins; J.Tillery).                                                               |       2 |               157 |     3 |           0 | Rush              |          2 |        1
 (Shotgun) I.Pacheco up the middle to LV 3 for 4 yards (A.Butler).                                                                                    |       2 |                68 |     4 | 
  */

-- Query to get the athlete details. This can be used to find the athlete ID for the above
-- query so the user doesn't need to deal with it
SELECT *
FROM athletes
WHERE first_name = 'Isiah' AND last_name = 'Pacheco';