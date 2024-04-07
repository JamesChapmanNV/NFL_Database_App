# Importing the data to the database

First navigate to the sql directory in the project. From the NFL Project directory:
`cd src/sql`

Connect to the postgreSQL database and provide your password when prompted:
`psql -U <username> -h postgresql.cs.ksu.edu`
	
Connect to your database:
`\c <database_name>`

Drop any previously created tables:
`\i drop_tables.sql`

Create the tables:
`\i create_tables.sql`

Import the data:
`\i data_import.sql`