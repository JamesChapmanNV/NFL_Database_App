from psycopg import Connection
from abc import ABC, abstractmethod


class Service(ABC):
    def __init__(self, conn: Connection = None):
        self.conn = conn

    def set_connection(self, conn: Connection):
        self.conn = conn

    @abstractmethod
    def get_data(self, args: [str]) -> ():
        pass

