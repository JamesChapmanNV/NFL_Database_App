import psycopg
import numpy as np
import pandas as pd
from rich import print
from configparser import ConfigParser
from sklearn.linear_model import LogisticRegression

from display import display, display_matchup
from FileManager import FileManager
from UserService import UserService
from GameService import GameService


class Query:
    def __init__(self):
        self.config = self.load_configuration()
        self.pgdb = None  # PostgreSQL Connection
        self.last_result = None # The output of the last executed query
        self.last_result_column_names = None # The column names of the last output
        self.file_manager = FileManager()
        self.file_manager.set_input_path('./python/Queries/')
        self.user_service = UserService(None)
        self.game_service = GameService(file_manager=self.file_manager)

    def load_configuration(self) -> dict:
        parser = ConfigParser()
        parser.read('./python/config.ini') # Required file for connection
        params = parser.items('Database') # Required database section
        return {param[0]: param[1] for param in params}

    def open_connections(self) -> None:
        try:
            self.pgdb = psycopg.connect(
                host = self.config['postgresqlserverurl'],
                dbname = self.config['postgresqlserverdatabase'],
                user = self.config['postgresqlserveruser'],
                password = self.config['postgresqlserverpassword'],
                sslmode = 'require'
            )
            # self.pgdb.set_autocommit(False)
            self.user_service.set_connection(self.pgdb)
            self.game_service.set_connection(self.pgdb)
            print('Connection Established!')
        except Exception as e:
            print('Connection Error: %s' % (e))

    def close_connections(self) -> None:
        if self.pgdb:
            self.pgdb.close()

    def helper_set_column_names(self, cursor) -> None:
        column_names = [desc[0] for desc in cursor.description]
        self.last_result_column_names = tuple(column_names)

    def login(self, username: str, password: str) -> int:
        return self.user_service.login(username, password)

    def register_user(self, username, password, first_name, last_name) -> None:
        self.user_service.register_user(username, password, first_name, last_name)
    
    def save_last_result(self, filetype: str, filename: str=None) -> None:
        name = filename or 'NFL_last_data'
        data = [self.last_result_column_names] + self.last_result
        result = self.file_manager.write_file(data, name + f'.{filetype}', filetype)
        if result > 0:
            print("Data saved successfully")
        else:
            print("Error: Unsupported file type")

    def get_team(self, team_name: str=None) -> None:
        cursor = self.pgdb.cursor()
        if team_name is not None:
            query = "SELECT * FROM teams WHERE team_name = %s"
            data = (team_name, )
            cursor.execute(query, data)
        else:
            query = 'SELECT * FROM teams'
            cursor.execute(query)
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        display(self.last_result,
                [('Name', 0), ('Abbreviation', 1), ('Location', 2), ('Home Stadium', 3)],
                (4, 5))

    def get_athlete(self, athlete_name: str, col_flag='-f') -> None:
        cursor = self.pgdb.cursor()
        column_name = 'first_name' if col_flag == '-f' else 'last_name'
        query = self.file_manager.read_file('athletes.sql').format(column_name=column_name)
        data = ('%' + athlete_name + '%', )
        cursor.execute(query, data)
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        display(self.last_result,
                [('ID', 0), ('Name', 1), ('Date of Birth', 2), ('Height, in', 3),
                 ('Weight, lbs', 4), ('Birth Place', 5), ('Team Name', 6), ('Position', 7), ('Platoon', 8)])

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
        cursor = self.game_service.get_game(game_id)
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        display(self.last_result,
                [('Game ID', 0), ('Date', 1), ('Attendance', 2),
                 ('Home Team', 3), ('Away Team', 4), ('Venue', 5),
                 ('Time', 6), ('Home Score', 7), ('Away Score', 8)],
                colors=(9, 10))

    def get_plays(self, athlete_id: int, game_id: int):
        cursor = self.pgdb.cursor()
        query = self.file_manager.read_file('player_game_plays.sql')
        data = (game_id, athlete_id, )
        cursor.execute(query, data)
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        display(self.last_result,
                [('Quarter', 0), ('Seconds Remaining', 1), ('Yards', 2), ('Score Value', 3),
                 ('Play Type', 4), ('Start Down', 5), ('End Down', 6)])

    def get_scores(self, year: int, week: int) -> None:
        cursor = self.game_service.get_scores(year, week)
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        display_matchup(self.last_result,
                [('name', 0), ('score', 1)],
                        [('name', 2), ('score', 3)],
                        [(4, 5), (6, 7)])
        
    def top_comeback_wins(self, year: int=None) -> None:
        cursor = self.pgdb.cursor()
        query = ""
        with open('./python/Queries/top_comeback_wins.sql') as file:
            query = file.read()
        data = (year,year, )
        if year is None:  
            data = (2011,2026, ) # if no year from input, use all years
        cursor.execute(query, data)
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        display(self.last_result,
                [('Team_name', 0), ('Comebacks', 1)],
                (2, 3))
        
    def win_probability(self, team_name: str, team_score: int, opponent_score: int) -> None:
        cursor = self.pgdb.cursor()
        query = ""
        with open('./python/Queries/win_probability.sql') as file:
            query = file.read()
        data = (team_name, team_name, )
        cursor.execute(query, data)
        self.helper_set_column_names(cursor)
        self.last_result = cursor.fetchall()
        """
        Query produces scores of all games, of a given team (provided by user input).
        Uses query results -('third_quarter_team_scores', 'opponent_scores', 'winner_bool')  
        to perform simple logistic regression from SKlearn: The target (Boolean) is 
        if the given team wins (Boolean). The features are simply game scores of a team.
        """
        df = pd.DataFrame(self.last_result, columns=['third_quarter_team_scores', 'opponent_scores', 'winner_bool'])
        df.loc[(df['winner_bool']=='f'),'winner_bool']= -1 # opponent wins
        df.loc[(df['winner_bool']=='t'),'winner_bool']= 1 # given team wins
        df.loc[(df['winner_bool'].isnull()),'winner_bool']= 0 # tie
        df.fillna(0, inplace=True)
        df['winner_bool'] = df['winner_bool'].astype('int64')
        X = df[['third_quarter_team_scores', 'opponent_scores']] # features
        y = df['winner_bool']  # Targets where -1 = away win, 0 = tie, 1 = home win
        model = LogisticRegression(multi_class='multinomial', solver='lbfgs').fit(X.values, y.values)
        probabilities = model.predict_proba([[team_score, opponent_score]])[0]
        given_team_index = np.where(model.classes_==1)[0][0]
        # display results
        print(f'Given a score of {team_score} to {opponent_score},')
        print(f'The probability of the {team_name} winning is {round(probabilities[given_team_index]*100, 1)}%')

    def build_database(self) -> None:
        print(f"Building Database . . .'")
        # Drop tables FROM drop_tables.sql
        cursor = self.pgdb.cursor()
        with open('./sql/drop_tables.sql', 'r') as file:
            drop_tables_commands = file.read()
        cursor.execute(drop_tables_commands)
        # create tables FROM create_tables.sql
        with open('./sql/create_tables.sql', 'r') as file:
            create_table_commands = file.read()
        cursor.execute(create_table_commands)
        # Import data FROM data/CSV's
        with cursor.copy("copy venues(venue_name, capacity, city, state, grass, indoor) FROM STDIN DELIMITER ',' CSV HEADER") as copy:
            copy.write(open("../data/venues.csv").read())
        with cursor.copy("copy teams(team_name, abbreviation, location, venue_name, primary_color, secondary_color) FROM STDIN DELIMITER ',' CSV HEADER") as copy:
            copy.write(open("../data/teams.csv").read())
        with cursor.copy("copy positions(position_name, abbreviation, platoon) FROM STDIN DELIMITER ',' CSV HEADER") as copy:
            copy.write(open("../data/positions.csv").read())
        with cursor.copy("copy athletes(athlete_id, first_name, last_name, dob, height, weight, birth_city, birth_state) FROM STDIN DELIMITER ',' CSV HEADER") as copy:
            copy.write(open("../data/athletes.csv").read())
        with cursor.copy("copy season_dates(date, season_year, season_type, week) FROM STDIN DELIMITER ',' CSV HEADER") as copy:
            copy.write(open("../data/season_dates.csv").read())
        with cursor.copy("copy games(game_id, date, attendance, home_team_name, away_team_name, venue_name, utc_time) FROM STDIN DELIMITER ',' CSV HEADER") as copy:
            copy.write(open("../data/games.csv").read())
        with cursor.copy("copy rosters(game_id, team_name, athlete_id, position_name, played) FROM STDIN DELIMITER ',' CSV HEADER") as copy:
            copy.write(open("../data/rosters.csv").read())
        with cursor.copy("copy plays(play_id, quarter, yards, score_value, play_type, text, seconds_remaining, start_down, end_down) FROM STDIN DELIMITER ',' CSV HEADER") as copy:
            copy.write(open("../data/plays.csv").read())
        with cursor.copy("copy player_plays(play_id, player_id, game_id, type) FROM STDIN DELIMITER ',' CSV HEADER") as copy:
            copy.write(open("../data/player_plays.csv").read())
        with cursor.copy("copy linescores(game_id, quarter, score, team_name) FROM STDIN DELIMITER ',' CSV HEADER") as copy:
            copy.write(open("../data/linescores.csv").read())
        # create and add users FROM users.sql
        with open('./sql/users.sql', 'r') as file:
            users_commands = file.read()
        cursor.execute(users_commands)
        # Change rosters FROM rosters_decomposition.sql
        with open('./sql/rosters_decomposition.sql', 'r') as file:
            rosters_decomposition_commands = file.read()
        cursor.execute(rosters_decomposition_commands)
        # Create views indexes and functions FROM views_indexes_functions.sql
        with open('./sql/views_indexes_functions.sql', 'r') as file:
            views_indexes_functions_commands = file.read()
        cursor.execute(views_indexes_functions_commands)
        # commit transaction
        self.pgdb.commit()
        print('success')