-- Get the venue information, including the home team that matches the given
-- search criteria.
-- This is a question type query
-- 15+ query requirement: Not satisfied
SELECT v.*, teams.team_name
FROM venues v
JOIN teams ON teams.venue_name = v.venue_name
WHERE v.venue_name LIKE '%';