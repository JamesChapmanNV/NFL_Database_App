-- there is a formatted string variable in this called column name. This is intended to be used so the user
-- can get games based on multiple criteria. Do not put user data into the column name unless you are
-- sure it is sanitized.
SELECT *
FROM games
WHERE {column_name} = %s