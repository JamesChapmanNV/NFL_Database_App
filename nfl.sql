-- This script will import the NFL data into PostgreSQL. 
-- To run, feed it to the psql utility as:
-- \i nfl.sql
-- Note that this script, as written, assumes that the files
-- is in the data directory.  

DROP TABLE season_dates;
CREATE TABLE season_dates (
	date DATE NOT NULL PRIMARY KEY,
	season_year INT NOT NULL,
	season_type varchar(30) NOT NULL,
	week INT NOT NULL
);
\copy season_dates from 'data/season_dates.csv' DELIMITER ',' CSV HEADER;

DROP TABLE venues;
CREATE TABLE venues (
	venue_name varchar(50) NOT NULL PRIMARY KEY,
	capacity INT,
	grass BOOLEAN,
	indoor BOOLEAN,
	city varchar(30),
	state varchar(30),
	zipCode INT
);
\copy venues from 'data/venues.csv' DELIMITER ',' CSV HEADER;

DROP TABLE teams;
CREATE TABLE teams (
	location varchar(30),
	team_name varchar(30) NOT NULL PRIMARY KEY,
	abbreviation varchar(10),
	primary_color varchar(30),
	secondary_color varchar(30),
	venue_name varchar(50),
	CONSTRAINT fk_venue_name FOREIGN KEY(venue_name) 
		REFERENCES venues(venue_name)
);
\copy teams from 'data/teams.csv' DELIMITER ',' CSV HEADER;

DROP TABLE positions;
CREATE TABLE positions (
	position_name varchar(30) NOT NULL PRIMARY KEY,
	abbreviation varchar(10)
);
\copy positions from 'data/positions.csv' DELIMITER ',' CSV HEADER;

DROP TABLE athletes;
CREATE TABLE athletes (
	athlete_id INT NOT NULL PRIMARY KEY,
	firstName varchar(50),
	lastName varchar(50),
	birth_place varchar(50),
	jersey INT,
	height INT,
	weight INT,
	dob DATE
);
\copy athletes from 'data/athletes.csv' DELIMITER ',' CSV HEADER;

DROP TABLE games;
CREATE TABLE games (
	game_id INT NOT NULL PRIMARY KEY,
	date DATE NOT NULL,
	attendance INT,
	utc_time TIME NOT NULL,
	venue_name varchar(50),
	home_team_name varchar(30) NOT NULL,
	away_team_name varchar(30) NOT NULL,
	CONSTRAINT fk_date FOREIGN KEY(date) 
		REFERENCES season_dates(date),
	CONSTRAINT fk_venue_name FOREIGN KEY(venue_name) 
		REFERENCES venues(venue_name),
	CONSTRAINT fk_home_team_name FOREIGN KEY(home_team_name) 
		REFERENCES teams(team_name),
	CONSTRAINT fk_away_team_name FOREIGN KEY(away_team_name) 
		REFERENCES teams(team_name)
);
\copy games from 'data/games.csv' DELIMITER ',' CSV HEADER;

DROP TABLE linescores;
CREATE TABLE linescores (
	game_id INT NOT NULL,
	quarter INT NOT NULL,
	score INT,
	team_name varchar(30) NOT NULL,
	PRIMARY KEY(game_id,quarter,team_name),
	CONSTRAINT fk_game_id FOREIGN KEY(game_id) 
		REFERENCES games(game_id),
    CONSTRAINT fk_team_name FOREIGN KEY(team_name) 
		REFERENCES teams(team_name)
);
\copy linescores from 'data/linescores.csv' DELIMITER ',' CSV HEADER;

DROP TABLE rosters;
CREATE TABLE rosters (
	game_id INT NOT NULL,
	athlete_id INT NOT NULL,
	played BOOLEAN,
	team_name varchar(30) NOT NULL,
	position_name varchar(30),
	PRIMARY KEY(game_id,athlete_id,team_name),
	CONSTRAINT fk_game_id FOREIGN KEY(game_id) 
		REFERENCES games(game_id),
	CONSTRAINT fk_athlete_id FOREIGN KEY(athlete_id) 
		REFERENCES athletes(athlete_id),
	CONSTRAINT fk_team_name FOREIGN KEY(team_name) 
		REFERENCES teams(team_name),
    CONSTRAINT fk_position_name FOREIGN KEY(position_name) 
		REFERENCES positions(position_name)

);
\copy rosters from 'data/rosters.csv' DELIMITER ',' CSV HEADER;

-- get rid of header row
-- DELETE FROM sales WHERE name='name';
/*
DROP TABLE games;
DROP TABLE positions;
DROP TABLE season_dates;
DROP TABLE rosters;
DROP TABLE venues;
DROP TABLE athletes;
DROP TABLE teams;
DROP TABLE linescores;
*/