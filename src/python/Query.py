
import psycopg # type: ignore
from configparser import ConfigParser
from pathlib import Path
from rich import print
from display import display, display_matchup


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

        
    def get_team(self, team_name: str=None) -> None:
        cursor = self.pgdb.cursor()
        if team_name is not None:
            query = "SELECT * FROM teams WHERE team_name = %s"
            data = (team_name, )
            print(query)
            cursor.execute(query, data)
        else:
            query = 'SELECT * FROM teams'
            cursor.execute(query)
        display(cursor,
                [('Name', 0), ('Abbreviation', 1), ('Location', 2), ('Home Stadium', 3)],
                (4, 5))

    def get_venue(self, venue_name: str=None) -> None:
        cursor = self.pgdb.cursor()
        if venue_name:
            query = "SELECT * FROM venues WHERE venue_name LIKE %s"
            data = ('%' + venue_name + '%', )
            cursor.execute(query, data)
        else:
            query = 'SELECT * FROM venues'
            cursor.execute(query)
        display(cursor,
                [('Name', 0), ('Capacity', 1), ('City', 2), ('State', 3), ('Grass', 4), ('Indoor', 5)])

    def get_game(self, game_id: int) -> None:
        cursor = self.pgdb.cursor()
        query = "SELECT * FROM games WHERE game_id = %s"
        data = (game_id, )
        cursor.execute(query, data)
        display(cursor,
                [('Game ID', 0), ('Date', 1), ('Attendance', 2), ('Home Team', 3), ('Away Team', 4), ('Venue', 5), ('Time', 6)])

    def get_scores(self, year: int, week: int) -> None:
        cursor = self.pgdb.cursor()
        query = ""
        with open('Queries/scores.sql') as file:
            query = file.read()
        data = (year, week, year, week, year, week, )
        cursor.execute(query, data)
        display_matchup(cursor,
                [('name', 0), ('score', 1)],
                        [('name', 2), ('score', 3)],
                        [(4, 5), (6, 7)])
#     def transaction_login(self, name, password):
#         pass

#     def transaction_personal_data(self, cid):
#         pass

#     def transaction_search(self, cid, movie_name):
#         pass
