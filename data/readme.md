Current tables are as follows:
**Teams**
| column | data_type | constraints |
| ------- | --------- | ----------- |
| team_name | VARCHAR(45) | PRIMARY KEY |
| abbreviation | VARCHAR(3) | UNIQUE |
| location | VARCHAR(20) | |
| venue_name | VARCHAR(55) | FOREGIN KEY(Venues.name) |
| primary_color | CHAR(6) | |
| secondary_color | CHAR(6) | |
**Positions**
| column | data_type | constraints |
| ------ | --------- | ----------- |
| position_name | VARCHAR(20) | PRIMARY KEY |
| abbreviation | VARCHAR(2) | UNIQUE |
| platoon | VARCHAR(13) | |
**Athletes**
| column | data_type | constraints |
| ------ | --------- | ----------- |
| athlete_id | BIGINT | PRIMARY KEY |
| first_name | VARCHAR(45) | |
| last_name | VARCHAR(45) | |
| dob | DATE | |
| height | NUMERIC | |
| weight | NUMERIC | |
| birth_city | VARCHAR(20) | |
| birth_state | VARCHAR(20) | |
**Rosters**
| column | data_type | constraints |
| ------ | --------- | ----------- |
| game_id | BIGINT | FOREIGN KEY(Games.game_id) |
| team_name | VARCHAR(45) | FOREIGN KEY(Teams.team_name) |
| athlete_id | BIGINT | FOREIGN KEY(Athletes.athlete_id) |
| position_name | VARCHAR(20) | FOREIGN KEY(Positions.position_name) |
| played | BOOLEAN | |
| game_id, team_name, athlete_id | | PRIMARY KEY |
**Venues**
| column | data_type | constraints |
| ------ | --------- | ----------- |
| venue_name | VARCHAR(45) | PRIMARY KEY |
| capacity | INT | |
| city | VARCHAR(20) | |
| state | CHAR(2) | |
| grass | BOOLEAN | |
| indoor | BOOLEAN | |
**Games**
| column | data_type | constraints |
| ------ | --------- | ----------- |
| game_id | BIGINT | PRIMARY KEY |
| date | DATE | NOT NULL FOREIGN KEY(Season_Dates.date) |
| attendance | INT | |
| home_team | VARCHAR(45) | FOREIGN KEY(Teams.team_name) |
| away_team | VARCHAR(45) | FOREIGN KEY(Teams.team_name) |
| venue_name | VARCHAR(45) | FOREIGN KEY(Venues.venue_name) |
| utc_time | TIME | |
**Season_Dates**
| column | data_type | constraints |
| ------ | --------- | ----------- |
| date | DATE | PRIMARY KEY |
| season_year | NOT NULL | NOT NULL |
| season_type | VARCHAR(20) | NOT NULL |
| week | INT | NOT NULL |
**Plays**
| column | data_type | constraints |
| ------ | --------- | ----------- |
| play_id | BIGINT | PRIMARY KEY |
| quarter | INT | NOT NULL |
| yards | INT | NOT NULL |
| score_value | INT | NOT NULL |
| play_type | VARCHAR(45) | NOT NULL |
| text | TEXT | |
| seconds_remaining | INT | |
| start_down | INT | NOT NULL |
| end_down | INT | NOT NULL |
**Player_Plays**
| column | data_type | constraints |
| ------ | --------- | ----------- |
| play_id | BIGINT | FOREIGN KEY(Plays.play_id) |
| player_id | BIGINT | FOREIGN KEY(Athletes.athlete_id) |
| game_id | BIGINT | NOT NULL |
| type | VARCHAR(20) | NOT NULL |
| play_id, player_id, type | | PRIMARY KEY |
**Linescores**
| column | data_type | constraints |
| ------ | --------- | ----------- |
| team_name | VARCHAR(45) | FOREIGN KEY(Teams.team_name) |
| game_id | BIGINT | FOREIGN KEY(Games.game_id) |
| quarter | INT | FOREIGN KEY(Games.quarter) |
| score | INT | NOT NULL |
| team_name, game_id, quarter | | PRIMARY KEY |
