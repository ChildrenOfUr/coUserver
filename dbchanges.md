The following changes have been made to the dev database and will need to be added to the live database upon release.

```
CREATE TABLE street_entities (
    id varchar(30) PRIMARY KEY UNIQUE NOT NULL,
    type varchar(30) NOT NULL,
    tsid varchar(20),
    x integer NOT NULL DEFAULT 0,
    y integer NOT NULL DEFAULT 0
);
```

```
ALTER TABLE stats
ADD COLUMN butterflies_milked integer NOT NULL DEFAULT 0,
ADD COLUMN cubimal_boxes_opened integer NOT NULL DEFAULT 0,
ADD COLUMN cubimals_set_free integer NOT NULL DEFAULT 0,
ADD COLUMN emblems_caressed integer NOT NULL DEFAULT 0,
ADD COLUMN emblems_considered integer NOT NULL DEFAULT 0,
ADD COLUMN emblems_contemplated integer NOT NULL DEFAULT 0,
ADD COLUMN favor_earned integer NOT NULL DEFAULT 0,
ADD COLUMN grapes_squished integer NOT NULL DEFAULT 0,
ADD COLUMN heli_kitties_petted integer NOT NULL DEFAULT 0,
ADD COLUMN icons_collected integer NOT NULL DEFAULT 0,
ADD COLUMN icons_tithed integer NOT NULL DEFAULT 0,
ADD COLUMN icons_revered integer NOT NULL DEFAULT 0,
ADD COLUMN icons_ruminated integer NOT NULL DEFAULT 0,
ADD COLUMN items_dropped integer NOT NULL DEFAULT 0,
ADD COLUMN items_picked_up integer NOT NULL DEFAULT 0,
ADD COLUMN items_from_vendors integer NOT NULL DEFAULT 0,
ADD COLUMN piggies_petted integer NOT NULL DEFAULT 0,
ADD COLUMN quoins_collected integer NOT NULL DEFAULT 0,
ADD COLUMN salmon_pocketed integer NOT NULL DEFAULT 0;
```
