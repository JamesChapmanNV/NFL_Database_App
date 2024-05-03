from psycopg import Cursor
from typing import Any, Callable
from enum import Enum


class ResponseStatus(Enum):
    UNSUCCESSFUL = -1,
    SUCCESSFUL_READ = 0,
    SUCCESSFUL_WRITE = 1,


class ServiceResponse:
    def __init__(self, cursor: Cursor = None, display_args: (Any) = None,
                 display_method: Callable[[Any], Any] = None,
                 status: ResponseStatus = None, value: Any = None):
        """
        Initialize a new ServiceResponse object. ServiceResponse is a container object to hold all relevant data
        returned by a given service.
        :param cursor: The cursor object that contains the database result set
        :param display_args: A tuple of arguments to pass to the display method, in the order they are expected
        :param display_method: The display method to use
        :param status: The status of the request, if any
        :param value: An optional value to include in the result
        """
        self.cursor = cursor
        self.display_args = display_args
        self.display_method = display_method
        self.status = status
        self.value = value
