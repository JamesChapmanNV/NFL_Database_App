class User:
    def __init__(self, uid: int = None,
                 username: str = None,
                 password: str = None,
                 first_name: str = None,
                 last_name: str = None,
                 created_on: str = None,
                 favorite_team: str = None,
                 favorite_athlete: str = None):
        self.__uid = uid
        self.__username = username
        self.__password = password
        self.__first_name = first_name
        self.__last_name = last_name
        self.__created_on = created_on
        self.__favorite_team = favorite_team
        self.__favorite_athlete = favorite_athlete

    def get_uid(self):
        return self.__uid

    def get_username(self):
        return self.__username

    def get_password(self):
        return self.__password

    def get_first_name(self):
        return self.__first_name

    def get_last_name(self):
        return self.__last_name

    def get_favorite_team(self):
        return self.__favorite_team

    def get_favorite_athlete(self):
        return self.__favorite_athlete

    def get_created_on(self):
        return self.__created_on

    def set_password(self, password):
        self.__password = password

    def set_first_name(self, first_name):
        self.__first_name = first_name

    def set_last_name(self, last_name):
        self.__last_name = last_name

    def set_favorite_team(self, favorite_team):
        self.__favorite_team = favorite_team

    def set_favorite_athlete(self, favorite_athlete):
        self.__favorite_athlete = favorite_athlete