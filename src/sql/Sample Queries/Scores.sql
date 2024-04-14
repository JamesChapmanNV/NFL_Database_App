
-- Find the scores for each game in a week
-- Accepts input of season year and week
SELECT home.team_name   AS home_team,
       home.total_score AS home_score,
       away.team_name   AS away_team,
       away.total_score AS away_score
FROM games
         JOIN season_dates s ON s.date = games.date
         JOIN (SELECT team_name, SUM(score) AS total_score
               FROM season_dates sd
                        JOIN games g ON sd.date = g.date
                        JOIN linescores l ON l.game_id = g.game_id
               WHERE season_year = 2018
                 AND week = 10
               GROUP BY team_name) AS home ON home.team_name = games.home_team_name
         JOIN (SELECT team_name, SUM(score) AS total_score
               FROM season_dates sd
                        JOIN games g ON sd.date = g.date
                        JOIN linescores l ON l.game_id = g.game_id
               WHERE season_year = 2018
                 AND week = 10
               GROUP BY team_name) AS away ON away.team_name = games.away_team_name
WHERE season_year = 2018
  AND week = 10;


/*
    Query to retrieve game scores along with primary and secondary colors of home and away teams


SELECT
    home.team_name AS home_team,
    home.total_score AS home_score,
    home.primary_color AS home_primary_color,
    home.secondary_color AS home_secondary_color,
    away.team_name AS away_team,
    away.total_score AS away_score,
    away.primary_color AS away_primary_color,
    away.secondary_color AS away_secondary_color
FROM
    games
    JOIN season_dates s ON s.date = games.date
    JOIN (
        SELECT
            t.team_name,
            SUM(score) AS total_score,
            t.primary_color,
            t.secondary_color
        FROM
            season_dates sd
            JOIN games g ON sd.date = g.date
            JOIN linescores l ON l.game_id = g.game_id
            JOIN teams t ON g.home_team = t.team_name
        WHERE
            season_year = :year AND
            week = :week
        GROUP BY
            t.team_name, t.primary_color, t.secondary_color
    ) AS home ON home.team_name = games.home_team_name
    JOIN (
        SELECT
            t.team_name,
            SUM(score) AS total_score,
            t.primary_color,
            t.secondary_color
        FROM
            season_dates sd
            JOIN games g ON sd.date = g.date
            JOIN linescores l ON l.game_id = g.game_id
            JOIN teams t ON g.away_team_name = t.team_name
        WHERE
            season_year = :year AND
            week = :week
        GROUP BY
            team_name, primary_color, secondary_color
    ) AS away ON away.team_name = games.away_team_name
WHERE
    season_year = :year AND
    week = :week;

*/