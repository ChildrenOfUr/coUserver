The following changes have been made to the dev database and will need to be added to the live database upon release.

- ALTER TABLE users ADD COLUMN friends text NOT NULL DEFAULT '[]'::text;
- UPDATE street_entities SET type = 'Jellisac' WHERE type = 'Jellasic';