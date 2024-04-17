
import psycopg # type: ignore
from configparser import ConfigParser
from pathlib import Path
from rich import print
from display import display, display_matchup
from FileManager import FileManager


class Query:
    def __init__(self):
        self.config = self.load_configuration()
        self.pgdb = None  # PostgreSQL Connection
        self.last_result = None # The output of the last executed query
        self.last_result_column_names = None # The column names of the last output
        self.file_manager = FileManager()
        self.file_manager.set_input_path('./Queries/')

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

    def helper_set_column_names(self, cursor) -> None:
        column_names = [desc[0] for desc in cursor.description]
        self.last_result_column_names = tuple(column_names)
        
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
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        display(self.last_result,
                [('Name', 0), ('Abbreviation', 1), ('Location', 2), ('Home Stadium', 3)],
                (4, 5))

    def get_venue(self, venue_name: str=None) -> None:
        cursor = self.pgdb.cursor()
        query = self.file_manager.read_file('venues.sql')
        if venue_name:
            data = ('%' + venue_name + '%', )
            cursor.execute(query, data)
        else:
            data = ('%', )
            cursor.execute(query, data)
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        display(self.last_result,
                [('Name', 0), ('Home Team', 6), ('Capacity', 1),
                 ('City', 2), ('State', 3), ('Grass', 4), ('Indoor', 5)])

    def get_game(self, game_id: int) -> None:
        cursor = self.pgdb.cursor()
        query = self.file_manager.read_file('games.sql')
        if len(str(game_id)) == 4:
            # User provided a year
            query = query.format(column_name='date_part(\'year\', date)')
        else:
            query = query.format(column_name='g.game_id')
        data = (game_id, )
        cursor.execute(query, data)
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        display(self.last_result,
                [('Game ID', 0), ('Date', 1), ('Attendance', 2),
                 ('Home Team', 3), ('Away Team', 4), ('Venue', 5),
                 ('Time', 6), ('Home Score', 7), ('Away Score', 8)],
                colors=(9, 10))

    def get_scores(self, year: int, week: int) -> None:
        cursor = self.pgdb.cursor()
        query = ""
        with open('Queries/scores.sql') as file:
            query = file.read()
        data = (year, week, year, week, year, week, )
        cursor.execute(query, data)
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        display_matchup(self.last_result,
                [('name', 0), ('score', 1)],
                        [('name', 2), ('score', 3)],
                        [(4, 5), (6, 7)])

    def save_last_result(self, filetype: str, filename: str=None) -> None:
        name = filename or 'NFL_last_data'
        data = [self.last_result_column_names] + self.last_result
        result = self.file_manager.write_file(data, name + f'.{filetype}', filetype)
        if result > 0:
            print("Data saved successfully")
        else:
            print("Error: Unsupported file type")
#     def transaction_login(self, name, password):
#         pass

#     def transaction_personal_data(self, cid):
#         pass

#     def transaction_search(self, cid, movie_name):
#         pass
