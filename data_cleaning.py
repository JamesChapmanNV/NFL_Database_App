import pandas as pd
import re
pd.set_option('display.max_columns', 500)
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
"""
Subset the plays data to pull the columns we need, then concatenate it
with the others.
"""
PLAYS_COLUMNS = ['play_id', 'start_down', 'end_down', 'quarter', 'play_type', 'seconds_remaining', 'text', 'score_value', 'yards']
INT_COLS = ['start_down', 'end_down', 'quarter', 'seconds_remaining', 'score_value', 'yards']
YEARS = range(2014, 2025)
full_df = pd.DataFrame()
for year in YEARS:
    df = pd.read_csv(f'data/Plays by Year/plays_{year}.csv')
    df = df[PLAYS_COLUMNS]
    df['start_down'] = df['start_down'].apply(lambda x: x if x >= 0 else 0)
    df['end_down'] = df['end_down'].apply(lambda x: x if x >= 0 else 0)
    full_df = pd.concat([full_df, df], ignore_index=True)
full_df[INT_COLS] = full_df[INT_COLS].astype('int64')
full_df.to_csv('data/full_plays.csv', index=False)
#%%
"""
Subset the player plays data to pull the columns we need, then
concatenate it with the other years
"""
PLAYER_PLAYS_COLUMNS = ['play_id', 'player_id', 'type']
YEARS = range(2014, 2025) # Same as above, but allows us to run this cell without the above
full_pp_df = pd.DataFrame()
for year in YEARS:
    df = pd.read_csv(f'data/Player Plays By Year/player_plays_{year}.csv')
    df = df[PLAYER_PLAYS_COLUMNS]
    full_pp_df = pd.concat([full_pp_df, df], ignore_index=True)
full_pp_df = full_pp_df.drop_duplicates()
full_pp_df.to_csv('data/full_player_plays.csv', index=False)
#%%

def split_birthplace(s: str, index: int):
    try:
        val = s.split(', ')[index]
        return val
    except:
        return ''
df_athletes = pd.read_csv('data/athletes.csv')
df_athletes['birth_city'] = df_athletes['birth_place'].apply(lambda x: split_birthplace(x, 0))
df_athletes['birth_state'] = df_athletes['birth_place'].apply(lambda x: split_birthplace(x, 1))
df_athletes = df_athletes.drop(['birth_place'], axis=1)
df_athletes.to_csv('data/athletes_split.csv', index=False)
#%%
df_athletes = pd.read_csv('data/athletes.csv')
df_pp = pd.read_csv('data/full_player_plays.csv')
df_joined = df_pp.merge(df_athletes, left_on='player_id', right_on='athlete_id', how='left')
missing_athletes = df_joined[df_joined['athlete_id'].isnull()]['player_id']
missing_athletes.to_csv('data/missing_athletes.csv', index=False)
#%%
df_athletes = pd.read_csv('data/athletes_split.csv')
df_pp = pd.read_csv('data/full_player_plays.csv')
df_joined = df_pp.merge(df_athletes, left_on='player_id', right_on='athlete_id', how='left')
df_pp = df_pp[~df_pp['player_id'].isin(missing_athletes)]
df_pp.to_csv('data/full_player_plays.csv', index=False)
