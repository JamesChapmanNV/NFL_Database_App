/*
	Kansas State University
	CIS 761: Database Management Systems
	NFL Database Project - Project Interim Update 

	Vishnu Bondalakunta
	Chuck Zumbaugh
	James Chapman
*/
-- CREATES 11 TABLES

-- copied from drop_tables.sql
DROP TABLE IF EXISTS users CASCADE;
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

-- Copied from create_tables.sql
-- Replaced rosters with rosters_decomposition.SQL
-- Added users
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
    home_team_name VARCHAR(45) NOT NULL REFERENCES teams(team_name),
    away_team_name VARCHAR(45) NOT NULL REFERENCES teams(team_name),
    venue_name VARCHAR(45) REFERENCES venues(venue_name),
    utc_time TIME
);


CREATE TABLE plays(
    play_id BIGINT PRIMARY KEY,
    quarter INT NOT NULL,
    yards INT NOT NULL,
    score_value INT NOT NULL,
    play_type VARCHAR(45) NOT NULL,
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

CREATE TABLE rosters(
    athlete_id BIGINT REFERENCES athletes(athlete_id),
    team_name VARCHAR(45) REFERENCES teams(team_name),
    position_name VARCHAR(20) REFERENCES positions(position_name),
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (athlete_id, team_name, start_date)
);

CREATE TABLE users(
    uid SERIAL PRIMARY KEY,
    username VARCHAR(45) UNIQUE NOT NULL,
    password VARCHAR(45) NOT NULL,
    first_name VARCHAR(45),
    last_name VARCHAR(45) NOT NULL,
    created_on DATE NOT NULL,
    favorite_team_name VARCHAR(45) REFERENCES teams(team_name),
    favorite_athlete_id BIGINT REFERENCES athletes(athlete_id)
);

