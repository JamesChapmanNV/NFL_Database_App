import sys
from Query import Query
from RegistrationManager import RegistrationManager
import argparse
from argparse import Action, SUPPRESS
from Exceptions.ArgParserException import ArgParserException

"""
Parser flags:
    * -a athlete ID
    * -g game ID
    * -y year
    * -u username
    * -p password for login or plays
    * -l last
    * -s score
    * -w week
    * -t team
    * -op opponent score
    * -o output filename
"""

class ErrorCatchingArgumentParser(argparse.ArgumentParser):
    """
    Subclass of ArgumentParser to prevent the default exit
    """
    def exit(self, status=0, message=None):
        # Rather than exiting the application when the ArgumentParser says so,
        # lets raise an error we can recover from
        raise ArgParserException('ArgParser attempted to exit')

class NFLapp:
    def __init__(self, username: str=None, password: str=None):
        self.username = username
        self.password = password
        self.query = Query()
        self.registration_manager = RegistrationManager(self.query)
        self.parser = ErrorCatchingArgumentParser(add_help=False)
        self.parser.add_argument('-h', '--help',
                                 action='store_false',
                                 default=argparse.SUPPRESS)
        self.parser.set_defaults(func=self.print_help)
        self.configure_parser()

    def configure_parser(self):
        """
        Register the subparsers for the program
        :return:
        """
        subparsers = self.parser.add_subparsers(help='Functions',
                                                dest='command')
        self.register_login_parser(subparsers)
        self.register_team_parser(subparsers)
        self.register_athlete_parser(subparsers)
        self.register_venue_parser(subparsers)
        self.register_game_parser(subparsers)
        self.register_comeback_parser(subparsers)
        self.register_probability_parser(subparsers)
        self.register_save_parser(subparsers)
        self.register_quit_parser(subparsers)

    def register_login_parser(self, subparsers):
        # Create the parser to handle login arguments
        login_parser = subparsers.add_parser('Login', help='Login to the NFL database program')
        login_parser.add_argument('-u', '--username', type=str)
        login_parser.add_argument('-p', '--password', type=str)
        login_parser.set_defaults(func=self.login)

    def register_team_parser(self, subparsers):
        # Create the parser to handle team searches
        team_parser = subparsers.add_parser('Team', help='Search for a team by name')
        team_parser.add_argument('team_name', nargs='?', default=None, type=str,
                                 help='Name of the team')
        team_parser.set_defaults(func=self.query.execute)

    def register_athlete_parser(self, subparsers):
        athlete_parser = subparsers.add_parser('Athlete',
                                               help='Search for a athlete by name')
        athlete_parser.add_argument('athlete_name', type=str)
        athlete_parser.add_argument('-l', '--last',
                                    action='store_true',
                                    help='Search by last name')
        athlete_parser.set_defaults(func=self.query.execute)

    def register_venue_parser(self, subparsers):
        venue_parser = subparsers.add_parser('Venue',
                                             help='Search for a venue by name')
        venue_parser.add_argument('venue_name',
                                  nargs='?',
                                  default=None,
                                  type=str,
                                  help='Name of the venue')
        venue_parser.set_defaults(func=self.query.execute)

    def register_game_parser(self, subparsers):
        game_parser = subparsers.add_parser('Game',
                                            help='Search for a game by id')
        game_parser.add_argument('-g', '--game_id',
                                 nargs='?',
                                 default=None,
                                 type=str,
                                 help='ID of the game')
        game_parser.add_argument('-s', '--score',
                                 action='store_true')
        game_parser.add_argument('-y', '--year',
                                 nargs='?',
                                 default=None,
                                 type=str,
                                 help='Year of the games to search for')
        game_parser.add_argument('-w', '--week',
                                 default=None,
                                 type=str,
                                 help='Week of the games to get scores for')
        game_parser.add_argument('-p', '--plays',
                                 action='store_true',
                                 help='Get plays for an athlete in a game')
        game_parser.add_argument('-a', '--athlete',
                                 default=None,
                                 type=str,
                                 help='The athlete to get plays for if the -p flag is used')
        game_parser.set_defaults(func=self.query.execute)

    def register_comeback_parser(self, subparsers):
        comeback_parser = subparsers.add_parser('Top_Comeback_Wins',
                                                help='Find the top comeback wins')
        comeback_parser.add_argument('-y', '--year',
                                     type=str,
                                     help='The year to search for comeback wins')
        comeback_parser.set_defaults(func=self.query.top_comeback_wins)

    def register_probability_parser(self, subparsers):
        win_prob_parser = subparsers.add_parser('Win_probability',
                                                help='Find the probability of a win given a team, score, and opponent score')
        win_prob_parser.add_argument('-t', '--team',
                                     type=str,
                                     help='The team name')
        win_prob_parser.add_argument('-s', '--score',
                                     type=int,
                                     help='The teams score')
        win_prob_parser.add_argument('-op', '--opponent_score',
                                     type=int,
                                     help='The opponents score')
        win_prob_parser.set_defaults(func=self.query.win_probability)

    def register_save_parser(self, subparsers):
        save_parser = subparsers.add_parser('Save',
                                            help='Save the last results')
        save_parser.add_argument('file_type',
                                 type=str,
                                 help='The file type, either md for markdown or csv for CSV')
        save_parser.add_argument('-o', '--output',
                                 nargs='?',
                                 default=None,
                                 type=str,
                                 help='[optional] The filename')
        save_parser.set_defaults(func=self.query.save_last_result)

    def register_quit_parser(self, subparsers):
        quit_parser = subparsers.add_parser('quit', help='Quit the program')
        quit_parser.set_defaults(func=self.quit)

    def set_username(self, username: str) -> None:
        self.username = username

    def set_password(self, password: str) -> None:
        self.password = password

    def login(self) -> None:
        uid = self.query.login(self.username, self.password)
        if uid > 0:
            self.menu()
        else:
            print('Invalid credentials')
            exit(1)

    def print_help(self, args: [str]):
        self.parser.print_help()

    @staticmethod
    def usage():
        print("\n *** Please enter one of the following commands *** ")
        print("> Build_Database")
        print("> Team [<team_name>]")
        print("> Athlete <athlete_name> [-l]")
        print("> Venue [<venue_name>]")
        print("> Game -g <game_id> | -y <year>")
        print("> Top_Comeback_Wins [-y <year>]")
        print("> Win_probability -t <team_name> -s <team_score> -op <opponent_score>")
        print("> Save <type> [-o <filename>]")
        print("> quit")

    @staticmethod
    def quit(args):
        sys.exit(0)

    def menu(self):
        while True:
            try:
                self.usage()
                response = input("> ").strip()
                parsed_args = self.parser.parse_args(response.split())
                parsed_args.func(parsed_args)
                args = response.split(" ", 10)
                command = args[0]

                if command == "Build_Database":
                    self.query.build_database()
            except ArgParserException:
                continue

def main() -> None:
    app = NFLapp()  
    app.query.open_connections()

    if len(sys.argv) < 3:
        app.registration_manager.register_account()
        sys.exit(1)
    try:
        # Parse the initial login command and enter the run loop
        args = app.parser.parse_args()
        username = args.username
        password = args.password
        app.set_username(username)
        app.set_password(password)
        uid = app.login()

        if uid > 0:
            app.menu()  # Enter the main menu loop
        else:
            print('Invalid credentials')
    except Exception as e:
        print("An error occurred:", e)
        sys.exit(1)

if __name__ == "__main__":
    main()
    
    