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