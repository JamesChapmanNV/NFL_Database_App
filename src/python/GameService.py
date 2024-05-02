from FileManager import FileManager
import display

"""
Service to get data related to games in the database. This service is involked when the user uses the 'Game' command.
The user can obtain information on specific games, games in a given year, plays made by a athlete in a given game,
or scores in a given year and week. The return value for each method is a tuple that contains first the cursor, 
some additional metadata used by the display method, and a reference to the display method to use. The metadata
that is returned should be what the display method expects, and in the order it expects. The caller will
simply pass everything between the cursor and the display method into the method.
"""


class GameService:

    def __init__(self, file_manager: FileManager, conn=None):
        self.__conn = conn
        self.__file_manager = file_manager

    def set_connection(self, conn):
        self.__conn = conn

    def get_game(self, args: [str]) -> ():
        """
        Main game service method. Dispatches to other methods depending on the flag
        :param args: Command line arguments
        :return: A tuple containing the cursor, column and optional color data, and the display method to use.
        The column and color data should be provided in-order the display method requires.
        """
        if args.score:
            return self.get_scores(args)
        elif args.plays:
            return self.get_plays(args)
        else:
            game_id = args.game_id
            year = args.year
            cursor = self.__conn.cursor()
            query = self.__file_manager.read_file('games.sql')
            if year is not None:
                # User provided a year
                query = query.format(column_name='date_part(\'year\', date)')
                data = (year,)
            else:
                query = query.format(column_name='g.game_id')
                data = (game_id,)

            cursor.execute(query, data)
            return (cursor,
                    [('Game ID', 0), ('Date', 1), ('Attendance', 2),
                     ('Home Team', 3), ('Away Team', 4), ('Venue', 5),
                     ('Time', 6), ('Home Score', 7), ('Away Score', 8)],
                    (9, 10),
                    display.display)

    def get_scores(self, args: [str]):
        """
        Get scores for the game is the -s flag is used
        :param args: Command line arguments
        :return: A tuple containing the cursor, column and optional color data, and the display method to use.
        The column and color data should be provided in-order the display method requires.
        """
        year = args.year
        week = args.week
        cursor = self.__conn.cursor()
        query = ""
        with open('./python/Queries/scores.sql') as file:
            query = file.read()
        data = (year, week, year, week, year, week, )
        cursor.execute(query, data)
        return (cursor,
                [('name', 0), ('score', 1)],
                [('name', 2), ('score', 3)],
                [(4, 5), (6, 7)],
                display.display_matchup)

    def get_plays(self, args: [str]):
        """
        Get plays for the game is the -p flag is used with a corresponding game and athlete id
        :param args: Command line arguments
        :return: A tuple containing the cursor, column and optional color data, and the display method to use.
        The column and color data should be provided in-order the display method requires.
        """
        athlete_id = args.athlete
        game_id = args.game_id
        cursor = self.__conn.cursor()
        query = self.__file_manager.read_file('player_game_plays.sql')
        data = (game_id, athlete_id,)
        cursor.execute(query, data)
        return (cursor,
                [('Quarter', 0), ('Seconds Remaining', 1), ('Yards', 2), ('Score Value', 3),
                 ('Play Type', 4), ('Start Down', 5), ('End Down', 6)],
                None,
                display.display)
