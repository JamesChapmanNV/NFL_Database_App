/* Find the top 5 teams with the highest average attendance per game in a season, 
considering only games with an attendance above a certain threshold, 
and display the percentage change in attendance compared to the previous season:
*/

WITH AvgAttendance AS (
    SELECT 
        sd.season_year, 
        g.home_team, 
        ROUND(AVG(g.attendance)) AS avg_attendance_per_game,
        ROW_NUMBER() OVER (PARTITION BY g.home_team ORDER BY AVG(g.attendance) DESC) AS rn
    FROM 
        Season_Dates sd
    JOIN 
        Games g ON sd.date = g.date
    GROUP BY 
        sd.season_year, 
        g.home_team
),
PrevSeasonAttendance AS (
    SELECT 
        s1.season_year, 
        s1.home_team, 
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
            s1.home_team = s2.home_team 
            AND s1.season_year = s2.season_year + 1
        LIMIT 1
    ) s2 ON true
)
SELECT 
    pa.season_year, 
    pa.home_team, 
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
    (pa.home_team, pa.curr_season_attendance) IN (
        SELECT 
            home_team, 
            MAX(curr_season_attendance)
        FROM 
            PrevSeasonAttendance
        GROUP BY 
            home_team
    )
ORDER BY 
    pa.curr_season_attendance DESC
LIMIT 5;
