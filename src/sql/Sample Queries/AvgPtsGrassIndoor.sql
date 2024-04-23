
-- average points based on grass/turf & indoor/outdoor
-- indoor seems to have greater points
-- grass/turf seems to not matter
-- QUERY TYPE: report 

SELECT 
    CASE 
        WHEN v.grass THEN 'Grass' 
        ELSE 'Turf' 
    END AS field,
    CASE 
        WHEN v.indoor THEN 'Indoor' 
        ELSE 'Outdoor' 
	END AS venue,
	AVG(gs.home_team_score + gs.away_team_score) AS avg_total_points
FROM game_scores gs
JOIN games g ON gs.game_id = g.game_id
JOIN venues v ON g.venue_name = v.venue_name
GROUP BY v.grass,v.indoor;

/* SAMPLE OUTPUT

 field |  venue  |  avg_total_points
-------+---------+---------------------
 Grass | Indoor  | 47.4365079365079365
 Turf  | Outdoor | 44.8225165562913907
 Turf  | Indoor  | 48.1671270718232044
 Grass | Outdoor | 44.7786705624543462
(4 rows)

*/
