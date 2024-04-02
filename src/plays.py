"""
Go through the data for each game, and pull the plays for it.
"""
import pandas as pd
import requests
import re
#%%
def get_data(url, key = None):
    """
    Get data from a given endpoint and return it in JSON. If a key is provided, the value at that key
    will be returned
    :param url: The URL to get the data from
    :param key: An optional key at the top level of the object.
    :return: dict
    """
    response = requests.get(url).json()
    if key:
        return response[key]
    return requests.get(url).json()

def save_data(df: pd.DataFrame, path: str) -> None:
    df.to_csv(path, index=False)
#%%
YEARS = range(2018, 2025)
PLAYS_URL = 'https://sports.core.api.espn.com/v2/sports/football/leagues/nfl/events/{event_id}/competitions/{event_id}/plays?limit=300'
#%%
games = pd.read_csv('../data/games.csv')
games['date'] = pd.to_datetime(games['date'], format='%Y-%m-%d')
games['year'] = games['date'].dt.year
games = games[games['year'] == 2014]
print(games)
#%%
def get_plays(year: int):
    games = pd.read_csv('../data/games.csv')
    games['date'] = pd.to_datetime(games['date'], format='%Y-%m-%d')
    games['year'] = games['date'].dt.year
    games = games[games['year'] == year]
    plays = pd.DataFrame()
    player_plays = pd.DataFrame()
    n_rows = len(games.index)
    cur_row = 1
    for game_id in games['game_id']:
        print(f'{cur_row}/{n_rows}', end='\r')
        cur_row += 1
        # For each game id, pull the play by play data
        play_data = get_data(PLAYS_URL.format(event_id=game_id), key='items')
        for play in play_data:
            # Get the play data if it exists, otherwise continue
            try:
                play_dict = {
                    'play_id': play['id'],
                    'game_id': game_id,
                    'play_type': play['type']['text'],
                    'text': play['text'],
                    'quarter': play['period']['number'],
                    'seconds_remaining': play['clock']['value'],
                    'score_value': play['scoreValue'],
                    'yards': play['statYardage'],
                    'start_down': play['start']['down'],
                    'end_down': play['end']['down']
                }
                plays = plays.append(play_dict, ignore_index=True)
                # Loop through each participant and pull the player data
                for player in play['participants']:
                    player_url = player['athlete']['$ref']
                    player_id = re.search(r'(?<=athletes/)[0-9]+(?=\?)', player_url).group(0)
                    player_plays_dict = {
                        'player_id': player_id,
                        'play_id': play['id'],
                        'game_id': game_id,
                        'type': player['type']
                    }
                    player_play_df = pd.DataFrame(player_plays_dict, index=[0])
                    player_plays = pd.concat([player_plays, player_play_df], ignore_index=True)
            except Exception as e:
                continue
    print('Complete')
    return plays, player_plays

#%%
plays, player_plays = get_plays(2017)
#%%
print(player_plays)
#%%
save_data(plays, 'data/plays_2017.csv')
save_data(player_plays, 'data/player_plays_2017.csv')
#%%
