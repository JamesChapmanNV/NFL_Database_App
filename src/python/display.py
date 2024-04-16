"""
This module provides functions to display the output of queries to the user.
"""
from rich import print


def display(results, columns, colors=None):
    """
    Display the results of the query to the user.
    :param results: A list of the results of the query
    :param columns: A list of tuples containing the display name and column index for each column to display in the results
    :param colors: A tuple containing (primary, secondary) colors either as their hex values, or the index in the result set
    :return: None
    """
    for row in results:
        # Block size is adjusted by 2 because there are 2 additional characters included in the output (': ')
        block_size = _get_block_size(row, columns) + 2
        print('\n')
        for name, index in columns:
            text = _pad_text(f"{name}: {row[index]}", block_size)
            if colors:
                if isinstance(colors[0], int):
                    primary_color = row[colors[0]]
                    secondary_color = row[colors[1]]
                    print(f"[#{secondary_color} on #{primary_color}]{text}")
                else:
                    print(f"[#{colors[1]} on #{colors[0]}]{text}")
            else:
                print(f"{text}")


def display_matchup(results, home_data, away_data, colors=None):
    """
    Display a matchup of 2 teams. The column names are not used for display, but are used to direct the
    function to the scores. This function will look for the name score in both the home and away data to
    determine the winner. If colors are passed, the result will be colored appropriately.
    :param results: The result set
    :param home_data: A list of tuples with the columns associated with the home team and their index
    :param away_data: A list of tuples with the columns associated with the away team and their index
    :param colors: A list of tuples containing the index for colors (primary, secondary) in the result set,
    for the home team and away team
    :return:
    """
    for row in results:
        print('\n')
        home_score = 0
        away_score = 0
        message = ""
        for name, index in home_data:
            message += f"{row[index]} "
            if name == 'score':
                home_score = row[index]

        message += " -- "

        for name, index in away_data:
            message += f"{row[index]} "
            if name == 'score':
                away_score = row[index]

        if colors:
            primary_color = ""
            secondary_color = ""
            if home_score > away_score:
                primary_color = row[colors[0][0]]
                secondary_color = row[colors[0][1]]
            else:
                primary_color = row[colors[1][0]]
                secondary_color = row[colors[1][1]]
            print(f"[#{secondary_color} on #{primary_color}]{message}")
        else:
            print(message)

def _get_block_size(row, columns) -> int:
    """
    Get the width of the row to print
    :param row: The current row to print
    :param columns: The columns and their display names to print
    :return: int The width of the row
    """
    current_max = 0
    for i in range(0, len(columns)):
        row_index = columns[i][1]
        current_max = max(current_max, len(str(row[row_index])) + len(columns[i][0]))
    return current_max


def _pad_text(text: str, width: int) -> str:
    """
    Pad the text with trailing spaces so it prints in a nice block
    :param text: The text to print
    :param width: The width of the block
    :return: str The text, with spaces added at the end
    """
    formatted_text = text
    while len(formatted_text) < width:
        formatted_text += " "
    return formatted_text