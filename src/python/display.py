"""
This module provides functions to display the output of queries to the user.
"""
from rich import print


def display(results, columns, colors=None):
    """
    Display the results of the query to the user.
    :param results: A list of the results of the query
    :param columns: A dict containing the column display names and their respective index in each tuple
    :param colors: A tuple containing (primary, secondary) colors either as their hex values, or the index in the result set
    :return: None
    """
    for row in results:
        print('\n')
        for name, index in columns.items():
            if colors:
                if isinstance(colors[0], int):
                    primary_color = row[colors[0]]
                    secondary_color = row[colors[1]]
                    print(f"[#{secondary_color} on #{primary_color}]{name}: {row[index]}")
                else:
                    print(f"[#{colors[1]} on #{colors[0]}]{name}: {row[index]}")
            else:
                print(f"{name}: {row[index]}")
