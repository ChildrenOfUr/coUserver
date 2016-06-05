The following changes have been made to the dev database and will need to be added to the live database upon release.

```
ALTER TABLE street_entities
ADD COLUMN metadata text NOT NULL DEFAULT '{}';
```
