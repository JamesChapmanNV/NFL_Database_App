from Services.Service import Service
from psycopg import Connection
from FileManager import FileManager
import display


class AthleteService(Service):
    def __init__(self, file_manager: FileManager, conn: Connection = None):
        super().__init__(conn)
        self.file_manager = file_manager

    def get_data(self, args: [str]) -> ():
        return self.get_athlete(args)

    def get_athlete(self, args: [str]) -> ():
        if args.last:
            column_name = 'last_name'
        else:
            column_name='first_name'
        athlete_name = args.athlete_name
        cursor = self.conn.cursor()
        query = self.file_manager.read_file('athletes.sql').format(column_name=column_name)
        data = ('%' + athlete_name + '%', )
        cursor.execute(query, data)
        return(cursor,
               [('ID', 0), ('Name', 1), ('Date of Birth', 2), ('Height, in', 3),
                ('Weight, lbs', 4), ('Birth Place', 5), ('Team Name', 6), ('Position', 7), ('Platoon', 8)],
               display.display)
