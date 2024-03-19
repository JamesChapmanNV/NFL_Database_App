# CIS 761 Class Project - Project Proposal

## Team
* Chuck Zumbaugh
* James Chapman
* Vishnu Bondalakunta

## Overview
This project will model NFL data for a sports network using a PostgreSQL database. The database will contain data regarding players, teams, stadiums, games, and plays within each game. The application will allow users to obtain information regarding their favorite players or teams, and allow them to view statistics for players, teams, and games. The data will be obtained through a publically available ESPN API. 

## Requirements
* Teams will be identified by a team ID and have attributes name, nickname, abbreviation, primary color, secondary color, and url slug.
* Players will be identified by a player ID and have attributes ~~age~~, date of birth, first name, last name, height, weight, jersey number, and url slug.
* A player can play for many teams in their career, and a team can have many players.
* Each position will be identified by a position ID and have attributes name and abbreviation.
* A position can be played by many players and a player can play many positions in their career.
* Stadiums will be identified by a stadium ID and have attributes name, capacity, city, state, zip code, grass (boolean), and indoor (boolean).
* A stadium can have many home teams (ex. MetLife Stadium), but a team must have exactly one stadium.
* Games will be identified by a game ID and have attributes attendance, date, name, short name, week, and year.
* Many games can be played at a given venue, but each game must be played at exactly one venue.
* Each game must have exactly one home team and one away team. Each team can play many games.
* Scores in each quarter (linescores) will be identified by the game ID, team ID, and quarter and have attributes score.
* Games and teams can have many linescores.
* Stat leaders in each game will be identified by the game ID and statistic name (ex. Passing Yards) and have attributes display name, display value, player ID, and value.
* Each game can have many stat leaders, and a player can be a leader in many categories.
* Each play will be identified by a play ID and have attributes play type, play text, quarter, seconds remaining in quarter, start down, start first down distance, start yardline, start yards to endzone, yards gained, end down, end first down distance, end yardline, end yards to endzone, and score value.
* A game can have many plays, and each player can be associated with many plays in each game. Additionally, a play can involve many players. 

