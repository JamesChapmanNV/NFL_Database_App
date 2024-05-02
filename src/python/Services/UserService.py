
class UserService:

    def __init__(self, conn):
        self.__conn = conn

    def set_connection(self, conn):
        self.__conn = conn

    def login(self, username: str, password: str) -> int:
        cursor = self.__conn.cursor()
        if username is not None and password is not None:
            try:
                query = 'SELECT * FROM users WHERE username = %s AND password = %s'
                data = (username, password,)
                cursor.execute(query, data)
                user = cursor.fetchone()
                return user[0]  # return the user's uid
            except:
                return -1
        else:
            return -1

    def register_user(self, username, password, first_name, last_name) -> None:
        if username is not None and password is not None:
            try:
                cursor = self.__conn.cursor()
                query = 'SELECT register_user(%s, %s, %s, %s);'
                data = (username, password, first_name, last_name, )
                cursor.execute(query, data)
                self.__conn.commit()
                print('Thank you for registering for an account')
            except Exception as e:
                print('An error occured: {}'.format(str(e)))

        return
