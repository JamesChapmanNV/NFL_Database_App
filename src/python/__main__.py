import sys
from Query import Query
from RegistrationManager import RegistrationManager

class NFLapp:
    def __init__(self, username: str=None, password: str=None):
        self.username = username
        self.password = password
        self.query = Query()
        self.registration_manager = RegistrationManager(self.query)

    def set_username(self, username: str) -> None:
        self.username = username

    def set_password(self, password: str) -> None:
        self.password = password

    def login(self) -> int:
        uid = self.query.login(self.username, self.password)
        return uid

    @staticmethod
    def usage():
        print("\n *** Please enter one of the following commands *** ")
        print("> Build_Database")
        print("> Team [<team_name>]")
        print("> Venue [<venue_name>]")
        print("> Scores <year> <week>")
        print("> Game <game_id | year>")
        print("> Top_Comeback_Wins [<year>]")
        print("> Win_probability <team_name> <team_score> <opponent_score>")
        print("> Save <type> [<filename>]")
        print("> quit")

    def menu(self):
        while True:
            self.usage()
            response = input("> ").strip()
            args = response.split(" ", 3)
            command = args[0]

            if command == "Build_Database":
                self.query.build_database()

            elif command == "Team":
                team_name = args[1] if len(args) > 1 else None
                self.query.get_team(team_name)

            elif command == "Venue":
                venue_name = args[1] if len(args) > 1 else None
                self.query.get_venue(venue_name)

            elif command == "Game":
                if len(args) > 1:
                    game_id = int(args[1])
                    print(f"Getting game - {game_id}")
                    self.query.get_game(game_id)
                else:
                    print("Error: Game <game_id | year>")

            elif command == "Scores":
                if len(args) > 2:
                    year = int(args[1])
                    week = int(args[2])
                    self.query.get_scores(year, week)
                else:
                    print("Error: Scores <year> <week>")
            
            elif command == "Top_Comeback_Wins":
                year = int(args[1]) if len(args) > 1 else None
                self.query.top_comeback_wins(year)

            elif command == "Win_probability":
                if len(args) > 3:
                    team_name = args[1]
                    team_score = int(args[2])
                    opponent_score = int(args[3])
                    self.query.win_probability(team_name, team_score, opponent_score)
                else:
                    print("Error: Win_probability <team_name> <team_score> <opponent_score>")

            elif command == "Save":
                if len(args) > 2:
                    filetype = args[1]
                    filename = args[2]
                    self.query.save_last_result(filetype, filename)
                elif len(args) > 1:
                    filetype = args[1]
                    self.query.save_last_result(filetype)
                else:
                    print("Error: Save <filetype> [<filename>]")

            elif command == "quit":
                sys.exit(0)

            else:
                print(f"Error: unrecognized command '{command}'")
                continue
            
def main() -> None:
    app = NFLapp()  
    app.query.open_connections()

    if len(sys.argv) < 3:
        app.registration_manager.register_account()
        print("Usage: python NFLdata.py USERNAME PASSWORD")
        sys.exit(1)
    try:
        username = sys.argv[1]
        password = sys.argv[2]
        # print(username,u"\u25CF"*12)
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
    
    