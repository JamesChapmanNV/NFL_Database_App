/* This query retrieves statistics and calculates passer rating for NFL players in a season year.

 Selecting player information along with calculated statistics and passer rating.
 
     Passing Yards: This refers to the total number of yards gained by a team's offense through completed passes.

    Pass Attempts: A pass attempt occurs when the quarterback throws the ball with the intention of completing a forward pass to a teammate. Pass attempts include both completed passes and incomplete passes 

    Pass Completions: A pass completion happens when the quarterback successfully throws the ball to a teammate, and the teammate catches the ball without it touching the ground.

    Touchdown Passes: This refers to the number of passes thrown by the quarterback that result in a touchdown.

    Interceptions: An interception occurs when a defensive player catches a pass thrown by the quarterback intended for an offensive player.
*/
-- QUERY TYPE: Report
-- 15+ query requirement: Satsfied

/* Note: Error in passer rating formula implementation, need to fix */

SELECT 
    -- Selecting player ID, first name, and last name.
    a.athlete_id AS player_id, 
    a.first_name, 
    a.last_name,
    -- Selecting passing yards, pass attempts, pass completions, touchdown passes, interceptions, and passer rating.
    passing_yards, 
    pass_attempts, 
    pass_completions, 
    touchdown_passes, 
    passes_intercepted,
    -- Calculating passer rating based on the NFL formula.
    ROUND(
        CASE WHEN pass_attempts > 0 -- Ensuring there are passing attempts to avoid division by zero.
            THEN (
                (
                    -- Calculating completion percentage component of passer rating.
                    LEAST(GREATEST(((pass_completions / pass_attempts) - 0.3) * 5, 0), 2.375) +
                    -- Calculating yards per attempt component of passer rating.
                    LEAST(GREATEST(((passing_yards / pass_attempts) - 3) * 0.25, 0), 2.375) +
                    -- Calculating touchdown pass component of passer rating.
                    LEAST(GREATEST(((touchdown_passes / pass_attempts) * 20), 0), 2.375) +
                    -- Calculating interception component of passer rating.
                    LEAST(GREATEST((2.375 - (passes_intercepted / pass_attempts) * 25), 0), 2.375)
                ) / 6
            ) * 100
            ELSE 0 -- If there are no passing attempts, set passer rating to 0.
        END, 1 -- Rounding the calculated passer rating to one decimal place.
    ) AS passer_rating
-- Subquery to calculate intermediate statistics for each player.
FROM (
    -- Selecting player ID along with aggregated statistics for passing attempts, completions, touchdowns, interceptions, and passing yards.
    SELECT 
        pp.player_id,
        SUM(CASE WHEN p.play_type = 'Pass Interception Return' THEN 1 ELSE 0 END) AS passes_intercepted,
        SUM(CASE WHEN p.play_type = 'Passing Touchdown' THEN 1 ELSE 0 END) AS touchdown_passes,
        SUM(CASE WHEN p.play_type IN ('Pass Reception', 'Passing Touchdown') THEN 1 ELSE 0 END) AS pass_completions,
        SUM(1) AS pass_attempts,
        SUM(p.yards) AS passing_yards
    FROM 
        player_plays pp -- Joining player_plays table to access player-specific plays.
    JOIN 
        plays p ON pp.play_id = p.play_id -- Joining plays table to access play information.
    JOIN 
        games g ON pp.game_id = g.game_id -- Joining games table to access game information.
    WHERE 
        EXTRACT(YEAR FROM g.date) = 2015 -- Filtering games from the year 2015.
        AND pp.type = 'passer' -- Selecting only players who are passers.
        AND (p.play_type IN ('Pass Reception', 'Passing Touchdown', 'Pass Incompletion', 'Pass Interception Return')) -- Filtering relevant play types.
    GROUP BY 
        pp.player_id -- Grouping statistics by player ID.
) AS stats -- Alias for the subquery to refer to its results.
JOIN 
    athletes a ON stats.player_id = a.athlete_id -- Joining athletes table to access player names.
ORDER BY 
    passing_yards DESC; -- Ordering the results by passing yards in descending order.

/*(Partial) Query result
 player_id | first_name |   last_name    | passing_yards | pass_attempts | pass_completions | touchdown_passes | passes_intercepted | passer_rating
-----------+------------+----------------+---------------+---------------+------------------+------------------+--------------------+---------------
      2330 | Tom        | Brady          |          5602 |           752 |              491 |               46 |                 10 |          56.3
      2580 | Drew       | Brees          |          4646 |           586 |              396 |               31 |                 10 |          56.3
     14881 | Russell    | Wilson         |          4612 |           524 |              348 |               37 |                 13 |          60.4
      5529 | Philip     | Rivers         |          4606 |           621 |              415 |               27 |                  7 |          56.3
      4459 | Carson     | Palmer         |          4554 |           520 |              329 |               34 |                 10 |          60.4
     12483 | Matthew    | Stafford       |          4445 |           594 |              397 |               30 |                 14 |          56.3
     16724 | Blake      | Bortles        |          4368 |           575 |              341 |               35 |                 13 |          56.3
      5526 | Eli        | Manning        |          4315 |           575 |              362 |               33 |                 12 |          56.3
     11237 | Matt       | Ryan           |          4269 |           581 |              384 |               19 |                 14 |          56.3
     13994 | Cam        | Newton         |          4175 |           540 |              318 |               37 |                 12 |          56.3
     14880 | Kirk       | Cousins        |          4109 |           534 |              368 |               26 |                 10 |          56.3
     16757 | Derek      | Carr           |          4042 |           532 |              326 |               31 |                  9 |          56.3
      8439 | Aaron      | Rodgers        |          4041 |           602 |              360 |               34 |                 10 |          52.1
      5536 | Ben        | Roethlisberger |          3987 |           475 |              323 |               19 |                 16 |          60.4
     14876 | Ryan       | Tannehill      |          3968 |           544 |              337 |               22 |                 10 |          56.3
   2969939 | Jameis     | Winston        |          3807 |           486 |              280 |               22 |                 11 |          56.3
      8664 | Ryan       | Fitzpatrick    |          3741 |           521 |              315 |               29 |                 12 |          56.3
      9597 | Jay        | Cutler         |          3502 |           460 |              295 |               19 |                  5 |          56.3
     13197 | Sam        | Bradford       |          3479 |           494 |              315 |               17 |                 12 |          56.3
     11252 | Joe        | Flacco         |          3426 |           485 |              311 |               20 |                 13 |          56.3
     14012 | Andy       | Dalton         |          3424 |           418 |              270 |               25 |                  7 |          60.4
      8416 | Alex       | Smith          |          3416 |           441 |              287 |               18 |                  5 |          56.3
     16728 | Teddy      | Bridgewater    |          3203 |           427 |              280 |               14 |                  8 |          56.3
     14874 | Andrew     | Luck           |          2885 |           421 |              236 |               18 |                 16 |          52.1
   2576980 | Marcus     | Mariota        |          2866 |           368 |              229 |               19 |                  8 |          56.3
     14163 | Tyrod      | Taylor         |          2799 |           353 |              224 |               20 |                  6 |          56.3
      1428 | Peyton     | Manning        |          2498 |           366 |              219 |               10 |                 14 |          52.1
     12477 | Brian      | Hoyer          |          2368 |           332 |              199 |               18 |                  5 |          56.3
      3609 | Josh       | McCown         |          2130 |           291 |              185 |               12 |                  3 |          56.3
     14877 | Nick       | Foles          |          2066 |           333 |              188 |                7 |                  8 |          52.1
      1575 | Matt       | Hasselbeck     |          1799 |           259 |              157 |                9 |                  5 |          52.1
     14879 | Brock      | Osweiler       |          1788 |           251 |              154 |                9 |                  4 |          56.3
     13987 | Blaine     | Gabbert        |          1730 |           240 |              151 |                9 |                  6 |          56.3
     14001 | Colin      | Kaepernick     |          1628 |           241 |              143 |                6 |                  3 |          52.1
     16736 | Johnny     | Manziel        |          1597 |           221 |              127 |                7 |                  5 |          56.3
      5209 | Tony       | Romo           |          1433 |           168 |              116 |                9 |                  5 |          60.4
      8644 | Matt       | Cassel         |          1296 |           204 |              119 |                5 |                  5 |          52.1
     14878 | Brandon    | Weeden         |          1126 |           141 |               96 |                5 |                  2 |          56.3
     14037 | Ryan       | Mallett        |          1078 |           188 |              105 |                4 |                  4 |          47.9
     16814 | Zach       | Mettenberger   |           998 |           154 |               97 |                4 |                  6 |          52.1
     13198 | Jimmy      | Clausen        |           747 |           124 |               72 |                2 |                  3 |          52.1
     16810 | AJ         | McCarron       |           731 |            91 |               62 |                4 |                  1 |          60.4
     15168 | Case       | Keenum         |           646 |            89 |               54 |                4 |                  1 |          56.3
     12482 | Mark       | Sanchez        |           640 |            91 |               60 |                4 |                  3 |          56.3
     15904 | Landry     | Jones          |           600 |            55 |               32 |                3 |                  4 |          68.8
     15803 | EJ         | Manuel         |           570 |            82 |               51 |                3 |                  2 |          52.1
      5615 | Matt       | Schaub         |           534 |            78 |               52 |                3 |                  2 |          52.1
     14882 | Kellen     | Moore          |           443 |            56 |               28 |                1 |                  4 |          56.3
     14114 | T.J.       | Yates          |           391 |            57 |               28 |                3 |                  1 |          52.1
      2549 | Mike       | Vick           |           391 |            68 |               40 |                2 |                  2 |          47.9
     15187 | Austin     | Davis          |           371 |            48 |               32 |                1 |                  1 |          56.3
      5631 | Luke       | McCown         |           327 |            38 |               31 |                0 |                  1 |          60.4
:
*/