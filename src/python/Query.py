
import psycopg # type: ignore
from configparser import ConfigParser
from pathlib import Path


class Query:
    def __init__(self):
        self.config = self.load_configuration()
        self.pgdb = None  # PostgreSQL Connection

    def load_configuration(self):
        parser = ConfigParser()
        parser.read('./python/config.ini') # Required file for connection
        params = parser.items('Database') # Required database section
        return {param[0]: param[1] for param in params}

    def open_connections(self):
        try:
            self.pgdb = psycopg.connect(
                host = self.config['postgresqlserverurl'],
                dbname = self.config['postgresqlserverdatabase'],
                user = self.config['postgresqlserveruser'],
                password = self.config['postgresqlserverpassword'],
                sslmode = 'require'
            )
            # self.pgdb.set_autocommit(False)
            print('Connection Established!')
        except Exception as e:
            print('Connection Error: %s' % (e))

    def close_connections(self):
        if self.pgdb:
            self.pgdb.close()
    
    def initialize_database(self):
        cursor = self.pgdb.cursor()
        
        with open('NFL_database/src/sql/table.sql', 'r') as file:
            create_table_commands = file.read()
        cursor.execute(create_table_commands)

        # commit is needed!
        cursor.close()

        
    def get_team(self, team_name: str) -> None:
        cursor = self.pgdb.cursor()
        query = "SELECT * FROM teams WHERE team_name = %s"
        data = (team_name, )
        print(query)
        # query = "SELECT * FROM teams"
        cursor.execute(query, data)
        for row in cursor:
            print(row)

    def get_venue(self, venue_name: str) -> None:
        cursor = self.pgdb.cursor()
        query = "SELECT * FROM venues WHERE venue_name = %s"
        data = (venue_name, )
        cursor.execute(query, data)
        for row in cursor:
            print(row)

    def get_game(self, game_id: int) -> None:
        cursor = self.pgdb.cursor()
        query = "SELECT * FROM games WHERE game_id = %s"
        data = (game_id, )
        cursor.execute(query, data)
        for row in cursor:
            print(row)
            
    def get_game_scores(self, year: int, week: int) -> None:
        cursor = self.pgdb.cursor()  # Establish a cursor for executing SQL queries
        query = """
            SELECT home.team_name   AS home_team,
                home.total_score AS home_score,
                away.team_name   AS away_team,
                away.total_score AS away_score
            FROM games
                    JOIN season_dates s ON s.date = games.date
                    JOIN (SELECT team_name, SUM(score) AS total_score
                        FROM season_dates sd
                                    JOIN games g ON sd.date = g.date
                                    JOIN linescores l ON l.game_id = g.game_id
                        WHERE season_year = %s
                            AND week = %s
                        GROUP BY team_name) AS home ON home.team_name = games.home_team_name
                        JOIN (SELECT team_name, SUM(score) AS total_score
                        FROM season_dates sd
                                    JOIN games g ON sd.date = g.date
                                    JOIN linescores l ON l.game_id = g.game_id
                        WHERE season_year = %s
                            AND week = %s
                        GROUP BY team_name) AS away ON away.team_name = games.away_team_name
            WHERE season_year = %s
            AND week = %s;
        """
        data = (year, week, year, week, year, week)  # Data tuple containing the year and week
        cursor.execute(query, data)  # Execute the SQL query with the provided data
        for row in cursor:  # Iterate over the result set
            print(row)  # Print each row retrieved from the database



#     def transaction_login(self, name, password):
#         pass

#     def transaction_personal_data(self, cid):
#         pass

#     def transaction_search(self, cid, movie_name):
#         pass
