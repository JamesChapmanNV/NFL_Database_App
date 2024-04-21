/* Find the teams with the highest average attendance per game in a specific season: */
/* QUERY TYPE: Question */
/* 15+ query requirement: Not satisfied(No nested query)

SELECT sd.season_year, t.team_name, ROUND(AVG(g.attendance)) AS avg_attendance_per_game
FROM Season_Dates sd
JOIN Games g ON sd.date = g.date
JOIN Teams t ON g.home_team = t.team_name OR g.away_team = t.team_name
GROUP BY sd.season_year, t.team_name
ORDER BY sd.season_year, avg_attendance_per_game DESC;
