from psycopg import Connection
from abc import ABC, abstractmethod
from Services.ServiceResponse import ServiceResponse


class Service(ABC):
    """
    Abstract base class that all services inherit from. This class contains a public method called set_connection
    which allows the connection to be set. An abstract method called get_data is defined, which must be implemented
    by the subclass. This is the primary public method to retrieve the desired data. It is up to the subclass to define
    how the request is fulfilled.
    """
    def __init__(self, conn: Connection = None):
        self.conn = conn

    def set_connection(self, conn: Connection):
        self.conn = conn

    @abstractmethod
    def get_data(self, args: [str]) -> ServiceResponse:
        pass

