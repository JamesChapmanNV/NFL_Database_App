import Query

class RegistrationManager:

    def __init__(self, query: Query):
        self.__query = query

    def register_account(self):

        print('Use the following steps to register for an account...')
        username = input('Please choose a username: ').strip()
        password = input('Please choose a password: ').strip()
        first_name = input('Please enter your first name: ').strip()
        last_name = input('Please enter your last name: ').strip()
        self.__query.register_user(username, password, first_name, last_name)
