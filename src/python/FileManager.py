from pathlib import Path

class FileManager:

    def __init__(self, output_path: str=None, input_path: str=None):
        self.OUTPUT_PATH = output_path or str(Path.home() / 'Downloads')
        self.INPUT_PATH = input_path or './'

    def set_input_path(self, input_path: str):
        self.INPUT_PATH = input_path

    def set_output_path(self, output_path: str):
        self.OUTPUT_PATH = output_path

    def read_file(self, filename: str) -> str:
        """
        Read the file with the provided filename and return it's contents. This method looks for the file in the
        current input path.
        :param filename: The name of the file to read and it's extension.
        :return: The contents of the file as a string
        """
        with open(self.INPUT_PATH + filename, 'r') as file:
            data = file.read()
            return data

    def write_file(self, data: [(str, ...)], filename: str, filetype: str) -> int:
        """
        Write the data to a file with the provided filename and extension. If the file already exists,
        it will be overwritten. This method will write to the current output directory
        :param data: The data to write
        :param filename: The filename and extension
        :return:
        """
        try:
            if filetype == 'md':
                self.__write_markdown(data, filename)
                return 1
            elif filetype == 'csv':
                self.__write_csv(data, filename)
                return 1
            else:
                return -1
        except:
            return -1

    def __write_markdown(self, data: [(str, ...)], filename: str):
        with open(self.OUTPUT_PATH + '/' + filename, 'w+') as file:
            payload = self.__generate_markdown(data)
            file.write(payload)

    def __write_csv(self, data: [(str, ...)], filename: str):
        with open(self.OUTPUT_PATH + '/' + filename, 'w+') as file:
            payload = self.__generate_csv(data)
            file.write(payload)

    @staticmethod
    def __generate_csv(data: [(str, ...)]) -> str:
        """
        Generate a comma-separated string of values in the provided data
        :param data: The data to write, as a list of tuples
        :return: A comma-separated string
        """
        ret = ''
        cur_line = ''
        for line in data:
            for cell in line:
                if cur_line == '':
                    cur_line += cell
                else:
                    cur_line += f',{cell}'
            cur_line += '\n'
            ret += cur_line
            cur_line = ''
        return ret

    @staticmethod
    def __generate_markdown(data: [(str, ...)]) -> str:
        """
        Generates a markdown table from the provided data.
        :param data: The data to write, a list of tuples
        :return: A markdown table string
        """
        ret = ''
        cur_line = '|'
        for i in range(0, len(data)):
            if i == 0:
                for cell in data[i]:
                    cur_line += f' {cell} |'
                cur_line += '\n'
                ret += cur_line
                cur_line = '|'
                for j in range(0, len(data[i])):
                    cur_line += ' ----- |'
                cur_line += '\n'
                ret += cur_line
                cur_line = '|'
            else:
                for cell in data[i]:
                    cur_line += f' {cell} |'
                cur_line += '\n'
                ret += cur_line
                cur_line = '|'
        return ret