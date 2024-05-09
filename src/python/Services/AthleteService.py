from Services.Service import Service
from Services.ServiceResponse import ServiceResponse, ResponseStatus
from psycopg import Connection
from FileManager import FileManager
import display


class AthleteService(Service):
    def __init__(self, file_manager: FileManager, conn: Connection = None):
        super().__init__(conn)
        self.file_manager = file_manager

    def get_data(self, args: [str], **kwargs) -> ServiceResponse:
        if args.statistics and args.week and args.year and args.season_type:
            return self.__get_weekly_receiving_stats(args)
        elif args.passer_rating:
            return self.__get_passer_rating(args)
        elif args.statistics:
            return self.__get_receiving_stats_for_athlete(args)
        elif args.athlete:
            return self.__get_athlete_by_id(args)
        else:
            return self.__get_athlete(args)

    def __get_athlete(self, args: [str]) -> ServiceResponse:
        if args.last:
            column_name = 'last_name'
        else:
            column_name='first_name'
        athlete_name = args.athlete_name
        cursor = self.conn.cursor()
        query = self.file_manager.read_file('athletes.sql').format(column_name=column_name)
        data = ('%' + athlete_name + '%', )
        cursor.execute(query, data)
        response = ServiceResponse(cursor=cursor,
                                   status=ResponseStatus.SUCCESSFUL_READ,
                                   display_args=(
                                       [('ID', 0), ('Name', 1), ('Date of Birth', 2), ('Height, in', 3),
                                        ('Weight, lbs', 4), ('Birth Place', 5), ('Team Name', 6), ('Position', 7),
                                        ('Platoon', 8)],
                                   ),
                                   display_method=display.display)
        return response

    def __get_athlete_by_id(self, args: [str]) -> ServiceResponse:
        athlete_id = args.athlete
        query = self.file_manager.read_file('athlete_by_id.sql')
        data = (athlete_id,)
        try:
            cursor = self.conn.cursor()
            cursor.execute(query, data)
            response = ServiceResponse(cursor=cursor,
                                       status=ResponseStatus.SUCCESSFUL_READ,
                                       display_args=(
                                           [('ID', 0), ('Name', 1), ('Date of Birth', 2), ('Height, in', 3),
                                            ('Weight, lbs', 4), ('Birth Place', 5), ('Team Name', 6), ('Position', 7),
                                            ('Platoon', 8)],
                                       ),
                                       display_method=display.display)
            return response
        except:
            response = ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)
            return response

    def __get_receiving_stats_for_athlete(self, args: [str]) -> ServiceResponse:
        athlete_id = args.athlete
        query = self.file_manager.read_file('athlete_receiving_stats.sql')
        data = (athlete_id,)
        try:
            cursor = self.conn.cursor()
            cursor.execute(query, data)
            response = ServiceResponse(cursor=cursor,
                                       status=ResponseStatus.SUCCESSFUL_READ,
                                       display_args=(
                                           [('Name', 0), ('Year', 1), ('Season Type', 2), ('Week', 3),
                                            ('Receiving Yards', 4)],
                                       ),
                                       display_method=display.display)
            return response
        except:
            response = ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)
            return response

    def __get_weekly_receiving_stats(self, args: [str]) -> ServiceResponse:
        year = args.year
        week = args.week
        query = self.file_manager.read_file('weekly_receiving_stats.sql')
        try:
            if args.season_type == 'rs':
                season_type = 'Regular Season'
            elif args.season_type == 'ps':
                season_type = 'Post Season'
            else:
                raise Exception('Unknown season type')
            cursor = self.conn.cursor()
            data = (year, season_type, week)
            cursor.execute(query, data)
            response = ServiceResponse(cursor=cursor,
                                       status=ResponseStatus.SUCCESSFUL_READ,
                                       display_args=(
                                           [('Game ID', 0), ('Name', 1), ('Receiving Yards', 2)],
                                       ),
                                       display_method=display.display,
                                       prefix_message=f'Weekly Receiving Statistics for week {week} in the {year} {season_type}')
            return response
        except Exception as e:
            print(e)
            if str(e) == 'Unknown season type':
                response = ServiceResponse(status=ResponseStatus.UNSUCCESSFUL,
                                           prefix_message='Unknown season type. Accepted values are rs for regular season and ps for post season')
                return response
            else:
                response = ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)
                return response

    def __get_passer_rating(self, args: [str]) -> ServiceResponse:
        year = args.year
        query = self.file_manager.read_file('passing.sql')
        if args.athlete:
            query = query.format(where_filter='WHERE a.athlete_id = %s')
            data = (year, args.athlete)
        else:
            query = query.format(where_filter='')
            data = (year, )
        try:
            cursor = self.conn.cursor()
            cursor.execute(query, data)
            response = ServiceResponse(cursor=cursor,
                                       status=ResponseStatus.SUCCESSFUL_READ,
                                       display_args=(
                                           [('Athlete ID', 0), ('Name', 1), ('Passing Yards', 2), ('Pass Attempts', 3),
                                            ('Pass Completions', 4), ('Touchdown Passes', 5), ('Passes Intercepted', 6),
                                            ('Passer Rating', 7)],
                                       ),
                                       display_method=display.display,
                                       prefix_message=f'Passing statistics for the year {year}')
            return response
        except:
            return ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)