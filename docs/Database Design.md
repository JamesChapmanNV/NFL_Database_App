# CIS 761- Project Database Design

## Relations

Teams(<ins>team_id</ins>, name, abbreviation, location, primary_color, secondary_color)

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

**Teams**:

$team\_id \to name, abbreviation, location, primary\_color, secondary\_color$

**Venues**

$venue\_id \to full\_name, capacity, city, state, zip\_code, grass, indoor$

**Games**

$game\_id \to name, shortName, date, week, year, attendance, season\_type, home\_win\_bool, home\_team\_id, away\_team\_id, venue\_id$

**Athletes**

$athlete\_id \to first\_name, last\_name, dob, jersey, height, weight, birth\_place, drafted\_bool$

**Positions**

$position\_id \to abbreviation, name$

**Rosters**

$game\_id, team\_id, athlete\_id \to position\_id, active, did\_not\_play$

**Linescores**

$team\_id, game\_id, quarter \to score$

**Plays**

$play\_id \to player\_id, game\_id, quarter, yards, score\_value, play\_type, text, seconds\_remaining$