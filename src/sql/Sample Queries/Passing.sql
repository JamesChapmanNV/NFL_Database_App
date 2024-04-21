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
