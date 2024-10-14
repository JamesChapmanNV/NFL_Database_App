# NFL Database Application <br>
CIS 761 Database Management Systems – Term Project <br>
Kansas State University <br>
<br>
James Chapman <br>
Chuck Zumbaugh, PhD <br>
Vishnu Bondalakunta, PhD Candidate <br>

---

A prototype for a **lightweight, command-line NFL database application** designed to deliver detailed NFL statistics and play-by-play data for statisticians and NFL enthusiasts. It enables users to retrieve information on individual players, teams, venues, and games, with features such as win probability calculations and exporting results in multiple formats.

## Key Features
- **PostgreSQL Relational Database**:
  Designed with **database normalization** to ensure **data consistency** and **preserve functional dependencies**.
  
- **High-Performance Queries**:  
  Optimized through **data indexing strategies**, enabling efficient handling of large datasets and faster query performance.

- **Win Probability Calculator**:  
  Integrated **logistic regression model** to calculate a team's chance of winning. **Future work** for this project would likely involve applying more advanced **machine learning techniques** for probabilistic predictions.

- **User Authentication**:  
  Allowing users to register, log in, and manage their profiles and preferences.



**Installing the application**

1.) Clone this repository by running the following command,

##
    git clone https://github.com/JamesChapmanNV/NFL_database

2.) Navigate to /src/python/ExampleConfig.ini and modify according to user's postgresql server credentials. Rename the file as 'Config.ini'

3.) Navigate to /src/sql/ and connect to the same postgresql server and database as mentioned in 'Config.ini'

4.) Run the following command to build the tables and function.

##
    \i build.sql

**Running the application**

1.) Ensure that the python modules mentioned in /src/python/requirements.txt are installed

2.) Navigate to /src/ and execute the following command to display the help and possible options in using the application.
##
    python3 python -h
    

<a target="_blank" href="https://colab.research.google.com/github/JamesChapmanNV/NFL_database/blob/main/data/ESPN_WebScraping.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>
