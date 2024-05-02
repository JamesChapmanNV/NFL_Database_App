from FileManager import FileManager
class GameService:

    def __init__(self, file_manager: FileManager, conn=None):
        self.__conn = conn
        self.__file_manager = file_manager

    def set_connection(self, conn):
        self.__conn = conn

    def get_game(self, game_id: int):
        cursor = self.__conn.cursor()
        query = self.__file_manager.read_file('games.sql')
        if len(str(game_id)) == 4:
            # User provided a year
            query = query.format(column_name='date_part(\'year\', date)')
        else:
            query = query.format(column_name='g.game_id')
        data = (game_id, )
        cursor.execute(query, data)

        return cursor

    def get_scores(self, year: int, week: int):
        cursor = self.__conn.cursor()
        query = ""
        with open('./python/Queries/scores.sql') as file:
            query = file.read()
        data = (year, week, year, week, year, week, )
        cursor.execute(query, data)
        return cursor