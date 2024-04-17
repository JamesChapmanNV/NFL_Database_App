SELECT v.*, teams.team_name
FROM venues v
         JOIN teams ON teams.venue_name = v.venue_name
WHERE v.venue_name LIKE %s;