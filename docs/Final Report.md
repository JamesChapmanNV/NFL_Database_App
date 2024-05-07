# NFL Database Application

## Team Members
* Chuck Zumbaugh
* James Chapman
* Vishnu Bondalakunta

Kansas State University
CIS 761: Database Management Systems

\newpage

## Table of Contents
1. [Introduction](#introduction)
2. Database Implementation
	* Technical Description
	* Features
	* E/R Diagram and relational schema
	* Queries
3. System Implementation
4. [System Features and Usage](#system-features-and-usage)
5. Evaluation
6. Technical Details and Justification
7. Summary and Discussion
	* General Summary
	* Learnings and Future Changes
	* Possible Improvements and Future Direction
8. Team Work Division and Experience

\newpage


## Introduction
The NFL Database Application manages and reports information for NFL games during the past decade (2013 - 2023). This system allows the user to easily retrieve information about players, teams, games, and even plays within each game (where available). With over 1.5 million records, users are able to obtain information down to each play made by a specific player in a game. The application itself is a lightweight, command line program that can be used once a user registers for an account. Target users are statisticians and eager NFL fans who want to have specific NFL game information at their fingertips! In addition to being able to view a data snapshot, users can export the snapshot in a filetype of their choice (ex. markdown or CSV) for their own use. 


## System Features and Usage
The NFL Database Application is a command line program, that once launched, allows the user to issue commands to retrieve data. The commands are discussed in detail below, and each command can be controlled by the use of flags.

### Top Level Commands
There are 7 top level commands that can be executed:

1. `Team`
2. `Athlete`
3. `Venue`
4. `Game`
5. `Top_Comeback_Wins`
6. `Win_probability`
7. `Save`
8. `Login`
9. `Register`
10. `User`

Each of these commands requires additional arguments and flags to retrieve specific data.

### The Team Command
The `Team` command is used to retrieve information related to a team. The team command can be executed without any arguments or flags to retrieve information on all 32 teams in the NFL. Optionally, users can specify a team name to retrieve information for that team only. 

#### Required Arguments
None

#### Flags and Optional Arguments

#####`-y or --year <year>` 
This is used when retrieving the records for teams in a given season. When only this flag is used, the records of all teams during that season will be returned.

#####`-t or --team <team_name>`
This is used in conjunction with the `-y or --year` flag. When provided, only the record for the provided team name in the given season is returned.

#### Usage

`> Team` Returns all teams in the NFL<br>
`> Team Chiefs` Returns information on the Chiefs<br>
`> Team -y 2020` Returns the records for all teams in the NFL during the 2020 season<br>
`> Team -y 2020 -t Chiefs` Returns the record for the Chiefs in the 2020 season<br>

### The Athlete Command
The `Athlete` command is used to retrieve information for a given athlete. This command requires at least one argument, either the first or last name of the athlete.

#### Required Arguments
Either the first or last name of the athlete must directly follow the `Athlete` command. The default strategy is to search by first name.

#### Flags and Optional Arguments

#####`-l or --last`
Search by last name instead of first

#### Usage
`> Athlete Patrick` Returns all athletes with the first name of Patrick
`> Athlete Mahomes -l` Returns all athletes with the last name of Mahomes

### The Venue Command
The `Venue` command is used to retrieve information related to venues (or stadiums). This can be executed with no arguments, in which case it returns all venues used by the NFL. Optionally, the user can specify the venue name (or a substring of the name).

#### Required Arguments
None

#### Flags and Optional Arguments
`-y or --year <year>` If a year is specified, the venues with the greatest number of home wins, their teams, and the number of wins in that season will be returned.

#### Usage
`> Venue` Returns all venues<br>
`> Venue GEHA` Returns all venues with 'GEHA' in the name<br>
`> Venue Field` Returns all venues with 'Field' in the name<br>
`> Venue -y 2023` Returns venues with the greatest number of home wins in 2023<br>

### The Game Command
The `Game` command is one of the more flexible and powerful commands in the program. It is used to retrieve all information related to a given game or games. A large number of flags and arguments can be given to the `Game` command to control it's execution.

#### Required Arguments and Flags
At the base level, at least one of the following flags and arguments must be provided. However, these may or may not be required if additional flags are used.

* `-y <year>` Returns information for all games in the given season
* `-g <game_id>` Returns information related to the game with the specified ID

#### Flags and Optional Arguments
The following flags and their arguments can be provided.

##### `-s or --score`
This specified that you would like to retrieve only the scores for the games. This flag requires no additional arguments, but requires the user to specify what year and week of the season to search for scores in. This is done through the `-y <year>` and `-w <week>` flags.

##### `-w or --week <week>`
Specify which week of the season to search in.

##### `-p or --plays`
Tell the program that you wish to find plays in a given game. This flag accepts no arguments, but requires the use of the `-g --game <game_id>` and `-a or --athlete <athlete_id>` flag. When used, the program will return all plays made by the given athlete in that game.

##### `-a or --athlete <athlete_id>`
Specify which athlete to find plays for. This flag accepts an athlete ID following the flag.

##### `-t or --team <team_name>`
Specify the name of the team to search for. This flag is used when retrieving the information related to games between two teams. If this flag is used, the opposing team must be specified using the `-op or --opponent <op_team_name>`.

##### `-pf or --percent_filled`
Specify that you would like to know how full the stadium was for a given game. This flag takes no arguments, but requires you to specify which game to compute the statistic for through the `-g or --game <game_id>` flag.

##### `-S or --statistics`
Specify that you would like to retrieve the leaders for passing, rushing, and receiving yards in the given game. This flag takes no arguments, but requires you to specify which game to compute the statistic for through the `-g or --game <game_id>` flag.

#### Usage
The general use pattern for each of the features is listed below.

`> Game -y 2020` Return information for all games in the 2020 season<br>
`> Game -g 401437927` Return information for the game with the id of '401437927'<br>
`> Game -s -y 2020 -w 10` Return the teams and their scores for all games in week 10 of the 2020 season<br>
`> Game -p -a 3139477 -g 401547235` Return all plays made by athlete with ID of '3139477' in the game with an ID of '401547235'<br>
`> Game -g 401547235 -pf` Return the percent fill of the stadium for the game with ID of '401547235'<br>
`> Game -t Chiefs -op Raiders` Return all games played by the Chiefs and Raiders in the database<br>
`> Game -t Chiefs -op Raiders -y 2020` Return all games played by the Chiefs and Raiders in the 2020 season<br>
`> Game -t Chiefs -op Chiefs` Return all games played by the Chiefs against any opponent in the database<br>
`> Game -t Chiefs -op Chiefs -y 2020` Return all games played by the Chiefs against any opponent in the 2020 season<br>
`> Game -g 401547235 -S` Return the leaders for passing, receiving, and rushing yards in the game with an ID of 401547235<br>

### The Save Command
In some cases, a user may wish to save the results returned by the program. This can be accomplished with the `Save` command. The `Save` command requires a filetype to be specified, and optionally a filename. The results of the most recently executed query will be saved in the user's Downloads folder.

#### Required Arguments
The filetype must immediately follow the `Save` command. Supported filetypes are markdown (specified as md) or comma separated value (specified as csv). The program will write the file in the appropriate format.

#### Flags and Optional Arguments

#####`-o or --output <filename>`
The name of the file, without the extension. If this is not provided, the default filename is NFL_last_data.
	
#### Usage
`> Save md` Save the results of the last executed query as a markdown file<br>
`> Save csv` Save the results of the last executed query as a CSV file<br>
`> Save md -o my_data` Save the results of the last executed query as a markdown file with the filename of 'my_data'<br>

### The Login Command
The login command is used to authenticate and gain access to the program.

#### Required Arguments and Flags
You must specify the username and password to use. This is done as follows.

`-u or --username <username>` Provide the username<br>
`-p or --password <password>` Provide the password<br>
	
#### Usage
`> NFLapp Login -u <username> -p <password>`
	
### The Register Command
The `Register` command is used to register an account. The system will prompt you to enter various details.

#### Required Arguments
None

#### Usage
`> NFLapp Register`<br>
Prompts to enter information will follow and you will need to provide a username, password, and name.

### The User Command
The `User` command is used for user related services. This command is used to update data in the user's account, and can be used to delete the account if desired.

#### Required Arguments
While the `User` command does not require any arguments on it's own, arguments are expected for some of the various flags that are used to update and delete data. If nothing is given to the `User` command, the user's details are printed.

#### Flags and Optional Arguments

##### `-f or --favorite` Specify that you would like to favorite either a team or athlete
##### `-t or --team <team_name>` Used in combination with the `-f` flag to specify a team name to favorite
##### `-a or --athlete <athlete_id>` Used in combination with the `-f` flag to specify an athlete to favorite.
##### `-d or --delete` Specify that you would like to perform a delete operation. When used without other flags, this will prompt an account deletion. When combined with the `-f` flag and either `-t` or `-a`, specify that you would like to delete your favorite team or athlete.
##### `-U or --update <field>` Specify that you would like to update the provided field. Accepted fields are `first_name`, `last_name`, or `password` 
##### `-V or --update <value>` Set the new value to use with the `-U` flag.
	
#### Usage
`User` Show the user's details
`User -f -t Chiefs` Set Chiefs as your favorite team<br>
`User -f -a 3139477` Set the athlete with an ID of 3139477 as your favorite<br>
`User -f -t -d` Delete your favorite team<br>
`User -f -a -d` Delete your favorite athlete<br>
`User -d` Delete your account. This is an irreversible action<br>
`User -U first_name -V John` Change your first name to John<br>
`User -U last_name -V Smith` Change your last name to Smith<br>
`User -U password -V securePassword` Change your password to securePassword. You will not be logged out by this action, but you will need your new password during the next sign in.<br>
