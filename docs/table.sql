-- This script will import the NFL data into PostgreSQL. 
-- To run, feed it to the psql utility as:
-- \i nfl.sql
-- Note that this script, as written, assumes that the files
-- is in the data directory.  

-- copied from drop_tables.sql
DROP TABLE IF EXISTS linescores CASCADE;
DROP TABLE IF EXISTS player_plays CASCADE;
DROP TABLE IF EXISTS plays CASCADE;
DROP TABLE IF EXISTS rosters CASCADE;
DROP TABLE IF EXISTS games CASCADE;
DROP TABLE IF EXISTS season_dates CASCADE;
DROP TABLE IF EXISTS athletes CASCADE;
DROP TABLE IF EXISTS positions CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP TABLE IF EXISTS venues CASCADE;

-- copied from create_tables.sql
-- Create tables in the database
CREATE TABLE venues(
    venue_name VARCHAR(45) PRIMARY KEY,
    capacity INT,
    city VARCHAR(20),
    state CHAR(2),
    grass BOOLEAN,
    indoor BOOLEAN
);

CREATE TABLE teams(
    team_name VARCHAR(45) PRIMARY KEY,
    abbreviation VARCHAR(3) UNIQUE,
    location VARCHAR(20),
    venue_name VARCHAR(45) REFERENCES venues(venue_name),
    primary_color CHAR(6),
    secondary_color CHAR(6)
);

CREATE TABLE positions(
    position_name VARCHAR(20) PRIMARY KEY,
    abbreviation VARCHAR(3) UNIQUE,
    platoon VARCHAR(13)
);

CREATE TABLE athletes(
    athlete_id BIGINT PRIMARY KEY,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    dob DATE,
    height NUMERIC,
    weight NUMERIC,
    birth_city VARCHAR(45),
    birth_state VARCHAR(45)
);

CREATE TABLE season_dates(
    date DATE PRIMARY KEY,
    season_year INT NOT NULL,
    season_type VARCHAR(20) NOT NULL,
    week INT NOT NULL
);

CREATE TABLE games(
    game_id BIGINT PRIMARY KEY,
    date DATE NOT NULL REFERENCES season_dates(date),
    attendance INT,
    home_team VARCHAR(45) NOT NULL REFERENCES teams(team_name),
    away_team VARCHAR(45) NOT NULL REFERENCES teams(team_name),
    venue_name VARCHAR(45) REFERENCES venues(venue_name),
    utc_time TIME
);

CREATE TABLE rosters(
    game_id BIGINT REFERENCES games(game_id),
    team_name VARCHAR(45) REFERENCES teams(team_name),
    athlete_id BIGINT REFERENCES athletes(athlete_id),
    position_name VARCHAR(20) REFERENCES positions(position_name),
    played BOOLEAN,
    PRIMARY KEY(game_id, team_name, athlete_id)
);

CREATE TABLE plays(
    play_id BIGINT PRIMARY KEY,
    quarter INT NOT NULL,
    yards INT NOT NULL,
    score_value INT NOT NULL,
    play_type VARCHAR(45),
    text TEXT,
    seconds_remaining INT,
    start_down INT NOT NULL,
    end_down INT NOT NULL
);

CREATE TABLE player_plays(
    play_id BIGINT REFERENCES plays(play_id),
    player_id BIGINT REFERENCES athletes(athlete_id),
    game_id BIGINT REFERENCES games(game_id),
    type VARCHAR(20) NOT NULL,
    PRIMARY KEY(play_id, player_id, type)
);

CREATE TABLE linescores(
    team_name VARCHAR(45) REFERENCES teams(team_name),
    game_id BIGINT REFERENCES games(game_id),
    quarter INT NOT NULL ,
    score INT NOT NULL ,
    PRIMARY KEY(team_name, game_id, quarter)
);

-- copied from data_import.sql
\copy venues(venue_name, capacity, grass, indoor, city, state) from '../../data/venues.csv' DELIMITER ',' CSV HEADER;
\copy teams(location, team_name, abbreviation, primary_color, secondary_color, venue_name) from '../../data/teams.csv' DELIMITER ',' CSV HEADER;
\copy positions(position_name, abbreviation, platoon) from '../../data/positions.csv' DELIMITER ',' CSV HEADER;
\copy athletes(athlete_id, first_name, last_name, height, weight, dob, birth_city, birth_state) from '../../data/athletes_split.csv' DELIMITER ',' CSV HEADER;
\copy season_dates(date, season_year, season_type, week) from '../../data/season_dates.csv' DELIMITER ',' CSV HEADER;
\copy games(game_id, date, attendance, utc_time, venue_name, home_team, away_team) from '../../data/games.csv' DELIMITER ',' CSV HEADER;
\copy rosters(game_id, athlete_id, played, team_name, position_name) from '../../data/rosters.csv' DELIMITER ',' CSV HEADER;
\copy plays(play_id, start_down, end_down, quarter, play_type, seconds_remaining, text, score_value, yards) from '../../data/full_plays.csv' DELIMITER ',' CSV HEADER;
\copy player_plays(play_id, game_id, player_id, type) from '../../data/full_player_plays.csv' DELIMITER ',' CSV HEADER;
\copy linescores(game_id, quarter, score, team_name) from '../../data/linescores.csv' DELIMITER ',' CSV HEADER;

