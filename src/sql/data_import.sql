copy venues(venue_name, capacity, city, state, grass, indoor) from FROM STDIN DELIMITER ',' CSV HEADER;

-- copy venues(venue_name, capacity, city, state, grass, indoor) from '../data/venues.csv' DELIMITER ',' CSV HEADER;
-- copy teams(team_name, abbreviation, location, venue_name, primary_color, secondary_color) from '../data/teams.csv' DELIMITER ',' CSV HEADER;
-- copy positions(position_name, abbreviation, platoon) from '../data/positions.csv' DELIMITER ',' CSV HEADER;
-- copy athletes(athlete_id, first_name, last_name, dob, height, weight, birth_city, birth_state) from '../data/athletes.csv' DELIMITER ',' CSV HEADER;
-- copy season_dates(date, season_year, season_type, week) from '../data/season_dates.csv' DELIMITER ',' CSV HEADER;
-- copy games(game_id, date, attendance, home_team_name, away_team_name, venue_name, utc_time) from '../data/games.csv' DELIMITER ',' CSV HEADER;
-- copy rosters(game_id, team_name, athlete_id, position_name, played) from '../data/rosters.csv' DELIMITER ',' CSV HEADER;
-- copy plays(play_id, quarter, yards, score_value, play_type, text, seconds_remaining, start_down, end_down) from '../data/plays.csv' DELIMITER ',' CSV HEADER;
-- copy player_plays(play_id, player_id, game_id, type) from '../data/player_plays.csv' DELIMITER ',' CSV HEADER;
-- copy linescores(game_id, quarter, score, team_name) from '../data/linescores.csv' DELIMITER ',' CSV HEADER;