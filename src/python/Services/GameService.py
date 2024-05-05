from FileManager import FileManager
import display
from Services.Service import Service
from Services.ServiceResponse import ServiceResponse, ResponseStatus
"""
Service to get data related to games in the database. This service is involked when the user uses the 'Game' command.
The user can obtain information on specific games, games in a given year, plays made by a athlete in a given game,
or scores in a given year and week. The return value for each method is a tuple that contains first the cursor, 
some additional metadata used by the display method, and a reference to the display method to use. The metadata
that is returned should be what the display method expects, and in the order it expects. The caller will
simply pass everything between the cursor and the display method into the method.
"""


class GameService(Service):

    def __init__(self, file_manager: FileManager, conn=None):
        super().__init__(conn)
        self.__file_manager = file_manager

    def get_data(self, args: [str], **kwargs) -> ServiceResponse:
        if args.score:
            return self.__get_scores(args)
        elif args.plays:
            return self.__get_plays(args)
        elif args.team:
            return self.__get_rival_games(args)
        elif args.percent_filled:
            return self.__get_percent_filled(args)
        elif args.statistics:
            return self.__get_stat_leaders(args)
        else:
            return self.__get_game(args)

    def __get_rival_games(self, args: [str]) -> ServiceResponse:
        """
        Get the games played by two opposing teams. Required flags are -t and -op to specify the two teams.
        The user can optionally pass a year using the -y flag to only return games in a specific year. The user
        can obtain all games played by a given team (possibly in a given season) by passing the same team
        name in -t and -op.
        :param args:
        :return:
        """
        team_1 = '%' + args.team + '%'
        team_2 = '%' + args.opponent + '%'
        cursor = self.conn.cursor()
        if args.year:
            query = self.__file_manager.read_file('team_rivals_year.sql')
            data = (team_1, team_1, team_2, team_2, args.year, )
        else:
            query = self.__file_manager.read_file('team_rivals.sql')
            data = (team_1, team_1, team_2, team_2, )

        cursor.execute(query, data)
        response = ServiceResponse(cursor = cursor,
                                   display_args=(
                                       [('Date', 0), ('Home Team', 1), ('Away Team', 2), ('Home Score', 3),
                                        ('Away Score', 4),
                                        ('Venue', 5), ('Location', 6)],
                                   ),
                                   display_method=display.display)
        return response

    def __get_game(self, args: [str]) -> ServiceResponse:
        """
        Get a game either by its ID specified with the -g flag, or all games in a given year using the -y flag.
        :param args:
        :return:
        """
        game_id = args.game_id
        year = args.year
        cursor = self.conn.cursor()
        query = self.__file_manager.read_file('games.sql')
        if year is not None:
            # User provided a year
            query = query.format(column_name='date_part(\'year\', date)')
            data = (year,)
        else:
            query = query.format(column_name='g.game_id')
            data = (game_id,)

        cursor.execute(query, data)
        response = ServiceResponse(cursor = cursor,
                                   display_args=(
                                       [('Game ID', 0), ('Date', 1), ('Attendance', 2),
                                        ('Home Team', 3), ('Away Team', 4), ('Venue', 5),
                                        ('Time', 6), ('Home Score', 7), ('Away Score', 8)],
                                       (9, 10)
                                   ),
                                   display_method=display.display)
        return response

    def __get_stat_leaders(self, args: [str]) -> ServiceResponse:
        game_id = args.game_id
        query = self.__file_manager.read_file('statistics.sql')
        data = (game_id, )
        try:
            cursor = self.conn.cursor()
            cursor.execute(query, data)
            response = ServiceResponse(cursor = cursor,
                                       status=ResponseStatus.SUCCESSFUL_READ,
                                       display_args=(
                                           [('Name', 0), ('Position', 1), ('Team', 2), ('Category', 3), ('Yards', 4)],
                                       ),
                                       display_method=display.display)
            return response
        except:
            return ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)


    def __get_scores(self, args: [str]) -> ServiceResponse:
        """
        Get scores for the game is the -s flag is used
        :param args: Command line arguments
        :return: A tuple containing the cursor, column and optional color data, and the display method to use.
        The column and color data should be provided in-order the display method requires.
        """
        year = args.year
        week = args.week
        cursor = self.conn.cursor()
        query = ""
        with open('./python/Queries/scores.sql') as file:
            query = file.read()
        data = (year, week, year, week, year, week, )
        cursor.execute(query, data)
        response = ServiceResponse(cursor = cursor,
                                   display_args=(
                                       [('name', 0), ('score', 1)],
                                       [('name', 2), ('score', 3)],
                                       [(4, 5), (6, 7)]
                                   ),
                                   display_method=display.display_matchup)
        return response

    def __get_plays(self, args: [str]) -> ServiceResponse:
        """
        Get plays for the game is the -p flag is used with a corresponding game and athlete id
        :param args: Command line arguments
        :return: A tuple containing the cursor, column and optional color data, and the display method to use.
        The column and color data should be provided in-order the display method requires.
        """
        athlete_id = args.athlete
        game_id = args.game_id
        cursor = self.conn.cursor()
        query = self.__file_manager.read_file('player_game_plays.sql')
        data = (game_id, athlete_id,)
        cursor.execute(query, data)
        response = ServiceResponse(cursor = cursor,
                                   display_args=(
                                       [('Quarter', 0), ('Seconds Remaining', 1), ('Yards', 2), ('Score Value', 3),
                                        ('Play Type', 4), ('Start Down', 5), ('End Down', 6)],
                                       None,
                                   ),
                                   display_method=display.display)
        return response

    def __get_percent_filled(self, args: [str]) -> ServiceResponse:
        game_id = args.game_id
        cursor = self.conn.cursor()
        query = self.__file_manager.read_file('percent_filled.sql')
        data = (game_id, )
        cursor.execute(query, data)
        response = ServiceResponse(cursor = cursor,
                                   display_args=(
                                       [('Percent Fill', 0)],
                                   ),
                                   display_method=display.display)
        return response
