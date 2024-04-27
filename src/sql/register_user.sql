CREATE OR REPLACE FUNCTION register_user(p_username VARCHAR,
                                         p_password VARCHAR,
                                         p_first_name VARCHAR,
                                         p_last_name VARCHAR)
    RETURNS VOID
AS
$$
BEGIN
    IF NOT EXISTS(SELECT *
                  FROM users
                  WHERE username = p_username) THEN
        INSERT INTO users(username, password, first_name, last_name, created_on)
        VALUES (p_username, p_password, p_first_name, p_last_name, CURRENT_DATE);
    ELSE
        RAISE EXCEPTION 'The username provided already exists';
    END IF;
END;
$$
    LANGUAGE plpgsql;