/* List all games where the total number of points scored in the first quarter is greater than the total number of points scored in any other quarter: */
/* QUERY TYPE: Report */
/* 15+ query requirement: Not satisfied(No aggregate function used in select statement) */

SELECT g.game_id, g.date, g.home_team_name, g.away_team_name
FROM Games g
JOIN (SELECT game_id,
             SUM(CASE WHEN quarter = 1 THEN score ELSE 0 END) AS first_quarter_score,
             SUM(CASE WHEN quarter = 2 THEN score ELSE 0 END) AS second_quarter_score,
             SUM(CASE WHEN quarter = 3 THEN score ELSE 0 END) AS third_quarter_score,
             SUM(CASE WHEN quarter = 4 THEN score ELSE 0 END) AS fourth_quarter_score
      FROM Linescores
      GROUP BY game_id) ls ON g.game_id = ls.game_id
WHERE first_quarter_score > GREATEST(second_quarter_score, third_quarter_score, fourth_quarter_score);

/* (partial) Query result

  game_id  |    date    | home_team_name | away_team_name
-----------+------------+----------------+----------------
 330106028 | 2013-01-06 | Commanders     | Seahawks
 330112007 | 2013-01-12 | Broncos        | Ravens
 330908030 | 2013-09-08 | Jaguars        | Chiefs
 330909028 | 2013-09-09 | Commanders     | Eagles
 330912017 | 2013-09-13 | Patriots       | Jets
 330915012 | 2013-09-15 | Chiefs         | Cowboys
 330915027 | 2013-09-15 | Buccaneers     | Saints
 330929013 | 2013-09-29 | Raiders        | Commanders
 331006011 | 2013-10-06 | Colts          | Seahawks
 331006025 | 2013-10-07 | 49ers          | Texans
 331013002 | 2013-10-13 | Bills          | Bengals
 331020020 | 2013-10-20 | Jets           | Patriots
 331021019 | 2013-10-22 | Giants         | Vikings
 331110019 | 2013-11-10 | Giants         | Raiders
 331117030 | 2013-11-17 | Jaguars        | Cardinals
 331121001 | 2013-11-22 | Falcons        | Saints
 331124014 | 2013-11-24 | Rams           | Bears
 331124034 | 2013-11-24 | Texans         | Jaguars
 331201029 | 2013-12-01 | Panthers       | Buccaneers
 331201002 | 2013-12-01 | Bills          | Falcons
 331208027 | 2013-12-08 | Buccaneers     | Bills
 331208007 | 2013-12-08 | Broncos        | Titans
 331215001 | 2013-12-15 | Falcons        | Commanders
 331215014 | 2013-12-15 | Rams           | Saints
 331215023 | 2013-12-16 | Steelers       | Bengals
 331229011 | 2013-12-29 | Colts          | Jaguars
 331229024 | 2013-12-29 | Chargers       | Chiefs
 340111017 | 2014-01-12 | Patriots       | Colts
 400554232 | 2014-09-07 | Bears          | Bills
 400554262 | 2014-09-07 | Dolphins       | Patriots
 400554269 | 2014-09-07 | Cowboys        | 49ers
 400554235 | 2014-09-14 | Vikings        | Patriots
 400554274 | 2014-09-14 | Buccaneers     | Rams
 400554244 | 2014-09-21 | Lions          | Packers
 400554213 | 2014-09-21 | Saints         | Vikings
 400554203 | 2014-09-21 | Eagles         | Commanders
 400554288 | 2014-09-23 | Jets           | Bears
 400554279 | 2014-09-28 | Steelers       | Buccaneers
 400554242 | 2014-09-28 | Vikings        | Falcons
 400554200 | 2014-10-05 | Panthers       | Bears
 400554216 | 2014-10-10 | Texans         | Colts
 400554225 | 2014-10-12 | Buccaneers     | Ravens
:
*/