# CIS 761- Project Database Design

## E/R Diagram
Please see the attached E/R diagram png file. Weak entity sets and their relationships are denoted as dashed lines. Additionally, exactly one relationships are denoted as a line with two dashes through them.

## Relations

Users([uid]{.underline}, username, password, first_name, last_name, created_on, favorite_team_name, favorite_athlete_id)

* favorite_team_name is a foreign key referencing Teams.team_name
* favorite_athlete_id is a foreign key referencing Athletes.athlete_id
* username is a unique key

Teams([team_name]{.underline}, location, abbreviation, venue_name, primary_color, secondary_color)

* venue_name is a foreign key referencing Venues.venue_name

Venues([venue_name]{.underline}, capacity, city, state, grass, indoor)

Games([game_id]{.underline}, date, attendance, home_team_name, away_team_name, venue_name, utc_time)

* date is a foreign key referencing Season_dates.date
* home_team_name is a foreign key referencing Teams.team_name
* away_team_name is a foreign key referencing Teams.team_name
* venue_name is a foreign key referencing Venues.venue_name
* date, home_team_name, away_team_name is a unique key

Season_dates([date]{.underline}, season_year, season_type, week)
	
Athletes([athlete_id]{.underline}, first_name, last_name, dob, height, weight, birth_city, birth_state)

Positions([position_name]{.underline}, abbreviation, platoon)

* abbreviation is a unique key

Rosters([team_name]{.underline}, [athlete_id]{.underline}, position_name, [start_date]{.underline}, end_date)

* team_name is a foreign key referencing teams.team_name
* athlete_id is a foreign key referencing players.player_id
* position_name is a foreign key referencing positions.position_name
	
Linescores([team_name]{.underline}, [game_id]{.underline}, [quarter]{.underline}, score)

* team_name is a foreign key referencing teams.team_name
* game_id is a foreign key referencing games.game_id

Plays([play_id]{.underline}, quarter, yards, score_value, play_type, text, seconds_remaining, start_down, end_down)

Player_Plays([play_id]{.underline}, [player_id]{.underline}, game_id, type)

* play_id is a foreign key referencing plays.play_id
* player_id is a foreign key referencing Athletes.athlete_id
* game_id is a foreign key referencing Games.game_id

## Functional Dependencies

**Users**:

$uid \to username, password, first\_name, last\_name, created\_on, favorite\_team\_name, favorite\_athlete\_name$

$username \to uid, password, first\_name, last\_name, created\_on, favorite\_team\_name, favorite\_athlete\_name$

**Teams**:

$team\_name \to location, abbreviation, venue\_name, primary\_color, secondary\_color$

$abbreviation \to location, team\_name, venue\_name, primary\_color, secondary\_color$

**Venues**

$venue\_name \to capacity, city, state, grass, indoor$


**Games**

$game\_id \to attendance, date, utc\_time, home\_team\_id, away\_team\_id, venue\_name$

$home\_team\_id, date \to game\_id, away\_team\_id, attendance, utc\_time, venue\_name$

$away\_team\_id, date \to game\_id, home\_team\_id, attendance, utc\_time, venue\_name$


**Season_Dates**

$date \to season\_year, season\_type, week$

**Athletes**

$athlete\_id \to first\_name, last\_name, dob, height, weight, birth\_city, birth\_state$

**Positions**

$position\_name \to abbreviation, platoon$

$abbreviation \to position\_name, platoon$

**Rosters**

$start\_date, athlete\_id, team\_name \to position\_name, end\_date$

$end\_date, team\_name, athlete\_id \to position\_name, start\_date$

**Linescores**

$team\_name, game\_id, quarter \to score$

**Plays**

$play\_id \to quarter, yards, score\_value, play\_type, text, seconds\_remaining, start\_down, end\_down$

**Player_plays**

$play\_id, player\_id \to game\_id, type$

## BCNF
Yes, all of the relations in the schema are in BCNF. Each of the functional dependencies listed is a superkey.

## Part E- Is there anything we don't like about the schema?
As it stands, we are happy with the schema as it stands. Originally the data contained numerical IDs for teams, venues, and position, which had the potential to result in duplicate entries. However, since position, team and venue names are unique, we decided to remove the numeric ID and use team/venue name as the key. The original data also had birth place as a string of the form CITY, STATE, which is not an optimal way to store this data. Therefore, we split the string and created an attribute for city and state separately. This will avoid string manipulation when working with this data. 

## Additional Notes
1. We assume the functional dependency $city \to state$ does not hold (ex. Kansas City in MO or KS)
2. While a single attribute (city, state) may be used instead of two attributes, the modelling we used is convienent as it allows us to more easily use the data and does not violate BCNF.
3. We may make small changes to the database design as we collect additional data.
4. We kept team name in the rosters primary key in case a player is contacted with one team on a given date, and then immediately re-contracted with a different team on the same day.
