The following changes have been made to the dev database and will need to be added to the live database upon release.

- users table
    - `ALTER TABLE users ADD COLUMN last_login TIMESTAMP;`
    - `ALTER TABLE users ADD COLUMN elevation VARCHAR(10) DEFAULT '' NOT NULL;`
    - `ALTER TABLE metabolics ADD COLUMN buffs_json text DEFAULT '{}' NOT NULL;`