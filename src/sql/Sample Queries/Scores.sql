
-- Find the scores for each game in a week
-- Accepts input of season year and week
-- QUERY TYPE: REPORT
--15+ query requirement: Satisfied(? Not sure about the compound where condition)
SELECT home.team_name   AS home_team,
       home.total_score AS home_score,
       away.team_name   AS away_team,
       away.total_score AS away_score,
       home_team.primary_color AS home_pc,
       home_team.secondary_color AS home_sc,
       away_team.primary_color AS away_pc,
       away_team.secondary_color AS away_sc
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
JOIN teams home_team ON home_team.team_name = home.team_name
JOIN teams away_team ON away_team.team_name = away.team_name
WHERE season_year = 2018
  AND week = 10;
  
 /* QUERY result
 
  home_team  | home_score | away_team  | away_score | home_pc | home_sc | away_pc | away_sc
------------+------------+------------+------------+---------+---------+---------+---------
 Steelers   |         52 | Panthers   |         21 | 000000  | ffb612  | 0085ca  | 000000
 Bears      |         34 | Lions      |         22 | 0b1c3a  | e64100  | 0076b6  | bbbbbb
 Bengals    |         14 | Saints     |         51 | fb4f14  | 000000  | d3bc8d  | 000000
 Browns     |         28 | Falcons    |         16 | 472a08  | ff3c00  | a71930  | 000000
 Titans     |         34 | Patriots   |         10 | 4b92db  | 002a5c  | 002a5c  | c60c30
 Colts      |         29 | Jaguars    |         26 | 003b75  | ffffff  | 007487  | d7a22a
 Chiefs     |         26 | Cardinals  |         14 | e31837  | ffb612  | a4113e  | ffffff
 Jets       |         10 | Bills      |         41 | 115740  | ffffff  | 00338d  | d50a0a
 Buccaneers |          3 | Commanders |         16 | bd1c36  | 3e3a35  | 5a1414  | ffb612
 Raiders    |          6 | Chargers   |         20 | 000000  | a5acaf  | 0080c6  | ffc20e
 Packers    |         31 | Dolphins   |         12 | 204e32  | ffb612  | 008e97  | fc4c02
 Rams       |         36 | Seahawks   |         31 | 003594  | ffd100  | 002a5c  | 69be28
 Eagles     |         20 | Cowboys    |         27 | 06424d  | 000000  | 002a5c  | b0b7bc
 49ers      |         23 | Giants     |         27 | aa0000  | b3995d  | 003c7f  | c9243f
(14 rows)

*/