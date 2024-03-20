import pandas as pd

"""
We need to break the games file up and extract the home and away teams.
The new table will have attributes game_id, team_id, and type.
"""
# Read in the games daya
df_games = pd.read_csv('data/games.csv')
# Get home team data and set the type
df_home_team = df_games[['game_id', 'home_team_id']]
df_home_team = df_home_team.rename(columns={'home_team_id': 'team_id'})
df_home_team['type'] = 'home'
# Get away team data and set type
df_away_team = df_games[['game_id', 'away_team_id']]
df_away_team = df_away_team.rename(columns={'away_team_id': 'team_id'})
df_away_team['type'] = 'away'

# Stack the data and sort by the game ID
df_team_games = pd.concat([df_home_team, df_away_team], axis=0).sort_values(by='game_id')

# Sanity check that each game has only 2 teams
df_team_games.groupby('game_id').agg({'team_id': len}).agg('max')

df_team_games.to_csv('data/team_games.csv', index=False)
#%%
