/*
 Find the % of the stadium filled for a given game

 Query Type: Question type
 */
SELECT ROUND(CAST(g.attendance AS DECIMAL) / CAST(v.capacity AS DECIMAL) * 100, 2) AS percent_fill
FROM games g
         JOIN venues v ON v.venue_name = g.venue_name
WHERE g.game_id = 330915001;