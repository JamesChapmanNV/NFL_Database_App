/* Find the teams with the highest average attendance per game in a specific season: */
/* QUERY TYPE: Question */
/* 15+ query requirement: Not satisfied(No nested query) */

SELECT sd.season_year, t.team_name, ROUND(AVG(g.attendance)) AS avg_attendance_per_game
FROM Season_Dates sd
JOIN Games g ON sd.date = g.date
JOIN Teams t ON g.home_team_name = t.team_name OR g.away_team_name = t.team_name
GROUP BY sd.season_year, t.team_name
ORDER BY sd.season_year, avg_attendance_per_game DESC;

/* (partial) Query result

 season_year | team_name  | avg_attendance_per_game
-------------+------------+-------------------------
        2012 | Ravens     |                       0
        2012 | Patriots   |                       0
        2012 | 49ers      |                       0
        2012 | Colts      |                       0
        2012 | Vikings    |                       0
        2012 | Commanders |                       0
        2012 | Texans     |                       0
        2012 | Bengals    |                       0
        2012 | Falcons    |                       0
        2012 | Seahawks   |                       0
        2012 | Packers    |                       0
        2012 | Broncos    |                       0
        2013 | Cowboys    |                   79974
        2013 | Giants     |                   75596
        2013 | Broncos    |                   75303
        2013 | Commanders |                   75000
        2013 | Jets       |                   73069
        2013 | Eagles     |                   71194
        2013 | Patriots   |                   70371
        2013 | Browns     |                   70172
        2013 | Saints     |                   70042
        2013 | Packers    |                   70036
        2013 | Panthers   |                   69765
        2013 | Chiefs     |                   69503
        2013 | Seahawks   |                   69132
        2013 | Ravens     |                   69126
        2013 | Texans     |                   68980
        2013 | Vikings    |                   68722
        2013 | 49ers      |                   66636
:

*/