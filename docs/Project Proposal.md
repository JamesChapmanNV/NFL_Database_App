# CIS 761 Class Project - Project Proposal

## Team
* Chuck Zumbaugh
* James Chapman
* Vishnu Bondalakunta

## Overview
This project will model NFL data for a sports network using a PostgreSQL database. The database will contain data regarding players, positions, teams, venues, games, and plays within each game. The application will allow users to obtain information regarding their favorite players or teams, and allow them to view statistics for players, teams, and games. The data will be obtained through a publically available ESPN API. 

## Requirements
* Teams will be identified by a team ID and have attributes name, abbreviation, primary color, and secondary color.
* Players will be identified by a player ID and have attributes date of birth, first name, last name, height, weight, and jersey number.
* A player can play for many teams in their career, and a team can have many players.
* Each position will be identified by a position ID and have attributes name and abbreviation.
* A position can be played by many players and a player can play many positions in different games. However, a player can only play a single position within a game.
* Venues will be identified by a venue ID and have attributes fullName, capacity, city, state, zip code, grass (boolean), and indoor (boolean).
* A stadium can have many home teams (ex. MetLife Stadium), but a team must have exactly one stadium.
* Games will be identified by a game ID and have attributes attendance, date, name, short name, season type, home team win (boolean) week, and year.
* Many games can be played at a given venue, but each game must be played at exactly one venue.
* Each game must have exactly one home team and one away team. Each team can play many games.
* Scores in each quarter (linescores) will be identified by the game its played in, the team it corresponds to, and quarter and have attributes score.
* Games and teams can have many linescores.
* Each play will be identified by a play ID and have attributes play type, play text, quarter, seconds remaining in quarter, and score value.
* A game can have many plays, and each player can be associated with many plays in each game. Additionally, a play can involve many players. 
