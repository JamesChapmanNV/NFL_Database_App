
import psycopg # type: ignore
from configparser import ConfigParser
from pathlib import Path


class Query:
    def __init__(self):
        self.config = self.load_configuration()
        self.pgdb = None  # PostgreSQL Connection

    def load_configuration(self):
        parser = ConfigParser()
        parser.read('./python/config.ini') # Required file for connection
        params = parser.items('Database') # Required database section
        return {param[0]: param[1] for param in params}

    def open_connections(self):
        try:
            self.pgdb = psycopg.connect(
                host = self.config['postgresqlserverurl'],
                dbname = self.config['postgresqlserverdatabase'],
                user = self.config['postgresqlserveruser'],
                password = self.config['postgresqlserverpassword'],
                sslmode = 'require'
            )
            # self.pgdb.set_autocommit(False)
            print('Connection Established!')
        except Exception as e:
            print('Connection Error: %s' % (e))

    def close_connections(self):
        if self.pgdb:
            self.pgdb.close()
    
    def initialize_database(self):
        cursor = self.pgdb.cursor()
        
        with open('NFL_database/src/sql/table.sql', 'r') as file:
            create_table_commands = file.read()
        cursor.execute(create_table_commands)

        # commit is needed!
        cursor.close()
        
    def xterm_256_color_code(self, hex_color):
        """ xterm 256-Color Mode: Modern terminal emulators often support 256 colors, which provides a wide range of colors for text and background. 
            This mode allows for a greater variety of hues and shades compared to the basic 16 colors.
            PuTTY supports xterm 256-Color Mode
        """
        """
            Conversion to 6x6x6 RGB Color Cube: In the 256-color palette, each color is represented by a 6x6x6 RGB color cube. 
            This cube consists of 216 colors, where each dimension (red, green, and blue) has 6 levels (0, 51, 102, 153, 204, and 255). 
            These 216 colors form the basis of the 256-color palette.
    
            Mapping RGB Values to Cube Levels: Map the given RGB values to the nearest cube levels.
            Each RGB value (r, g, b) is divided by 255 (the maximum value for each color component) and multiplied by 5 (the number of levels per dimension in the cube) to map it to the corresponding cube level.
    
            Calculating the 256-Color Code: Once the RGB values are mapped to the cube levels, calculate the 256-color code using the formula:
            color_code = 16 + (36 * red_level) + (6 * green_level) + blue_level
    
            The constant 16 is added to account for the first 16 colors in the palette, which are standard system colors like black, white, red, green, etc.
            (36 * red_level) calculates the offset for the red dimension.
            (6 * green_level) calculates the offset for the green dimension.
            blue_level represents the offset for the blue dimension.
        """
            
        # Convert hexadecimal color code to RGB values
        r = int(hex_color[1:3], 16)
        g = int(hex_color[3:5], 16)
        b = int(hex_color[5:7], 16)

        # Convert RGB values to the closest matching xterm 256-color code
        xterm_code = 16 + (36 * round(r / 255 * 5)) + (6 * round(g / 255 * 5)) + round(b / 255 * 5)
        
        return xterm_code
        
    def ANSI_escape_code_string(self, text, primary_hex_code, secondary_hex_code):
        """ ANSI escape codes for text formatting and colorization, 
            including those used for specifying text and background colors, support a wide range of colors. 
            The exact number of colors supported can vary depending on the capabilities of the terminal emulator or software being used.
            
            Here's a basic overview of ANSI color codes:
    
            Escape Character: ANSI color codes start with an escape character, which is represented by the ASCII control character \033 (octal) or \x1b (hexadecimal). In Python strings, you can represent the escape character as \033 or \x1b.
    
            Color Codes: After the escape character, ANSI color codes are followed by one or more parameters that specify the desired text formatting or color. These parameters are enclosed in square brackets []. Common parameters include:
            0: Reset all formatting (return to default).
            1: Bold or increased intensity.
            2: Dim (decreased intensity, not widely supported).
            3: Italic (not widely supported).
            4: Underline.
            5: Blink (not widely supported).
            7: Reverse video (swap foreground and background colors).
            8: Conceal (hide text, not widely supported).
            30 to 37: Set foreground color (0-7 are standard colors, 8+ are high-intensity colors).
            40 to 47: Set background color (0-7 are standard colors, 8+ are high-intensity colors).
    
            Color Sequences: To apply a color or text formatting, you concatenate the escape character, the open square bracket, the color code(s), and the letter m.
            For example, to set text color to red, you would use \033[31m.
    
            Resetting Formatting: It's important to reset formatting after applying color or other formatting to avoid unexpected behavior. 
            You can reset formatting by using the escape character followed by the sequence \033[0m.
        
        """
    
        xterm_primary_color_code = self.xterm_256_color_code(primary_hex_code)
        xterm_secondary_color_code = self.xterm_256_color_code(secondary_hex_code)
        
        # ANSI escape sequence to start bold text
        start_bold = "\033[1m"
        # ANSI escape sequence to set foreground color
        set_foreground_color = f"\033[38;5;{xterm_secondary_color_code}m"
        # ANSI escape sequence to set background color
        set_background_color = f"\033[48;5;{xterm_primary_color_code}m"
        # ANSI escape sequence to reset text attributes (color, formatting) to default
        reset_attributes = "\033[0m"

        # Concatenate all escape sequences and text
        ansi_escape_code_string = start_bold + set_foreground_color + set_background_color + text + reset_attributes

        # return text in the specified color
        return (ansi_escape_code_string)
        
    
    
    def get_team(self, team_name: str) -> None:
        cursor = self.pgdb.cursor()
        query = "SELECT * FROM teams WHERE team_name = %s"
        data = (team_name, )
        print(query)
        # query = "SELECT * FROM teams"
        cursor.execute(query, data)
        for row in cursor:
            print(row)

    def get_venue(self, venue_name: str) -> None:
        cursor = self.pgdb.cursor()
        query = "SELECT * FROM venues WHERE venue_name = %s"
        data = (venue_name, )
        cursor.execute(query, data)
        for row in cursor:
            print(row)

    def get_game(self, game_id: int) -> None:
        cursor = self.pgdb.cursor()
        query = "SELECT * FROM games WHERE game_id = %s"
        data = (game_id, )
        cursor.execute(query, data)
        for row in cursor:
            print(row)
            
    def get_game_scores(self, year: int, week: int) -> None:
        cursor = self.pgdb.cursor()  # Establish a cursor for executing SQL queries
        query = """
            SELECT
                home.team_name AS home_team,
                home.total_score AS home_score,
                home.primary_color AS home_primary_color,
                home.secondary_color AS home_secondary_color,
                away.team_name AS away_team,
                away.total_score AS away_score,
                away.primary_color AS away_primary_color,
                away.secondary_color AS away_secondary_color
            FROM
                games
                JOIN season_dates s ON s.date = games.date
                JOIN (
                    SELECT
                        t.team_name,
                        SUM(score) AS total_score,
                        t.primary_color,
                        t.secondary_color
                    FROM
                        season_dates sd
                        JOIN games g ON sd.date = g.date
                        JOIN linescores l ON l.game_id = g.game_id
                        JOIN teams t ON g.home_team_name = t.team_name
                    WHERE
                        season_year = %s AND
                        week = %s
                    GROUP BY
                        t.team_name, t.primary_color, t.secondary_color
                ) AS home ON home.team_name = games.home_team_name
                JOIN (
                    SELECT
                        t.team_name,
                        SUM(score) AS total_score,
                        t.primary_color,
                        t.secondary_color
                    FROM
                        season_dates sd
                        JOIN games g ON sd.date = g.date
                        JOIN linescores l ON l.game_id = g.game_id
                        JOIN teams t ON g.away_team_name = t.team_name
                    WHERE
                        season_year = %s AND
                        week = %s
                    GROUP BY
                        t.team_name, t.primary_color, t.secondary_color
                ) AS away ON away.team_name = games.away_team_name
            WHERE
                season_year = %s AND
                week = %s;
        """
        data = (year, week, year, week, year, week)  # Data tuple containing the year and week
        cursor.execute(query, data)  # Execute the SQL query with the provided data
        for row in cursor:  # Iterate over the result set
            
            home_team, home_score, home_primary_color, home_secondary_color, away_team, away_score, away_primary_color, away_secondary_color = row
            
            formatted_home = self.ANSI_escape_code_string(home_team + " - " + str(home_score), home_primary_color, home_secondary_color)
            formatted_away = self.ANSI_escape_code_string(away_team + " - " + str(away_score), away_primary_color, away_secondary_color)
            
            # Print the formatted data
            print(f"{formatted_home} || {formatted_away}")
            
            
            




#     def transaction_login(self, name, password):
#         pass

#     def transaction_personal_data(self, cid):
#         pass

#     def transaction_search(self, cid, movie_name):
#         pass
