# Importing the data to the database

First navigate to the sql directory in the project. From the NFL Project directory:
`cd src/sql`

Connect to the postgreSQL database and provide your password when prompted:
`psql -U <username> -h postgresql.cs.ksu.edu`
	
Connect to your database:
`\c <database_name>`

## Rebuild the database
The rebuild.sql sequentially executes the scripts needed to rebuild the database. Any previously created tables are dropped, re-created, and populated with data.
`\i build.sql`

## Executing scripts individually
`rebuild.sql` is a wrapper around the following commands:

Drop any previously created tables:
`\i drop_tables.sql`

Create the tables:
`\i create_tables.sql`

Import the data:
`\i data_import.sql`