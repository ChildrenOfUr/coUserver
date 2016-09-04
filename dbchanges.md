The following changes have been made to the dev database and will need to be added to the live database upon release.

Friend lists:

- ALTER TABLE users ADD COLUMN friends text NOT NULL DEFAULT '[]'::text;

Street instancing changes:

1. ALTER TABLE streets ALTER COLUMN id TYPE varchar(32);
1. ALTER TABLE streets ADD COLUMN uid integer NOT NULL DEFAULT -1 REFERENCES users(id);
1. ALTER TABLE streets ADD COLUMN tsid varchar(24);
1. UPDATE streets SET tsid = id;

Fix typo:

- UPDATE street_entities SET type = 'Jellisac' WHERE type = 'Jellasic';

Allow longer metadata:

- ALTER TABLE street_entities ALTER COLUMN type TYPE character varying(60);

Add new stats:

- ALTER TABLE stats ADD COLUMN test_tube_uses integer NOT NULL DEFAULT 0;
- ALTER TABLE stats ADD COLUMN beaker_uses integer NOT NULL DEFAULT 0;

Map Filler:

save LCR199KIJRK1I2B to the live server (load from dev server)