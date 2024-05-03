from Services.Service import Service
from Services.ServiceResponse import ServiceResponse
from psycopg import Connection
from FileManager import FileManager
import display


class VenueService(Service):
    def __init__(self, file_manager: FileManager, conn: Connection = None):
        super().__init__(conn)
        self.file_manager = file_manager

    def get_data(self, args: [str]) -> ServiceResponse:
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
