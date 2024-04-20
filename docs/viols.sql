/*
	Kansas State University
	CIS 761: Database Management Systems
	NFL Database Project - Interim Project Update 

	Vishnu Bondalakunta
	Chuck Zumbaugh
	James Chapman
*//*
	Write data modification commands to illustrate the following scenarios and submit a
	file viols.sql containing all five commands below, together with screenshots that show
	proper functionality:
		a. An INSERT command creating a key violation
		b. An UPDATE command creating a key violation
		c. An INSERT command creating a referential integrity violation
		d. A DELETE command creating a referential integrity violation
		e. An UPDATE command creating a referential integrity violation
*/

-- a.
-- SELECT * FROM athletes ORDER BY random() LIMIT 1;
INSERT INTO athletes (athlete_id, first_name, last_name, dob, height, weight, birth_city, birth_state) VALUES
('4682912', 'James', 'Chapman', '1990-02-09', '69', '168', 'Las Vegas', 'NV');
/*OUTPUT
	ERROR:  duplicate key value violates unique constraint "athletes_pkey"
	DETAIL:  Key (athlete_id)=(4682912) already exists.
*/

-- b.
UPDATE teams 
SET team_name = 'Texans' 
WHERE abbreviation = 'GB' ;
/* OUTPUT
	ERROR:  duplicate key value violates unique constraint "teams_pkey"
	DETAIL:  Key (team_name)=(Texans) already exists.
*/

-- c.
INSERT INTO rosters (athlete_id, team_name, position_name, start_date, end_data) VALUES
('13860', 'Buccaneers', 'Benchwarmer', '2011-09-09', '2011-12-30');
/*OUTPUT
	ERROR:  insert or update on table "rosters" violates foreign key constraint "rosters_position_name_fkey"
	DETAIL:  Key (position_name)=(Benchwarmer) is not present in table "positions".
*/

-- d.
-- SELECT game_id FROM games ORDER BY random() LIMIT 1;
DELETE FROM games 
WHERE game_id = 400554298 ;
/* OUTPUT
	ERROR:  update or delete on table "games" violates foreign key constraint "player_plays_game_id_fkey" on table "player_plays"
	DETAIL:  Key (game_id)=(400554298) is still referenced from table "player_plays".
*/

-- e.
UPDATE venues 
SET venue_name = 'strip club' 
WHERE city = 'Las Vegas' ;
/* OUTPUT
	ERROR:  update or delete on table "venues" violates foreign key constraint "teams_venue_name_fkey" on table "teams"
	DETAIL:  Key (venue_name)=(Allegiant Stadium) is still referenced from table "teams".
*/