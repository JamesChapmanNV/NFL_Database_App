/*
The idea here is that we want to create groups for each combination of athlete, team, and position
The trick is that the dates need to be more or less continuous with respect to the team (and position).
For example, in the below data the player played for the steelers in between 2 stints with the Chiefs.
Simply grouping by the above would result in a date span of 2019-10-13 -- 2021-02-07, which would be incorrect

| athlete\_id | team\_name | position\_name | start\_date | end\_date |
| :--- | :--- | :--- | :--- | :--- |
| 169 | Chiefs | Guard | 2019-10-13 | 2020-02-02 |
| 169 | Steelers | Guard | 2020-09-14 | 2020-11-01 |
| 169 | Chiefs | Guard | 2020-12-07 | 2021-02-07 |

The idea is to generate groupings (or islands) where the player played for the same team/position in a
generally continuous date range. The end date needs not equal the next start date, but a change in the team name
or position name should trigger a new grouping.

 */

DROP TABLE IF EXISTS rosters_old;
ALTER TABLE rosters RENAME TO rosters_old; 

DROP TABLE IF EXISTS rosters;
CREATE TABLE rosters(
    athlete_id BIGINT REFERENCES athletes(athlete_id),
    team_name VARCHAR(45) REFERENCES teams(team_name),
    position_name VARCHAR(20) REFERENCES positions(position_name),
    start_date DATE,
    end_data DATE,
    PRIMARY KEY (athlete_id, team_name, position_name, start_date)
);

SELECT *
INTO rosters
FROM (
    SELECT athlete_id, team_name, position_name, min(date) AS start_date, max(date) AS end_date
FROM (
SELECT *,
       SUM(CASE
               WHEN
                   (athlete_groups.previous_team != athlete_groups.team_name OR athlete_groups.previous_team IS NULL) OR
                   (athlete_groups.previous_position != athlete_groups.position_name OR
                    athlete_groups.previous_position IS NULL)
                   THEN 1
               ELSE 0 END) OVER (ORDER BY athlete_groups.row_number) AS island_id
FROM (SELECT ROW_NUMBER() OVER (ORDER BY athlete_id, date, team_name, position_name)          AS row_number,
             athlete_id,
             team_name,
             position_name,
             date,
             LAG(team_name, 1) OVER (ORDER BY athlete_id, date, team_name, position_name)     AS previous_team,
             LAG(position_name, 1) OVER (ORDER BY athlete_id, date, team_name, position_name) AS previous_position
      FROM rosters
               JOIN games ON games.game_id = rosters.game_id) athlete_groups) roster_groups
GROUP BY roster_groups.athlete_id, roster_groups.team_name, roster_groups.position_name, roster_groups.island_id
ORDER BY athlete_id, start_date
     ) AS new_roster;
