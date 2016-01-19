The following changes have been made to the dev database and will need to be added to the live database upon release.

- metabolics table
    - Added skills_json text column with default '{}' and NOT NULL constraint

- users table
    - Added chat_disabled boolean column with default false and NOT NULL constraint
      (this allows us to disable sending messages to global chat for spammers)
    - Added achievements text column with default '[]' and NOT NULL constraint
      (stores a list of ids in JSON format)