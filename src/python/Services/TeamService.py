from psycopg import Connection
import display
from Services.Service import Service
from Services.ServiceResponse import ServiceResponse, ResponseStatus
from FileManager import FileManager


class TeamService(Service):

    def __init__(self, file_manager: FileManager, conn: Connection = None):
        self.file_manager = file_manager
        super().__init__(conn)

    def get_data(self, args: [str], **kwargs) -> ServiceResponse:
        if args.year:
            return self.__get_record(args)
        elif args.postseason_count:
            return self.__get_postseason_game_count(args)
        else:
            return self.__get_team(args)

    def __get_team(self, args: [str]) -> ServiceResponse:
        team_name = args.team_name
        cursor = self.conn.cursor()
        if team_name is not None:
            query = "SELECT * FROM teams WHERE team_name = %s"
            data = (team_name, )
            cursor.execute(query, data)
        else:
            query = 'SELECT * FROM teams'
            cursor.execute(query)
        response = ServiceResponse(cursor=cursor,
                                   display_args=(
                                       [('Name', 0), ('Abbreviation', 1), ('Location', 2), ('Home Stadium', 3)],
                                       (4, 5),
                                   ),
                                   display_method=display.display)
        return response

    def __get_record(self, args: [str]) -> ServiceResponse:
        year = args.year
        cursor = self.conn.cursor()
        if args.team:
            query = self.file_manager.read_file('team_records_team.sql')
            data = (year, year, args.team, )
        else:
            query = self.file_manager.read_file('team_records.sql')
            data = (year, year, )
        cursor.execute(query, data)
        response = ServiceResponse(cursor=cursor,
                                   display_args=(
                                       [('Team Name', 0), ('Home Wins', 1), ('Home Losses', 2), ('Away Wins', 3),
                                        ('Away Losses', 4), ('Record', 5)],
                                   ),
                                   display_method=display.display)
        return response

    def __get_postseason_game_count(self, args: [str]) -> ServiceResponse:
        """
        Get the post-season game count for each team.
        :param args: Arguments passed by the user
        :return: A ServiceResponseObject
        """
        query = self.file_manager.read_file('post_season_game_count.sql')
        try:
            cursor = self.conn.cursor()
            cursor.execute(query)
            response = ServiceResponse(cursor = cursor,
                                       status=ResponseStatus.SUCCESSFUL_READ,
                                       display_args=(
                                           [('Team', 0), ('Total Games', 1), ('Wildcard', 2),
                                            ('Divisional', 3), ('Conference Championship', 4), ('Superbowl', 5)],
                                           (6, 7)
                                       ),
                                       display_method=display.display,
                                       prefix_message='Post-Season Game Counts')
            return response
        except:
            return ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)