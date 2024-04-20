/*
    does this work?
 */

DROP TABLE IF EXISTS Users;
CREATE TABLE users(
    uid SERIAL PRIMARY KEY,
    username VARCHAR(45),
    password VARCHAR(45),
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    created_on DATE,
    favorite_team_name VARCHAR(45) REFERENCES teams(team_name),
    favorite_athlete_id BIGINT REFERENCES athletes(athlete_id)
);

INSERT INTO users (username, password, first_name, last_name, created_on, favorite_team_name, favorite_athlete_id) VALUES
('JamesChapmanNV', 'secret', 'James', 'Chapman', '2024-04-19', 'Raiders', '13229');