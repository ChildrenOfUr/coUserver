The following changes have been made to the dev database and will need to be added to the live database upon release.

- users table
    - added `last_login` column of type DateTime: `ALTER TABLE users ADD COLUMN last_login TIMESTAMP;`