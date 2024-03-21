-- This script will import the NFL data into PostgreSQL. 
-- To run, feed it to the psql utility as:
-- \i nfl.sql
-- Note that this script, as written, assumes that the files
-- is in the data directory.  

DROP TABLE games;
CREATE TABLE games (
	game_id INT,
	name varchar(50),
	shortName varchar(10),
	date varchar(20),
	attendance INT,
	venue_id INT,
	home_team_id INT,
	away_team_id INT,
	utc_time varchar(20)
);
-- home_score INT,
-- away_score INT,
-- home_win_bool BOOLEAN
\copy games from 'data/games.csv' DELIMITER ',' CSV HEADER;

DROP TABLE season_dates;
CREATE TABLE season_dates (
	date varchar(30),
	season_year INT,
	season_type varchar(30),
	week INT
);
\copy season_dates from 'data/season_dates.csv' DELIMITER ',' CSV HEADER;

DROP TABLE linescores;
CREATE TABLE linescores (
	game_id INT,
	team_id INT,
	quarter INT,
	score INT
);
\copy linescores from 'data/linescores.csv' DELIMITER ',' CSV HEADER;

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
	firstName varchar(30),
	lastName varchar(30),
	birth_place varchar(30),
	drafted_bool varchar(30),
	jersey INT,
	heightInches INT,
	weight INT,
	dob varchar(30)
);
-- drafted_bool BOOLEAN
\copy athletes from 'data/athletes.csv' DELIMITER ',' CSV HEADER;

DROP TABLE venues;
CREATE TABLE venues (
	venue_id INT,
	fullName varchar(40),
	grass BOOLEAN,
	indoor BOOLEAN,
	city varchar(20),
	state varchar(10),
	zipCode INT
);
-- capacity INT,
\copy venues from 'data/venues.csv' DELIMITER ',' CSV HEADER;

DROP TABLE teams;
CREATE TABLE teams (
	team_id INT,
	location varchar(20),
	name varchar(20),
	abbreviation varchar(20),
	venue_id INT,
	primary_color varchar(20),
	secondary_color varchar(20)
);
\copy teams from 'data/teams.csv' DELIMITER ',' CSV HEADER;

DROP TABLE positions;
CREATE TABLE positions (
	position_id INT,
	name varchar(20),
	abbreviation varchar(10)
);
\copy positions from 'data/positions.csv' DELIMITER ',' CSV HEADER;


-- get rid of header row
-- DELETE FROM sales WHERE name='name';
