import pandas as pd
import re
#%%
"""
We need to remove some of the un-needed columns from games
"""
FINAL_GAMES_COLUMNS = ['game_id', 'year', 'season_type', 'week', 'date', 'name', 'shortName', 'attendance',
                       'venue_id', 'home_win_bool', 'home_team_id', 'away_team_id']
# Read in the games data
df_games = pd.read_csv('data/games.csv')

df_games_decomposed = df_games[FINAL_GAMES_COLUMNS]
df_games_decomposed.to_csv('data/decomposed_data/decomposed_games.csv', index=False)
#%%

"""
Not much to do in the athletes table, but we need to drop some of the attributes we aren't using.
I think it makes the most sense to drop the 'lbs' from the weight and store as an int. Also, lets convert
x feet and y in to inches and store as an int.
"""

def extract_number(s: str) -> str:
    try:
        return re.match(r'[0-9]+', s).group(0)
    except:
        return 'NULL'


def get_height_inches(height_str: str) -> int:
    # pattern of display height in [0-9]'[0-9]+" where the first
    # value is height in feet and the second is height in inches.
    try:
        matches = re.findall(r'[0-9]+', height_str)
        feet = matches[0]
        inches = matches[1]
        return int(feet) * 12 + int(inches)
    except:
        return pd.NA

def clean_date(date_string: str) -> str:
    # The date is formatted in one of several ways:
    # %M-%d-%Y
    # %M-%d-%y
    # %m-%d-%Y
    # %m-%d-%y
    try:
        date_values = re.findall(r'[0-9]+', date_string)
        day = date_values[0]
        month = date_values[1]
        year = date_values[2]
        day = '0' + day if len(day) < 2 else day
        month = '0' + month if len(month) < 2 else month
        if len(year) < 4:
            if int(year) > 24:
                year = '19' + year
            else:
                year = '20' + year
        return f'{month}-{day}-{year}'
    except:
        return pd.NA


FINAL_ATHLETES_COLUMNS = ['athlete_id', 'firstName', 'lastName', 'displayHeight', 'displayWeight',
                          'displayDOB']
df_athletes = pd.read_csv('data/athletes.csv')
df_athletes_decomposed = df_athletes[FINAL_ATHLETES_COLUMNS]
df_athletes_decomposed['weight'] = df_athletes_decomposed['displayWeight']\
    .apply(extract_number)
df_athletes_decomposed['heightInches'] = df_athletes_decomposed['displayHeight'].apply(get_height_inches)
df_athletes_decomposed['dob'] = df_athletes_decomposed['displayDOB'].apply(clean_date)
df_athletes_decomposed.drop(columns=['displayHeight', 'displayWeight', 'displayDOB'], inplace=True)
df_athletes_decomposed.to_csv('data/decomposed_data/athletes.csv')
#%%
#%%
