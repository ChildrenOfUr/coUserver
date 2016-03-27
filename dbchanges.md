The following changes have been made to the dev database and will need to be added to the live database upon release.

- users table
    - `ALTER TABLE users ADD COLUMN last_login TIMESTAMP;`
    - `ALTER TABLE users ADD COLUMN elevation VARCHAR(10) DEFAULT '' NOT NULL;`
    - `ALTER TABLE metabolics ADD COLUMN buffs_json text DEFAULT '{}' NOT NULL;`
    - ```
      CREATE TABLE notes (
        id serial NOT NULL,
        title text NOT NULL DEFAULT 'A note!',
        body text NOT NULL DEFAULT '',
        username text NOT NULL,
        timestamp timestamp without time zone NOT NULL DEFAULT (now() at time zone 'utc')
      );
      ```