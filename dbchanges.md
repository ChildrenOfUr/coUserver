The following changes have been made to the dev database and will need to be added to the live database upon release.

alter table street_entities add column h_flip boolean default false;
alter table street_entities add column rotation int default 0;
alter table stats add column rainbo_snocones_blended int not null default 0;

Use id instead of username for note author: (RUN THESE IN ORDER!)

UPDATE notes SET username = (SELECT id FROM users WHERE users.username = notes.username)::text;
ALTER TABLE notes ALTER COLUMN username TYPE int USING username::integer;
ALTER TABLE notes RENAME COLUMN username TO author_id;
ALTER TABLE notes ADD FOREIGN KEY (author_id) REFERENCES users;