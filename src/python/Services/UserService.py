import display
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
            return self.__user_command_action(args, **kwargs)

    def __user_command_action(self, args: [str], **kwargs) -> ServiceResponse:
        if args.favorite:
            return self.__handle_favorite(args, **kwargs)
        elif args.delete:
            return self.__delete_user(args, **kwargs)
        else:
            return self.__get_user_by_uid(kwargs['uid'])

    def __handle_favorite(self, args: [str], **kwargs) -> ServiceResponse:
        arg_dict = vars(args)
        if 'team' in arg_dict:
            return self.__favorite_team(args, **kwargs)
        elif 'athlete' in arg_dict:
            return self.__favorite_athlete(args, **kwargs)

    def __get_user_by_uid(self, uid: int) -> ServiceResponse:
        query = 'SELECT * FROM users WHERE uid = %s'
        data = (uid, )
        cursor = self.conn.cursor()
        cursor.execute(query, data)
        response = ServiceResponse(cursor=cursor,
                                   display_args=(
                                       [('Username', 1),
                                        ('First Name', 3),
                                        ('Last Name', 4),
                                        ('Created On', 5),
                                        ('Favorite Team', 6),
                                        ('Favorite Athlete', 7)],
                                   ),
                                   display_method=display.display)
        return response


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

    def __delete_user(self, args: [str], **kwargs) -> ServiceResponse:
        pass

    def __favorite_team(self, args: [str], **kwargs) -> ServiceResponse:
        """
        Set the user's favorite team
        :param args:
        :return:
        """
        if args.delete:
            return self.__delete_favorite_team(args, **kwargs)
        uid = kwargs['uid']
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
            response = ServiceResponse(value={'user': {
                'updated_field': 'favorite_team_name',
                'updated_value': args.team
            }},
                status=ResponseStatus.SUCCESSFUL_WRITE)
            print(f'Team {args.team} has been successfully favorited')
            return response
        else:
            self.conn.rollback()
            response = ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)
            print('The provided team does not exist')
            return response

    def __delete_favorite_team(self, args: [str], **kwargs) -> ServiceResponse:
        uid = kwargs['uid']
        try:
            delete_query = 'UPDATE users SET favorite_team_name = NULL WHERE uid = %s'
            delete_data = (uid,)
            cursor = self.conn.cursor()
            cursor.execute(delete_query, delete_data)
            self.conn.commit()
            response = ServiceResponse(value={
                'user': {
                    'updated_field': 'favorite_team_name',
                    'updated_value': None
                }
            },
                status=ResponseStatus.SUCCESSFUL_WRITE)
            return response
        except:
            self.conn.rollback()
            response = ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)
            return response

    def __favorite_athlete(self, args: [str], **kwargs) -> ServiceResponse:
        if args.delete:
            return self.__delete_favorite_athlete(args, **kwargs)
        uid = kwargs['uid']
        athlete_query = 'SELECT * FROM athletes WHERE athlete_id = %s'
        athlete_data = (args.athlete, )
        update_query = 'UPDATE users SET favorite_athlete_id = %s WHERE uid = %s'
        update_data = (args.athlete, uid, )
        cursor = self.conn.cursor()
        cursor.execute(athlete_query, athlete_data)
        athlete = cursor.fetchone()
        if athlete:
            cursor = self.conn.cursor()
            cursor.execute(update_query, update_data)
            self.conn.commit()
            response = ServiceResponse(value={'user': {
                'updated_field': 'favorite_athlete_id',
                'updated_value': args.athlete
            }},
                status=ResponseStatus.SUCCESSFUL_WRITE)
            print(f'Athlete ID {args.athlete} has been successfully favorited')
            return response
        else:
            self.conn.rollback()
            response = ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)
            print('The provided athlete ID does not exist')
            return response

    def __delete_favorite_athlete(self, args, **kwargs) -> ServiceResponse:
        uid = kwargs['uid']
        try:
            query = 'UPDATE users SET favorite_athlete_id = NULL WHERE uid = %s'
            update_data = (uid,)
            cursor = self.conn.cursor()
            cursor.execute(query, update_data)
            self.conn.commit()
            response = ServiceResponse(value={
                'user': {
                    'updated_field': 'favorite_athlete_id',
                    'updated_value': None
                }
            },
                status=ResponseStatus.SUCCESSFUL_WRITE)
            return response
        except:
            self.conn.rollback()
            response = ServiceResponse(status=ResponseStatus.UNSUCCESSFUL)
            return response
