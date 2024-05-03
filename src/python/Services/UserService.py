from Services.Service import Service
from Services.ServiceResponse import ServiceResponse, ResponseStatus


class UserService(Service):

    def __init__(self, conn):
        super().__init__(conn)

    def get_data(self, args: [str], **kwargs) -> ServiceResponse:
        command = args.command
        if command == 'Login':
            return self.__login(args.username, args.password)
        elif command == 'Register':
            return self.__prompt_registration_input()
        elif command == 'User':
            return self.__favorite_team(args, **kwargs)

    def __login(self, username: str, password: str) -> ServiceResponse:
        cursor = self.conn.cursor()
        if username is not None and password is not None:
            try:
                query = 'SELECT * FROM users WHERE username = %s AND password = %s'
                data = (username, password,)
                cursor.execute(query, data)
                user = cursor.fetchone()
                response = ServiceResponse(status=ResponseStatus.SUCCESSFUL_READ,
                                           value=user)
                return response  # return the user
            except:
                return ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)
        else:
            return ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)

    def __prompt_registration_input(self):

        print('Use the following steps to register for an account...')
        username = input('Please choose a username: ').strip()
        password = input('Please choose a password: ').strip()
        first_name = input('Please enter your first name: ').strip()
        last_name = input('Please enter your last name: ').strip()
        return self.__register_user(username, password, first_name, last_name)

    def __register_user(self, username, password, first_name, last_name) -> ServiceResponse:
        if username is not None and password is not None:
            try:
                cursor = self.conn.cursor()
                query = 'SELECT register_user(%s, %s, %s, %s);'
                data = (username, password, first_name, last_name, )
                cursor.execute(query, data)
                self.conn.commit()
                print('Thank you for registering for an account')
                return ServiceResponse(status=ResponseStatus.SUCCESSFUL_WRITE)
            except Exception as e:
                return ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)

    def __favorite_team(self, args: [str], **kwargs):
        """
        Set the user's favorite team
        :param args:
        :return:
        """
        uid = None
        for key, value in kwargs.items():
            if key == 'uid':
                uid = value
        team_query = 'SELECT * FROM teams WHERE team_name = %s'
        team_data = (args.team, )
        update_query = 'UPDATE users SET favorite_team_name = %s WHERE uid = %s'
        update_data = (args.team, uid, )
        cursor = self.conn.cursor()
        cursor.execute(team_query, team_data)
        team = cursor.fetchone()
        if team:
            cursor = self.conn.cursor()
            cursor.execute(update_query, update_data, )
            self.conn.commit()
            print('Updated')

