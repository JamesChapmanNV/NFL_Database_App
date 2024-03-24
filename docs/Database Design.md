# CIS 761- Project Database Design

## Relations

Teams(<ins>team_name</ins>, location, abbreviation, venue_name, primary_color, secondary_color)

* venue_name is a foreign key referencing Venues.venue_name

Venues(<ins>venue_name</ins>, capacity, zip_code, grass, indoor)

* zip_code is a foreign key referencing Locations.zip_code

Locations(<ins>zip_code</ins>, city, state)

Games(<ins>game_id</ins>, date, attendance, home_team_name, away_team_name, venue_name, utc_time)

* date is a foreign key referencing Season_dates.date
* home_team_name is a foreign key referencing Teams.team_name
* away_team_name is a foreign key referencing Teams.team_name
* venue_name is a foreign key referencing Venues.venue_name

Season_dates(<ins>date</ins>, season_year, season_type, week)
	
Athletes(<ins>athlete_id</ins>, first_name, last_name, dob, jersey, height, weight, birth_place)

Positions(<ins>position_name</ins>, abbreviation)

Rosters(<ins>game_id</ins>, <ins>team_name</ins>, <ins>athlete_id</ins>. position_name, played)

* game_id is a foreign key referencing games.game_id
* team_name is a foreign key referencing teams.team_name
* athlete_id is a foreign key referencing players.player_id
* position_name is a foreign key referencing positions.position_name
	
Linescores(<ins>team_name</ins>, <ins>game_id</ins>, <ins>quarter</ins>, score)

* team_name is a foreign key referencing teams.team_name
* game_id is a foreign key referencing games.game_id

Plays(<ins>play_id</ins>, game_id, quarter, yards, score_value, play_type, text, seconds_remaining, start_down, end_down)

* player_id is a foreign key referencing players.player_id
* game_id is a foreign key referencing games.game_id

Player_Plays(<ins>play_id</ins>, <ins>player_id</ins>, <ins>game_id</ins>, type)

* play_id is a foreign key referencing plays.play_id
* player_id is a foreign key referencing Athletes.athlete_id
* game_id is a foreign key referencing Games.game_id

## Functional Dependencies

**Teams**:

$`team\_name \to location, abbreviation, venue\_name, primary\_color, secondary\_color`$
$`abbreviation \to location, team\_name, venue\_name, primary\_color, secondary\_color`$

**Venues**

$`venue\_name \to capacity, zip\_code, grass, indoor`$

**Locations**

$`zip\_code \to city, state`$

**Games**

$`game\_id \to attendance, date, utc\_time, home\_team\_id, away\_team\_id, venue\_name`$

**Athletes**

$`athlete\_id \to first\_name, last\_name, dob, jersey, height, weight, birth\_place`$

**Positions**

$`position\_name \to abbreviation`$

**Rosters**

$`game\_id, team\_name, athlete\_id \to position\_id, played`$

**Linescores**

$`team\_name, game\_id, quarter \to score`$

**Plays**

$`play\_id \to game\_id, quarter, yards, score\_value, play\_type, text, seconds\_remaining`$

**Player_plays**

$`game\_id, play\_id, player\_id \to type`$
