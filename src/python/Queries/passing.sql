SELECT
    a.athlete_id AS player_id,
    a.first_name || ' ' || a.last_name AS name,
    passing_yards,
    pass_attempts,
    pass_completions,
    touchdown_passes,
    passes_intercepted,
    ROUND(
        CASE WHEN pass_attempts > 0
            THEN (
                (
                    LEAST(GREATEST(((pass_completions / pass_attempts) - 0.3) * 5, 0), 2.375) +
                    LEAST(GREATEST(((passing_yards / pass_attempts) - 3) * 0.25, 0), 2.375) +
                    LEAST(GREATEST(((touchdown_passes / pass_attempts) * 20), 0), 2.375) +
                    LEAST(GREATEST((2.375 - (passes_intercepted / pass_attempts) * 25), 0), 2.375)
                ) / 6
            ) * 100
            ELSE 0
        END, 1
    ) AS passer_rating
FROM (
    SELECT
        pp.player_id,
        SUM(CASE WHEN p.play_type = 'Pass Interception Return' THEN 1 ELSE 0 END) AS passes_intercepted,
        SUM(CASE WHEN p.play_type = 'Passing Touchdown' THEN 1 ELSE 0 END) AS touchdown_passes,
        SUM(CASE WHEN p.play_type IN ('Pass Reception', 'Passing Touchdown') THEN 1 ELSE 0 END) AS pass_completions,
        SUM(1) AS pass_attempts,
        SUM(p.yards) AS passing_yards
    FROM
        player_plays pp
    JOIN
        plays p ON pp.play_id = p.play_id
    JOIN
        games g ON pp.game_id = g.game_id
    WHERE
        EXTRACT(YEAR FROM g.date) = %s
        AND pp.type = 'passer'
        AND (p.play_type IN ('Pass Reception', 'Passing Touchdown', 'Pass Incompletion', 'Pass Interception Return')) -- Filtering relevant play types.
    GROUP BY
        pp.player_id
) AS stats
JOIN
    athletes a ON stats.player_id = a.athlete_id
    {where_filter}
ORDER BY
    passing_yards DESC;