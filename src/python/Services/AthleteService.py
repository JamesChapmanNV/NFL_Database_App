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
        if args.athlete:
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