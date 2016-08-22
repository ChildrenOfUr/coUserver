The following changes have been made to the dev database and will need to be added to the live database upon release.

- ALTER TABLE users ADD COLUMN friends text NOT NULL DEFAULT '[]'::text;
- UPDATE street_entities SET type = 'Jellisac' WHERE type = 'Jellasic';
- ALTER TABLE street_entities ALTER COLUMN type TYPE character varying(60);

The following changes must be made when the affected streets are updated using the mapfiller.

- UPDATE street_entities SET type = 'EarthshakerRespawningItem' WHERE tsid = 'LIF101NCNU112O2' AND type = 'BundleOfJoy';
- UPDATE street_entities SET type = 'AwesomeStewRespawningItem' WHERE tsid = 'LIF12PMQ5121D68' AND type = 'BundleOfJoy';
