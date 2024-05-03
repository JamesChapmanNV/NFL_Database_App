from psycopg import Connection
import display
from Services.Service import Service
from FileManager import FileManager


class TeamService(Service):

    def __init__(self, file_manager: FileManager, conn: Connection = None):
        self.file_manager = file_manager
        super().__init__(conn)

    def get_data(self, args: [str]) -> ():
        if args.year:
            return self.__get_record(args)
        else:
            return self.__get_team(args)

    def __get_team(self, args: [str]) -> ():
        team_name = args.team_name
        cursor = self.conn.cursor()
        if team_name is not None:
            query = "SELECT * FROM teams WHERE team_name = %s"
            data = (team_name, )
            cursor.execute(query, data)
        else:
            query = 'SELECT * FROM teams'
            cursor.execute(query)
        return (cursor,
                [('Name', 0), ('Abbreviation', 1), ('Location', 2), ('Home Stadium', 3)],
                (4, 5),
                display.display)

    def __get_record(self, args: [str]) -> ():
        year = args.year
        cursor = self.conn.cursor()
        if args.team:
            query = self.file_manager.read_file('team_records_team.sql')
            data = (year, year, args.team, )
        else:
            query = self.file_manager.read_file('team_records.sql')
            data = (year, year, )
        cursor.execute(query, data)
        return (cursor,
                [('Team Name', 0), ('Home Wins', 1), ('Home Losses', 2), ('Away Wins', 3), ('Away Losses', 4)],
                display.display)