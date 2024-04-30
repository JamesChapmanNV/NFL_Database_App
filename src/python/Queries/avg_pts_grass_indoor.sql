
-- ***  avg_pts_grass_indoor ***
-- average points based on grass/turf & indoor/outdoor
-- indoor games seems to have greater points
-- grass/turf seems to not matter
-- INPUT: 
-- OUTPUT: average points scored 
-- QUERY TYPE: Report 

/*Query explanation
****************************************
Simple idea,  how does indoor/outdoor affect points
 how does grass/turf affect points?
****************************************

Sample Query result 

 field |  venue  | avg_total_points
-------+---------+------------------
 Turf  | Indoor  |             48.2
 Grass | Indoor  |             47.4
 Turf  | Outdoor |             44.8
 Grass | Outdoor |             44.8
(4 rows)

*/

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


