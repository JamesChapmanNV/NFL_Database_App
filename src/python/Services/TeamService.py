from psycopg import Connection
import display
from Services.Service import Service


class TeamService(Service):

    def get_data(self, args: [str]) -> ():
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
