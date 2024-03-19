-- This script will import the NFL data into PostgreSQL. 
-- To run, feed it to the psql utility as:
-- \i nfl.sql
-- Note that this script, as written, assumes that the files
-- is in the data directory.  

DROP TABLE games;

CREATE TABLE games (
	game_id INT,
	year INT,
	season_type INT,
	week INT,
	date varchar(20),
	name varchar(50),
	shortName varchar(10),
	attendance INT,
	venue_id INT,
	home_team_id INT,
	home_score INT,
	away_team_id INT,
	away_score INT,
	home_win_bool BOOLEAN,
	away_win_bool BOOLEAN 
);

\copy games from 'data/games.csv' DELIMITER ',' CSV HEADER;

DROP TABLE rosters;

CREATE TABLE rosters (
	game_id INT,
	team_id INT,
	player_id INT,
	position_id INT,
	active BOOLEAN,
	didNotPlay BOOLEAN
);

\copy rosters from 'data/rosters.csv' DELIMITER ',' CSV HEADER;

DROP TABLE athletes;

CREATE TABLE athletes (
	athlete_id INT,
	firstName varchar(20),
	lastName varchar(20),
	displayName varchar(30),
	fullName varchar(30),
	debutYear INT,
	displayBirthPlace varchar(30),
	displayHeight varchar(10),
	displayWeight varchar(10),
	displayDOB varchar(10),
	age INT,
	displayDraft varchar(30)
);

\copy athletes from 'data/athletes.csv' DELIMITER ',' CSV HEADER;

DROP TABLE venues;

CREATE TABLE venues (
	venue_id INT,
	fullName varchar(40),
	capacity INT,
	grass BOOLEAN,
	indoor BOOLEAN,
	city varchar(20),
	state varchar(10),
	zipCode INT
);

\copy venues from 'data/venues.csv' DELIMITER ',' CSV HEADER;

DROP TABLE teams;

CREATE TABLE teams (
	team_id INT,
	slug varchar(30),
	location varchar(20),
	name varchar(10),
	nickname varchar(10),
	abbreviation varchar(10),
	displayName varchar(30),
	shortDisplayName varchar(10),
	color varchar(10),
	alternateColor varchar(10),
	franchise_id INT
);

\copy teams from 'data/teams.csv' DELIMITER ',' CSV HEADER;

DROP TABLE positions;

CREATE TABLE positions (
	id INT,
	name varchar(20),
	displayName varchar(20),
	abbreviation varchar(10)
);

\copy positions from 'data/positions.csv' DELIMITER ',' CSV HEADER;


-- get rid of header row
-- DELETE FROM sales WHERE name='name';
