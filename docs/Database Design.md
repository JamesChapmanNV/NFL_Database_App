# CIS 761- Project Database Design

## Relations

Teams(<ins>team_id</ins>, name, abbreviation, location, primary_color, secondary_color, home_team_id, away_team_id)

Venues(<ins>venue_id</ins>, full_name, capacity, city, state, zip_code, grass, indoor)

Games(<ins>game_id</ins>, name, shortName, date, week, year, attendance, season_type, home_win_bool, home_team_id, away_team_id, venue_id)

* home_team_id is a foreign key referencing Teams.team_id
* away_team_id is a foreign key referencing Teams.team_id
* venue_id is a foreign key referencing Venues.venue_id
	
Athletes(<ins>athlete_id</ins>, first_name, last_name, dob, jersey, height, weight, birth_place, drafted_bool)

Positions(<ins>position_id</ins>, abbreviation, name)

Rosters(<ins>game_id</ins>, <ins>team_id</ins>, <ins>athlete_id</ins>. position_id, active, did_not_play)

* game_id is a foreign key referencing games.game_id
* team_id is a foreign key referencing teams.team_id
* athlete_id is a foreign key referencing players.player_id
* position_id is a foreign key referencing positions.position_id
	
Linescores(<ins>team_id</ins>, <ins>game_id</ins>, <ins>quarter</ins>, score)

* team_id is a foreign key referencing teams.team_id
* game_id is a foreign key referencing games.game_id

Plays(<ins>play_id</ins>, player_id, game_id, quarter, yards, score_value, play_type, text, seconds_remaining)

* player_id is a foreign key referencing players.player_id
* game_id is a foreign key referencing games.game_id

## Functional Dependencies
