/* Find the top 5 teams with the highest average attendance per game in a season, 
considering only games with an attendance above a certain threshold, 
and display the percentage change in attendance compared to the previous season:
*/
/* QUERY TYPE: Question */
/* 15+ query requirement: Satisfied */

WITH AvgAttendance AS (
    SELECT 
        sd.season_year, 
        g.home_team_name, 
        ROUND(AVG(g.attendance)) AS avg_attendance_per_game,
        ROW_NUMBER() OVER (PARTITION BY g.home_team_name ORDER BY AVG(g.attendance) DESC) AS rn
    FROM 
        Season_Dates sd
    JOIN 
        Games g ON sd.date = g.date
    GROUP BY 
        sd.season_year, 
        g.home_team_name
),
PrevSeasonAttendance AS (
    SELECT 
        s1.season_year, 
        s1.home_team_name, 
        s1.avg_attendance_per_game AS curr_season_attendance,
        COALESCE(s2.avg_attendance_per_game, NULL) AS prev_season_attendance
    FROM 
        AvgAttendance s1
    LEFT JOIN LATERAL (
        SELECT 
            s2.avg_attendance_per_game
        FROM 
            AvgAttendance s2
        WHERE 
            s1.home_team_name = s2.home_team_name 
            AND s1.season_year = s2.season_year + 1
        LIMIT 1
    ) s2 ON true
)
SELECT 
    pa.season_year, 
    pa.home_team_name, 
    pa.curr_season_attendance, 
    CASE 
        WHEN pa.prev_season_attendance IS NULL THEN NULL
        ELSE ROUND(
            COALESCE(
                ((pa.curr_season_attendance - pa.prev_season_attendance) / NULLIF(pa.prev_season_attendance, 0)) * 100,
                0
            ), 
            3
        )
    END AS attendance_change_percentage
FROM 
    PrevSeasonAttendance pa
WHERE 
    (pa.home_team_name, pa.curr_season_attendance) IN (
        SELECT 
            home_team_name, 
            MAX(curr_season_attendance)
        FROM 
            PrevSeasonAttendance
        GROUP BY 
            home_team_name
    )
ORDER BY 
    pa.curr_season_attendance DESC
LIMIT 5;

/* Query result

 season_year | home_team_name | curr_season_attendance | attendance_change_percentage
-------------+----------------+------------------------+------------------------------
        2023 | Cowboys        |                  93594 |                        0.137
        2016 | Rams           |                  83165 |                       58.703
        2013 | Giants         |                  80148 |
        2019 | Jets           |                  78523 |                        0.694
        2015 | Packers        |                  78414 |                        0.129
(5 rows)

*/