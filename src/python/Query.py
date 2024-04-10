
import psycopg # type: ignore
from configparser import ConfigParser
from pathlib import Path


class Query:
    def __init__(self):
        self.config = self.load_configuration()
        self.pgdb = None  # PostgreSQL Connection

    def load_configuration(self):
        parser = ConfigParser()
        parser.read('NFL_database/config.ini') # Required file for connection
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
        query = f"SELECT * FROM teams WHERE team_name = '{team_name}'"
        print(query)
        # query = "SELECT * FROM teams"
        cursor.execute(query)
        for row in cursor:
            print(row)

    def get_venue(self, venue_name: str) -> None:
        cursor = self.pgdb.cursor()
        query = f"SELECT * FROM venues WHERE venue_name = '{venue_name}'"
        cursor.execute(query)
        for row in cursor:
            print(row)

    def get_game(self, game_id: int) -> None:
        cursor = self.pgdb.cursor()
        query = f"SELECT * FROM games WHERE game_id = {game_id}"
        cursor.execute(query)
        for row in cursor:
            print(row)


#     def transaction_login(self, name, password):
#         pass

#     def transaction_personal_data(self, cid):
#         pass

#     def transaction_search(self, cid, movie_name):
#         pass