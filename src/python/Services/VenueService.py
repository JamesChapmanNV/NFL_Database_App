from Services.Service import Service
from Services.ServiceResponse import ServiceResponse, ResponseStatus
from psycopg import Connection
from FileManager import FileManager
import display


class VenueService(Service):
    def __init__(self, file_manager: FileManager, conn: Connection = None):
        super().__init__(conn)
        self.file_manager = file_manager

    def get_data(self, args: [str], **kwargs) -> ServiceResponse:
        if args.year:
            return self.__get_most_home_wins(args)
        elif args.statistics:
            return self.__get_stadium_stats(args)
        else:
            return self.__get_venue(args)

    def __get_venue(self, args: [str]) -> ServiceResponse:
        venue_name = args.venue_name
        cursor = self.conn.cursor()
        query = self.file_manager.read_file('venues.sql')
        if venue_name:
            data = ('%' + venue_name + '%',)
            cursor.execute(query, data)
        else:
            data = ('%',)
            cursor.execute(query, data)
        service_response = ServiceResponse(cursor=cursor,
                                           display_args=([('Name', 0), ('Home Team', 6), ('Capacity', 1),
                 ('City', 2), ('State', 3), ('Grass', 4), ('Indoor', 5)], ),
                                           display_method=display.display)
        return service_response

    def __get_most_home_wins(self, args: [str]) -> ServiceResponse:
        """
        Get the venue(s) with the greatest home field advantage (most home wins in a given season) in a given season,
        along with the team's name and number of wins.
        :param args: Arguments provided by the user
        :return: A ServiceResponse object
        """
        year = args.year
        query = self.file_manager.read_file('home_field_advantage.sql')
        data = (year, )
        try:
            cursor = self.conn.cursor()
            cursor.execute(query, data)
            response = ServiceResponse(cursor=cursor,
                                       status = ResponseStatus.SUCCESSFUL_READ,
                                       display_args=(
                                           [('Venue', 0), ('Team', 1), ('Home Wins', 2)],
                                       ),
                                       display_method=display.display,
                                       prefix_message=f'Venues with the most home wins in {year}')
            return response
        except:
            return ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)

    def __get_stadium_stats(self, args: [str]) -> ServiceResponse:
        """
        Get statistics related to the average number of points scored for various stadium combinations
        (grass vs turf field and indoor vs outdoor stadium)
        :param args: Arguments provided by the user
        :return: A ServiceResponse object
        """
        query = self.file_manager.read_file('avg_pts_grass_indoor.sql')
        try:
            cursor = self.conn.cursor()
            cursor.execute(query)
            response = ServiceResponse(cursor=cursor,
                                       status=ResponseStatus.SUCCESSFUL_READ,
                                       display_args=(
                                           [('Field', 0), ('Venue', 1), ('Average Total Points', 2)],
                                       ),
                                       display_method=display.display,
                                       prefix_message='Average points scored for various stadium combinations')
            return response
        except:
            return ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)