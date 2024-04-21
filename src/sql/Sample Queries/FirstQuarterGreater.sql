/* List all games where the total number of points scored in the first quarter is greater than the total number of points scored in any other quarter: */
/* QUERY TYPE: Report */
/* 15+ query requirement: Not satisfied(No aggregate function used in select statement)

SELECT g.game_id, g.date, g.home_team, g.away_team
FROM Games g
JOIN (SELECT game_id,
             SUM(CASE WHEN quarter = 1 THEN score ELSE 0 END) AS first_quarter_score,
             SUM(CASE WHEN quarter = 2 THEN score ELSE 0 END) AS second_quarter_score,
             SUM(CASE WHEN quarter = 3 THEN score ELSE 0 END) AS third_quarter_score,
             SUM(CASE WHEN quarter = 4 THEN score ELSE 0 END) AS fourth_quarter_score
      FROM Linescores
      GROUP BY game_id) ls ON g.game_id = ls.game_id
WHERE first_quarter_score > GREATEST(second_quarter_score, third_quarter_score, fourth_quarter_score);
